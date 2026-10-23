# Power
extends RefCounted

class Top extends Ability:  # Faustian Scholar
	func acts(): return {slot = {cost = {teeth = 1}, label = "Lose a tooth: this card becomes a permanent empty slot"}}
	func act_slot():
		me.extra_slots += 1
		g.remove(card)

class Inv extends Ability:  # Tumorous Magi
	func acts(): return {die = {cost = {Q = 1, teeth = 1, burn = true}, label = "1Q, a tooth, incinerate: gain a Potency die"}}
	func act_die(): g.give_die(me, Die.potency())
