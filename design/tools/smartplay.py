"""Fast exact smart-play solver for the Swig phase (numba).

Model: NP potency d6 (1-6) and NE elemental dice (faces ELEM_FACES). Each roll, roll every
uncommitted die and commit at least min(MIN_COMMIT, remaining). Repeat until all are committed.
No cards and no discards (discarding never helps base set detection).

Engine(np_, ne, min_commit).solve(goal_mask) -> P(reaching a terminal state in goal_mask)
under optimal commit decisions. goal_mask is a bool array over Engine.terminals.
Engine.raw(goal_mask) -> the same event for a single raw roll of all dice.
"""
import itertools
from math import factorial
import numpy as np
from numba import njit

ELEM_FACES = {'E': 2, 'W': 2, 'F': 1, 'A': 1}


def _multisets(k, n):
    """All count-vectors of length k summing to <= n, grouped by size."""
    out = []
    for size in range(n + 1):
        for combo in itertools.combinations_with_replacement(range(k), size):
            c = [0] * k
            for x in combo:
                c[x] += 1
            out.append(tuple(c))
    return out


def _multinomial_prob(counts, weights):
    n = sum(counts)
    tot = sum(weights)
    p = factorial(n)
    for c, w in zip(counts, weights):
        p = p / factorial(c) * (w / tot) ** c
    return p


class Pool:
    def __init__(self, k, n, weights):
        self.ms = _multisets(k, n)
        self.index = {m: i for i, m in enumerate(self.ms)}
        self.size = np.array([sum(m) for m in self.ms], dtype=np.int64)
        N = len(self.ms)
        self.add = -np.ones((N, N), dtype=np.int64)
        for i, a in enumerate(self.ms):
            for j, b in enumerate(self.ms):
                s = tuple(x + y for x, y in zip(a, b))
                if sum(s) <= n:
                    self.add[i, j] = self.index[s]
        # sub-multisets of each multiset (ragged -> flat)
        subs, off = [], [0]
        for m in self.ms:
            for sub in itertools.product(*[range(c + 1) for c in m]):
                subs.append(self.index[tuple(sub)])
            off.append(len(subs))
        self.subs = np.array(subs, dtype=np.int64)
        self.subs_off = np.array(off, dtype=np.int64)
        # roll outcomes for rolling u dice
        ro, rp, roff = [], [], [0]
        for u in range(n + 1):
            for i, m in enumerate(self.ms):
                if sum(m) == u:
                    ro.append(i)
                    rp.append(_multinomial_prob(m, weights))
            roff.append(len(ro))
        self.roll_idx = np.array(ro, dtype=np.int64)
        self.roll_p = np.array(rp, dtype=np.float64)
        self.roll_off = np.array(roff, dtype=np.int64)


@njit(cache=True)
def _solve(V, NP, NE, minc, pS, eS, pAdd, eAdd, pSubs, pSubOff, eSubs, eSubOff,
           pRo, pRp, pRoff, eRo, eRp, eRoff, order):
    for t in range(order.shape[0]):
        i = order[t, 0]
        j = order[t, 1]
        up = NP - pS[i]
        ue = NE - eS[j]
        rem = up + ue
        need = minc if minc < rem else rem
        val = 0.0
        for a_ in range(pRoff[up], pRoff[up + 1]):
            rp = pRo[a_]
            pp = pRp[a_]
            for b_ in range(eRoff[ue], eRoff[ue + 1]):
                re = eRo[b_]
                best = -1.0
                for x in range(pSubOff[rp], pSubOff[rp + 1]):
                    a = pSubs[x]
                    i2 = pAdd[i, a]
                    sa = pS[a]
                    for y in range(eSubOff[re], eSubOff[re + 1]):
                        b = eSubs[y]
                        if sa + eS[b] >= need:
                            v = V[i2, eAdd[j, b]]
                            if v > best:
                                best = v
                val += pp * eRp[b_] * best
        V[i, j] = val
    return V[0, 0]


@njit(cache=True)
def _solve_eval(V, A, NP, NE, minc, pS, eS, pAdd, eAdd, pSubs, pSubOff, eSubs, eSubOff,
                pRo, pRp, pRoff, eRo, eRp, eRoff, order):
    """Like _solve, but also propagates auxiliary values A[..., k] along the V-optimal choices
    (policy evaluation: probability of each auxiliary event under the V-maximising policy)."""
    K = A.shape[2]
    for t in range(order.shape[0]):
        i = order[t, 0]
        j = order[t, 1]
        up = NP - pS[i]
        ue = NE - eS[j]
        rem = up + ue
        need = minc if minc < rem else rem
        val = 0.0
        aux = np.zeros(K)
        for a_ in range(pRoff[up], pRoff[up + 1]):
            rp = pRo[a_]
            for b_ in range(eRoff[ue], eRoff[ue + 1]):
                re = eRo[b_]
                pr = pRp[a_] * eRp[b_]
                best = -1.0
                bi = -1
                bj = -1
                for x in range(pSubOff[rp], pSubOff[rp + 1]):
                    a = pSubs[x]
                    i2 = pAdd[i, a]
                    sa = pS[a]
                    for y in range(eSubOff[re], eSubOff[re + 1]):
                        b = eSubs[y]
                        if sa + eS[b] >= need:
                            j2 = eAdd[j, b]
                            v = V[i2, j2]
                            if v > best:
                                best = v
                                bi = i2
                                bj = j2
                val += pr * best
                for k in range(K):
                    aux[k] += pr * A[bi, bj, k]
        V[i, j] = val
        for k in range(K):
            A[i, j, k] = aux[k]
    return V[0, 0]


class Engine:
    def __init__(self, np_, ne, min_commit=3, elem_faces=ELEM_FACES):
        self.NP, self.NE, self.minc = np_, ne, min_commit
        self.P = Pool(6, np_, [1] * 6)
        self.E = Pool(4, ne, list(elem_faces.values()))
        pS, eS = self.P.size, self.E.size
        # terminal states: all dice committed
        self.t_i = np.array([i for i in range(len(pS)) if pS[i] == np_])
        self.t_j = np.array([j for j in range(len(eS)) if eS[j] == ne])
        ti, tj = np.meshgrid(self.t_i, self.t_j, indexing='ij')
        self.ti, self.tj = ti.ravel(), tj.ravel()
        # counts arrays for set detection (one row per terminal)
        self.Pc = np.array([self.P.ms[i] for i in self.ti])
        self.Ec = np.array([self.E.ms[j] for j in self.tj])
        # raw single-roll probability of each terminal
        pr = {self.P.roll_idx[k]: self.P.roll_p[k] for k in range(self.P.roll_off[np_], self.P.roll_off[np_ + 1])}
        er = {self.E.roll_idx[k]: self.E.roll_p[k] for k in range(self.E.roll_off[ne], self.E.roll_off[ne + 1])}
        self.raw_w = np.array([pr[i] * er[j] for i, j in zip(self.ti, self.tj)])
        # non-terminal states to solve, most-committed first; reachable totals are 0 and >= min_commit
        N = np_ + ne
        st = [(i, j) for i in range(len(pS)) for j in range(len(eS))
              if pS[i] + eS[j] < N and (pS[i] + eS[j] == 0 or pS[i] + eS[j] >= min(min_commit, N))]
        st.sort(key=lambda s: -(pS[s[0]] + eS[s[1]]))
        self.order = np.array(st, dtype=np.int64)

    def raw(self, mask):
        return float(self.raw_w[mask].sum())

    def solve(self, mask):
        V = np.zeros((len(self.P.ms), len(self.E.ms)))
        V[self.ti, self.tj] = mask.astype(np.float64)
        P, E = self.P, self.E
        return _solve(V, self.NP, self.NE, self.minc, P.size, E.size, P.add, E.add, P.subs, P.subs_off,
                      E.subs, E.subs_off, P.roll_idx, P.roll_p, P.roll_off, E.roll_idx, E.roll_p, E.roll_off,
                      self.order)

    def evaluate(self, objective, events):
        """Play to maximise `objective` (float array over terminals); return P(each event mask)
        under that policy, plus the objective value."""
        V = np.zeros((len(self.P.ms), len(self.E.ms)))
        V[self.ti, self.tj] = objective
        A = np.zeros((len(self.P.ms), len(self.E.ms), len(events)))
        for k, m in enumerate(events):
            A[self.ti, self.tj, k] = m.astype(np.float64)
        P, E = self.P, self.E
        v = _solve_eval(V, A, self.NP, self.NE, self.minc, P.size, E.size, P.add, E.add, P.subs, P.subs_off,
                        E.subs, E.subs_off, P.roll_idx, P.roll_p, P.roll_off, E.roll_idx, E.roll_p, E.roll_off,
                        self.order)
        return v, A[0, 0].copy()


def run_len(pc):
    best = cur = 0
    for c in pc:
        cur = cur + 1 if c else 0
        best = max(best, cur)
    return best


def library(P, E):
    """Candidate sets -> bool vector over terminals. P: counts per potency 1..6; E: counts per E,W,F,A."""
    runs = np.array([run_len(r) for r in P])
    mx, pairs, trips = P.max(1), (P >= 2).sum(1), (P >= 3).sum(1)
    L = {}
    for n in (3, 4, 5, 6):
        L[f'{n} Straight'] = runs >= n
    L['Two Pairs'] = pairs >= 2
    L['Triplet'] = mx >= 3
    L['Full House'] = (trips >= 1) & (pairs >= 2)
    L['Quadruplet'] = mx >= 4
    L['Quintuplet'] = mx >= 5
    for v, nm in ((1, 'Ones'), (6, 'Sixes')):
        L[f'Two {nm}'] = P[:, v - 1] >= 2
        L[f'Three {nm}'] = P[:, v - 1] >= 3
    L['Three Low'] = P[:, :2].sum(1) >= 3
    L['Three High'] = P[:, 4:].sum(1) >= 3
    L['Four Low'] = P[:, :2].sum(1) >= 4
    L['Four High'] = P[:, 4:].sum(1) >= 4
    L['All Odd'] = (P[:, 1] + P[:, 3] + P[:, 5]) == 0
    L['All Even'] = (P[:, 0] + P[:, 2] + P[:, 4]) == 0
    emx = E.max(1)
    names = {'E': 'Earth', 'W': 'Water', 'F': 'Fire', 'A': 'Air'}
    for i, x in enumerate('EWFA'):
        for n, w in ((2, 'Two'), (3, 'Three'), (4, 'Four')):
            L[f'{w} {names[x]}'] = E[:, i] >= n
    for n, w in ((3, 'Three'), (4, 'Four'), (5, 'Five')):
        L[f'{w} of a Color'] = emx >= n
    L['All Colors'] = E.min(1) >= 1
    L['Fire and Air'] = (E[:, 2] >= 1) & (E[:, 3] >= 1)
    L['Color Pairs'] = (E >= 2).sum(1) >= 2
    L['Color Full House'] = ((E >= 3).sum(1) >= 1) & ((E >= 2).sum(1) >= 2)
    L['Fire Pair and Air Pair'] = (E[:, 2] >= 2) & (E[:, 3] >= 2)
    return L


ELEMENT_SET = lambda k: any(w in k for w in ('Color', 'Earth', 'Water', 'Fire', 'Air'))
