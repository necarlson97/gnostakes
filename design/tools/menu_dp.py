"""Optimal-play (smart committing) probabilities for a proposed set menu.
Usage: python menu_dp.py NP NE GOAL [MIN_COMMIT=3]   where GOAL in {easy, medium, hard}
Prints P(reaching at least GOAL tier) under optimal commit decisions.
"""
import sys
NP, NE, GOAL = int(sys.argv[1]), int(sys.argv[2]), sys.argv[3]
MINC = int(sys.argv[4]) if len(sys.argv) > 4 else 3
sys.argv = [sys.argv[0], str(NP), str(NE)]
import os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import swig_dp as s
from collections import Counter
s.MIN_COMMIT = MINC

# Candidate A (5 potency + 4 elemental)
def tier(p, e):
    c = Counter(p)
    mx = max(c.values(), default=0)
    if s.has_straight(p, 5) or mx >= 4 or max(e) >= 4 or min(e) >= 1: return 3
    if s.has_straight(p, 4) or e[0] >= 3 or e[1] >= 3: return 2
    if mx >= 3 or c[1] >= 2 or (c[1] + c[2]) >= 3 or max(e) >= 3: return 1
    return 0

g = {'easy': 1, 'medium': 2, 'hard': 3}[GOAL]
print(f'{NP}P+{NE}E commit>={MINC} optimal P(>= {GOAL}) = {s.solve(lambda p, e: 1.0 if tier(p, e) >= g else 0.0):.1%}')
