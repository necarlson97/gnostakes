# The Devil
extends RefCounted

class Top extends Ability:  # Pact Proctor
	func acts(): return {resurrect = {cost = {Q = 2, teeth = 1}, label = "2Q + a tooth: resurrect an incinerated card"}}
	func can_resurrect(): return not g.pyre.is_empty()
	func act_resurrect(): await g.resurrect(me, await g.pick(me, "Resurrect which card?", g.pyre.duplicate(), self, &"target"), self)

class Inv extends Ability:  # Wrathful Sovern
	func on_any_tooth_lost(ev):
		if ev.player != me and await may_pay({F = 3}, "Wrathful Sovern: spend 3F to gain a key?", {keys = 1}): await gain_keys()
