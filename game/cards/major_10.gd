# Wheel of Fortune
extends RefCounted

class Top extends Ability:  # Barefoot Pilgrim
	func on_scheme_start(_ev):
		if await may("Incinerate Barefoot Pilgrim for an all-Water elemental die?", {cost = {burn = true}, gain = {die = 1}}):
			await incinerate_self()
			g.give_die(me, Die.uniform("W"))

class Inv extends Ability:  # Marooned Wanderer
	func on_incinerate(ev):
		if ev.card != card and g.deck and await may_pay({Q = 1}, "Marooned Wanderer: spend 1Q to draw and claim the top card?", {claim_top = 1}):
			await g.claim(me, g.draw(), self)
