class_name DiceSolver extends RefCounted
## Expectimax for the Swig commit decision. In-game port of design/tools/smartplay.py.
##
## smartplay solves the whole Swig backwards over (Potency, Elemental) multisets. Here we
## solve forward from the actual roll, which is all a decision needs:
##   value(commit K) = E over the reroll of the remaining dice [ value(final commit) ]
##
## The key trick is that every set except Four Pairs lives entirely in one *part*: numbers
## (Potency faces) or crystals (Elemental faces). The parts roll independently, so the
## expectation factorises into a distribution over each part's arrangement "signature"
## (which sets that part can form). Those distributions are memoised and shared across all
## candidate commits, and pairing two signatures is a small memoised table.
##
## Exact for the base game (10 dice, commit >= 5: the reroll is the last roll). With more
## rolls left (bonus dice, Gargoyle Mother) the next roll is treated as final, a slight
## underestimate. Discards are used only to meet the commit minimum, as in smartplay:
## discarding never helps you form a set. Mixed dice (a crystal on a Potency die) count
## toward their majority part, and their minority faces are treated as blank.

const NUM := 0
const CRY := 1

var g: Game
var p: Player
var rules: Dictionary
var value_fn: Callable      # (arrangement: Array) -> float
var _rk: String            # rules key: the shared caches below depend only on the rules
var _w := {}                # signature id pair -> best value (depends on value_fn)
var _state := {}            # kept + reroll -> expected value
var _inner := {}            # number-part state + crystal signature id -> sum_a p_a W(a, b)
# Shared across all solvers and decisions (they depend only on dice and scoring rules):
static var _sig := {}       # rules + part + faces -> signature {id, key, opts, pairs}
static var _sig_by_key := {}
static var _roll := {}      # part + dice types -> [[faces, prob], ...]
static var _dist := {}      # rules + part + kept faces + dice -> [[sig, prob], ...]
const CACHE_LIMIT := 200000
var _val := {}              # arrangement (set ids) -> value_fn result
var _four_pairs := Scoring.get_def(&"four_pairs")

func _init(g_: Game, p_: Player, value_fn_: Callable) -> void:
	g = g_
	p = p_
	value_fn = value_fn_
	rules = g.query(&"score_rules", p, {})
	_rk = var_to_str(rules)
	if _dist.size() > CACHE_LIMIT or _sig.size() > CACHE_LIMIT:
		_dist.clear(); _sig.clear(); _sig_by_key.clear(); _roll.clear()

# --- the decision -----------------------------------------------------------------
## Best {commit, discard} for this roll. `need` = dice that must be committed or discarded.
func decide(ready: Array, need: int) -> Dictionary:
	# Per-die strings are computed once; dice are sorted by them, so every subset taken in
	# order yields a canonical key with plain joins (no per-candidate sorting).
	var info := {}
	for d in ready:
		var part := part_of(d)
		var f = in_part(part, d.face())
		info[d] = {part = part, face = f, fs = var_to_str(f), ts = var_to_str(d.faces)}
	var dice := ready.duplicate()
	dice.sort_custom(func(a, b): return info[a].fs + info[a].ts < info[b].fs + info[b].ts)
	var base := _faces(p.committed())
	var base_key := [_fkey(base[NUM]), _fkey(base[CRY])]
	var n := dice.size()
	var final := n <= need
	var best := {commit = dice.duplicate(), discard = []}
	var best_v := -INF
	var seen := {}
	for mask in range(1 << n):
		var commit := []
		var rest := []
		for i in n: (commit if mask & (1 << i) else rest).append(dice[i])
		var opts := []   # [commit, discard, reroll]
		if final:
			opts.append([commit, rest, []])
		elif commit.size() >= need:
			opts.append([commit, [], rest])
		else:
			for drop in _choices(rest, need - commit.size()):
				opts.append([commit, drop, rest.filter(func(d): return not drop.has(d))])
		for o in opts:
			var st := _keys(info, base, base_key, o[0], o[2])
			if seen.has(st.key): continue
			seen[st.key] = true
			# prefer, at equal value: fewer discards
			var v: float = _expect(st) - 1e-6 * o[1].size()
			if v > best_v:
				best_v = v
				best = {commit = o[0], discard = o[1]}
	return best

## Expected value of holding `kept` (faces per part) and rolling `reroll` once more, then
## committing everything. (Convenience entry point; decide() uses the keyed fast path.)
func state_value(kept: Array, reroll: Array) -> float:
	var info := {}
	for d in reroll:
		var part := part_of(d)
		info[d] = {part = part, face = null, fs = "", ts = var_to_str(d.faces)}
	return _expect(_keys(info, kept, [_fkey(kept[NUM]), _fkey(kept[CRY])], [], reroll))

## Keys and dice for one candidate state, built from precomputed per-die strings.
func _keys(info: Dictionary, base: Array, base_key: Array, commit: Array, reroll: Array) -> Dictionary:
	var kept := [base[NUM].duplicate(), base[CRY].duplicate()]
	var kk := [PackedStringArray([base_key[NUM]]), PackedStringArray([base_key[CRY]])]
	for d in commit:
		var x: Dictionary = info[d]
		kept[x.part].append(x.face)
		kk[x.part].append(x.fs)
	var rr := [[], []]
	var rk := [PackedStringArray(), PackedStringArray()]
	for d in reroll:
		var x: Dictionary = info[d]
		rr[x.part].append(d)
		rk[x.part].append(x.ts)
	rk[NUM].sort()
	rk[CRY].sort()
	var nk := ",".join(kk[NUM]) + "#" + ";".join(rk[NUM])
	var ck := ",".join(kk[CRY]) + "#" + ";".join(rk[CRY])
	return {key = nk + "/" + ck, nk = nk, ck = ck, kept = kept, rr = rr}

func _expect(st: Dictionary) -> float:
	if _state.has(st.key): return _state[st.key]
	var dn := _distribution(NUM, st.kept[NUM], st.rr[NUM], st.nk)
	var dc := _distribution(CRY, st.kept[CRY], st.rr[CRY], st.ck)
	# E[W] = sum_b p_b * (sum_a p_a W(a, b)); the inner sum is shared by every state with
	# the same number part, so it's cached per (number state, crystal signature).
	var v := 0.0
	for b in dc:
		var ik: String = st.nk + "@" + str(b[0].id)
		var inner: float
		if _inner.has(ik): inner = _inner[ik]
		else:
			inner = 0.0
			for a in dn: inner += a[1] * _pair_value(a[0], b[0])
			_inner[ik] = inner
		v += b[1] * inner
	_state[st.key] = v
	return v

# --- parts --------------------------------------------------------------------------
static func part_of(d: Die) -> int:
	var ints := d.faces.filter(func(f): return f is int).size()
	return NUM if ints * 2 >= d.faces.size() else CRY

static func in_part(part: int, f):
	if part == NUM: return f if f is int else ""
	return f if f is String else ""

func _faces(dice: Array) -> Array:
	var out := [[], []]
	for d in dice:
		var part := part_of(d)
		out[part].append(in_part(part, d.face()))
	return out

func _add(a: Array, b: Array) -> Array: return [a[NUM] + b[NUM], a[CRY] + b[CRY]]

## Which arrangements one part can make from these faces, plus its pair count (Four Pairs).
func _signature(part: int, faces: Array) -> Dictionary:
	var key := _rk + str(part) + _fkey(faces)
	if _sig.has(key): return _sig[key]
	var opts := Scoring.arrangements(faces, rules)
	var cnt := {}
	for f in faces:
		if not (f is String and (f == "" or f == "Q")): cnt[f] = cnt.get(f, 0) + 1
	var pairs := cnt.values().filter(func(c): return c >= 2).size()
	var skey := "%s|%d:%s;p%d" % [_rk, part, ",".join(opts.map(func(a): return DiceSolver._arr_key(a))), mini(pairs, 4)]
	if not _sig_by_key.has(skey): _sig_by_key[skey] = {id = _sig_by_key.size(), opts = opts, pairs = pairs}
	_sig[key] = _sig_by_key[skey]
	return _sig[key]

func _pair_value(a: Dictionary, b: Dictionary) -> float:
	var key: int = a.id * 1048576 + b.id
	if _w.has(key): return _w[key]
	var best := -INF
	for x in a.opts:
		for y in b.opts: best = maxf(best, _value(x + y))
	var banned: Array = rules.get("banned", [])
	var only: Array = rules.get("only", [])
	if a.pairs + b.pairs >= 4 and not banned.has(&"four_pairs") and (only.is_empty() or only.has(&"four_pairs")):
		best = maxf(best, _value([{def = _four_pairs, faces = []}]))
	_w[key] = best
	return best

## An arrangement's value depends only on which sets it holds, so memoise on that.
func _value(arr: Array) -> float:
	var k := DiceSolver._arr_key(arr)
	if not _val.has(k): _val[k] = value_fn.call(arr)
	return _val[k]

## Distribution over signatures of (kept + roll of `dice`) within one part: [[sig, p], ...].
func _distribution(part: int, kept: Array, dice: Array, state_key: String) -> Array:
	var key := _rk + str(part) + state_key
	if _dist.has(key): return _dist[key]
	var acc := {}
	for o in _outcomes(part, dice):
		var s := _signature(part, kept + o[0])
		if acc.has(s.id): acc[s.id][1] += o[1]
		else: acc[s.id] = [s, o[1]]
	_dist[key] = acc.values()
	return _dist[key]

## All face multisets from rolling `dice` (one part), with probabilities.
func _outcomes(part: int, dice: Array) -> Array:
	var key := str(part) + _dice_key(dice, true)
	if _roll.has(key): return _roll[key]
	var acc := {"": [[], 1.0]}
	for d in dice:
		var face_p := {}
		for f in d.faces:
			var x = in_part(part, f)
			face_p[var_to_str(x)] = [x, face_p.get(var_to_str(x), [x, 0.0])[1] + 1.0 / d.faces.size()]
		var nxt := {}
		for k in acc:
			for fk in face_p:
				var faces: Array = acc[k][0] + [face_p[fk][0]]
				var nk := _fkey(faces)
				var pr: float = acc[k][1] * face_p[fk][1]
				if nxt.has(nk): nxt[nk][1] += pr
				else: nxt[nk] = [faces, pr]
		acc = nxt
	var out := acc.values()
	_roll[key] = out
	return out

# --- keys -----------------------------------------------------------------------------
static func _fkey(faces: Array) -> String:
	var s := faces.map(func(f): return var_to_str(f))
	s.sort()
	return ",".join(s)

## Dice identity for dedupe: showing face + face list (two plain d6 showing 3 are equal).
static func _dice_key(dice: Array, types_only := false) -> String:
	var s := dice.map(func(d): return ("" if types_only else var_to_str(d.face()) + "@") + var_to_str(d.faces))
	s.sort()
	return ";".join(s)

static func _arr_key(arr: Array) -> String:
	var ids := arr.map(func(s): return String(s.def.id))
	ids.sort()
	return "+".join(ids)

## Distinct ways to pick k dice from `dice` (dice of the same type are interchangeable).
static func _choices(dice: Array, k: int) -> Array:
	var groups := {}
	for d in dice:
		var t := var_to_str(d.faces)
		if not groups.has(t): groups[t] = []
		groups[t].append(d)
	var out := []
	_pick(groups.values(), 0, k, [], out)
	return out

static func _pick(groups: Array, i: int, k: int, cur: Array, out: Array) -> void:
	if k == 0:
		out.append(cur.duplicate())
		return
	if i >= groups.size(): return
	for take in range(mini(k, groups[i].size()), -1, -1):
		_pick(groups, i + 1, k - take, cur + groups[i].slice(0, take), out)
