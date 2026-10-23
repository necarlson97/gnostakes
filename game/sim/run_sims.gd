extends SceneTree
## Batch simulation:
##   run.sh sim games=200 players=3 seed=1
##   run.sh sim games=300 bots=adaptive,straights,random      (league: named bots per seat)
##   run.sh sim games=150 players=4 fuzz=1                    (engine fuzz + hook coverage)
## bots=  comma list of Bots.make() names; one per seat, rotated each game so seat order
##        doesn't bias results. Default: random bots.
## pool=  comma list (or "all") to sample `players` distinct bots from for each game.
## out=   path to append one JSON line per game (seats, keys, winners, claims, key sources);
##        tools/league.py runs many processes with this and merges the results.
## fuzz=1 deals every player 4 random villagers in random orientations, makes random bots
##        trigger-happy, and reports which card hooks never ran.
## verbose=1 prints each final state; verbose=2 also prints each seed before it plays.
## Any GK.DEFAULTS key overrides that rule for every game, e.g. win_keys=7 commit_min=4.

func _initialize() -> void:
	var args := {games = 100, players = 3, seed = 1, verbose = 0, fuzz = 0, bots = "", pool = "", out = ""}
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=", true, 1)
		if kv.size() == 2: args[kv[0]] = kv[1] if kv[0] in ["bots", "pool", "out"] else int(kv[1])
	var rules := {}   # rule overrides (GK.DEFAULTS keys other than players)
	for k in args:
		if GK.DEFAULTS.has(k) and k != "players": rules[k] = args[k]
	var specs: Array = Array(args.bots.split(",")) if args.bots else []
	if specs: args.players = specs.size()
	var pool: Array = Bots.names() if args.pool == "all" else (Array(args.pool.split(",")) if args.pool else [])
	var pick := RandomNumberGenerator.new()
	pick.seed = args.seed
	var out_file: FileAccess = null
	if args.out:
		out_file = FileAccess.open(args.out, FileAccess.READ_WRITE if FileAccess.file_exists(args.out) else FileAccess.WRITE)
		out_file.seek_end()
	var trace := {}
	var reasons := {}
	var rounds := []
	var keys := []
	var events := {}
	var table := {}    # bot name -> {games, wins, keys, final_strategy -> count}
	var t0 := Time.get_ticks_msec()
	for i in args.games:
		var s: int = args.seed + i
		var names := []
		if pool:
			var shuffled := pool.duplicate()
			for j in range(shuffled.size() - 1, 0, -1):
				var r := pick.randi_range(0, j)
				var t = shuffled[j]; shuffled[j] = shuffled[r]; shuffled[r] = t
			names = shuffled.slice(0, args.players)
		else:
			for k in args.players: names.append(specs[(k + i) % specs.size()] if specs else "random")
		var bots := []
		for k in names.size():
			var b: Controller = Bots.make(names[k], s * 31 + k)
			if args.fuzz and b is RandomBot and not b is Bot:
				b.act_rate = 0.8
				b.yes_rate = 0.7
			bots.append(b)
		var g := Game.new().setup(bots, s, rules)
		g.keep_log = false
		if args.fuzz:
			g.trace = trace
			for p in g.players:
				for _j in 4:
					var c: Card = g.deck.pop_back()
					await g.claim(p, c)
					c.inverted = g.rng.randf() < 0.5
				for t in GK.TOKENS: p.tokens[t] = g.rng.randi_range(0, 6)
		var claims := {}      # player -> [card ids]
		var key_src := {}     # player -> {card id: keys}
		var tok := {}         # player -> {gain, spent, peak, peak_total, src {card: {t: n}}, paid {card: {cost: n}}}
		for pl in g.players: tok[pl] = {gain = {}, spent = {}, peak = {}, peak_total = 0, src = {}, paid = {}, tooth_lost = {}, tooth_gained = {}}
		# "<id>" or "<id>:inv": which face did it (an Exorcist copy counts as its own card)
		var face_id := func(src) -> String:
			if not (src is Ability and src.card): return "engine"
			return src.card.id + (":inv" if src.card.faces.size() > 1 and src.card.faces[1] == src else "")
		g.event.connect(func(ev):
			events[ev.name] = events.get(ev.name, 0) + 1
			var pl = ev.get("player")
			if ev.name == &"claim":
				if not claims.has(pl): claims[pl] = []
				claims[pl].append(ev.card.id)
			elif ev.name == &"key_gained" and ev.src is Ability and ev.src.card:
				if not key_src.has(pl): key_src[pl] = {}
				key_src[pl][ev.src.card.id] = key_src[pl].get(ev.src.card.id, 0) + ev.amount
			elif ev.name == &"token_gained":
				var t: Dictionary = tok[pl]
				t.gain[ev.type] = t.gain.get(ev.type, 0) + ev.amount
				var cid: String = face_id.call(ev.src)
				if not t.src.has(cid): t.src[cid] = {}
				t.src[cid][ev.type] = t.src[cid].get(ev.type, 0) + ev.amount
				t.peak_total = maxi(t.peak_total, pl.token_total())
				t.peak[ev.type] = maxi(t.peak.get(ev.type, 0), pl.tokens[ev.type])
			elif ev.name == &"tooth_lost" or ev.name == &"tooth_gained":
				var bucket: Dictionary = tok[pl][String(ev.name)]
				var cid: String = face_id.call(ev.src)
				bucket[cid] = bucket.get(cid, 0) + ev.get("amount", 1)
			elif ev.name == &"spent":
				var t: Dictionary = tok[pl]
				for k in ev.tokens: t.spent[k] = t.spent.get(k, 0) + ev.tokens[k]
			elif ev.name == &"paid" and ev.src is Ability and ev.src.card:
				var paid: Dictionary = tok[pl].paid
				var cid: String = ev.src.card.id
				var ck := ",".join(ev.cost.keys().map(func(k): return "%s=%s" % [k, ev.cost[k]]))
				if not paid.has(cid): paid[cid] = {}
				paid[cid][ck] = paid[cid].get(ck, 0) + 1)
		if args.verbose > 1: printerr("seed %d bots=%s" % [s, ",".join(names)])
		await g.play()
		reasons[g.ending] = reasons.get(g.ending, 0) + 1
		rounds.append(g.round_no)
		for k in g.players.size():
			var p := g.players[k]
			keys.append(p.keys)
			var row: Dictionary = table.get(names[k], {games = 0, wins = 0.0, keys = 0, final = {}})
			row.games += 1
			row.keys += p.keys
			if g.winners.has(p): row.wins += 1.0 / g.winners.size()   # ties split the win
			if bots[k] is Bot:
				var ms: String = bots[k].main_strategy().name
				row.final[ms] = row.final.get(ms, 0) + 1
			table[names[k]] = row
		if out_file:
			var seats := []
			for k in g.players.size():
				var p := g.players[k]
				seats.append({bot = names[k], keys = p.keys, teeth = p.teeth, win = (1.0 / g.winners.size()) if g.winners.has(p) else 0.0,
					strategy = bots[k].main_strategy().name if bots[k] is Bot else "", claims = claims.get(p, []), key_src = key_src.get(p, {}),
					tok_gain = tok[p].gain, tok_spent = tok[p].spent, tok_peak = tok[p].peak, tok_peak_total = tok[p].peak_total,
					tok_src = tok[p].src, paid = tok[p].paid, tooth_lost = tok[p].tooth_lost, tooth_gained = tok[p].tooth_gained})
			out_file.store_line(JSON.stringify({seed = s, rounds = g.round_no, ending = g.ending, rules = rules, seats = seats}))
		if args.verbose: print(g.summary())
		g.dispose()
	var ms := Time.get_ticks_msec() - t0
	print("%d games x %d players in %d ms (%.1f ms/game)" % [args.games, args.players, ms, ms / float(args.games)])
	print("end reasons: ", reasons)
	print("rounds: mean %.1f  min %d  max %d" % [_mean(rounds), rounds.min(), rounds.max()])
	print("final keys: mean %.2f  max %d" % [_mean(keys), keys.max()])
	if specs:
		print("\n%-12s %6s %8s %9s  %s" % ["bot", "games", "win %", "keys/g", "main strategy at game end"])
		var order := table.keys()
		order.sort_custom(func(a, b): return table[a].wins / table[a].games > table[b].wins / table[b].games)
		for n in order:
			var r: Dictionary = table[n]
			print("%-12s %6d %7.1f%% %9.2f  %s" % [n, r.games, 100.0 * r.wins / r.games, r.keys / float(r.games), r.final if n == "adaptive" else ""])
	if args.verbose or args.fuzz:
		var ev := events.keys()
		ev.sort_custom(func(a, b): return events[a] > events[b])
		print("events per game:")
		for e in ev: print("  %-16s %8.1f" % [e, events[e] / float(args.games)])
	if args.fuzz: _coverage(trace)
	if out_file: out_file.close()
	quit()

## Every hook/act method defined on a card face, and whether the fuzz run ever called it.
func _coverage(trace: Dictionary) -> void:
	var g := Game.new()
	var never := []
	var total := 0
	var base := {}
	for m in Ability.new().get_method_list(): base[m.name] = true
	for r in CardDB.rows():
		var c := CardDB.make(g, r.id)
		for ab in c.faces:
			for m in ab.get_script().get_script_method_list():
				var n: String = m.name
				var hook := n.begins_with("on_") or n.begins_with("mod_") or n.begins_with("replace_") or n.begins_with("act_")
				if not hook or base.has(n): continue
				total += 1
				if not trace.has("%s.%s" % [ab.title, n]): never.append("%s.%s" % [ab.title, n])
	print("hook coverage: %d / %d methods ran" % [total - never.size(), total])
	if never: print("never ran:\n  " + "\n  ".join(never))

func _mean(a: Array) -> float: return a.reduce(func(x, y): return x + y, 0) / float(a.size())
