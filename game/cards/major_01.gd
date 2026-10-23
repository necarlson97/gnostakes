# The Magician
extends RefCounted

class Top extends Ability:  # Knower of True Names
	func on_score_set(ev):
		if not set_has(ev, "F"): bury("W")
	func on_scheme_start(_ev):
		if buried("W") == 0: return
		await swap_face("W", func(d): return d.kind == GK.Kind.ELEMENTAL, func(f): return f is String and f != "W")
		card.unbury("W")

class Inv extends Ability:  # Lockpicking Archon
	# Attach to ANY player's card, including your own. While attached, that player
	# cannot lose teeth and cannot gain keys.
	func acts(): return {attach = {label = "Relinquish onto any player's card"}}
	func targets() -> Array: return g.live_cards().filter(func(c): return c != card and c.loc == GK.Loc.CADRE)
	func can_attach(): return not targets().is_empty()
	func act_attach(): await g.relinquish(card, await g.pick(me, "Attach Lockpicking Archon to which card?", targets(), self, &"target"))
	func mod_can_lose_teeth(p, v, _c): return false if attached() and p == victim() else v
	func mod_can_gain_keys(p, v, _c): return false if attached() and p == victim() else v
