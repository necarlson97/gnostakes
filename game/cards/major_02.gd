# The High Priestess
extends RefCounted

class Top extends Ability:  # Mooncalf Mother
	func acts(): return {rotate = {when = "roll", per = &"roll", cost = {discard = 1}, label = "Discard a die: rotate a die to any face"}}
	func act_rotate(): await rotate_any()

class Inv extends Ability:  # Carrier of the Droplet
	func acts(): return {invert = {cost = {W = 3}, label = "3W: invert a card"}}
	func act_invert():
		await g.invert(me, await g.pick(me, "Invert which card?", me.cadre.duplicate(), self, &"target"), self)
