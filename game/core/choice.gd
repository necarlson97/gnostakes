class_name Choice extends RefCounted
## A decision the engine needs from a player. The engine blocks (awaits) until the
## player's Controller answers, so card code reads linearly:  if await may(...): ...
##
## kinds and answer shapes:
##   &"yes_no"  -> bool
##   &"one"     -> one element of options (options may include null = "none/pass")
##   &"many"    -> Array subset of options, size in [lo, hi]
##   &"number"  -> int in [lo, hi]
##   &"tokens"  -> Dictionary token -> count, within options[0] (the player's holdings)
##   &"assign"  -> {commit: Array[Die], discard: Array[Die]}  (options = ready dice;
##                 lo = minimum dice that must be committed or discarded)

var player: Player
var kind: StringName
var prompt: String
var options: Array = []
var lo := 0
var hi := 1
var source: Ability     # card ability asking, if any
var tag: StringName     # machine-readable purpose, for bots/GUI (e.g. &"act", &"request")
var data := {}          # extra context for bots/GUI: offer {cost, gain}, the wagered card, ...

func _init(p: Player, kind_: StringName, prompt_: String, options_ := [], lo_ := 0, hi_ := 1, src: Ability = null, tag_: StringName = &"") -> void:
	player = p
	kind = kind_
	prompt = prompt_
	options = options_
	lo = lo_
	hi = hi_
	source = src
	tag = tag_

func valid(a) -> bool:
	match kind:
		&"yes_no": return a is bool
		&"one": return options.has(a)
		&"number": return a is int and a >= lo and a <= hi
		&"tokens":
			if not a is Dictionary: return false
			for t in a:
				if not options[0].has(t) or not a[t] is int or a[t] < 0 or a[t] > options[0][t]: return false
			return true
		&"many": return a is Array and a.size() >= lo and a.size() <= hi and a.all(func(x): return options.has(x))
		&"assign":
			if not (a is Dictionary and a.has("commit") and a.has("discard")): return false
			var all: Array = a.commit + a.discard
			if all.size() < lo: return false
			for d in all:
				if not options.has(d) or all.count(d) > 1: return false
			return true
	return false

## Compact, replayable encoding of an answer (option indices instead of objects).
func encode(a):
	match kind:
		&"one": return options.find(a)
		&"many": return a.map(func(x): return options.find(x))
		&"assign": return [a.commit.map(func(x): return options.find(x)), a.discard.map(func(x): return options.find(x))]
	return a

func decode(e):
	match kind:
		&"one": return options[e]
		&"many": return e.map(func(i): return options[i])
		&"assign": return {"commit": e[0].map(func(i): return options[i]), "discard": e[1].map(func(i): return options[i])}
	return e

func _to_string() -> String: return "%s? (%s %s)" % [prompt, player, kind]
