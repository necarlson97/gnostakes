extends SceneTree
## AI-layer tests:   run.sh tests ai

var failures := 0
var checks := 0

func _initialize() -> void:
	for m in get_method_list():
		if m.name.begins_with("test_"):
			var before := failures
			await call(m.name)
			print("%s %s" % ["ok  " if failures == before else "FAIL", m.name])
	print("\n%d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)

func check(cond: bool, what: String) -> void:
	checks += 1
	if not cond:
		failures += 1
		print("    expected: ", what)

func card(g: Game, id: String) -> Card: return CardDB.make(g, id)

func test_features_are_signed() -> void:
	var g := Game.new()
	var oath: Dictionary = card(g, "earth_09").info.features.inv           # Oathkeeper
	check(oath.get("kind", 0) > 0 and oath.get("straight", 0) < 0, "Oathkeeper: pro-kind, anti-straight %s" % oath)
	var hairshirt: Dictionary = card(g, "water_08").info.features.top      # Hairshirt Bearer
	check(hairshirt.get("straight", 0) > 0, "Hairshirt Bearer is pro-straight")
	var baker: Dictionary = card(g, "earth_06").info.features.inv          # Hard-Tack Baker
	check(baker.get("straight", 0) < 0 and baker.get("kind", 0) > 0, "Hard-Tack Baker: kinds yes, straights no")

func test_strategy_fit() -> void:
	var g := Game.new()
	var straights := Strategy.named("straights")
	var kinds := Strategy.named("kinds")
	var binger := card(g, "major_14")
	check(straights.fit_card(binger) > 0.2, "Binger fits straights")
	check(kinds.fit_face(card(g, "earth_09").info.features.inv) > straights.fit_face(card(g, "earth_09").info.features.inv), "Oathkeeper fits kinds better than straights")

func test_offer_pricing() -> void:
	var g := Game.new().setup([Bot.new(), Bot.new()], 3)
	var b: Bot = g.controllers[0]
	var p := g.players[0]
	check(b.valuer.offer_value(g, p, {cost = {W = 2}, gain = {keys = 1}}) > 0, "2W for a key is worth it")
	check(b.valuer.offer_value(g, p, {cost = {teeth = 3}, gain = {W = 1}}) < 0, "3 teeth for 1W is not")
	p.tokens.W = 40
	b.valuer.begin()   # new decision, new prices
	check(b.valuer.token_price(g, p, "W") < Valuer.TOKEN, "hoarded tokens are cheaper")

func test_last_tooth_is_precious() -> void:
	var g := Game.new().setup([Bot.new(), Bot.new()], 3)
	var b: Bot = g.controllers[0]
	var p := g.players[0]
	var comfy := b.valuer.teeth_loss(g, p, 1)
	p.teeth = 1
	b.valuer.begin()
	check(b.valuer.teeth_loss(g, p, 1) >= 3.0 and comfy < 0.5, "last tooth %.2f vs comfortable %.2f" % [b.valuer.teeth_loss(g, p, 1), comfy])
	check(b.valuer.offer_value(g, p, {cost = {teeth = 1}, gain = {keys = 1}}) < 0, "won't die for a key")
	p.teeth = 0
	b.valuer.begin()
	check(b.valuer.offer_value(g, p, {cost = {E = 8}, gain = {teeth = 1}}) > 0, "will pay a lot to come back to life")
	p.teeth = 10
	b.valuer.begin()
	check(b.valuer.offer_value(g, p, {cost = {teeth = 2}, gain = {keys = 1}}) > 0, "2 of 10 teeth for a key is fine")

## Fleabitten Penitent (water_08 inverted) drains a tooth most rounds: fine at 10 teeth for
## a straights bot, but it must flip the card upright when its teeth run low.
func test_flips_tooth_drain_when_low() -> void:
	var g := Game.new().setup([Bot.new([Strategy.named("straights")]), Bot.new()], 3)
	var b: Bot = g.controllers[0]
	var p := g.players[0]
	var c := card(g, "water_08")
	await g.claim(p, c)
	p.teeth = 2
	var o: Array = b.decide(g, Choice.new(p, &"many", "", [c], 0, 1, null, &"orient"))
	check(not o.has(c), "at 2 teeth, keeps Fleabitten Penitent face-down (upright Hairshirt)")

func test_engine_builds_then_flips() -> void:
	var g := Game.new().setup([AdaptiveBot.new(), Bot.new()], 3)
	var b: Bot = g.controllers[0]
	var p := g.players[0]
	var c := card(g, "fire_05")   # Fingerless Sapper / Powder Monkey (5F: key)
	await g.claim(p, c)
	var orient := func() -> bool:
		b.valuer.begin()
		return b.decide(g, Choice.new(p, &"many", "", [c], 0, 1, null, &"orient")).has(c)
	check(not orient.call(), "with no F, keeps Fingerless Sapper up to farm")
	check(b.valuer.token_price(g, p, "F") > Valuer.TOKEN, "Powder Monkey on the face that's down still prices F")
	p.tokens.F = 5 * Valuer.ENGINE_BATCH
	check(orient.call(), "with a batch of F, turns to Powder Monkey to cash in")
	c.inverted = true
	b.valuer.begin()
	var blast = b.decide(g, Choice.new(p, &"pick", "", [null] + g.legal_acts(p, &"scheme"), 0, 1, null, &"act"))
	check(blast != null and blast.id == &"key", "cashes F for keys instead of burning Monkey (got %s)" % [blast.id if blast else null])
	p.tokens.F = 2
	check(not orient.call(), "after cashing in, turns back to Sapper")

func test_no_keys_while_locked() -> void:
	var g := Game.new().setup([Bot.new(), Bot.new()], 3)
	var b: Bot = g.controllers[0]
	var p := g.players[0]
	var mine := card(g, "fire_03")
	await g.claim(p, mine)
	var archon := card(g, "major_01")   # Lockpicking Archon, attached by the opponent
	await g.claim(g.players[1], archon)
	archon.inverted = true
	await g.relinquish(archon, mine)
	b.valuer.begin()
	check(b.valuer.offer_value(g, p, {cost = {F = 2}, gain = {keys = 1}}) < 0, "won't pay for a key it can't gain")

func test_adaptive_commits() -> void:
	var g := Game.new().setup([AdaptiveBot.new(), Bot.new()], 3)
	var b: AdaptiveBot = g.controllers[0]
	var p := g.players[0]
	var flat := b.weights([])
	for id in ["major_14", "water_08", "water_07"]:   # Binger, Hairshirt Bearer, Absinthard: straights
		await g.claim(p, card(g, id))
	var after := b.weights(p.cadre)
	var s := Strategy.named("straights")
	check(after[s] > flat[s] * 2, "straight cards pull the mix toward straights (%.2f -> %.2f)" % [flat[s], after[s]])

func test_assign_keeps_a_triplet() -> void:
	var g := Game.new().setup([Bot.new([Strategy.named("kinds")]), Bot.new()], 3)
	var p := g.players[0]
	p.swig_dice.assign(p.dice)
	var faces := [4, 4, 4, 1, 6]
	for i in 5: p.dice[i].up = p.dice[i].index_of(faces[i])
	var c := Choice.new(p, &"assign", "", p.dice.slice(0, 5), 2, 5, null, &"assign")
	var a: Dictionary = g.controllers[0].decide(g, c)
	var kept: Array = a.commit.map(func(d): return d.face())
	check(kept.count(4) == 3, "commits the three 4s (kept %s)" % [kept])

## Roll 1,2,3,4,6 + E,E,W,F,A chasing Five Straight: keep 1-2-3-4, reroll the 6.
func test_solver_chases_five_straight() -> void:
	var g := Game.new().setup([Controller.new(), Controller.new()], 3)
	var p := g.players[0]
	p.swig_dice.assign(p.dice)
	var faces := [1, 2, 3, 4, 6, "E", "E", "W", "F", "A"]
	for i in 10:
		p.dice[i].zone = GK.Zone.READY
		p.dice[i].up = p.dice[i].index_of(faces[i])
	var s := DiceSolver.new(g, p, func(arr): return 1.0 if arr.any(func(x): return x.def.id == &"five_straight") else 0.0)
	var a := s.decide(p.dice, 5)
	var kept: Array = a.commit.map(func(d): return d.face())
	check([1, 2, 3, 4].all(func(f): return kept.has(f)) and not kept.has(6), "keeps 1-4, rerolls the 6 (kept %s)" % [kept])
	# The exact chance from here: keep 1-4 and reroll one die needing a 5 = 1/6.
	var v := s.state_value([[1, 2, 3, 4], ["E", "E", "W", "F", "A"]], [p.dice[4]])
	check(absf(v - 1.0 / 6.0) < 1e-6, "P(5 on one reroll) = 1/6 (got %.4f)" % v)

func test_solver_final_roll_skips_punished_set() -> void:
	var g := Game.new().setup([Controller.new(), Controller.new()], 3)
	var p := g.players[0]
	p.swig_dice.assign(p.dice)
	for i in 3:
		p.dice[i].zone = GK.Zone.READY
		p.dice[i].up = p.dice[i].index_of([2, 3, 4][i])
	# a value function that punishes straights (like owning Oathkeeper)
	var s := DiceSolver.new(g, p, func(arr): return -1.0 if arr.any(func(x): return Scoring.is_straight(x.def.id)) else 0.0)
	var a := s.decide(p.dice.slice(0, 3), 3)
	check(a.discard.size() >= 1, "final roll: discards a die rather than score the punished straight")

func test_strategies_generated() -> void:
	var all := Strategy.all()
	check(all.size() >= 27, "%d strategies loaded" % all.size())
	var g := Game.new()
	var cards := CardDB.rows().map(func(r): return CardDB.make(g, r.id))
	for s in all:
		var support := cards.filter(func(c): return s.fit_card(c) > 0.2).size()
		check(support >= 5, "%s is supported by %d cards" % [s.name, support])
	check(Bots.make("earth_water", 1) is Bot and Bots.make("adaptive", 1) is AdaptiveBot, "factory builds token-pair and adaptive bots")

func test_bot_knobs() -> void:
	var b: Bot = Bots.make("adaptive@drain=0.25/last=2", 1)
	check(b.valuer.tooth_drain == 0.25 and b.valuer.last_tooth == 2.0 and b.label == "adaptive@drain=0.25/last=2", "knobs parsed onto the valuer")
	check(Bots.make("adaptive", 1).valuer.tooth_drain == Valuer.TOOTH_DRAIN, "defaults untouched")

func test_bot_games_answer_validly() -> void:
	for spec in [["adaptive", "straights", "random"], ["colors", "burner", "saboteur", "tooth_miser"]]:
		var bots := []
		for i in spec.size(): bots.append(Bots.make(spec[i], 10 + i))
		var g := Game.new().setup(bots, 11)
		g.keep_log = false
		await g.play()
		check(g.over(), "%s finished" % [spec])
		check(g.invalid_answers == 0, "%s gave %d invalid answers" % [spec, g.invalid_answers])
		g.dispose()

## Winning a wager for a slot you're buying with tokens must not overdraw you (Q < 0).
func test_tokens_never_negative() -> void:
	var neg := []
	for i in 12:
		var bots := []
		for j in 4: bots.append(Bots.make("adaptive", i * 10 + j + 1))
		var g := Game.new().setup(bots, i + 1)
		g.keep_log = false
		g.event.connect(func(ev):
			for p in g.players:
				for t in p.tokens:
					if p.tokens[t] < 0 and neg.size() < 3: neg.append("seed %d: %s %s=%d after %s" % [i + 1, p, t, p.tokens[t], ev.name]))
		await g.play()
		g.dispose()
	check(neg.is_empty(), "no negative tokens (%s)" % [neg])
