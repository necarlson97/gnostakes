"""Sweep one rule across values: a smaller league per value, then a comparison document.

    python game/tools/sweep.py --rule win_keys --values 10,9,8,7,6,5 --games 390

Each value runs `league.run` with `--rule <rule>=<value>` (same bots and seeds per value,
so differences come from the rule). Writes design/sim_sweep_<rule>.md (overwritten per
sweep). The main design/sim_report.md is not touched.
"""
import argparse, json, os, sys, time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import league

ENDINGS = ['edification', 'conflagration', 'putrescence']


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--rule', required=True, help='a GK.DEFAULTS key, e.g. win_keys')
    ap.add_argument('--values', required=True, help='comma list, e.g. 10,9,8,7,6,5')
    ap.add_argument('--games', type=int, default=390, help='games per value')
    ap.add_argument('--players', type=int, default=4)
    ap.add_argument('--pool', default='all')
    ap.add_argument('--jobs', type=int, default=13)
    ap.add_argument('--seed', type=int, default=777)
    ap.add_argument('--from', dest='src', default='', help='reuse a previous sweep: json of {value: run dir}')
    a = ap.parse_args()
    values = a.values.split(',')
    runs = json.load(open(a.src)) if a.src else {}
    for v in values:
        if v in runs: continue
        ns = argparse.Namespace(games=a.games, players=a.players, pool=a.pool, bots='', jobs=a.jobs, seed=a.seed,
                                rule=['%s=%s' % (a.rule, v)])
        print('--- %s = %s' % (a.rule, v))
        runs[v] = league.run(ns)
    rows = []
    for v in values:
        S = league.stats(league.load(runs[v]))
        rows.append((v, S, runs[v]))
    doc = os.path.join(league.ROOT, 'design', 'sim_sweep_%s.md' % a.rule)
    write(doc, a, rows)
    with open(os.path.join(league.RESULTS, 'sweep_%s_%s.json' % (a.rule, time.strftime('%Y%m%d-%H%M%S'))), 'w') as fh:
        json.dump(runs, fh, indent=1)
    print('sweep written to %s' % doc)


def write(path, a, rows):
    L = ['# Rule sweep: `%s`' % a.rule, '',
         '*Overwritten by each sweep of this rule. Written %s.*' % time.strftime('%Y-%m-%d %H:%M'), '',
         '%d games per value, %d players, bots: %s. Same seeds for every value, so differences come from the rule.' % (
             a.games, a.players, a.pool), '',
         '| %s | Games | Rounds mean | p50 | p90 | %s | Dead %% | Winner keys p50 | Strongest bots |' % (
             a.rule, ' | '.join(e.capitalize() + ' %' for e in ENDINGS)),
         '|---:|---:|---:|---:|---:|%s---:|---:|---|' % ('---:|' * len(ENDINGS))]
    for v, S, _ in rows:
        r = S['rounds']
        ends = ' | '.join('%.0f%%' % (100 * S['endings'].get(e, 0) / S['games']) for e in ENDINGS)
        bots = sorted(((k, b) for k, b in S['bots'].items() if k != 'random'), key=lambda kv: -kv[1]['win'] / kv[1]['exp'])[:3]
        L.append('| %s | %d | %.1f | %.0f | %.0f | %s | %.1f%% | %g | %s |' % (
            v, S['games'], r['mean'], r['p50'], r['p90'], ends, 100 * S['dead'], S['winner_keys']['p50'],
            ', '.join('%s %.2fx' % (k, b['win'] / b['exp']) for k, b in bots)))
    L += ['', 'Run folders (each has its own full report.md via `league.py --from <dir>`):', '']
    L += ['- %s = %s: `%s`' % (a.rule, v, os.path.relpath(d, league.ROOT).replace('\\', '/')) for v, _, d in rows]
    with open(path, 'w', encoding='utf-8') as fh: fh.write('\n'.join(L) + '\n')


if __name__ == '__main__':
    main()
