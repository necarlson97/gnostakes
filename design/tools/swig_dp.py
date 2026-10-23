"""Exact DP for the base Swig phase (no cards).

Model (per current rules doc): 4 potency d6 (1-6), 4 elemental dice (E,E,W,W,F,A).
Roll all uncommitted, commit >= min(3, remaining), repeat until all committed.
Discarding never helps base hand detection, so it is ignored.
Score = best single hand among committed dice (assumption: one hand per turn).
"""
import itertools, functools, sys
from collections import Counter
from fractions import Fraction

POT = [1, 2, 3, 4, 5, 6]
ELEM = ['E', 'E', 'W', 'W', 'F', 'A']
NP, NE = 4, 4
if len(sys.argv) > 1:
    NP, NE = int(sys.argv[1]), int(sys.argv[2])
MIN_COMMIT = 3

def has_straight(p, n):
    s = set(p)
    return any(all(v + i in s for i in range(n)) for v in range(1, 10))

def hands(p, e):
    """p: sorted tuple of potencies, e: tuple counts (E,W,F,A). Returns set of hand names."""
    c = Counter(p)
    out = set()
    if has_straight(p, 3): out.add('Three Straight')
    if max(c.values(), default=0) >= 3: out.add('Triplet')
    if sum(1 for v in c.values() if v >= 2) >= 2: out.add('Two Pairs')
    if max(e) >= 3: out.add('Three of a Color')
    if has_straight(p, 4): out.add('Four Straight')
    if c[1] >= 2: out.add('Two Ones')
    if max(e) >= 4: out.add('Four of a Color')
    if min(e) >= 1: out.add('All Colors')
    if e[0] >= 2: out.add('Two Earth')
    if has_straight(p, 5): out.add('Five Straight')
    if c[6] >= 3: out.add('Three Sixes')
    if max(c.values(), default=0) >= 4: out.add('Quadruplet')
    if e[3] >= 3: out.add('Three Air')
    return out

TIER = {'Three Straight': 1, 'Triplet': 1, 'Two Pairs': 1, 'Three of a Color': 1,
        'Four Straight': 2, 'Two Ones': 2, 'Four of a Color': 2, 'All Colors': 2, 'Two Earth': 2,
        'Five Straight': 3, 'Three Sixes': 3, 'Quadruplet': 3, 'Three Air': 3}
ALL_HANDS = list(TIER)

def multiset_outcomes(faces, n):
    """Distribution over sorted tuples of n draws from faces."""
    d = Counter()
    for combo in itertools.product(faces, repeat=n):
        d[tuple(sorted(combo))] += 1
    tot = len(faces) ** n
    return [(k, Fraction(v, tot)) for k, v in d.items()]

OUT_P = {n: multiset_outcomes(POT, n) for n in range(NP + 1)}
OUT_E = {n: multiset_outcomes(ELEM, n) for n in range(NE + 1)}
EIDX = {'E': 0, 'W': 1, 'F': 2, 'A': 3}

def sub_multisets(t):
    c = Counter(t)
    keys = sorted(c)
    for counts in itertools.product(*[range(c[k] + 1) for k in keys]):
        yield tuple(v for k, n in zip(keys, counts) for v in [k] * n)

def solve(value_fn):
    @functools.lru_cache(maxsize=None)
    def V(cp, ce):
        up, ue = NP - len(cp), NE - sum(ce)
        if up + ue == 0:
            return value_fn(cp, ce)
        need = min(MIN_COMMIT, up + ue)
        tot = 0.0
        for rp, pp in OUT_P[up]:
            for re_, pe in OUT_E[ue]:
                best = -1.0
                for sp in sub_multisets(rp):
                    np_ = tuple(sorted(cp + sp))
                    for se in sub_multisets(re_):
                        if len(sp) + len(se) < need:
                            continue
                        ne = list(ce)
                        for x in se: ne[EIDX[x]] += 1
                        v = V(np_, tuple(ne))
                        if v > best: best = v
                tot += float(pp * pe) * best
        return tot
    return V((), (0, 0, 0, 0))

def single_roll(pred):
    tot = 0.0
    for rp, pp in OUT_P[NP]:
        for re_, pe in OUT_E[NE]:
            ce = [0, 0, 0, 0]
            for x in re_: ce[EIDX[x]] += 1
            if pred(rp, tuple(ce)): tot += float(pp * pe)
    return tot

def best_tier(p, e):
    return max((TIER[h] for h in hands(p, e)), default=0)

if __name__ == '__main__':
    print(f'Dice: {NP} potency, {NE} elemental')
    print('\n== Single roll of all dice (no rerolls) ==')
    for h in ALL_HANDS:
        print(f'  {h:18s} T{TIER[h]}  {single_roll(lambda p,e,h=h: h in hands(p,e)):6.1%}')
    print(f'  any hand            {single_roll(lambda p,e: best_tier(p,e)>=1):6.1%}')
    print(f'  tier2+              {single_roll(lambda p,e: best_tier(p,e)>=2):6.1%}')
    print(f'  tier3               {single_roll(lambda p,e: best_tier(p,e)>=3):6.1%}')

    print('\n== Optimal play targeting ONE specific hand ==')
    for h in ALL_HANDS:
        print(f'  {h:18s} T{TIER[h]}  {solve(lambda p,e,h=h: 1.0 if h in hands(p,e) else 0.0):6.1%}')

    print('\n== Optimal play for tier thresholds ==')
    for t in (1, 2, 3):
        print(f'  P(tier>={t})  {solve(lambda p,e,t=t: 1.0 if best_tier(p,e)>=t else 0.0):6.1%}')

    # Expected cards claimed if you play to maximise it (T1=1, T2=1, T3=2)
    w = {0: 0, 1: 1, 2: 1, 3: 2}
    print(f'\n  max E[cards] (T1=1,T2=1,T3=2): {solve(lambda p,e: w[best_tier(p,e)]):.3f}')
