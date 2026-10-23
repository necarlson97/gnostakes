class_name Bots
## Bot factory by name:
##   "random" | "adaptive" | "<strategy>" | "<strategy>+<strategy>" (a fixed blend)
## plus optional Valuer knobs after "@", separated by "/":
##   "adaptive@drain=0.25/last=2"   (knobs: tooth, last, urgency, drain; see Valuer.KNOBS)
## e.g. Bots.make("straights", 7). The full spec string is the bot's name in league tables.

static func make(spec: String, seed_ := 0) -> Controller:
	var parts := spec.split("@")
	var base := parts[0]
	var b: Controller
	match base:
		"random": b = RandomBot.new(seed_)
		"adaptive": b = AdaptiveBot.new([], seed_)
		_:
			var ss := Array(base.split("+")).map(func(n): return Strategy.named(n))
			assert(not ss.has(null), "unknown strategy in " + spec)
			b = Bot.new(ss, seed_)
	if parts.size() > 1 and b is Bot:
		for kv in parts[1].split("/"):
			var pair := kv.split("=")
			assert(pair.size() == 2 and Valuer.KNOBS.has(pair[0]), "bad knob in " + spec)
			b.valuer.set(Valuer.KNOBS[pair[0]], float(pair[1]))
		b.label = spec
	return b

static func names() -> Array:
	return ["random", "adaptive"] + Strategy.all().map(func(s): return s.name)
