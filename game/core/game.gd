class_name Game extends RefCounted
## Headless Gnostakes engine. It holds all game state and runs the rules.
##
## Flow: `await play()` runs whole rounds (Swig -> Scry -> Scheme) until the game ends.
## Whenever a player must decide something, the engine awaits that seat's Controller.
## Bots answer immediately, so a headless simulation never actually suspends. A GUI
## controller suspends the coroutine until the player clicks.
##
## Card abilities plug in through four channels (see Ability):
##   emit(event)            triggered abilities   "On rolling an F...", "Whenever you..."
##   query(name, p, value)  static modifiers      "While this is active, ..."
##   replace(event)         replacement effects   "Whenever you would lose a tooth, instead..."
##   acts() + action windows  activated abilities "Spend 2E to gain 1 key..."
## Every state change also goes to `log` and the `event` signal, so a GUI can animate it.

signal event(ev: Dictionary)
signal asking(c: Choice)

var cfg := GK.DEFAULTS.duplicate()
var rng := RandomNumberGenerator.new()
var seed_used: int
var players: Array[Player] = []
var controllers: Array = []
var deck: Array[Card] = []          # back = top
var square: Array = []              # Card or null per slot; slot 0 is leftmost
var pyre: Array[Card] = []          # back = most recently incinerated
var attached: Array[Card] = []      # relinquished cards attached to other cards
var phase := GK.Phase.SETUP
var round_no := 0
var roll_no := 0                    # global roll counter (for "once per roll")
var scry_no := 0
var ending := ""                    # end condition met; game ends after this Scheme
var winners: Array[Player] = []
var log: Array = []                 # every emitted event (Dictionary)
var answers: Array = []             # [seat, encoded answer] for replay
var invalid_answers := 0            # controller answers that failed validation (should stay 0)
var keep_log := true
## Optional face generator for physical dice (the 3D GUI). Called as
## `await roller.call(game, player, dice)` and must set `d.up` on every die. Unset, the
## engine rolls with `rng`, so headless sims and replays are unaffected.
var roller := Callable()
var trace = null                    # set to {} to count "<card title>.<hook>" calls (coverage)
var _depth := 0
var _running := {}                 # hooks currently on the stack (no self-retrigger)
var _next_die := 0

# =============================================================================
# Setup
# =============================================================================
func setup(ctrls: Array, seed_ := 0, overrides := {}, card_ids := []) -> Game:
	cfg.merge(overrides, true)
	seed_used = seed_ if seed_ else randi()
	rng.seed = seed_used
	controllers = ctrls
	for i in ctrls.size():
		var p := Player.new(i, "P%d" % (i + 1), cfg.start_teeth)
		for _j in cfg.potency_dice: give_die(p, Die.potency())
		for _j in cfg.elemental_dice: give_die(p, Die.elemental())
		players.append(p)
	deck = CardDB.build_deck(self, card_ids)
	shuffle(deck)
	square.resize(cfg.square_slots)
	for i in square.size(): square[i] = draw_to_square()
	return self

func give_die(p: Player, d: Die) -> Die:
	d.id = _next_die
	_next_die += 1
	d.owner = p
	p.dice.append(d)
	return d

func shuffle(a: Array) -> void:
	for i in range(a.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var t = a[i]; a[i] = a[j]; a[j] = t

func draw() -> Card:
	if deck.is_empty():
		end_when(&"conflagration")
		return null
	var c: Card = deck.pop_back()
	if deck.is_empty(): end_when(&"conflagration")
	return c

func draw_to_square() -> Card:
	var c := draw()
	if c: c.loc = GK.Loc.SQUARE
	return c

# =============================================================================
# Main loop
# =============================================================================
func play() -> void:
	while not over():
		round_no += 1
		for p in players: p.stats.clear()
		await swig_phase()
		if over(): break
		await scry_phase()
		if over(): break
		await scheme_phase()
		if ending or round_no >= cfg.max_rounds: finish(ending if ending else &"round_limit")

func over() -> bool: return phase == GK.Phase.OVER

## Order for "simultaneous" steps, resolved one player at a time. The first player
## rotates each round.
func seats() -> Array[Player]:
	var out: Array[Player] = []
	for i in players.size(): out.append(players[(i + round_no - 1) % players.size()])
	return out

# --- Swig ---------------------------------------------------------------------
func swig_phase() -> void:
	phase = GK.Phase.SWIG
	for p in seats():
		await swig(p)
		if over(): return

func swig(p: Player) -> void:
	p.swig_dice.assign(p.dice + query(&"bonus_dice", p, []))
	for d in p.swig_dice:
		d.zone = GK.Zone.READY
		d.owner = p
	p.scored.clear()
	await emit(&"swig_start", {player = p})
	await action_window(p, &"swig")
	var guard := 0
	while not over() and p.ready_dice() and guard < 50:
		guard += 1
		await roll(p, p.ready_dice())
		await action_window(p, &"roll")
		var ready := p.ready_dice()
		if ready.is_empty(): continue
		var need := mini(query(&"commit_min", p, cfg.commit_min), ready.size())
		var a = await ask(Choice.new(p, &"assign", "Commit or discard at least %d" % need, ready, need, ready.size(), null, &"assign"))
		await commit(p, a.commit)
		for d in a.discard: await discard(p, d)
		await action_window(p, &"swig")

func roll(p: Player, dice: Array) -> void:
	roll_no += 1
	await toss(p, dice)
	await emit(&"rolled", {player = p, dice = dice})
	for d in dice:
		if d.ready(): await emit(&"roll", {player = p, die = d, face = d.face(), manual = false})

func commit(p: Player, dice: Array, src: Ability = null) -> void:
	if dice.is_empty(): return
	for d in dice: d.zone = GK.Zone.COMMITTED
	await emit(&"commit", {player = p, dice = dice, src = src})

func uncommit(p: Player, d: Die, src: Ability = null) -> void:
	d.zone = GK.Zone.READY
	await emit(&"uncommit", {player = p, die = d, src = src})

func discard(p: Player, d: Die, src: Ability = null) -> void:
	d.zone = GK.Zone.DISCARDED
	await emit(&"discard", {player = p, die = d, src = src})

func undiscard(p: Player, d: Die, src: Ability = null) -> void:
	d.zone = GK.Zone.READY
	await emit(&"undiscard", {player = p, die = d, src = src})

## Randomise the faces of `dice` (no events): physical dice when a `roller` is set.
func toss(p: Player, dice: Array) -> void:
	if roller.is_valid(): await roller.call(self, p, dice)
	else:
		for d in dice: d.up = rng.randi_range(0, d.faces.size() - 1)

## Manually rotate a die to a face index. This retriggers "on rolling" (per the rules).
func rotate(p: Player, d: Die, face_idx: int, src: Ability = null) -> void:
	d.up = face_idx
	await emit(&"rotate", {player = p, die = d, src = src})
	await emit(&"roll", {player = p, die = d, face = d.face(), manual = true})

## Permanently change a face on a die (Scheme crystal / Potency swaps).
func set_face(p: Player, d: Die, face_idx: int, value, src: Ability = null) -> void:
	if d.locked_empty: return
	var ev := {player = p, die = d, face = face_idx, value = value, src = src}
	if await replace(&"face_swap", ev): return   # Self-Sacrificant
	var old = d.faces[face_idx]
	d.faces[face_idx] = value
	d.refresh_kind()
	await emit(&"face_swap", {player = p, die = d, old = old, new = value, src = src})

# --- Scry ---------------------------------------------------------------------
func scry_phase() -> void:
	phase = GK.Phase.SCRY
	scry_no += 1
	for p in seats(): await emit(&"scry_start", {player = p})
	for p in seats():
		await emit(&"pre_score", {player = p})   # Nubile Nymph, Hairshirt Bearer
		await score(p)
		await action_window(p, &"scry")
		if over(): return
	await requests()
	await slide_square()

func score(p: Player) -> void:
	var faces := p.committed().map(func(d): return d.face())
	var opts := Scoring.arrangements(faces, query(&"score_rules", p, {}))
	var arr: Array = opts[0] if opts.size() == 1 else await pick(p, "Arrange your scoring sets", opts, null, &"arrangement")
	p.scored = _bind_dice(p.committed(), arr)
	await announce_scored(p, p.scored)

## Emit score events for a list of sets (also used to "score a set again").
func announce_scored(p: Player, sets: Array) -> void:
	for s in sets:
		await emit(&"score_set", {player = p, def = s.def, id = s.def.id, dice = s.dice, color = _color_of(s.dice)})
	if sets.is_empty(): await emit(&"score_nothing", {player = p})
	await emit(&"scored", {player = p, sets = sets})

func _bind_dice(dice: Array, arr: Array) -> Array:
	var pool := dice.duplicate()
	var out := []
	for s in arr:
		var ds := []
		for f in s.faces:
			for d in pool:
				if typeof(d.face()) == typeof(f) and d.face() == f:
					ds.append(d)
					pool.erase(d)
					break
		out.append({def = s.def, dice = ds})
	return out

func _color_of(dice: Array) -> String:
	for d in dice:
		if d.crystal() and d.crystal() != "Q": return d.crystal()
	return ""

## Town Square requests. Each round of requesting is simultaneous: every player who
## hasn't passed picks a slot or passes. A request uses a scored-set right, or pays the
## slot's tokens (3W / 3E / 3F / 3A, as often as you can afford). Uncontested picks are
## claimed at once and the slot refills; contested slots go to a wager. Wager losers keep
## their right and may re-request, so they can wait for the replacement villager.
func requests() -> void:
	var rights := {}
	var passed := {}
	for p in players: rights[p] = Scoring.rights(p.scored, square.size())
	var guard := 0
	while guard < 30:
		guard += 1
		var picks := {}   # slot -> [[player, option]]
		for p in query(&"request_order", null, seats().duplicate()):   # Academic Artillerist
			if passed.has(p): continue
			var opts := [null]
			for r in rights[p]:
				for s in r:
					if square[s] and not opts.any(func(o): return o and o.slot == s and o.right == r):
						opts.append({slot = s, right = r, card = square[s], tokens = {}})
			for s in square.size():
				var price := slot_price(s)
				if square[s] and has(p, price): opts.append({slot = s, right = null, card = square[s], tokens = price})
			if opts.size() == 1: continue
			var o = await pick(p, "Request a villager", opts, null, &"request")
			if o == null: passed[p] = true
			else:
				if not picks.has(o.slot): picks[o.slot] = []
				picks[o.slot].append([p, o])
		if picks.is_empty(): return
		for s in picks:
			var who: Array = picks[s]
			var winner: Player = who[0][0] if who.size() == 1 else await wager(who.map(func(w): return w[0]), square[s])
			for w in who:
				if w[0] == winner:
					if w[1].right != null: rights[winner].erase(w[1].right)
					if w[1].tokens: await spend(winner, w[1].tokens)
			await claim(winner, square[s])
			if over(): return

func slot_price(s: int) -> Dictionary: return {cfg.slot_tokens[s]: cfg.token_request_cost}

## Hidden simultaneous wager of specific tokens. The highest raw total wins and spends
## exactly what they wagered. Ties re-wager; a tie after that rolls off.
func wager(ps: Array, card: Card) -> Player:
	for p in ps:
		if query(&"wager_auto_win", p, false): return await _wager_result(p, ps, {})
	var live := ps.duplicate()
	var bids := {}
	for _r in cfg.max_wager_rounds:
		for p in live:
			var c := Choice.new(p, &"tokens", "Wager tokens for %s" % card, [p.tokens.duplicate()], 0, p.token_total(), null, &"wager")
			c.data = {card = card, rivals = ps.filter(func(x): return x != p)}
			bids[p] = await ask(c)
		var top: int = live.map(func(p): return Game._sum(bids[p])).max()
		live = live.filter(func(p): return Game._sum(bids[p]) == top)
		if live.size() == 1: break
	var w: Player = live[rng.randi_range(0, live.size() - 1)]   # roll for it if still tied
	return await _wager_result(w, ps, bids[w])

static func _sum(tok: Dictionary) -> int: return tok.values().reduce(func(a, b): return a + b, 0)

func _wager_result(w: Player, ps: Array, bid: Dictionary) -> Player:
	var exact := {}
	for t in bid: exact[t] = mini(bid[t], w.tokens[t])
	for t in exact: w.tokens[t] -= exact[t]
	if exact: _log({name = &"spent", player = w, tokens = exact, via = &"wager"})
	await emit(&"wager_won", {player = w, bid = exact})
	for p in ps:
		if p != w: await emit(&"wager_lost", {player = p})
	return w

## Move a card into a player's cadre (from square, deck or pyre). Opponent cards may
## replace the claim (Purger, Fire-Drake).
func claim(p: Player, c: Card, src: Ability = null) -> void:
	if c == null: return
	var slot := square.find(c)
	var ev := {player = p, card = c, src = src, slot = slot}
	if await replace(&"claim", ev): p = ev.player
	if slot >= 0: square[slot] = draw_to_square()
	deck.erase(c)
	pyre.erase(c)
	c.loc = GK.Loc.CADRE
	c.owner = p
	c.inverted = false
	p.cadre.append(c)
	await emit(&"claim", ev)

func slide_square() -> void:
	var left = square.pop_front()
	if left:
		left.loc = GK.Loc.PYRE
		pyre.append(left)
		await emit(&"square_burn", {card = left})
	square.append(draw_to_square())

# --- Scheme -------------------------------------------------------------------
func scheme_phase() -> void:
	phase = GK.Phase.SCHEME
	for p in seats(): await emit(&"scheme_start", {player = p})
	for p in seats():
		if over(): return
		var own := p.cadre.duplicate()
		if own:
			var inv: Array = await ask(Choice.new(p, &"many", "Choose which villagers are inverted", own, 0, own.size(), null, &"orient"))
			for c in own:
				if c.inverted != inv.has(c): await invert(p, c, null, true)
		await swap_spares(p)
		await action_window(p, &"scheme")
		var limit: int = query(&"villager_limit", p, cfg.villager_limit) + p.extra_slots
		while p.cadre.size() > limit:
			await incinerate(await pick(p, "Incinerate down to %d villagers" % limit, p.cadre.duplicate(), null, &"trim"), p)
	for p in seats(): await emit(&"round_end", {player = p})

## Spare faces from "When you incinerate this, gain an X face. During Scheme, you may swap it in."
func swap_spares(p: Player) -> void:
	for f in p.spare_faces.duplicate():
		var d = await pick(p, "Swap in your spare %s face? (pick a die, or none)" % f, [null] + p.dice, null, &"spare")
		if d == null: continue
		await set_face(p, d, await pick_face(p, "Replace which face?", range(d.faces.size())), f)
		p.spare_faces.erase(f)

func invert(p: Player, c: Card, src: Ability = null, free := false) -> void:
	c.inverted = not c.inverted
	await emit(&"invert", {player = p, card = c, src = src, free = free})

# =============================================================================
# Resources: tokens, keys, teeth
# =============================================================================
func gain(p: Player, tok: Dictionary, src: Ability = null, additional := false) -> void:
	for t in tok:
		var n: int = query(&"gain_amount", p, tok[t], {type = t, src = src})
		if n <= 0: continue
		p.tokens[t] += n
		await emit(&"token_gained", {player = p, type = t, amount = n, src = src, additional = additional})

## Spend exact tokens; Q covers any shortfall of E/W/F/A. Caller checks has().
func spend(p: Player, tok: Dictionary) -> void:
	for t in tok:
		var n: int = tok[t]
		var own := mini(n, p.tokens[t])
		p.tokens[t] -= own
		p.tokens.Q -= n - own
	await emit(&"spent", {player = p, tokens = tok})

func has(p: Player, tok: Dictionary) -> bool:
	var short := 0
	for t in tok:
		if t == "Q": short += tok[t]
		else: short += maxi(0, tok[t] - p.tokens[t])
	return p.tokens.Q >= short

## Spend n tokens of any types (largest piles first, Q last). Returns what was spent.
func spend_any(p: Player, n: int) -> Dictionary:
	var out := {}
	for _i in n:
		var best := "Q"
		for t in GK.ELEMENTS:
			if p.tokens[t] > 0 and (best == "Q" or p.tokens[t] > p.tokens[best]): best = t
		if p.tokens[best] > 0:
			p.tokens[best] -= 1
			out[best] = out.get(best, 0) + 1
	if out: _log({name = &"spent", player = p, tokens = out})
	return out

func gain_keys(p: Player, n := 1, src: Ability = null, additional := false) -> void:
	var ev := {player = p, amount = n, src = src, additional = additional}
	if not query(&"can_gain_keys", p, true, ev): return
	if await replace(&"gain_keys", ev): return
	p.keys += ev.amount
	await emit(&"key_gained", ev)
	if p.keys >= win_keys(): end_when(&"edification")

func lose_keys(p: Player, n := 1, src: Ability = null) -> void:
	p.keys = maxi(0, p.keys - n)
	await emit(&"key_lost", {player = p, amount = n, src = src})

## Lose teeth one at a time, so each loss can be prevented or replaced on its own.
## Teeth paid as a cost can be prevented/replaced too (ruling 2026-10-22).
## ev.by is the player whose card caused it (Craven Cannoneer: "Opponents cannot...").
func lose_teeth(p: Player, n := 1, src: Ability = null, as_cost := false) -> int:
	var lost := 0
	for _i in n:
		if p.teeth <= 0: break   # nothing left to lose
		var ev := {player = p, src = src, cost = as_cost, by = src.me if src else null}
		if not query(&"can_lose_teeth", p, true, ev): continue
		if await replace(&"lose_tooth", ev): continue
		p.teeth -= 1
		lost += 1
		await emit(&"tooth_lost", ev)
		if p.teeth <= 0: end_when(&"putrescence")
	return lost

func gain_teeth(p: Player, n := 1, src: Ability = null) -> void:
	var cap: int = query(&"max_teeth", p, cfg.max_teeth)
	var k := clampi(cap - p.teeth, 0, n)
	if k <= 0: return
	p.teeth += k
	await emit(&"tooth_gained", {player = p, amount = k, src = src})

func win_keys() -> int: return query(&"win_keys", null, cfg.win_keys)

func end_when(reason: StringName) -> void:
	if not ending: ending = reason

## Immediate win (Sun-Blinded Prismist, Driveling Chemist).
func win(p: Player, reason: StringName) -> void:
	winners.assign([p])
	ending = reason
	phase = GK.Phase.OVER
	_log({name = &"game_over", reason = reason, winners = winners})

## End of game: players with no teeth "die in ruined bodies". Among the living, most keys
## wins (ties share). If nobody is alive, nobody wins. Teeth regained before the final
## Scheme ends count, so a player can trigger Putrescence and still survive.
func finish(reason: StringName) -> void:
	var living := players.filter(func(p): return p.teeth > 0)
	var best := -1
	for p in living: best = maxi(best, p.keys)
	winners.assign(living.filter(func(p): return p.keys == best))
	phase = GK.Phase.OVER
	_log({name = &"game_over", reason = reason, winners = winners})

# =============================================================================
# Cards in play
# =============================================================================
## Every card whose ability is live, in a deterministic order: seat order, then cadre
## left-to-right, then attached cards.
func live_cards() -> Array[Card]:
	var out: Array[Card] = []
	for p in players: out.append_array(p.cadre)
	out.append_array(attached)
	return out

## Incinerate a card from wherever it is. Cards attached to it go too.
func incinerate(c: Card, by: Player, src: Ability = null) -> void:
	if c == null or c.loc == GK.Loc.PYRE: return
	var ev := {player = by, card = c, owner = c.owner, src = src}
	var ab := c.ability.resolve()
	if c.in_play() and ab.has_method(&"on_leave"): await _fire(ab, "on_leave", ev)
	if c.owner: c.owner.cadre.erase(c)
	attached.erase(c)
	var slot := square.find(c)
	if slot >= 0: square[slot] = draw_to_square()
	c.loc = GK.Loc.PYRE
	c.attached_to = null
	c.buried.clear()
	pyre.append(c)
	if by: by.bump(&"incinerated")
	await emit(&"incinerate", ev)
	for a in attached.filter(func(a): return a.attached_to == c):
		await incinerate(a, a.owner, src)

## Relinquish: move `c` out of its owner's cadre and attach it to `target`.
func relinquish(c: Card, target: Card) -> void:
	c.owner.cadre.erase(c)
	c.loc = GK.Loc.ATTACHED
	c.attached_to = target
	attached.append(c)
	await emit(&"relinquish", {player = c.owner, card = c, target = target})

## Incinerate the top card of the village deck (Doomed Pandorite).
func burn_top() -> void:
	var c := draw()
	if c:
		c.loc = GK.Loc.PYRE
		pyre.append(c)
		await emit(&"deck_burn", {card = c})

## Take a card out of the game without incinerating it (Faustian Scholar).
func remove(c: Card) -> void:
	if c.owner: c.owner.cadre.erase(c)
	attached.erase(c)
	c.loc = GK.Loc.GONE

func resurrect(p: Player, c: Card, src: Ability = null) -> void:
	await claim(p, c, src)

# =============================================================================
# Hook channels
# =============================================================================
## Fire a triggered event. `on_<name>` runs on the cards whose owner is ev.player;
## `on_any_<name>` runs on every live card.
func emit(name: StringName, ev: Dictionary) -> Dictionary:
	ev.name = name
	_log(ev)
	_depth += 1
	if _depth > 40:
		push_warning("trigger depth limit hit at %s" % name)
	else:
		var mine := "on_" + name
		var any := "on_any_" + name
		var who = ev.get("player")
		for c in live_cards():
			var ab := c.ability.resolve()
			if not c.in_play(): continue
			if ab.has_method(any): await _fire(ab, any, ev)
			if who == c.owner and c.in_play() and ab.has_method(mine): await _fire(ab, mine, ev)
			if over(): break
	_depth -= 1
	return ev

## Fold a value through every live `mod_<name>(p, value, ctx)`. Synchronous.
func query(name: StringName, p: Player, value, ctx := {}):
	var m := "mod_" + name
	for c in live_cards():
		var ab := c.ability.resolve()
		if ab.has_method(m):
			_trace(ab, m)
			value = ab.call(m, p, value, ctx)
	return value

## Offer an event to replacement effects. The first `replace_<name>(ev)` returning true wins.
## A replacement can't replace events caused while it is itself resolving: Oathbreaker
## paying "5E" through Strawman ("lose two teeth") must not prevent those two teeth with
## Oathbreaker again, which would loop forever. Other replacements still apply.
func replace(name: StringName, ev: Dictionary) -> bool:
	var m := "replace_" + name
	for c in live_cards():
		var ab := c.ability.resolve()
		var key := [ab, m]
		if not ab.has_method(m) or _running.has(key): continue
		_running[key] = true
		_trace(ab, m)
		var done: bool = await ab.call(m, ev)
		_running.erase(key)
		if done:
			_log({name = &"replaced", what = name, by = ab})
			return true
	return false

## Run one triggered hook. A hook never retriggers itself while it is still resolving
## (e.g. Patient Confidant's own E->W rotation doesn't fire its W->E line). Other cards
## still see the event.
func _fire(ab: Ability, m: String, ev: Dictionary) -> void:
	var key := [ab, m]
	if _running.has(key): return
	_running[key] = true
	_trace(ab, m)
	await ab.call(m, ev)
	_running.erase(key)

func _trace(ab: Ability, m: String) -> bool:
	if trace != null:
		var k := "%s.%s" % [ab.title, m]
		trace[k] = trace.get(k, 0) + 1
	return true

func _log(ev: Dictionary) -> void:
	if keep_log: log.append(ev)
	event.emit(ev)

## Period stamps for once-per limits.
func stamp(per: StringName):
	match per:
		&"roll": return roll_no
		&"round": return round_no
		&"scry": return scry_no
		&"game": return 0
	return round_no

# =============================================================================
# Costs (the italic sections on cards)
# =============================================================================
## Cost keys: E W F A Q (tokens; Q covers shortfalls), any (n tokens of any kinds),
## teeth, keys, burn (incinerate this card), inc (incinerate n other own cards),
## discard (discard n own dice that are not already discarded), one_type (n tokens of a
## single type), burn_card (incinerate that specific Card: Autoerotic Anesthetist).
func cost_options(p: Player, cost: Dictionary) -> Array:
	var opts := [query(&"cost", p, cost)]
	opts.append_array(query(&"cost_alts", p, [], {cost = cost}))
	return opts.filter(func(c): return _affordable(p, c))

func can_pay(p: Player, cost: Dictionary) -> bool: return not cost_options(p, cost).is_empty()

func _affordable(p: Player, c: Dictionary) -> bool:
	var tok := {}
	for t in GK.TOKENS:
		if c.has(t): tok[t] = c[t]
	if not has(p, tok): return false
	if c.has("any") and p.token_total() < c.any + tok.values().reduce(func(a, b): return a + b, 0): return false
	if c.has("teeth") and p.teeth < c.teeth: return false
	if c.has("keys") and p.keys < c.keys: return false
	if c.has("inc") and p.cadre.size() - (1 if c.get("burn") else 0) < c.inc: return false
	if c.has("one_type") and not GK.TOKENS.any(func(t): return p.tokens[t] >= c.one_type): return false
	if c.has("burn_card") and not c.burn_card.in_play(): return false
	if c.has("discard") and p.swig_dice.filter(func(d): return not d.discarded()).size() < c.discard: return false
	return true

func pay(p: Player, cost: Dictionary, src: Ability) -> bool:
	var opts := cost_options(p, cost)
	if opts.is_empty(): return false
	var c: Dictionary = opts[0] if opts.size() == 1 else await pick(p, "Choose how to pay", opts, src, &"cost")
	var tok := {}
	for t in GK.TOKENS:
		if c.has(t): tok[t] = c[t]
	if tok: await spend(p, tok)
	if c.has("any"): spend_any(p, c.any)
	if c.has("one_type"):
		var t = await pick(p, "Spend %d of which token?" % c.one_type, GK.TOKENS.filter(func(t): return p.tokens[t] >= c.one_type), src, &"token")
		p.tokens[t] -= c.one_type
		_log({name = &"spent", player = p, tokens = {t: c.one_type}})
	if c.has("keys"): await lose_keys(p, c.keys, src)
	if c.has("teeth"): await lose_teeth(p, c.teeth, src, true)
	for _i in c.get("discard", 0):
		var dice := p.swig_dice.filter(func(d): return not d.discarded())
		await discard(p, await pick(p, "Discard a die", dice, src, &"cost_discard"), src)
	for _i in c.get("inc", 0):
		var others := p.cadre.filter(func(x): return x != src.card)
		await incinerate(await pick(p, "Incinerate a villager", others, src, &"cost_inc"), p, src)
	if c.get("burn"): await incinerate(src.card, p, src)
	if c.has("burn_card"): await incinerate(c.burn_card, p, src)
	await emit(&"paid", {player = p, cost = c, src = src})
	return true

func cost_str(c: Dictionary) -> String:
	return ", ".join(c.keys().map(func(k): return k if c[k] is bool else ("incinerate %s" % c[k] if c[k] is Card else "%s %s" % [c[k], k])))

# =============================================================================
# Activated abilities
# =============================================================================
## Activated abilities `p` may use in `window` (&"swig", &"roll", &"scry", &"scheme").
## An act's "when" may be "any", or a window name or list of names; "roll" acts are
## also usable in "swig" windows.
func legal_acts(p: Player, window: StringName) -> Array:
	var out := []
	for c in p.cadre:
		var ab := c.ability.resolve()
		var acts := ab.acts()
		for id in acts:
			var a: Dictionary = acts[id]
			var when = a.get("when", "any")
			var ok: bool = when == "any" or when == String(window) or (when is Array and when.has(String(window))) \
				or (when == "roll" and window == &"swig") or (when == "swig" and window == &"roll")
			if not ok or (a.has("per") and ab.used(id, a.per)): continue
			if a.has("cost") and not can_pay(p, a.cost): continue
			if ab.has_method("can_" + id) and not ab.call("can_" + id): continue
			out.append({ability = ab, id = id, label = a.get("label", "%s: %s" % [ab.title, id])})
	return out

func action_window(p: Player, window: StringName) -> void:
	for _i in 30:
		if over(): return
		var opts := legal_acts(p, window)
		if opts.is_empty(): return
		var o = await pick(p, "Use an ability? (%s)" % window, [null] + opts, null, &"act")
		if o == null: return
		await use_act(p, o.ability, o.id)

func use_act(p: Player, ab: Ability, id: StringName) -> void:
	var a: Dictionary = ab.acts()[id]
	if a.has("per"): ab.once(id, a.per)
	if a.has("cost") and not await pay(p, a.cost, ab): return
	_trace(ab, "act_" + id)
	await emit(&"act", {player = p, ability = ab, id = id})
	if ab.has_method("act_" + id): await ab.call("act_" + id)

# =============================================================================
# Choices
# =============================================================================
func ask(c: Choice):
	asking.emit(c)
	var a = await controllers[c.player.idx].decide(self, c)
	if not c.valid(a):
		invalid_answers += 1
		push_warning("invalid answer %s to %s; using default" % [a, c])
		a = Controller.default_answer(c)
	answers.append([c.player.idx, c.encode(a)])
	return a

## `offer` = {cost = {...}, gain = {...}} in cost vocabulary (plus gain-only keys like
## control, face, die, claim); bots price it, a GUI can show it.
func may(p: Player, prompt: String, src: Ability = null, offer := {}) -> bool:
	var c := Choice.new(p, &"yes_no", prompt, [], 0, 1, src, &"may")
	c.data = offer
	return await ask(c)

func pick(p: Player, prompt: String, options: Array, src: Ability = null, tag: StringName = &"pick"):
	if options.is_empty(): return null
	if options.size() == 1: return options[0]
	return await ask(Choice.new(p, &"one", prompt, options, 1, 1, src, tag))

func pick_many(p: Player, prompt: String, options: Array, lo: int, hi: int, src: Ability = null, tag: StringName = &"pick_many") -> Array:
	return await ask(Choice.new(p, &"many", prompt, options, lo, mini(hi, options.size()), src, tag))

func pick_die(p: Player, prompt: String, filter: Callable = func(_d): return true, src: Ability = null, tag: StringName = &"die"):
	return await pick(p, prompt, p.swig_dice.filter(filter), src, tag)

func pick_face(p: Player, prompt: String, choices: Array, src: Ability = null, tag: StringName = &"face"):
	return await pick(p, prompt, choices, src, tag)

## Break reference cycles (card <-> ability, player <-> die) so finished games free.
func dispose() -> void:
	for c in deck + pyre + attached + square.filter(func(x): return x != null) + _all_cadres():
		for ab in c.faces: ab.card = null
		c.faces.clear()
		c.owner = null
		c.attached_to = null
	for p in players:
		for d in p.dice + p.swig_dice: d.owner = null
		p.cadre.clear()
	players.clear()
	controllers.clear()

func _all_cadres() -> Array:
	var out := []
	for p in players: out.append_array(p.cadre)
	return out

func opponents_of(p: Player) -> Array: return players.filter(func(x): return x != p)

## Read-only summary for debugging and observers.
func summary() -> String:
	var s := "Round %d  deck %d  pyre %d  square %s\n" % [round_no, deck.size(), pyre.size(), square]
	for p in players:
		s += "  %s keys %d teeth %d tokens %s cadre %s\n" % [p, p.keys, p.teeth, p.tokens, p.cadre]
	return s
