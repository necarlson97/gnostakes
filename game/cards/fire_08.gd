# Eight of Wands
extends RefCounted

class Top extends Ability:  # Furnace Keeper
	func on_roll(ev):
		if ev.die.shows("F") and await may_pay({inc = 1}, "Furnace Keeper: incinerate a card to gain 2F?", {F = 2}): await gain({F = 2})
	func on_scheme_start(_ev): await adjust_potency(1)

class Inv extends Ability:  # Staunch Stoker
	func acts(): return {stoke = {cost = {Q = 1}, label = "1Q: resurrect the most recently incinerated card"}}
	func can_stoke(): return not g.pyre.is_empty()
	func act_stoke(): await g.resurrect(me, g.pyre.back(), self)
