# Four of Swords
extends RefCounted

class Top extends Ability:  # Flayed Flagellant
	func on_roll(ev): await potency_for(ev, "A")
	func acts(): return {rotate = {when = "roll", per = &"round", cost = {A = 1}, label = "1A: rotate a die to any face"}}
	func act_rotate(): await rotate_any()

class Inv extends Ability:  # Lash-Blessed Monk
	func on_any_key_gained(ev):
		if ev.player != me and await may("Lash-Blessed Monk: incinerate to gain a key?", {cost = {burn = true}, gain = {keys = 1}}):
			await incinerate_self()
			await gain_keys()
	func acts(): return {key = {cost = {A = 2, burn = true}, label = "2A, incinerate: gain a key"}}
	func act_key(): await gain_keys()
