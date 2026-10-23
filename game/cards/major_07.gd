# The Chariot
extends RefCounted

class Top extends Ability:  # Promising Pugilist
	# The chosen set is remembered by the token buried for it.
	const CHOICES := {quadruplet = "E", five_straight = "W", five_of_a_color = "F", four_air = "A"}
	func chosen() -> StringName:
		for s in CHOICES:
			if buried(CHOICES[s]) > 0: return s
		return &""
	func choose() -> void:
		if chosen() == &"": bury(CHOICES[await g.pick(me, "Promising Pugilist: choose a set", CHOICES.keys(), self, &"set")])
	func on_claim(ev):
		if ev.card == card: await choose()
	func on_scheme_start(_ev): await choose()
	func on_score_set(ev):
		if chosen() != &"" and ev.id == chosen():
			await gain_keys()
			if me.teeth > 1: await lose_teeth(1)

class Inv extends Ability:  # Bruised Boxer
	func replace_lose_tooth(ev):
		if ev.player != me: return false
		var kinds := GK.TOKENS.filter(func(t): return me.tokens[t] > 0)
		var others := me.cadre.filter(func(c): return c != card)
		if kinds.is_empty() or others.size() < 2: return false
		if not await may("Bruised Boxer: spend all of one token and incinerate two cards to keep the tooth?", {cost = {inc = 2, any = 3}, gain = {save_teeth = 1}}): return false
		me.tokens[await g.pick(me, "Spend all of which token?", kinds, self, &"token")] = 0
		for c in await g.pick_many(me, "Incinerate which two?", others, 2, 2, self, &"cost_inc"):
			await g.incinerate(c, me, self)
		return true
