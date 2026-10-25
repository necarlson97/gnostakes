"""Run a bot league in parallel Godot processes, merge the results, report, and learn.

    python game/tools/league.py --games 1200 --players 4 --pool all --jobs 13
    python game/tools/league.py --games 600 --bots adaptive,straights,random
    python game/tools/league.py --from game/sim/results/<run> --learn

Each process runs res://sim/run_sims.gd on its own seed range and appends one JSON line
per game. After a run (or with --from):
  * a console summary is printed;
  * design/sim_report.md is OVERWRITTEN with the full findings (and a copy is kept in the
    run folder as report.md), unless --no-doc;
  * --learn writes ai/data/card_power.json (keys a card produces per claim, shrunk toward
    the mean) and ai/data/viability.json (each fixed strategy's win share vs even). Bots
    read both, so: run, learn, run again.
"""
import argparse, glob, json, math, os, shutil, subprocess, sys, time
from collections import defaultdict

GAME = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ROOT = os.path.dirname(GAME)
GODOT = os.environ.get('GODOT', r'F:\Program Files (x86)\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe')
RESULTS = os.path.join(GAME, 'sim', 'results')
DATA = os.path.join(GAME, 'ai', 'data')
DOC = os.path.join(ROOT, 'design', 'sim_report.md')
PRIOR_CLAIMS = 8.0     # shrinkage for card power
PRIOR_SEATS = 40.0     # shrinkage for viability
FLOOR = 0.1
TOKENS = 'EWFAQ'


# =============================================================================
# Running
# =============================================================================
def run(args):
    stamp = time.strftime('%Y%m%d-%H%M%S')
    out_dir = os.path.join(RESULTS, stamp)
    os.makedirs(out_dir, exist_ok=True)
    per = math.ceil(args.games / args.jobs)
    procs = []
    for j in range(args.jobs):
        out = os.path.join(out_dir, 'part%02d.jsonl' % j)
        cmd = [GODOT, '--headless', '--path', GAME, '--script', 'res://sim/run_sims.gd', '--',
               'games=%d' % per, 'seed=%d' % (args.seed + j * 100000), 'out=%s' % out.replace('\\', '/')]
        cmd += ['bots=' + args.bots] if args.bots else ['pool=' + args.pool, 'players=%d' % args.players]
        cmd += list(getattr(args, 'rule', []) or [])   # e.g. win_keys=7
        if getattr(args, 'variant', ''): cmd.append('variant=' + args.variant)
        procs.append(subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True))
    t0 = time.time()
    errors = 0
    for j, p in enumerate(procs):
        out, _ = p.communicate()
        errors += out.count('SCRIPT ERROR')
        with open(os.path.join(out_dir, 'part%02d.log' % j), 'w', encoding='utf-8') as fh: fh.write(out)
        if 'Failed to load script' in out: print(out[-2000:]); sys.exit('a script failed to load')
    meta = {'run': stamp, 'games_requested': per * args.jobs, 'jobs': args.jobs, 'seconds': round(time.time() - t0),
            'pool': args.bots or args.pool, 'players': len(args.bots.split(',')) if args.bots else args.players,
            'seed': args.seed, 'script_errors': errors, 'rules': list(getattr(args, 'rule', []) or []),
            'variants': [v for v in (getattr(args, 'variant', '') or '').split(',') if v]}
    with open(os.path.join(out_dir, 'meta.json'), 'w') as fh: json.dump(meta, fh, indent=1)
    print('%d games on %d processes in %ds -> %s%s' % (per * args.jobs, args.jobs, meta['seconds'], out_dir,
                                                       ('  (!! %d script errors: see part*.log)' % errors) if errors else ''))
    return out_dir


def load(path):
    games = []
    for f in sorted(glob.glob(os.path.join(path, '*.jsonl'))):
        with open(f, encoding='utf-8') as fh:
            games += [json.loads(l) for l in fh if l.strip()]
    return games


# =============================================================================
# Statistics (one pass; printing and the report both read this)
# =============================================================================
def pct(xs, q):
    xs = sorted(xs)
    if not xs: return 0
    i = q * (len(xs) - 1)
    lo = int(i)
    return xs[lo] + (xs[min(lo + 1, len(xs) - 1)] - xs[lo]) * (i - lo)


def card_names():
    cards = {c['id']: c for c in json.load(open(os.path.join(GAME, 'data', 'cards.json'), encoding='utf-8'))}
    def face(cid):
        base, _, side = cid.partition(':')
        if base not in cards: return cid
        return cards[base]['inv_name'] if side == 'inv' else cards[base]['name']
    return cards, face


def stats(games):
    cards, face = card_names()
    S = {'games': len(games), 'cards': cards, 'face': face}
    seats = [(g, s) for g in games for s in g['seats']]
    S['seats'] = len(seats)
    rounds = [g['rounds'] for g in games]
    S['rounds'] = {'mean': sum(rounds) / len(rounds), 'p10': pct(rounds, .1), 'p50': pct(rounds, .5), 'p90': pct(rounds, .9),
                   'min': min(rounds), 'max': max(rounds)}
    S['player_rounds'] = sum(g['rounds'] * len(g['seats']) for g in games)
    endings = defaultdict(int)
    for g in games: endings[g['ending']] += 1
    S['endings'] = dict(endings)
    S['dead'] = sum(1 for _, s in seats if s['teeth'] <= 0) / len(seats)
    S['no_winner'] = sum(1 for g in games if not any(s['win'] for s in g['seats'])) / len(games)
    win_keys = [max(s['keys'] for s in g['seats'] if s['win']) for g in games if any(s['win'] for s in g['seats'])]
    S['winner_keys'] = {'p10': pct(win_keys, .1), 'p50': pct(win_keys, .5), 'p90': pct(win_keys, .9)}

    # --- bots
    by = defaultdict(lambda: {'n': 0, 'win': 0.0, 'exp': 0.0, 'keys': 0, 'dead': 0, 'teeth': 0, 'strat': defaultdict(int)})
    for g, s in seats:
        r = by[s['bot']]
        r['n'] += 1; r['win'] += s['win']; r['exp'] += 1.0 / len(g['seats']); r['keys'] += s['keys']
        r['dead'] += s['teeth'] <= 0; r['teeth'] += max(0, s['teeth'])
        if s.get('strategy'): r['strat'][s['strategy']] += 1
    S['bots'] = by

    # --- tokens
    tok_seats = [s for _, s in seats if 'tok_gain' in s]
    S['has_tokens'] = bool(tok_seats)
    T = {}
    for t in TOKENS:
        gain = [s['tok_gain'].get(t, 0) for s in tok_seats]
        peak = [s['tok_peak'].get(t, 0) for s in tok_seats]
        spent = [s['tok_spent'].get(t, 0) for s in tok_seats]
        src = defaultdict(float)
        for s in tok_seats:
            for cid, d in s['tok_src'].items(): src[cid] += d.get(t, 0)
        total = sum(src.values()) or 1.0
        T[t] = {'gain_p50': pct(gain, .5), 'gain_p90': pct(gain, .9), 'gain_mean': sum(gain) / max(1, len(gain)),
                'per_round': sum(gain) / max(1, S['player_rounds']), 'spent_mean': sum(spent) / max(1, len(spent)),
                'peak_p50': pct(peak, .5), 'peak_p90': pct(peak, .9), 'peak_max': max(peak) if peak else 0,
                'zero': sum(1 for x in gain if x == 0) / max(1, len(gain)),
                'sources': sorted(((cid, v, v / total) for cid, v in src.items()), key=lambda x: -x[1]),
                'n_sources_1pct': sum(1 for v in src.values() if v / total >= .01)}
    allg = [sum(s['tok_gain'].values()) for s in tok_seats]
    allp = [s['tok_peak_total'] for s in tok_seats]
    T['all'] = {'gain_p50': pct(allg, .5), 'gain_p90': pct(allg, .9), 'gain_mean': sum(allg) / max(1, len(allg)),
                'per_round': sum(allg) / max(1, S['player_rounds']), 'peak_p50': pct(allp, .5), 'peak_p90': pct(allp, .9),
                'peak_max': max(allp) if allp else 0, 'zero': sum(1 for x in allg if x == 0) / max(1, len(allg))}
    S['tokens'] = T

    # --- cards (per card id; faces folded together, since claims are per card)
    C = {cid: {'claims': 0, 'keys': 0, 'tokens': defaultdict(float), 'teeth_holder': 0, 'teeth_others': 0,
               'teeth_gained': 0, 'held_wins': 0.0, 'held_dead': 0, 'held_seats': 0} for cid in cards}
    for g, s in seats:
        held = set(s['claims'])
        for cid in s['claims']:
            if cid in C: C[cid]['claims'] += 1
        for cid in held:
            if cid in C:
                C[cid]['held_seats'] += 1; C[cid]['held_wins'] += s['win']; C[cid]['held_dead'] += s['teeth'] <= 0
        for cid, k in s['key_src'].items():
            if cid in C: C[cid]['keys'] += k
        for fid, d in s.get('tok_src', {}).items():
            cid = fid.split(':')[0]
            if cid in C:
                for t, n in d.items(): C[cid]['tokens'][t] += n
        for fid, n in s.get('tooth_lost', {}).items():
            cid = fid.split(':')[0]
            if cid in C: C[cid]['teeth_holder' if cid in held else 'teeth_others'] += n
        for fid, n in s.get('tooth_gained', {}).items():
            cid = fid.split(':')[0]
            if cid in C: C[cid]['teeth_gained'] += n
    S['card_stats'] = C
    S['has_teeth'] = any('tooth_lost' in s for _, s in seats)
    S['seat_win_base'] = sum(s['win'] for _, s in seats) / len(seats)
    return S


# =============================================================================
# Console summary
# =============================================================================
def print_summary(S, top_tokens=5):
    r = S['rounds']
    print('%d games, rounds mean %.1f (p50 %.0f, p90 %.0f), endings %s' % (S['games'], r['mean'], r['p50'], r['p90'], S['endings']))
    print('deaths: %.1f%% of players; %.1f%% of games have no living winner' % (100 * S['dead'], 100 * S['no_winner']))
    print('%-22s %6s %7s %7s %7s %6s %7s' % ('bot', 'seats', 'win %', '+-95%', 'vs even', 'keys', 'dead %'))
    for name, b in sorted(S['bots'].items(), key=lambda kv: -kv[1]['win'] / kv[1]['exp']):
        w = b['win'] / b['n']
        print('%-22s %6d %6.1f%% %6.1f%% %6.2fx %6.2f %6.1f%%' % (name, b['n'], 100 * w, 100 * ci(w, b['n']), b['win'] / b['exp'],
                                                              b['keys'] / b['n'], 100 * b['dead'] / b['n']))
    if S['has_tokens']:
        T = S['tokens']
        print('tokens per player-game p50/p90: ' + '  '.join('%s %g/%g' % (t, T[t]['gain_p50'], T[t]['gain_p90']) for t in list(TOKENS) + ['all']))


def ci(w, n): return 1.96 * math.sqrt(max(w * (1 - w), 1e-9) / max(1, n))


def card_report(games, cid):
    """How a card's costs got paid, and what it produced."""
    paid, keys, claims = defaultdict(int), 0, 0
    for g in games:
        for s in g['seats']:
            for k, n in s.get('paid', {}).get(cid, {}).items(): paid[k] += n
            keys += s['key_src'].get(cid, 0)
            claims += s['claims'].count(cid)
    print('\n%s: claimed %d times, produced %d keys (%.2f per claim)' % (cid, claims, keys, keys / max(1, claims)))
    for k, n in sorted(paid.items(), key=lambda kv: -kv[1]): print('   paid %-24s %5d  (%.0f%%)' % (k, n, 100 * n / sum(paid.values())))


# =============================================================================
# The findings document
# =============================================================================
def write_doc(S, meta, path, run_dir):
    cards, face = S['cards'], S['face']
    both = lambda cid: '%s / %s' % (cards[cid]['name'], cards[cid]['inv_name'])
    L = []
    add = L.append
    r = S['rounds']
    learned = os.path.join(DATA, 'card_power.json')
    add('# Gnostakes simulation report')
    add('')
    add('*Overwritten after every finished league run; this file always holds the most recent results.*')
    add('')
    add('| | |')
    add('|---|---|')
    add('| Run | `%s` (%s) |' % (meta.get('run', os.path.basename(run_dir)), os.path.relpath(run_dir, ROOT).replace('\\', '/')))
    add('| Games | %d (%s players each) |' % (S['games'], meta.get('players', '?')))
    add('| Bots | %s |' % meta.get('pool', '?'))
    add('| Rule overrides | %s |' % (', '.join(meta.get('rules') or []) or 'none (rules as written)'))
    add('| Card variants | %s |' % (', '.join(meta.get('variants') or []) or 'none (cards as written)'))
    add('| Card data | design/source_snapshot, synced %s |' % time.strftime('%Y-%m-%d %H:%M', time.localtime(os.path.getmtime(os.path.join(GAME, 'data', 'cards.json')))))
    if os.path.exists(learned):
        add('| Learned card power | %s |' % time.strftime('%Y-%m-%d %H:%M', time.localtime(os.path.getmtime(learned))))
    if meta.get('script_errors'): add('| **Script errors** | %d (see the run folder logs) |' % meta['script_errors'])
    add('| Written | %s |' % time.strftime('%Y-%m-%d %H:%M'))
    add('')

    # --- headlines
    bots = S['bots']
    strat = {k: v for k, v in bots.items() if k not in ('random',)}
    ranked = sorted(strat.items(), key=lambda kv: -kv[1]['win'] / kv[1]['exp'])
    C = S['card_stats']
    keyed = sorted((c for c in C if C[c]['claims'] >= 20), key=lambda c: -C[c]['keys'] / C[c]['claims'])
    add('## Headlines')
    add('')
    add('- **Game length:** %.1f rounds on average (half of games end by round %.0f, 90%% by round %.0f).' % (r['mean'], r['p50'], r['p90']))
    end_txt = ', '.join('%s %.0f%%' % (k, 100 * v / S['games']) for k, v in sorted(S['endings'].items(), key=lambda kv: -kv[1]))
    add('- **How games end:** %s.' % end_txt)
    add('- **Deaths:** %.1f%% of players finish with no teeth; %.1f%% of games have no living winner.' % (100 * S['dead'], 100 * S['no_winner']))
    add('- **Winning score:** the winner holds %g keys at the median (p10 %g, p90 %g).' % (S['winner_keys']['p50'], S['winner_keys']['p10'], S['winner_keys']['p90']))
    if ranked:
        add('- **Strongest bots:** %s.' % ', '.join('%s %.2fx' % (k, v['win'] / v['exp']) for k, v in ranked[:3]))
        add('- **Weakest bots:** %s.' % ', '.join('%s %.2fx' % (k, v['win'] / v['exp']) for k, v in ranked[-3:]))
    if keyed:
        add('- **Best key cards (keys per claim):** %s. Average card: %.2f.' % (
            ', '.join('%s %.2f' % (both(c), C[c]['keys'] / C[c]['claims']) for c in keyed[:3]),
            sum(C[c]['keys'] for c in C) / max(1, sum(C[c]['claims'] for c in C))))
    if S['has_tokens']:
        T = S['tokens']
        add('- **Tokens:** the median player gains %g tokens a game (90th percentile %g); %.0f%% of players gain none.' % (
            T['all']['gain_p50'], T['all']['gain_p90'], 100 * T['all']['zero']))
    if S['has_teeth']:
        hurt = sorted(C, key=lambda c: -(C[c]['teeth_holder'] / max(1, C[c]['claims'])))[:3]
        add('- **Most tooth loss to its holder (per claim):** %s.' % ', '.join('%s %.2f' % (both(c), C[c]['teeth_holder'] / max(1, C[c]['claims'])) for c in hurt))
    add('')

    # --- bots
    add('## Bots')
    add('')
    add('"vs even" is win share divided by an even share at the table (1.00x = average). The 95% interval is on the win rate; differences smaller than it are noise.')
    add('')
    add('| Bot | Seats | Win % | ±95% | vs even | Keys/game | Teeth left | Dead % |')
    add('|---|---:|---:|---:|---:|---:|---:|---:|')
    for name, b in sorted(bots.items(), key=lambda kv: -kv[1]['win'] / kv[1]['exp']):
        w = b['win'] / b['n']
        add('| %s | %d | %.1f%% | %.1f%% | %.2fx | %.2f | %.1f | %.1f%% |' % (name, b['n'], 100 * w, 100 * ci(w, b['n']), b['win'] / b['exp'],
                                                                           b['keys'] / b['n'], b['teeth'] / b['n'], 100 * b['dead'] / b['n']))
    adaptive = [(k, v) for k, v in bots.items() if k.startswith('adaptive')]
    for k, v in adaptive:
        top = sorted(v['strat'].items(), key=lambda kv: -kv[1])[:8]
        add('')
        add('**%s** ends committed to: %s.' % (k, ', '.join('%s %d' % kv for kv in top)))
    add('')

    # --- game length
    add('## Game length and endings')
    add('')
    add('| Rounds | min | p10 | p50 | mean | p90 | max |')
    add('|---|---:|---:|---:|---:|---:|---:|')
    add('| | %d | %.0f | %.0f | %.1f | %.0f | %d |' % (r['min'], r['p10'], r['p50'], r['mean'], r['p90'], r['max']))
    add('')
    add('| Ending | Games | Share |')
    add('|---|---:|---:|')
    for k, v in sorted(S['endings'].items(), key=lambda kv: -kv[1]): add('| %s | %d | %.1f%% |' % (k, v, 100 * v / S['games']))
    add('')

    # --- tokens
    if S['has_tokens']:
        T = S['tokens']
        add('## Tokens')
        add('')
        add('Per player. "Per game" percentiles are over player-games; peaks are the most held at one time.')
        add('')
        add('| Token | Per round | Per game p50 | p90 | mean | Spent/game | None gained | Peak p50 | Peak p90 | Peak max |')
        add('|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|')
        for t in list(TOKENS) + ['all']:
            x = T[t]
            add('| %s | %.2f | %g | %g | %.1f | %s | %.0f%% | %g | %g | %d |' % (
                t, x['per_round'], x['gain_p50'], x['gain_p90'], x['gain_mean'], '%.1f' % x['spent_mean'] if 'spent_mean' in x else '',
                100 * x['zero'], x['peak_p50'], x['peak_p90'], x['peak_max']))
        add('')
        add('### Top 5 producers per token')
        add('')
        add('Share of all income of that token, total produced in this run, and per claim of the card.')
        add('')
        for t in TOKENS:
            src = [x for x in T[t]['sources'] if x[0] != 'engine'][:5]
            parts = []
            for fid, v, share in src:
                cid = fid.split(':')[0]
                per = v / max(1, C[cid]['claims']) if cid in C else 0
                parts.append('%s %.0f%% (%d, %.1f/claim)' % (face(fid), 100 * share, v, per))
            add('- **%s** (%d cards give at least 1%%): %s' % (t, T[t]['n_sources_1pct'], '; '.join(parts) or 'none'))
        add('')

    # --- cards
    add('## Cards')
    add('')
    add('Per claim of the card (either face). Teeth lost (holder) = teeth the card\'s own effects cost its holder; '
        '(others) = teeth it took from opponents. Win/dead %% are for players who held the card at some point '
        '(baseline win share per seat: %.1f%%).' % (100 * S['seat_win_base']))
    add('')
    add('| Card (upright / inverted) | Claims | Keys/claim | Teeth lost (holder) | Teeth taken (others) | Teeth regained | Tokens/claim | Main tokens | Holder win % | Holder dead % |')
    add('|---|---:|---:|---:|---:|---:|---:|---|---:|---:|')
    for cid in sorted(C, key=lambda c: -(C[c]['keys'] / max(1, C[c]['claims']))):
        c = C[cid]
        n = max(1, c['claims'])
        toks = sum(c['tokens'].values())
        main = ' '.join('%s%.1f' % (t, c['tokens'][t] / n) for t in sorted(c['tokens'], key=lambda t: -c['tokens'][t])[:3] if c['tokens'][t] > 0)
        hs = max(1, c['held_seats'])
        add('| %s | %d | %.2f | %.2f | %.2f | %.2f | %.1f | %s | %.0f%% | %.0f%% |' % (
            both(cid), c['claims'], c['keys'] / n, c['teeth_holder'] / n, c['teeth_others'] / n, c['teeth_gained'] / n,
            toks / n, main, 100 * c['held_wins'] / hs, 100 * c['held_dead'] / hs))
    add('')
    add('Which ability lines fire, how often, and what each produces: see [sim_abilities.md](sim_abilities.md).')
    add('')
    add('---')
    add('Generated by `game/tools/league.py`. Re-create from saved games: `python game/tools/league.py --from %s`.' %
        os.path.relpath(run_dir, ROOT).replace('\\', '/'))
    text = '\n'.join(L) + '\n'
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8') as fh: fh.write(text)
    with open(os.path.join(run_dir, 'report.md'), 'w', encoding='utf-8') as fh: fh.write(text)
    print('report written to %s' % path)


# =============================================================================
# Learning
# =============================================================================
def learn(S):
    os.makedirs(DATA, exist_ok=True)
    C = S['card_stats']
    mean = sum(c['keys'] for c in C.values()) / max(1, sum(c['claims'] for c in C.values()))
    power = {cid: round(FLOOR + (c['keys'] + PRIOR_CLAIMS * mean) / (c['claims'] + PRIOR_CLAIMS), 3) for cid, c in C.items()}
    with open(os.path.join(DATA, 'card_power.json'), 'w') as fh: json.dump(power, fh, indent=1, sort_keys=True)
    top = sorted(power, key=lambda k: -power[k])
    print('card power (keys per claim; mean %.3f). top: %s' % (mean, ', '.join('%s %.2f' % (S['cards'][k]['name'], power[k]) for k in top[:8])))
    strategies = [os.path.basename(p)[:-5] for p in glob.glob(os.path.join(GAME, 'ai', 'strategies', '*.json'))]
    via = {}
    for st in strategies:
        if st in S['bots']:
            r = S['bots'][st]
            via[st] = round((r['win'] + PRIOR_SEATS * r['exp'] / max(1, r['n'])) / (r['exp'] + PRIOR_SEATS * r['exp'] / max(1, r['n'])), 3)
    if via:
        with open(os.path.join(DATA, 'viability.json'), 'w') as fh: json.dump(via, fh, indent=1, sort_keys=True)
        print('viability: ' + ', '.join('%s %.2f' % kv for kv in sorted(via.items(), key=lambda kv: -kv[1])))


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('--games', type=int, default=600)
    ap.add_argument('--players', type=int, default=4)
    ap.add_argument('--pool', default='all')
    ap.add_argument('--bots', default='')
    ap.add_argument('--jobs', type=int, default=13)
    ap.add_argument('--seed', type=int, default=1)
    ap.add_argument('--from', dest='src', default='')
    ap.add_argument('--learn', action='store_true')
    ap.add_argument('--no-doc', action='store_true', help="don't overwrite design/sim_report.md")
    ap.add_argument('--doc', default=DOC, help='where to write the findings document')
    ap.add_argument('--card', action='append', default=[], help='payment / output breakdown for a card id')
    ap.add_argument('--rule', action='append', default=[], help='rule override for every game, e.g. win_keys=7')
    ap.add_argument('--variant', default='', help='card variants (cards/variants/<name>/), comma list')
    a = ap.parse_args()
    path = a.src or run(a)
    meta = json.load(open(os.path.join(path, 'meta.json'))) if os.path.exists(os.path.join(path, 'meta.json')) else {}
    games = load(path)
    S = stats(games)
    print_summary(S)
    for cid in a.card: card_report(games, cid)
    if not a.no_doc:
        write_doc(S, meta, a.doc, path)
        if any('abilities' in st for g in games[:5] for st in g['seats']):
            import abilities
            abilities.write(games, os.path.join(os.path.dirname(a.doc), 'sim_abilities.md'), path, meta)
    if a.learn: learn(S)
