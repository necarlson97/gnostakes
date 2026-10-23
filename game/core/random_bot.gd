class_name RandomBot extends Controller
## Legal random play with light preferences: it usually requests villagers, sometimes uses
## abilities, and arranges sets for the most request value. It is a baseline for
## simulations and a fuzzer for the engine. Smarter bots override decide() per Choice.tag.

var rng := RandomNumberGenerator.new()
var act_rate := 0.35
var yes_rate := 0.5

func _init(seed_ := 0) -> void:
	rng.seed = seed_ if seed_ else randi()

func decide(g: Game, c: Choice):
	match c.kind:
		&"yes_no": return rng.randf() < yes_rate
		&"number": return rng.randi_range(c.lo, mini(c.hi, c.lo + 3))
		&"tokens":
			var bid := {}
			for t in c.options[0]:
				if c.options[0][t] > 0 and rng.randf() < 0.4: bid[t] = rng.randi_range(1, c.options[0][t])
			return bid
		&"many":
			var o := _shuffled(c.options)
			return o.slice(0, rng.randi_range(c.lo, c.hi))
		&"assign":
			var o := _shuffled(c.options)
			var n := rng.randi_range(c.lo, o.size())
			var commit := []
			var discard := []
			for i in n: (discard if rng.randf() < 0.15 else commit).append(o[i])
			return {commit = commit, discard = discard}
		&"one":
			match c.tag:
				&"act": return null if rng.randf() > act_rate else _any_but_null(c.options)
				&"request":
					# set rights almost always; paid (token) requests sometimes
					var free := c.options.filter(func(o): return o != null and o.tokens.is_empty())
					if free and rng.randf() < 0.9: return free[rng.randi_range(0, free.size() - 1)]
					return _any_but_null(c.options) if rng.randf() < 0.3 else null
				&"arrangement": return _best_arrangement(c.options)
			return c.options[rng.randi_range(0, c.options.size() - 1)]
	return Controller.default_answer(c)

func _any_but_null(o: Array):
	var x := o.filter(func(v): return v != null)
	return x[rng.randi_range(0, x.size() - 1)] if x else null

func _best_arrangement(opts: Array):
	var best = opts[0]
	var bv := -1
	for a in opts:
		var v: int = a.reduce(func(acc, s): return acc + [0, 1, 3, 6][s.def.tier], 0)
		if v > bv:
			bv = v
			best = a
	return best

func _shuffled(a: Array) -> Array:
	var o := a.duplicate()
	for i in range(o.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var t = o[i]; o[i] = o[j]; o[j] = t
	return o
