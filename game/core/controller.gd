class_name Controller extends RefCounted
## Answers Choices for one seat. Bots answer immediately (no suspension, so headless
## sims run as plain synchronous loops); a GUI controller awaits player input.

func decide(_g: Game, c: Choice):
	return default_answer(c)

## A safe, legal answer: decline optional things, do the minimum.
static func default_answer(c: Choice):
	match c.kind:
		&"yes_no": return false
		&"one": return null if c.options.has(null) else c.options[0]
		&"many": return c.options.slice(0, c.lo)
		&"number": return c.lo
		&"tokens": return {}
		&"assign": return {"commit": c.options.slice(0, c.lo), "discard": []}
	return null


## Waits for the UI: listen to `asked`, show c, then call submit(answer).
class Async extends Controller:
	signal asked(c: Choice)
	signal _answered(a)
	var pending: Choice

	func decide(_g: Game, c: Choice):
		pending = c
		asked.emit(c)
		var a = await _answered
		pending = null
		return a

	func submit(a) -> void:
		if pending and pending.valid(a): _answered.emit(a)
		else: push_warning("invalid answer %s for %s" % [a, pending])


## Replays recorded answers (Game.answers) for deterministic reproduction.
class Replay extends Controller:
	var queue: Array
	func _init(q: Array) -> void: queue = q
	func decide(_g: Game, c: Choice):
		return c.decode(queue.pop_front()) if queue else default_answer(c)
