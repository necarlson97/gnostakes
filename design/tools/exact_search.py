"""Exact staged menu search over curated set pools (no proxy; every candidate solved exactly).

python exact_search.py NP NE MIN_COMMIT [easy med hard]
"""
import itertools, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import numpy as np
import smartplay as sp

NP, NE, MINC = (int(x) for x in sys.argv[1:4])
TGT = tuple(float(x) for x in sys.argv[4:7]) if len(sys.argv) > 6 else (0.96, 0.80, 0.25)
KEEP = 4

HARD = ['5 Straight', 'Quadruplet', 'Three Air', 'Three Fire', 'Three Sixes', 'Three Ones', 'Full House',
        'Fire Pair and Air Pair', 'Five of a Color', 'Four Earth', 'Four Water', 'Four High', 'Four Low']
MED = ['Two Pairs', 'Triplet', 'Color Full House', 'All Colors', 'Four of a Color', '4 Straight', 'Two Ones',
       'Two Sixes', 'Two Fire', 'Two Air', 'Four Earth', 'Four Water', 'Full House']
EASY = ['Three of a Color', '3 Straight', 'Three Low', 'Three High', 'Three Earth', 'Three Water', 'Fire and Air',
        'Two Pairs', 'Triplet', 'Color Pairs', 'Two Earth', 'Two Water']

eng = sp.Engine(NP, NE, MINC)
L = sp.library(eng.Pc, eng.Ec)
one = {k: eng.solve(L[k]) for k in set(HARD + MED + EASY)}
cache = {}


def S(ks):
    key = frozenset(ks)
    if key not in cache:
        cache[key] = eng.solve(np.logical_or.reduce([L[k] for k in ks]))
    return cache[key]


def R(ks):
    return eng.raw(np.logical_or.reduce([L[k] for k in ks]))


mixed = lambda ks: any(sp.ELEMENT_SET(k) for k in ks) and any(not sp.ELEMENT_SET(k) for k in ks)

hard = sorted((abs(S(hs) - TGT[2]), hs) for n in (2, 3) for hs in itertools.combinations(HARD, n) if mixed(hs))[:KEEP]
med = []
for e0, hs in hard:
    top = max(one[k] for k in hs)
    pool = [k for k in MED if k not in hs and one[k] > top]
    for n in (2, 3, 4):
        for ms in itertools.combinations(pool, n):
            if mixed(ms):
                med.append((e0 + abs(S(hs + ms) - TGT[1]), hs, ms))
med = sorted(med)[:KEEP]
easy = []
for e0, hs, ms in med:
    top = max(one[k] for k in ms)
    pool = [k for k in EASY if k not in hs + ms and one[k] > top]
    for es in itertools.combinations(pool, 4):
        if mixed(es):
            v = S(hs + ms + es)
            easy.append((e0 + max(0, TGT[0] - 0.01 - v, v - TGT[0] - 0.03), hs, ms, es))
easy.sort()

print(f'### {NP}P+{NE}E commit>={MINC}  smart targets {TGT}')
for n, (err, hs, ms, es) in enumerate(easy[:5], 1):
    full = hs + ms + es
    print(f'-- option {n} (err {err:.3f})\n   smart: >=easy {S(full):.1%}  >=med {S(hs + ms):.1%}  hard {S(hs):.1%}  nothing {1 - S(full):.1%}'
          f'\n   raw:   >=easy {R(full):.1%}  >=med {R(hs + ms):.1%}  hard {R(hs):.1%}  nothing {1 - R(full):.1%}')
    for lab, ks in (('easy', es), ('medium', ms), ('hard', hs)):
        print(f'   {lab:6s} ' + ', '.join(f'{k} ({one[k]:.0%}/{eng.raw(L[k]):.0%})' for k in ks))
