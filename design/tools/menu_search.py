"""Search set menus against SMART-PLAY targets (exact optimal committing, no cards).

python menu_search.py NP NE MIN_COMMIT [easy med hard]
Default targets: >=easy 0.96, >=medium 0.80, hard 0.25

Each tier mixes number and element sets. Easy has exactly 4 sets (one per Town Square slot).
Every set in a tier is individually (smart) harder than every set in the tier below.
"""
import itertools, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import numpy as np
import smartplay as sp

NP, NE, MINC = (int(x) for x in sys.argv[1:4])
TGT = tuple(float(x) for x in sys.argv[4:7]) if len(sys.argv) > 6 else (0.96, 0.80, 0.25)
BEAM, EVAL = 6, 40

eng = sp.Engine(NP, NE, MINC)
L = sp.library(eng.Pc, eng.Ec)
L = {k: v for k, v in L.items() if v.any() and not v.all()}
smart = {k: eng.solve(v) for k, v in L.items()}
raw = {k: eng.raw(v) for k, v in L.items()}
cache = {}


def S(ks):
    key = frozenset(ks)
    if key not in cache:
        cache[key] = eng.solve(np.logical_or.reduce([L[k] for k in ks]))
    return cache[key]


def R(ks):
    return eng.raw(np.logical_or.reduce([L[k] for k in ks]))


def proxy(ks):
    return 1 - np.prod([1 - smart[k] for k in ks])


def mixed(ks):
    return any(sp.ELEMENT_SET(k) for k in ks) and any(not sp.ELEMENT_SET(k) for k in ks)


def stage(bases, pool_fn, sizes, tgt_idx, tgt):
    cands = []
    for base in bases or [()]:
        pool = pool_fn(base)
        for n in sizes:
            for ks in itertools.combinations(pool, n):
                if not mixed(ks):
                    continue
                full = base[-1] + ks if base else ks
                cands.append((abs(proxy(full) - tgt), base, ks))
    cands.sort(key=lambda c: c[0])
    scored = []
    for _, base, ks in cands[:EVAL * max(1, len(bases))]:
        full = (base[-1] + ks) if base else ks
        err = (base[0] if base else 0) + abs(S(full) - tgt)
        scored.append((err, *(base[1:-1] if base else ()), ks, full))
    scored.sort(key=lambda c: c[0])
    out = []
    for s in scored[:BEAM]:
        out.append((s[0], *s[1:-1], s[-1]))
    return out


names = sorted(L, key=lambda k: -smart[k])
hard = stage([], lambda b: [k for k in names if 0.02 <= smart[k] <= 0.30], (2, 3, 4), 2, TGT[2])
med = stage(hard, lambda b: [k for k in names if k not in b[-1] and smart[k] > max(smart[x] for x in b[1])
                             and smart[k] <= 0.75], (2, 3, 4), 1, TGT[1])
easy = stage(med, lambda b: [k for k in names if k not in b[-1] and smart[k] > max(smart[x] for x in b[2])],
             (4,), 0, TGT[0])

print(f'### {NP}P+{NE}E, commit >= {MINC}  targets(smart) easy {TGT[0]:.0%} med {TGT[1]:.0%} hard {TGT[2]:.0%}')
for n, (err, hs, ms, es, full) in enumerate(easy[:4], 1):
    print(f'-- option {n} (err {err:.3f})')
    print(f'   smart: >=easy {S(full):.1%}  >=med {S(hs + ms):.1%}  hard {S(hs):.1%}  nothing {1 - S(full):.1%}')
    print(f'   raw:   >=easy {R(full):.1%}  >=med {R(hs + ms):.1%}  hard {R(hs):.1%}  nothing {1 - R(full):.1%}')
    for lab, ks in (('easy', es), ('medium', ms), ('hard', hs)):
        print(f'   {lab:6s} ' + ', '.join(f'{k} ({smart[k]:.0%}/{raw[k]:.0%})' for k in ks))
print('   (per-set numbers are smart/raw)')
