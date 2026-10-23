extends SceneTree
## Learn each card's power (expected keys it produces per time it's claimed) from sims,
## and write res://ai/data/card_power.json, which Valuer.power() reads.
##   run.sh learn games=400 bots=random,random,random
## Keys are credited to the card whose ability produced them (key_gained.src). Cards
## rarely claimed are shrunk toward the mean (empirical Bayes), so one lucky game
## doesn't make a card look broken.

const OUT := "res://ai/data/card_power.json"
const PRIOR_N := 8.0      # pseudo-claims pulling sparse cards toward the mean
const FLOOR := 0.1        # every card is worth something (churn, trims, denial)

func _initialize() -> void:
	var args := {seed = 5000, games = 300, bots = "random,random,random"}
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=", true, 1)
		if kv.size() == 2: args[kv[0]] = kv[1] if kv[0] == "bots" else int(kv[1])
	var names := Array(args.bots.split(","))
	var claims := {}
	var keys := {}
	for i in args.games:
		var s: int = args.seed + i
		var bots := []
		for k in names.size(): bots.append(Bots.make(names[(k + i) % names.size()], s * 31 + k))
		var g := Game.new().setup(bots, s)
		g.keep_log = false
		g.event.connect(func(ev):
			if ev.name == &"claim": claims[ev.card.id] = claims.get(ev.card.id, 0) + 1
			elif ev.name == &"key_gained" and ev.src is Ability and ev.src.card:
				keys[ev.src.card.id] = keys.get(ev.src.card.id, 0) + ev.amount)
		await g.play()
		g.dispose()
	var total_c := 0.0
	var total_k := 0.0
	for id in claims: total_c += claims[id]
	for id in keys: total_k += keys[id]
	var mean := total_k / maxf(1.0, total_c)
	var power := {}
	for r in CardDB.rows():
		var c: float = claims.get(r.id, 0)
		power[r.id] = snappedf(FLOOR + (keys.get(r.id, 0) + PRIOR_N * mean) / (c + PRIOR_N), 0.001)
	DirAccess.make_dir_recursive_absolute("res://ai/data")
	var f := FileAccess.open(OUT, FileAccess.WRITE)
	f.store_string(JSON.stringify(power, "\t", true))
	f.close()
	var ids := power.keys()
	ids.sort_custom(func(a, b): return power[a] > power[b])
	print("%d games, mean %.3f keys per claim; wrote %s" % [args.games, mean, OUT])
	print("top:    ", ids.slice(0, 10).map(func(id): return "%s %s %.2f" % [id, CardDB.row(id).name, power[id]]))
	print("bottom: ", ids.slice(-6).map(func(id): return "%s %s %.2f" % [id, CardDB.row(id).name, power[id]]))
	quit()
