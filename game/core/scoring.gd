class_name Scoring extends RefCounted
## The Town Square set menu and the arrangement search.
## An arrangement is a list of disjoint sets drawn from the committed dice. Rules: each die
## is in at most one set, and if a set *can* still be formed you have scored it, so only
## maximal arrangements are legal. Dice with equal faces are interchangeable, so the
## search works on face multisets.

class SetDef:
	var id: StringName
	var name: String
	var tier: int        # 1: claims its own slot; 2: any one slot; 3: any two slots
	var slot: int        # Town Square slot for tier 1, else -1
	var size: int
	var kind: StringName  # matcher, see Scoring.test()
	var arg              # matcher argument
	func _init(id_, name_, tier_, slot_, size_, kind_, arg_ = null) -> void:
		id = id_; name = name_; tier = tier_; slot = slot_; size = size_; kind = kind_; arg = arg_
	func sizes(rules: Dictionary) -> Array:
		if id == &"quadruplet" and rules.get("triplet_as_quad"): return [4, 3]
		if kind == &"straight" and rules.get("short_straight"): return [size, size - 1]
		return [size]
	func _to_string() -> String: return name

static var MENU: Array = [
	SetDef.new(&"three_straight", "Three Straight", 1, 0, 3, &"straight"),
	SetDef.new(&"two_color_pairs", "Two Color-Pairs", 1, 1, 4, &"pairs", true),
	SetDef.new(&"triplet", "Triplet", 1, 2, 3, &"of_kind"),
	SetDef.new(&"four_of_a_color", "Four of a Color", 1, 3, 4, &"of_color", ""),
	SetDef.new(&"four_straight", "Four Straight", 2, -1, 4, &"straight"),
	SetDef.new(&"three_ones", "Three Ones", 2, -1, 3, &"all_pips", 1),
	SetDef.new(&"all_colors", "All Colors", 2, -1, 4, &"all_colors"),
	SetDef.new(&"four_pairs", "Four Pairs", 2, -1, 8, &"pairs", false),
	SetDef.new(&"five_straight", "Five Straight", 3, -1, 5, &"straight"),
	SetDef.new(&"quadruplet", "Quadruplet", 3, -1, 4, &"of_kind"),
	SetDef.new(&"four_air", "Four Air", 3, -1, 4, &"of_color", "A"),
	SetDef.new(&"five_of_a_color", "Five of a Color", 3, -1, 5, &"of_color", ""),
]

static func test(d: SetDef, f: Array, r: Dictionary) -> bool:
	match d.kind:
		&"straight": return straight(f, r)
		&"pairs": return pairs(f, d.arg)
		&"of_kind": return of_kind(f)
		&"of_color": return of_color(f, r, d.arg)
		&"all_pips": return f.all(func(x): return x is int and x == d.arg)
		&"all_colors": return all_colors(f)
	return false

static func get_def(id: StringName) -> SetDef:
	for d in MENU:
		if d.id == id: return d
	return null

static func is_straight(id: StringName) -> bool: return String(id).ends_with("straight")

## Strategy family of a set: straight / kind / pairs / color.
static func family(id: StringName) -> String:
	if is_straight(id): return "straight"
	match id:
		&"triplet", &"quadruplet", &"three_ones": return "kind"
		&"two_color_pairs", &"four_pairs": return "pairs"
	return "color"

# --- matchers (faces: exactly `size` faces) -------------------------------------
static func _ints(f: Array) -> bool: return f.all(func(x): return x is int)
static func _crystals(f: Array) -> bool: return f.all(func(x): return x is String and x != "")

static func straight(f: Array, r: Dictionary) -> bool:
	if r.get("no_straights") or not _ints(f): return false
	var s := f.duplicate()
	s.sort()
	for i in range(1, s.size()):
		if s[i] == s[i - 1]: return false
	var span: int = s[-1] - s[0]
	return span == f.size() - 1 or (r.get("straight_gap", 0) > 0 and span == f.size())

static func of_kind(f: Array) -> bool:
	return _ints(f) and f.all(func(x): return x == f[0])

## n of one crystal colour (or the given colour). Q is wild.
static func of_color(f: Array, r: Dictionary, color: String) -> bool:
	if not _crystals(f): return false
	var c := color
	for x in f:
		var x2: String = "A" if (r.get("fire_as_air") and color == "A" and x == "F") else x
		if x2 == "Q": continue
		if c == "": c = x2
		elif x2 != c: return false
	return true

static func all_colors(f: Array) -> bool:
	if not _crystals(f): return false
	var seen := {}
	for x in f:
		if x != "Q":
			if seen.has(x): return false
			seen[x] = true
	return true

## Distinct pairs: Two Color-Pairs (crystals only) or Four Pairs (numbers and/or crystals).
static func pairs(f: Array, crystals_only: bool) -> bool:
	if crystals_only and not _crystals(f): return false
	if f.has(""): return false
	var cnt := {}
	var wild := 0
	for x in f:
		if x is String and x == "Q": wild += 1
		else: cnt[x] = cnt.get(x, 0) + 1
	var need := 0
	for k in cnt:
		if cnt[k] > 2: return false
		need += 2 - cnt[k]
	return wild >= need and (wild - need) % 2 == 0

# --- arrangement search ---------------------------------------------------------
## Returns Array of arrangements; each is Array of {def: SetDef, faces: Array}.
## Always returns at least one arrangement ([] = scored nothing).
static var _memo := {}

static func arrangements(faces: Array, rules := {}, cap := 400) -> Array:
	var sorted := faces.map(func(f): return var_to_str(f))
	sorted.sort()
	var key := "%s|%s|%d" % [",".join(sorted), var_to_str(rules), cap]
	if _memo.has(key): return _memo[key]
	if _memo.size() > 50000: _memo.clear()
	var out := _arrangements(faces, rules, cap)
	_memo[key] = out
	return out

static func _arrangements(faces: Array, rules: Dictionary, cap: int) -> Array:
	var counts := {}
	for f in faces:
		if not (f is String and f == ""): counts[f] = counts.get(f, 0) + 1
	var cands := []   # [{def, faces}]
	var banned: Array = rules.get("banned", [])
	var only: Array = rules.get("only", [])
	for d in MENU:
		if banned.has(d.id) or (only and not only.has(d.id)): continue
		for n in d.sizes(rules):
			if n < rules.get("min_size", 0): continue
			for sub in _sub_multisets(counts, n):
				if test(d, sub, rules): cands.append({"def": d, "faces": sub})
	var out := []
	var seen := {}
	_search(cands, 0, counts, [], out, seen, cap)
	return out if out else [[]]

static func _search(cands: Array, start: int, left: Dictionary, cur: Array, out: Array, seen: Dictionary, cap: int) -> void:
	if out.size() >= cap: return
	var extended := false
	for i in range(start, cands.size()):
		if _fits(cands[i].faces, left):
			extended = true
			_take(cands[i].faces, left, -1)
			cur.append(cands[i])
			_search(cands, i, left, cur, out, seen, cap)
			cur.pop_back()
			_take(cands[i].faces, left, 1)
	if extended: return
	# maximal only: nothing at all (not just from `start`) may still fit
	for c in cands:
		if _fits(c.faces, left): return
	var key := ",".join(cur.map(func(s): return "%s%s" % [s.def.id, s.faces]))
	if not seen.has(key):
		seen[key] = true
		out.append(cur.duplicate())

static func _fits(f: Array, left: Dictionary) -> bool:
	var need := {}
	for x in f: need[x] = need.get(x, 0) + 1
	for x in need:
		if left.get(x, 0) < need[x]: return false
	return true

static func _take(f: Array, left: Dictionary, sgn: int) -> void:
	for x in f: left[x] += sgn

static func _sub_multisets(counts: Dictionary, n: int) -> Array:
	var keys := counts.keys()
	var out := []
	_subs(keys, counts, 0, n, [], out)
	return out

static func _subs(keys: Array, counts: Dictionary, i: int, n: int, cur: Array, out: Array) -> void:
	if n == 0:
		out.append(cur.duplicate())
		return
	if i >= keys.size(): return
	for k in range(mini(counts[keys[i]], n), -1, -1):
		for _j in k: cur.append(keys[i])
		_subs(keys, counts, i + 1, n - k, cur, out)
		for _j in k: cur.pop_back()

## Request rights granted by an arrangement: Array of allowed-slot lists.
static func rights(arr: Array, slots: int) -> Array:
	var all := range(slots)
	var out := []
	for s in arr:
		match s.def.tier:
			1: out.append([s.def.slot])
			2: out.append(all)
			3: out.append_array([all, all])
	return out
