# Four of Wands
extends RefCounted

class Top extends Ability:  # Fire-Drake
	func on_roll(ev): await potency_for(ev, "F")
	func on_any_incinerate(ev):
		if ev.card != card and ev.card.loc == GK.Loc.PYRE and await may_pay({F = 2}, "Fire-Drake: spend 2F to claim %s?" % ev.card, {claim = ev.card}):
			await g.claim(me, ev.card, self)

class Inv extends Ability:  # Powder Miller
	func on_scry_start(_ev): await gain({F = 1})
	func acts(): return {key = {cost = {F = 2, burn = true}, label = "2F, incinerate: gain a key"}}
	func act_key(): await gain_keys()
