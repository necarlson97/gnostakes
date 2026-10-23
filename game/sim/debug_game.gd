extends SceneTree
## What does each bot actually do? Plays N games and totals per-bot behaviour:
##   run.sh debug games=30 bots=adaptive,straights,random
## games=1 also prints the final state.

func _initialize() -> void:
	var args := {seed = 1, games = 1, bots = "adaptive,straights,random"}
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=", true, 1)
		if kv.size() == 2: args[kv[0]] = kv[1] if kv[0] == "bots" else int(kv[1])
	var names := Array(args.bots.split(","))
	var totals := {}
	for n in names: totals[n] = {}
	for i in args.games:
		var s: int = args.seed + i
		var bots := []
		for k in names.size(): bots.append(Bots.make(names[k], s * 31 + k))
		var g := Game.new().setup(bots, s)
		g.keep_log = false
		var seat := {}
		for k in g.players.size(): seat[g.players[k]] = names[k]
		g.event.connect(func(ev):
			var p = ev.get("player")
			if not p is Player: return
			var k: String = ev.name
			match ev.name:
				&"act": k = "act " + String(ev.id)
				&"key_gained": k = "key from " + (ev.src.title if ev.src else "?")
				&"claim", &"score_set", &"score_nothing", &"wager_won", &"tooth_lost", &"incinerate", &"spent": pass
				_: return
			var t: Dictionary = totals[seat[p]]
			t[k] = t.get(k, 0) + 1)
		await g.play()
		for p in g.players:
			var t: Dictionary = totals[seat[p]]
			t["=keys"] = t.get("=keys", 0) + p.keys
			t["=wins"] = t.get("=wins", 0.0) + (1.0 / g.winners.size() if g.winners.has(p) else 0.0)
		if args.games == 1:
			print(g.summary())
			print("ended: %s after %d rounds; winners %s" % [g.ending, g.round_no, g.winners])
		g.dispose()
	for n in names:
		var t: Dictionary = totals[n]
		var ks := t.keys()
		ks.sort_custom(func(a, b): return t[a] > t[b])
		print("%s  (per game)" % n)
		for k in ks.slice(0, 18): print("    %-34s %6.2f" % [k, t[k] / float(args.games)])
	quit()
