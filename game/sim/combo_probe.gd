extends SceneTree
## Forced-hold probe: what is a card worth when its holder has it from round 1? Deals seat 0
## one card upright at game start and seats bots against it.
##   run.sh probe games=200 card=fire_05 me=adaptive|sapper opp=adaptive [verbose=1]
##   run.sh probe games=60 cards=fire_05,air_04,none out=res://sim/results/x.jsonl
## card=none deals nothing (the baseline). tools/probe_cards.py sweeps every card in
## parallel and writes ai/data/card_probe.json, which Valuer.power() uses as a ceiling.
## "sapper" plays Fingerless Sapper -> Powder Monkey the way a human would: farm F with
## Sapper (discard Potency on every F roll, park elementals in the discard pile, then
## undiscard all and go again), flip to Monkey once the F covers the remaining keys,
## then cash 5F per key.

class SapperBot extends AdaptiveBot:
	func _sapper(p: Player) -> Card:
		for c in p.cadre:
			if c.id == "fire_05": return c
		return null

	func choose_may(g: Game, c: Choice) -> bool:
		if c.source and c.source.card and c.source.card.id == "fire_05": return true
		return super.choose_may(g, c)

	## Commit Potency dice (still discardable for F) and keep elementals rolling; when the
	## elementals must be resolved, discard them so the undiscard brings them back.
	func choose_assign(g: Game, c: Choice) -> Dictionary:
		var s := _sapper(c.player)
		if s == null or s.inverted: return super.choose_assign(g, c)
		var out := {commit = [], discard = []}
		var elem := []
		for d in c.options:
			if d.kind == GK.Kind.POTENCY: out.commit.append(d)
			else: elem.append(d)
		if out.commit.size() < c.lo: out.discard = elem
		return out

	func choose_act(g: Game, c: Choice):
		var p := c.player
		for o in c.options:
			if o == null: continue
			if o.ability.card and o.ability.card.id == "fire_05":
				if o.id == &"key": return o
				if o.id == &"undiscard" and p.ready_dice().is_empty() and p.discarded().size() >= 4: return o
		var best = super.choose_act(g, c)
		if best and best.ability.card and best.ability.card.id == "fire_05" and best.id == &"blast": return null
		return best

	func choose_orient(g: Game, c: Choice) -> Array:
		var p := c.player
		var s := _sapper(p)
		var out: Array = super.choose_orient(g, c).filter(func(x): return x != s)
		if s and p.tokens.F >= 5 * maxi(1, g.win_keys() - p.keys) or (s and g.ending != ""): out.append(s)
		return out

	func choose_trim(g: Game, c: Choice):
		var s := _sapper(c.player)
		var opts := c.options.filter(func(x): return x != s)
		return _argmax(opts, func(card): return -valuer.card_value(g, c.player, card, false)) if opts else super.choose_trim(g, c)


func _initialize() -> void:
	var args := {games = 100, seed = 1, players = 4, me = "adaptive", opp = "adaptive", card = "fire_05", cards = "", out = "", verbose = 0}
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=", true, 1)
		if kv.size() == 2: args[kv[0]] = kv[1] if kv[0] in ["me", "opp", "card", "cards", "out"] else int(kv[1])
	var ids: Array = Array(args.cards.split(",")) if args.cards else [args.card]
	var out: FileAccess = null
	if args.out: out = FileAccess.open(args.out, FileAccess.WRITE)
	for id in ids:
		var r: Dictionary = await probe(id, args)
		if out:
			out.store_line(JSON.stringify(r))
			out.flush()
		else: report(r, args)
	quit()

func probe(id: String, args: Dictionary) -> Dictionary:
	var r := {card = id, me = args.me, games = args.games, wins = 0.0, keys = 0, card_keys = 0, reached = 0, reach_rounds = [],
		rounds = 0, tokens = {}, paid = {}, attached = {}}   # a dict: lambdas capture locals by value
	for i in args.games:
		var s: int = args.seed + i
		var bots := []
		bots.append(SapperBot.new([], s * 31) if args.me == "sapper" else Bots.make(args.me, s * 31))
		for k in range(1, args.players): bots.append(Bots.make(args.opp, s * 31 + k))
		var g := Game.new().setup(bots, s, {win_keys = 7})
		g.keep_log = false
		var me: Player = g.players[0]
		for c in g.deck:
			if c.id == id:
				g.deck.erase(c)
				await g.claim(me, c)
				c.inverted = false
				break
		var hit := [0]
		g.event.connect(func(ev):
			if ev.name == &"relinquish" and ev.target.holder() == me:
				r.attached[ev.card.title] = r.attached.get(ev.card.title, 0) + 1
			if ev.get("player") != me: return
			if ev.name == &"token_gained": r.tokens[ev.type] = r.tokens.get(ev.type, 0) + ev.amount
			elif ev.name == &"paid":
				var k := "%s %s" % [ev.src.title if ev.src else "engine", ev.cost]
				r.paid[k] = r.paid.get(k, 0) + 1
			elif ev.name == &"key_gained":
				if ev.src is Ability and ev.src.card and ev.src.card.id == id: r.card_keys += ev.amount
				if me.keys >= 7 and hit[0] == 0: hit[0] = g.round_no)
		await g.play()
		r.wins += 1.0 / g.winners.size() if g.winners.has(me) else 0.0
		r.keys += me.keys
		r.rounds += g.round_no
		if hit[0]:
			r.reached += 1
			r.reach_rounds.append(hit[0])
		g.dispose()
	r.reach_rounds.sort()
	return r

func report(r: Dictionary, args: Dictionary) -> void:
	var n := float(r.games)
	print("%s held by %s vs %s x%d, %d games" % [r.card, r.me, args.opp, args.players - 1, r.games])
	print("  win %.0f%% (even share %.0f%%)  keys/game %.2f (%.2f from this card)  game length %.1f rounds" % [100 * r.wins / n, 100.0 / args.players, r.keys / n, r.card_keys / n, r.rounds / n])
	print("  tokens gained/game: ", ", ".join(r.tokens.keys().map(func(t): return "%s %.1f" % [t, r.tokens[t] / n])))
	if r.reached: print("  reached 7 keys in %d%% of games, median round %d" % [100 * r.reached / int(n), r.reach_rounds[r.reach_rounds.size() / 2]])
	if args.verbose:
		print("  paid: ", r.paid)
		print("  attached to me: ", r.attached)
