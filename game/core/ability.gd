class_name Ability extends RefCounted
## One face of a villager card. Subclass it in res://cards/<id>.gd as `Top` / `Inv`.
##
## Hooks are found by method name; define only the ones you need. All may `await`.
##   on_<event>(ev)        triggered: only when ev.player is this card's owner ("you")
##   on_any_<event>(ev)    triggered: for every player's event
##   replace_<event>(ev)   replacement ("would ... instead"): return true to replace
##   mod_<query>(p, v, ctx) static modifier: return the adjusted value (no awaits)
##   on_leave(ev)          this card itself is being incinerated
##   acts()                activated abilities: {id: {cost={...}, when="any", per=&"round"}}
##   can_<id>() / act_<id>()  optional condition / effect for each activated ability
##
## Events (see Game for payloads): swig_start, roll, rolled, commit, uncommit, discard,
## undiscard, rotate, scry_start, pre_score, score_set, scored, score_nothing, claim,
## wager_won, wager_lost, square_burn, scheme_start, invert, face_swap, relinquish,
## token_gained, spent, key_gained, key_lost, tooth_lost, tooth_gained, incinerate,
## paid, act, round_end.
##
## Queries: commit_min, bonus_dice, villager_limit, win_keys, max_teeth, gain_amount,
## can_lose_teeth, can_gain_keys, score_rules, request_order, wager_auto_win, cost,
## cost_alts.
## score_rules keys: straight_gap, no_straights, triplet_as_quad, fire_as_air, banned,
## only, min_size.

var card: Card
var g: Game
var title := ""
var text := ""
var implemented := true
var _used := {}     # act/once key -> stamp it was last used at

## Owner of the card; "you" in the card text.
var me: Player:
	get: return card.owner

func active() -> bool: return card.in_play() and card.ability == self

## The ability that actually runs for this face (Failed Exorcist returns a copy).
func resolve() -> Ability: return self

func acts() -> Dictionary: return {}

## True once per `per` period (&"roll", &"round", &"scry", &"swig", &"game"), then false.
func once(key: StringName, per: StringName = &"round") -> bool:
	var stamp = g.stamp(per)
	if _used.get(key) == stamp: return false
	_used[key] = stamp
	return true
func used(key: StringName, per: StringName) -> bool: return _used.get(key) == g.stamp(per)

# --- terse helpers for card scripts -------------------------------------------
## `offer` describes the trade for bots: {cost = {...}, gain = {...}} (see Valuer.price).
func may(prompt: String, offer := {}) -> bool: return await g.may(me, prompt, self, offer)
func may_pay(cost: Dictionary, prompt := "", gain := {}) -> bool:
	if not g.can_pay(me, cost): return false
	if not await g.may(me, prompt if prompt else "%s: pay %s?" % [title, g.cost_str(cost)], self, {cost = cost, gain = gain}): return false
	return await g.pay(me, cost, self)
func pay(cost: Dictionary) -> bool: return await g.pay(me, cost, self)
func gain(tok: Dictionary, additional := false) -> void: await g.gain(me, tok, self, additional)
func gain_keys(n := 1, additional := false) -> void: await g.gain_keys(me, n, self, additional)
func lose_teeth(n := 1) -> void: await g.lose_teeth(me, n, self)
func incinerate_self() -> void: await g.incinerate(card, me, self)
## Take buried tokens off this card (logged so the ability meter sees it); returns how many.
func unbury(k: String, n := -1) -> int:
	var took := card.unbury(k, n)
	if took: g._log({name = &"unbury", player = me, card = card, token = k, amount = took, src = self})
	return took

## Gain a spare face of colour `t` (swapped onto a die at the next opportunity).
func gain_face(t: String) -> void:
	me.spare_faces.append(t)
	g._log({name = &"face_gained", player = me, face = t, src = self})

func bury(k: String, n := 1) -> void:
	card.bury(k, n)
	g._log({name = &"bury", player = me, card = card, token = k, amount = n, src = self})
func buried(k: String) -> int: return card.buried_n(k)
func opponents() -> Array: return g.players.filter(func(p): return p != me)
func victim() -> Player: return card.holder()   # for relinquished cards
func set_has(ev: Dictionary, f) -> bool: return ev.dice.any(func(d): return d.shows(f))
func is_set(ev: Dictionary, ids: Array) -> bool: return ids.has(ev.id)
func color_set(ev: Dictionary, id: StringName, color: String) -> bool: return ev.id == id and ev.color == color

## Static bonus die: `func mod_bonus_dice(p, v, _c): return with_die(p, v, die)`
func with_die(p: Player, dice: Array, d: Die) -> Array:
	if p == me: dice.append(d)
	return dice

# --- recurring card phrases -----------------------------------------------------
## "On rolling X, you may discard a Potency die to gain X equal to that Potency."
func potency_for(ev: Dictionary, tok: String) -> void:
	if not ev.die.shows(tok): return
	var pd := me.swig_dice.filter(func(d): return d.kind == GK.Kind.POTENCY and not d.discarded())
	if pd.is_empty(): return
	var most: int = pd.map(func(d): return d.pips()).max()
	if not await may("%s: discard a Potency die to gain %s?" % [title, tok], {cost = {discard = 1, set = 0.5}, gain = {tok: most}}): return
	var d: Die = await g.pick(me, "Discard which Potency die?", pd, self, &"potency_die")
	await g.discard(me, d, self)
	await gain({tok: d.pips()})

## "On Scheme start, you may increase/decrease a Potency by +1/-1"
func adjust_potency(delta: int) -> void:
	if not await may("%s: change a Potency face by %+d?" % [title, delta]): return
	var dice := me.dice.filter(func(d): return d.faces.any(func(f): return f is int))
	if dice.is_empty(): return
	var d: Die = await g.pick(me, "Which die?", dice, self, &"die")
	var i: int = await g.pick_face(me, "Which face?", range(d.faces.size()).filter(func(i): return d.faces[i] is int), self)
	await g.set_face(me, d, i, maxi(0, d.faces[i] + delta), self)

## "Relinquish this card, attaching it to an opponent's card." Use as an act:
##   func acts(): return {relinquish = {}}   (can_/act_ provided here)
func can_relinquish() -> bool: return opponents().any(func(p): return not p.cadre.is_empty())
func act_relinquish() -> void:
	var targets := []
	for p in opponents(): targets.append_array(p.cadre)
	await g.relinquish(card, await g.pick(me, "Attach %s to which card?" % title, targets, self, &"target"))
func attached() -> bool: return card.loc == GK.Loc.ATTACHED

## Dice still in play this Swig (not discarded): what "rotate a die" can act on.
func live_dice() -> Array: return me.swig_dice.filter(func(d): return not d.discarded())

## An Elemental die with a crystal face that isn't already Q ("replace a crystal face with Q").
func can_quint() -> bool:
	return me.dice.any(func(d): return d.kind == GK.Kind.ELEMENTAL and d.faces.any(func(f): return f is String and f != "" and f != "Q"))

## "Rotate a die to any face": pick a die (default: any not discarded), then a face.
func rotate_any(filter: Callable = func(d): return not d.discarded()) -> Die:
	var d: Die = await g.pick_die(me, "%s: rotate which die?" % title, filter, self, &"rotate_die")
	if d: await g.rotate(me, d, await g.pick_face(me, "To which face?", range(d.faces.size()), self, &"rotate_face"), self)
	return d

## "Rotate a die one face over in either direction."
func rotate_step(filter: Callable = func(d): return not d.discarded()) -> void:
	var d: Die = await g.pick_die(me, "%s: rotate which die?" % title, filter, self)
	if d == null: return
	var dir: int = await g.pick(me, "Which way?", [1, -1], self, &"dir")
	await g.rotate(me, d, posmod(d.up + dir, d.faces.size()), self)

## "On rolling an X, you may rotate it to a Y" (Patient Confidant, Jar Dweller).
func may_rotate_to(ev: Dictionary, from: String, to: String) -> void:
	var i: int = ev.die.index_of(to)
	if ev.die.shows(from) and i >= 0 and await may("%s: rotate that %s to %s?" % [title, from, to]):
		await g.rotate(me, ev.die, i, self)

## "Rotate and commit a ready die."
func rotate_and_commit() -> void:
	var d := await rotate_any(func(d): return d.ready())
	if d and d.ready(): await g.commit(me, [d], self)

## Swap a face on one of your dice: pick die (filtered), pick face index (filtered), set.
func swap_face(value, die_filter: Callable = func(_d): return true, face_filter: Callable = func(_f): return true) -> void:
	var d: Die = await g.pick(me, "%s: which die?" % title, me.dice.filter(die_filter), self, &"die")
	if d == null: return
	var idx := range(d.faces.size()).filter(func(i): return face_filter.call(d.faces[i]))
	if idx: await g.set_face(me, d, await g.pick_face(me, "Replace which face?", idx, self), value, self)

## A choice between alternatives that the card text joins with "or". With Toothless
## Grinner you may spend 2Q to do all of them ("and"). Returns the chosen options.
## `offers[i]` = {cost, gain} for opts[i], so bots can price each alternative.
func either(prompt: String, opts: Array, optional := false, offers: Array = []) -> Array:
	if opts.is_empty(): return []
	if g.query(&"or_to_and", me, false) and g.can_pay(me, {Q = 2}) \
			and await g.may(me, "Toothless Grinner: spend 2Q to take all of: %s?" % [opts], self, {cost = {Q = 2}, gain = {option = opts.size() - 1}}) \
			and await g.pay(me, {Q = 2}, self):
		return opts
	var c := Choice.new(me, &"one", prompt, ([null] if optional else []) + opts, 1, 1, self, &"either")
	c.data = {offers = ([{}] if optional else []) + offers} if offers else {}
	var o = await g.ask(c)
	return [] if o == null else [o]

## "Incinerate all your cards, including this, to gain N keys."
func wipe_for_keys(n: int) -> void:
	for c in me.cadre.duplicate(): await g.incinerate(c, me, self)
	await gain_keys(n)

func is_straight(ev: Dictionary) -> bool: return Scoring.is_straight(ev.id)
func empty_slots() -> int: return g.query(&"villager_limit", me, g.cfg.villager_limit) + me.extra_slots - me.cadre.size()

func _to_string() -> String: return title
