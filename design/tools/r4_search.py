"""R4: fixed easy tier, choose 4 medium + 4 hard from a user-specified pool (5P+5E, commit>=5)."""
import itertools, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import numpy as np
import smartplay as sp

e = sp.Engine(5, 5, 5)
L = sp.library(e.Pc, e.Ec)
P, E = e.Pc, e.Ec
L['Five of a Color'] = E.max(1) >= 5
L['Six of a Color'] = E.max(1) >= 6
L['Two Color-Pairs'] = L['Color Pairs']
L['Four Ones'] = P[:, 0] >= 4
EASY = ['3 Straight', 'Two Color-Pairs', 'Triplet', 'Four of a Color']
POOL = ['4 Straight', '5 Straight', '6 Straight', 'Five of a Color', 'Six of a Color', 'All Colors', 'Quadruplet',
        'Quintuplet', 'Two Earth', 'Three Earth', 'Four Earth', 'Three Air', 'Four Air', 'Two Ones', 'Three Ones',
        'Four Ones']
TGT_MED, TGT_HARD = 0.80, 0.25
U = lambda ks: np.logical_or.reduce([L[k] for k in ks])
one = {k: (e.solve(L[k]), e.raw(L[k])) for k in EASY + POOL}

print('Per-set (smart / raw), 5P+5E commit>=5')
for k in sorted(one, key=lambda k: -one[k][0]):
    tag = 'EASY' if k in EASY else ('impossible' if one[k][1] == 0 else '')
    print(f'  {k:18s} {one[k][0]:6.1%} {one[k][1]:6.1%}  {tag}')
print(f'  easy tier alone    {e.solve(U(EASY)):6.1%} {e.raw(U(EASY)):6.1%}')

cand = [k for k in POOL if 0 < one[k][1] and one[k][0] < max(one[x][0] for x in EASY)]
cache = {}
def S(ks):
    f = frozenset(ks)
    if f not in cache: cache[f] = e.solve(U(ks))
    return cache[f]
hard = sorted((abs(S(h) - TGT_HARD), h) for h in itertools.combinations(cand, 4))[:6]
res = []
for eh, h in hard:
    top = max(one[k][0] for k in h)
    pool = [k for k in cand if k not in h and one[k][0] >= top]
    for m in itertools.combinations(pool, 4):
        res.append((eh + abs(S(h + m) - TGT_MED), h, m))
res.sort()
print('\nTop menus (4 medium + 4 hard; each medium set individually >= every hard set)')
for err, h, m in res[:6]:
    full = EASY + list(m) + list(h)
    print(f'-- err {err:.3f} | smart >=easy {S(tuple(full)):.1%} >=med {S(h + m):.1%} hard {S(h):.1%}'
          f' | raw {e.raw(U(full)):.1%} {e.raw(U(h + m)):.1%} {e.raw(U(h)):.1%}')
    print('   medium: ' + ', '.join(m) + '\n   hard:   ' + ', '.join(h))
