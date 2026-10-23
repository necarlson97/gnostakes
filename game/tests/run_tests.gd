extends SceneTree
## Headless tests:
##   godot --headless --path game --script res://tests/run_tests.gd

var failures := 0
var checks := 0

## Answers choices with a script: `rules` maps Choice.tag (or kind) to an answer or a Callable(c) -> answer.
class Scripted extends Controller:
	var rules := {}
	func _init(r := {}) -> void: rules = r
	func decide(_g: Game, c: Choice):
		var r = rules.get(c.tag, rules.get(c.kind))
		if r == null: return Controller.default_answer(c)
		return r.call(c) if r is Callable else r

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

func ids(arr: Array) -> Array:
	var out := arr.map(func(s): return String(s.def.id))
	out.sort()
	return out

func has_arr(opts: Array, want: Array) -> bool:
	want.sort()
	return opts.any(func(a): return ids(a) == want)

## A 2-player game with a tiny deck, and `id` put straight into P1's cadre.
func game_with(cards: Array, ctrls := [Scripted.new(), Scripted.new()]) -> Game:
	var g := Game.new().setup(ctrls, 7, {}, ["earth_01", "earth_02", "earth_03", "earth_04", "earth_05", "earth_07", "earth_08", "earth_10"])
	for spec in cards:   # "id" or "id:inv", optional "@2" for player 2
		var parts: PackedStringArray = spec.split("@")
		var p := g.players[int(parts[1]) - 1 if parts.size() > 1 else 0]
		var c := CardDB.make(g, parts[0].trim_suffix(":inv"))
		await g.claim(p, c)
		c.inverted = parts[0].ends_with(":inv")
	return g

# --- scoring --------------------------------------------------------------------
func test_scoring_basic() -> void:
	var o := Scoring.arrangements([1, 2, 3, "E", "E", "W", "W"])
	check(has_arr(o, ["three_straight", "two_color_pairs"]), "straight + color pairs")
	check(Scoring.arrangements([1, 1, 5, "E"]) == [[]], "nothing scores")
	o = Scoring.arrangements([5, 5, 5, 5])
	check(has_arr(o, ["quadruplet"]) and has_arr(o, ["triplet"]), "quad, or triplet (both maximal)")
	o = Scoring.arrangements([1, 2, 3, 4, 5, "E", "W", "F", "A"])
	check(has_arr(o, ["five_straight", "all_colors"]), "five straight + all colors")
	check(not has_arr(o, ["three_straight"]), "non-maximal arrangement excluded")
	check(has_arr(Scoring.arrangements(["A", "A", "Q", "A"]), ["four_air"]), "Q is wild")
	check(has_arr(Scoring.arrangements([2, 2, 4, 4, "E", "E", "W", "W"]), ["four_pairs"]), "four pairs")

func test_scoring_rules() -> void:
	check(Scoring.arrangements([1, 2, 4]) == [[]], "gap not a straight by default")
	check(has_arr(Scoring.arrangements([1, 2, 4], {straight_gap = 1}), ["three_straight"]), "Binger gap")
	check(has_arr(Scoring.arrangements([3, 3, 3], {triplet_as_quad = true}), ["quadruplet"]), "Hard-Tack triplet as quad")
	check(has_arr(Scoring.arrangements(["F", "F", "F", "F"], {fire_as_air = true}), ["four_air"]), "fire as air")
	check(Scoring.arrangements([1, 2, 3], {banned = [&"three_straight"]}) == [[]], "banned set")

# --- hooks ----------------------------------------------------------------------
func test_trigger_additional_does_not_loop() -> void:
	var g := await game_with(["major_00", "earth_01", "earth_02"])   # Hollowhead + 2 others
	await g.gain_keys(g.players[0], 1)
	check(g.players[0].keys == 2, "Hollowhead adds exactly one additional key (got %d)" % g.players[0].keys)

func test_static_bonus_die_and_commit_min() -> void:
	var g := await game_with(["major_09", "major_03"])   # Pillar-top Hermit, Gargoyle Mother
	var p := g.players[0]
	check(g.query(&"commit_min", p, 5) == 4, "Gargoyle commit min 4")
	check(g.query(&"bonus_dice", p, []).size() == 1, "Hermit bonus die")
	await g.gain(p, {E = 3})
	check(p.tokens.E == 2, "Hermit gains 1 less")

func test_replacement_stoic() -> void:
	var g := await game_with(["major_08:inv"])
	var p := g.players[0]
	await g.lose_teeth(p, 2)
	check(p.teeth == 8 and p.cadre[0].buried_n("tooth") == 2, "two teeth buried on Stoic")
	await g.lose_teeth(p, 1)
	check(p.cadre.is_empty() and g.pyre.size() == 1, "third tooth burns Stoic")

func test_cost_replacement_strawman() -> void:
	var g := await game_with(["fire_prince", "water_03:inv"])   # Strawman + Dependable Tosspot
	var p := g.players[0]
	p.tokens.A = 1
	var acts := g.legal_acts(p, &"scheme")
	check(acts.size() == 1, "Tosspot key act is legal through Strawman (no W needed)")
	await g.use_act(p, acts[0].ability, acts[0].id)
	check(p.keys == 1 and p.tokens.A == 0 and p.cadre.size() == 2, "paid 1A instead of 2W+burn")

func test_relinquish_and_cascade() -> void:
	var g := await game_with(["water_queen:inv", "earth_01@2"])   # Tarred Prophet; P2 holds Pomologist
	var me := g.players[0]
	var them := g.players[1]
	var prophet: Card = me.cadre[0]
	await g.use_act(me, prophet.ability, &"relinquish")
	check(prophet.loc == GK.Loc.ATTACHED and prophet.holder() == them, "attached to P2's card")
	await g.gain_keys(them, 1)
	check(me.keys == 1, "Prophet mirrors P2's key")
	await g.incinerate(them.cadre[0], them)
	check(prophet.loc == GK.Loc.PYRE and g.attached.is_empty(), "attachment burns with its card")

func test_failed_exorcist_copies_left() -> void:
	var g := await game_with(["fire_02", "air_king:inv"])   # Branded Protégé, then Failed Exorcist
	var p := g.players[0]
	await g.discard(p, p.dice[0])
	check(p.tokens.F == 2, "Protégé + its copy each gain 1F on discard (got %d)" % p.tokens.F)

func test_purger_steals_claim() -> void:
	var yes := Scripted.new({&"may": true})
	var g := await game_with(["major_14:inv"], [yes, Scripted.new()])
	var target: Card = g.square[0]
	await g.claim(g.players[1], target)
	check(g.players[0].cadre.has(target) and g.players[0].teeth == 9, "Purger takes the claim for a tooth")

func test_async_controller_suspends_and_resumes() -> void:
	var gui := Controller.Async.new()
	var g := Game.new().setup([gui, RandomBot.new(1)], 5)
	g.play()   # not awaited: returns at the first human decision
	check(not g.over() and gui.pending != null, "engine suspends awaiting the GUI")
	var n := 0
	while not g.over() and n < 20000:
		gui.submit(Controller.default_answer(gui.pending))
		n += 1
	check(g.over(), "game completes through submit() (%d answers)" % n)

# --- rulings (2026-10-22) -------------------------------------------------------
func test_first_player_rotates() -> void:
	var g := await game_with([])
	g.round_no = 1
	check(g.seats()[0] == g.players[0], "P1 first in round 1")
	g.round_no = 2
	check(g.seats()[0] == g.players[1], "P2 first in round 2")

func test_slot_token_request() -> void:
	var p1 := Scripted.new({&"request": func(c): return c.options.filter(func(o): return o and o.slot == 0).front()})
	var g := await game_with([], [p1, Scripted.new()])
	g.players[0].tokens.W = 3
	var target: Card = g.square[0]
	await g.requests()
	check(g.players[0].cadre.has(target) and g.players[0].tokens.W == 0, "slot 1 bought with 3W")

func test_wager_spends_exact_bid() -> void:
	var g := await game_with([], [Scripted.new({&"wager": {E = 3}}), Scripted.new({&"wager": {E = 1}})])
	for p in g.players: p.tokens.E = 5
	var w := await g.wager(g.players, g.square[0])
	check(w == g.players[0] and g.players[0].tokens.E == 2 and g.players[1].tokens.E == 5, "winner spends exactly their wager, loser keeps theirs")

func test_cost_teeth_can_be_replaced() -> void:
	var g := await game_with(["major_15", "earth_09"], [Scripted.new({&"either": func(c): return c.options[1]}), Scripted.new()])
	var p := g.players[0]
	p.tokens.Q = 2
	p.tokens.E = 5
	g.pyre.append(CardDB.make(g, "earth_10"))
	await g.use_act(p, p.cadre[0].ability, &"resurrect")
	check(p.teeth == 10 and p.tokens.E == 0 and p.cadre.size() == 3, "Oathbreaker pays 5E instead of Pact Proctor's tooth")

func test_god_struck_needs_potency() -> void:
	var g := await game_with(["major_00:inv"])
	await g.announce_scored(g.players[0], [])
	check(g.players[0].cadre.is_empty(), "God-Struck Fool burns when no Potency die scored")

func test_prismist_all_dice() -> void:
	var g := await game_with(["air_01:inv"])
	var p := g.players[0]
	p.swig_dice.assign(p.dice)
	for d in p.dice:
		d.up = d.index_of(6) if d.kind == GK.Kind.POTENCY else d.index_of("A")
		d.zone = GK.Zone.COMMITTED
	await g.announce_scored(p, [])
	check(g.over() and g.winners == [p], "Prismist wins when every die is committed and shows A or 6")

func test_grinner_turns_or_into_and() -> void:
	var g := await game_with(["major_13", "earth_princess"], [Scripted.new({&"may": true}), Scripted.new()])
	var p := g.players[0]
	p.tokens.Q = 2
	await g.emit(&"score_set", {player = p, def = Scoring.get_def(&"triplet"), id = &"triplet", dice = [], color = ""})
	check(p.tokens.E == 2 and p.tokens.Q == 0, "Sower gives both options for 2Q")

## Oathbreaker + Strawman: preventing a tooth costs 2 teeth (Strawman), which Oathbreaker
## must not prevent again (no self-replacement), or the game loops forever.
func test_replacement_cannot_replace_itself() -> void:
	var g := await game_with(["earth_09", "fire_prince"], [Scripted.new({&"either": func(c): return c.options[1]}), Scripted.new()])
	var p := g.players[0]
	await g.lose_teeth(p, 1)
	check(p.teeth == 8 and not g.over(), "one prevented tooth cost 2 teeth via Strawman, then stopped (teeth %d)" % p.teeth)

## Rules 2026-10-22: players with no teeth die; most keys among the living wins.
func test_dead_players_cannot_win() -> void:
	var g := await game_with([])
	g.players[0].keys = 7
	g.players[0].teeth = 0
	g.players[1].keys = 2
	g.finish(&"putrescence")
	check(g.winners == [g.players[1]], "the living player wins despite fewer keys")
	var h := await game_with([])
	for p in h.players: p.teeth = 0
	h.finish(&"putrescence")
	check(h.winners.is_empty(), "nobody wins if everyone is dead")

func test_teeth_floor_at_zero() -> void:
	var g := await game_with([])
	var p := g.players[0]
	await g.lose_teeth(p, 15)
	check(p.teeth == 0, "teeth stop at 0 (got %d)" % p.teeth)
	await g.gain_teeth(p, 1)
	check(p.teeth == 1, "a dead player can regain a tooth before the end")

func test_every_face_implemented() -> void:
	var g := Game.new()
	var missing := []
	for r in CardDB.rows():
		for ab in CardDB.make(g, r.id).faces:
			if not ab.implemented: missing.append(ab.title)
	check(missing.is_empty(), "all 156 faces scripted; missing %s" % [missing])

# --- whole games ----------------------------------------------------------------
func test_full_games_complete_and_replay() -> void:
	for s in [1, 2, 3]:
		var g := Game.new().setup([RandomBot.new(s), RandomBot.new(s + 100), RandomBot.new(s + 200)], s)
		g.keep_log = false
		await g.play()
		check(g.over() and g.winners.size() >= 1, "seed %d finished (%s)" % [s, g.ending])
		var shared := g.answers.map(func(a): return a[1])
		var r := Controller.Replay.new(shared)
		var h := Game.new().setup([r, r, r], s)
		h.keep_log = false
		await h.play()
		check(h.round_no == g.round_no and h.players.map(func(p): return p.keys) == g.players.map(func(p): return p.keys), "seed %d replays identically" % s)
