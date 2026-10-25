"""Forced-hold probe for every card: what is each card worth when its holder has it from round 1?

    python game/tools/probe_cards.py --games 60 --jobs 13
    python game/tools/probe_cards.py --from game/sim/results/probe-<stamp>
    python game/tools/probe_cards.py --cards fire_05,air_04 --games 200 --no-write

Each process runs res://sim/combo_probe.gd on a slice of the cards. Seat 0 is dealt the card
upright at game start, against bots (adaptive by default). Every card is played on the same
seeds, and so is a "none" baseline that deals nothing, so differences come from the card.

Writes:
  * ai/data/card_probe.json: card id -> power ceiling, FLOOR + SCALE * (keys/game over baseline).
    Valuer.power() uses max(learned power, this). Learned power comes from leagues, where bots
    that misplay a card make it look weak, so the probe keeps a strong card from being written off.
  * design/card_probe.md: the full table, with the cards the league undervalues flagged.
"""
import argparse, json, math, os, subprocess, sys, time

GAME = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ROOT = os.path.dirname(GAME)
GODOT = os.environ.get('GODOT', r'F:\Program Files (x86)\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe')
RESULTS = os.path.join(GAME, 'sim', 'results')
DATA = os.path.join(GAME, 'ai', 'data')
DOC = os.path.join(ROOT, 'design', 'card_probe.md')
FLOOR = 0.1      # same floor as learned card power
SCALE = 0.5      # probe keys are per game held from round 1; a claimed card is held about half as long
FLAG = 0.3       # report a card as undervalued when its probe power beats learned power by this much


def run(args, ids):
    out_dir = os.path.join(RESULTS, 'probe-' + time.strftime('%Y%m%d-%H%M%S'))
    os.makedirs(out_dir, exist_ok=True)
    jobs = min(args.jobs, len(ids))
    slices = [ids[j::jobs] for j in range(jobs)]
    procs = []
    for j, sl in enumerate(slices):
        out = os.path.join(out_dir, 'part%02d.jsonl' % j).replace('\\', '/')
        cmd = [GODOT, '--headless', '--path', GAME, '--script', 'res://sim/combo_probe.gd', '--',
               'games=%d' % args.games, 'seed=%d' % args.seed, 'me=' + args.me, 'opp=' + args.opp,
               'cards=' + ','.join(sl), 'out=' + out]
        procs.append(subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True))
    t0 = time.time()
    errors = 0
    for j, p in enumerate(procs):
        log, _ = p.communicate()
        errors += log.count('SCRIPT ERROR')
        with open(os.path.join(out_dir, 'part%02d.log' % j), 'w', encoding='utf-8') as fh: fh.write(log)
        if 'Failed to load script' in log: print(log[-2000:]); sys.exit('a script failed to load')
    meta = {'games_per_card': args.games, 'cards': len(ids), 'seed': args.seed, 'me': args.me, 'opp': args.opp,
            'seconds': round(time.time() - t0), 'script_errors': errors}
    with open(os.path.join(out_dir, 'meta.json'), 'w') as fh: json.dump(meta, fh, indent=1)
    print('%d cards x %d games in %ds -> %s%s' % (len(ids), args.games, meta['seconds'], out_dir,
                                                  ('  (!! %d script errors)' % errors) if errors else ''))
    return out_dir


def load(run_dir):
    rows = {}
    for name in sorted(os.listdir(run_dir)):
        if name.endswith('.jsonl'):
            for line in open(os.path.join(run_dir, name), encoding='utf-8'):
                r = json.loads(line)
                rows[r['card']] = r
    meta = json.load(open(os.path.join(run_dir, 'meta.json')))
    return rows, meta


def ci(w, n): return 1.96 * math.sqrt(max(w * (1 - w), 1e-9) / max(1, n))


def report(rows, meta, run_dir, write):
    cards = {c['id']: c for c in json.load(open(os.path.join(GAME, 'data', 'cards.json'), encoding='utf-8'))}
    learned_path = os.path.join(DATA, 'card_power.json')
    learned = json.load(open(learned_path)) if os.path.exists(learned_path) else {}
    base = rows.get('none')
    if not base: sys.exit('no "none" baseline in this run')
    n = base['games']
    b_keys, b_win = base['keys'] / n, base['wins'] / n
    out = []
    for cid, r in rows.items():
        if cid == 'none': continue
        g = r['games']
        keys, win = r['keys'] / g, r['wins'] / g
        delta = keys - b_keys
        out.append({'id': cid, 'name': '%s / %s' % (cards[cid]['name'], cards[cid]['inv_name']), 'win': win, 'ci': ci(win, g),
                    'keys': keys, 'delta': delta, 'own': r['card_keys'] / g,
                    'reach': r['reached'] / g, 'probe': round(FLOOR + SCALE * max(0.0, delta), 3), 'learned': learned.get(cid)})
    out.sort(key=lambda x: -x['win'])
    if write:
        with open(os.path.join(DATA, 'card_probe.json'), 'w') as fh:
            json.dump({x['id']: x['probe'] for x in out}, fh, indent=1, sort_keys=True)
    under = [x for x in out if x['learned'] is not None and x['probe'] > x['learned'] + FLAG]
    lines = [
        '# Card probe: each card held from round 1',
        '',
        '*Overwritten by `game/tools/probe_cards.py`. Written %s.*' % time.strftime('%Y-%m-%d %H:%M'),
        '',
        'Run `%s`: %d games per card. Seat 0 (`%s`) is dealt the card upright at game start, against 3 `%s` bots, with `win_keys=7`. '
        'Every card is played on the same seeds as the **baseline**, which deals nothing: win %.0f%%, %.2f keys/game.'
        % (os.path.relpath(run_dir, ROOT).replace('\\', '/'), n, meta['me'], meta['opp'], 100 * b_win, b_keys),
        '',
        'Column key:',
        '',
        '- **Δkeys:** keys/game over the baseline.',
        '- **Own keys:** keys the card\'s own abilities produced.',
        '- **Probe power** = %.1f + %.1f × max(0, Δkeys). It is the ceiling `Valuer.power()` uses against **learned power** (keys per claim from leagues).' % (FLOOR, SCALE),
        '- **⚑:** the probe beats learned power by more than %.1f, so the league undervalues the card.' % FLAG,
        '',
    ]
    if under:
        lines += ['**Undervalued by the league (%d):** %s.' % (len(under), ', '.join('%s (%.2f vs %.2f)' % (x['name'], x['probe'], x['learned']) for x in under)), '']
    lines += ['| Card (upright / inverted) | Win % | ±95% | Keys/game | Δkeys | Own keys | Reach 7 | Probe power | Learned power | |',
              '|---|---:|---:|---:|---:|---:|---:|---:|---:|---|']
    for x in out:
        lines.append('| %s | %.0f%% | %.0f%% | %.2f | %+.2f | %.2f | %.0f%% | %.2f | %s | %s |' % (
            x['name'], 100 * x['win'], 100 * x['ci'], x['keys'], x['delta'], x['own'], 100 * x['reach'], x['probe'],
            '%.2f' % x['learned'] if x['learned'] is not None else '–', '⚑' if x in under else ''))
    if write:
        with open(DOC, 'w', encoding='utf-8') as fh: fh.write('\n'.join(lines) + '\n')
        with open(os.path.join(run_dir, 'report.md'), 'w', encoding='utf-8') as fh: fh.write('\n'.join(lines) + '\n')
    print('baseline: win %.0f%%, %.2f keys/game' % (100 * b_win, b_keys))
    for x in out[:12]: print('  %-55s win %3.0f%%  dkeys %+.2f  probe %.2f  learned %s' % (x['name'], 100 * x['win'], x['delta'], x['probe'], x['learned']))
    print('undervalued by the league: %s' % (', '.join(x['name'] for x in under) or 'none'))


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('--games', type=int, default=60)
    ap.add_argument('--jobs', type=int, default=13)
    ap.add_argument('--seed', type=int, default=7000)
    ap.add_argument('--me', default='adaptive')
    ap.add_argument('--opp', default='adaptive')
    ap.add_argument('--cards', default='', help='comma list of card ids (default: every card)')
    ap.add_argument('--from', dest='src', default='')
    ap.add_argument('--no-write', action='store_true', help="don't write ai/data/card_probe.json or design/card_probe.md")
    args = ap.parse_args()
    if args.src: run_dir = args.src
    else:
        ids = args.cards.split(',') if args.cards else [c['id'] for c in json.load(open(os.path.join(GAME, 'data', 'cards.json'), encoding='utf-8'))]
        run_dir = run(args, ids + ['none'])
    rows, meta = load(run_dir)
    report(rows, meta, run_dir, not args.no_write)
