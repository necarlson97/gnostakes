"""Single raw-roll probabilities for candidate scoring sets, across dice configurations,
plus a search for tier menus that hit target cumulative rates.

Targets (single raw roll, no rerolls, no cards):
  P(nothing) ~30%  ->  P(>=easy) ~70%,  P(>=medium) ~40%,  P(hard) ~15%

Usage:
  python set_explorer.py table            # per-set probabilities for each config
  python set_explorer.py search NP NE     # menu search for one config
"""
import itertools, sys
from collections import Counter
import numpy as np

ELEMS = 'EWFA'
ELEM_FACES = {'E': 2, 'W': 2, 'F': 1, 'A': 1}  # Earth, Earth, Water, Water, Fire, Air


def multisets(weights, n):
    """Yield (counts tuple over keys, probability) for n dice with per-face weights."""
    keys = list(weights)
    tot = sum(weights.values())
    out = Counter()
    for combo in itertools.product(keys, repeat=n):
        out[tuple(combo.count(k) for k in keys)] += np.prod([weights[k] / tot for k in combo])
    return list(out.items())


def outcome_space(npot, nel):
    pot = multisets({v: 1 for v in range(1, 7)}, npot)
    el = multisets(ELEM_FACES, nel)
    P, E, w = [], [], []
    for pc, pp in pot:
        for ec, pe in el:
            P.append(pc); E.append(ec); w.append(pp * pe)
    return np.array(P), np.array(E), np.array(w)


def run_len(pc):
    best = cur = 0
    for c in pc:
        cur = cur + 1 if c else 0
        best = max(best, cur)
    return best


def library(P, E):
    """Candidate sets -> boolean vector over outcomes. P[:, v-1] = count of potency v."""
    runs = np.array([run_len(row) for row in P])
    mx = P.max(axis=1)
    pairs = (P >= 2).sum(axis=1)
    trips = (P >= 3).sum(axis=1)
    L = {}
    for n in (3, 4, 5, 6):
        L[f'{n} Straight'] = runs >= n
    L['Two Pairs'] = pairs >= 2
    L['Three Pairs'] = pairs >= 3
    L['Triplet'] = mx >= 3
    L['Full House'] = (trips >= 1) & (pairs >= 2)
    L['Two Triplets'] = trips >= 2
    L['Quadruplet'] = mx >= 4
    L['Quintuplet'] = mx >= 5
    for v, nm in ((1, 'Ones'), (6, 'Sixes')):
        L[f'Two {nm}'] = P[:, v - 1] >= 2
        L[f'Three {nm}'] = P[:, v - 1] >= 3
    L['Ones and Sixes'] = (P[:, 0] >= 1) & (P[:, 5] >= 1)
    L['Three High (5+)'] = P[:, 4:].sum(axis=1) >= 3
    L['Three Low (2-)'] = P[:, :2].sum(axis=1) >= 3
    emx = E.max(axis=1)
    for i, x in enumerate(ELEMS):
        for n in (2, 3, 4):
            L[f'{n} {x}'] = E[:, i] >= n
    for n in (3, 4, 5):
        L[f'{n} of a Color'] = emx >= n
    L['All Colors'] = E.min(axis=1) >= 1
    L['Fire and Air'] = (E[:, 2] >= 1) & (E[:, 3] >= 1)
    L['Two Color Pairs'] = (E >= 2).sum(axis=1) >= 2
    return L


def table(configs):
    rows = {}
    for npot, nel in configs:
        P, E, w = outcome_space(npot, nel)
        for k, v in library(P, E).items():
            rows.setdefault(k, {})[(npot, nel)] = float(w[v].sum())
    hdr = ''.join(f'{f"{a}P+{b}E":>8}' for a, b in configs)
    print(f'{"set":18s}{hdr}')
    for k, d in sorted(rows.items(), key=lambda kv: -kv[1][configs[0]]):
        print(f'{k:18s}' + ''.join(f'{d[c]:8.1%}' for c in configs))


ELEM_SETS = lambda k: any(t in k for t in ('Color', ' E', ' W', ' F', ' A', 'Fire'))


def search(npot, nel, targets=(0.70, 0.40, 0.15), sizes=(4, (3, 4, 5), (3, 4)), beam=40):
    P, E, w = outcome_space(npot, nel)
    L = library(P, E)
    names = list(L)
    prob = {k: float(w[L[k]].sum()) for k in names}
    union = lambda ks: float(w[np.logical_or.reduce([L[k] for k in ks])].sum()) if ks else 0.0
    mixed = lambda ks: any(ELEM_SETS(k) for k in ks) and any(not ELEM_SETS(k) for k in ks)

    # hard: individually 1-10%
    hard_pool = [k for k in names if 0.01 <= prob[k] <= 0.10]
    med_pool = [k for k in names if 0.06 <= prob[k] <= 0.30]
    easy_pool = [k for k in names if 0.12 <= prob[k] <= 0.50]

    cands = []
    for n in sizes[2]:
        for hs in itertools.combinations(hard_pool, n):
            if not mixed(hs): continue
            cands.append((abs(union(hs) - targets[2]), hs))
    cands.sort(); hard_beam = [c[1] for c in cands[:beam]]

    stage2 = []
    for hs in hard_beam:
        hmax = max(prob[k] for k in hs)
        pool = [k for k in med_pool if k not in hs and prob[k] > hmax]
        for n in sizes[1]:
            for ms in itertools.combinations(pool, n):
                if not mixed(ms): continue
                u = union(hs + ms)
                stage2.append((abs(union(hs) - targets[2]) + abs(u - targets[1]), hs, ms))
    stage2.sort(); stage2 = stage2[:beam]

    final = []
    for err, hs, ms in stage2:
        mmax = max(prob[k] for k in ms)
        pool = [k for k in easy_pool if k not in hs + ms and prob[k] > mmax]
        for es in itertools.combinations(pool, sizes[0]):
            if not mixed(es): continue
            u = union(hs + ms + es)
            final.append((err + abs(u - targets[0]), hs, ms, es))
    final.sort()
    print(f'\n### {npot} potency + {nel} elemental  (targets >=easy {targets[0]:.0%}, >=med {targets[1]:.0%}, hard {targets[2]:.0%})')
    seen = 0
    for err, hs, ms, es in final[:5]:
        seen += 1
        print(f'-- option {seen}: err {err:.3f}  | P(>=easy) {union(hs+ms+es):.1%}  P(>=med) {union(hs+ms):.1%}  P(hard) {union(hs):.1%}')
        for lab, ks in (('easy', es), ('medium', ms), ('hard', hs)):
            print(f'   {lab:6s} ' + ', '.join(f'{k} ({prob[k]:.0%})' for k in ks))
    if not final:
        print('   no menu satisfies the ordering constraints')


if __name__ == '__main__':
    if sys.argv[1] == 'table':
        table([(4, 4), (5, 4), (4, 5), (5, 5), (6, 4), (6, 6)])
    else:
        search(int(sys.argv[2]), int(sys.argv[3]))
