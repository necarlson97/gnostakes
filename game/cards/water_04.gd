# Four of Cups
extends RefCounted

class Top extends Ability:  # Hollow-Bellied Saint
	func on_roll(ev): await potency_for(ev, "W")
	func on_scheme_start(_ev): await adjust_potency(-1)

class Inv extends Ability:  # Pot-Licking Friar
	func on_discard(_ev): await gain({W = 1})
	func acts(): return {key = {cost = {W = 2, burn = true}, label = "2W, incinerate: gain a key"}}
	func act_key(): await gain_keys()
