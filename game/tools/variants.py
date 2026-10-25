"""Compare card-design variants against the cards as written, on identical seeds.

    python game/tools/variants.py --variants friar_once,friar_cost3 --games 650

A variant is res://cards/variants/<name>/<card id>.gd (see core/card_db.gd); a variant
folder may change one card or several. Each run uses the same seeds and bots, so
differences come from the card text. Writes design/sim_variants.md (overwritten each time).
"""
import argparse, glob, json, os, re, sys, time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import league, abilities

VAR_DIR = os.path.join(league.GAME, 'cards', 'variants')
TEXT_RE = re.compile(r'(inv_rule|rule)\s*=\s*"((?:[^"\\]|\\.)*)"')


def variant_cards(v):
    """card ids a variant replaces, and their new text: {id: {rule|inv_rule: text}}"""
    out = {}
    for f in glob.glob(os.path.join(VAR_DIR, v, '*.gd')):
        src = open(f, encoding='utf-8').read()
        out[os.path.basename(f)[:-3]] = {k: t.encode().decode('unicode_escape') for k, t in TEXT_RE.findall(src)}
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--variants', required=True)
    ap.add_argument('--games', type=int, default=650)
    ap.add_argument('--players', type=int, default=4)
    ap.add_argument('--pool', default='all')
    ap.add_argument('--jobs', type=int, default=13)
    ap.add_argument('--seed', type=int, default=4321)
    ap.add_argument('--baseline', default='', help='reuse a baseline run folder (must use the same seed and games)')
    ap.add_argument('--from', dest='src', default='', help='json {name: run dir} to rebuild the document only')
    a = ap.parse_args()
    names = ['as written'] + a.variants.split(',')
    runs = json.load(open(a.src)) if a.src else {}
    if a.baseline: runs.setdefault('as written', a.baseline)
    for v in names:
        if v in runs: continue
        ns = argparse.Namespace(games=a.games, players=a.players, pool=a.pool, bots='', jobs=a.jobs, seed=a.seed,
                                rule=[], variant='' if v == 'as written' else v)
        print('--- %s' % v)
        runs[v] = league.run(ns)
    with open(os.path.join(league.RESULTS, 'variants_%s.json' % time.strftime('%Y%m%d-%H%M%S')), 'w') as fh:
        json.dump(runs, fh, indent=1)
    write(a, names, runs)


def write(a, names, runs):
    cards = {c['id']: c for c in json.load(open(os.path.join(league.GAME, 'data', 'cards.json'), encoding='utf-8'))}
    targets = sorted({cid for v in names[1:] for cid in variant_cards(v)})
    data = {}
    for v in names:
        games = league.load(runs[v])
        held, A = abilities.stats(games, cards)
        for fid, ms in abilities.code_lines('' if v == 'as written' else v).items():
            for m in ms: A[(fid, m)]   # lines that never fired still get a row
        data[v] = (league.stats(games), (held, A))
    L = ['# Card variant experiments', '',
         '*Overwritten by each variants run. Written %s.*' % time.strftime('%Y-%m-%d %H:%M'), '',
         '%d games per run, %d players, bots: %s, same seeds for every run. Cards under test: %s.' % (
             a.games, a.players, a.pool, ', '.join('%s / %s' % (cards[c]['name'], cards[c]['inv_name']) for c in targets)), '',
         'Each run varies only the card text. With these game counts, per-card holder win rates are good to about ±5 points, so look for big or consistent moves.', '']
    L += ['## Variants', '']
    for v in names[1:]:
        for cid, txt in variant_cards(v).items():
            for side in ('rule', 'inv_rule'):
                if side in txt:
                    face = cards[cid]['name' if side == 'rule' else 'inv_name']
                    old = ' / '.join(l for l in cards[cid][side].split('\n') if l.strip())
                    new = ' / '.join(l for l in txt[side].split('\n') if l.strip())
                    L.append('- **%s**, %s: "%s" (was: "%s")' % (v, face, new, old))
    L += ['', '## The game overall', '',
          '| Run | Rounds | Edification | Conflagration | Putrescence | Dead % | Winner keys p50 | Tokens/player p50 / p90 |',
          '|---|---:|---:|---:|---:|---:|---:|---|']
    for v in names:
        S = data[v][0]
        e = lambda k: '%.0f%%' % (100 * S['endings'].get(k, 0) / S['games'])
        L.append('| %s | %.1f | %s | %s | %s | %.1f%% | %g | %g / %g |' % (v, S['rounds']['mean'], e('edification'), e('conflagration'),
                 e('putrescence'), 100 * S['dead'], S['winner_keys']['p50'], S['tokens']['all']['gain_p50'], S['tokens']['all']['gain_p90']))
    for cid in targets:
        L += ['', '## %s / %s' % (cards[cid]['name'], cards[cid]['inv_name']), '',
              '| Run | Claims | Keys/claim | Tokens/claim | Teeth lost/claim | Holder win % | Holder dead % |',
              '|---|---:|---:|---:|---:|---:|---:|']
        for v in names:
            S = data[v][0]
            c = S['card_stats'][cid]
            n = max(1, c['claims'])
            hs = max(1, c['held_seats'])
            L.append('| %s | %d | %.2f | %.1f | %.2f | %.0f%% | %.0f%% |' % (v, c['claims'], c['keys'] / n, sum(c['tokens'].values()) / n,
                     c['teeth_holder'] / n, 100 * c['held_wins'] / hs, 100 * c['held_dead'] / hs))
        L += ['', 'Ability lines: activations per game held (winners / others), keys and tokens per activation.', '',
              '| Run | Face | Line | Per game held | Winners | Others | Keys/act | Tokens/act | Spent/act |',
              '|---|---|---|---:|---:|---:|---:|---|---|']
        for v in names:
            held, A = data[v][1]
            h, hw = held[cid]
            for (fid, m), r in sorted(A.items()):
                if fid.split(':')[0] != cid: continue
                face = cards[cid]['inv_name' if fid.endswith(':inv') else 'name']
                n = r['n'] or 1
                tok = ' '.join('%s%.1f' % (t, x / n) for t, x in r['tokens'].items() if x) or ''
                sp = ' '.join('%s%.1f' % (t, x / n) for t, x in r['spent'].items() if x) or ''
                L.append('| %s | %s | %s | %.2f | %.2f | %.2f | %.2f | %s | %s |' % (
                    v, face, abilities.label(m), r['n'] / h if h else 0, r['n_win'] / hw if hw else 0,
                    (r['n'] - r['n_win']) / (h - hw) if h - hw > 0 else 0, r['keys'] / n, tok, sp))
    L += ['', '## Strongest and weakest bots per run', '']
    for v in names:
        S = data[v][0]
        ranked = sorted(((k, b) for k, b in S['bots'].items() if k != 'random'), key=lambda kv: -kv[1]['win'] / kv[1]['exp'])
        L.append('- **%s**: top %s; bottom %s' % (v, ', '.join('%s %.2fx' % (k, b['win'] / b['exp']) for k, b in ranked[:4]),
                                                ', '.join('%s %.2fx' % (k, b['win'] / b['exp']) for k, b in ranked[-3:])))
    L += ['', 'Run folders: ' + '; '.join('%s `%s`' % (v, abilities.rel(runs[v])) for v in names)]
    path = os.path.join(league.ROOT, 'design', 'sim_variants.md')
    with open(path, 'w', encoding='utf-8') as fh: fh.write('\n'.join(L) + '\n')
    print('variants report written to %s' % path)


if __name__ == '__main__':
    main()
