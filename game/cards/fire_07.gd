# Seven of Wands
extends RefCounted

class Top extends Ability:  # Witch Drowner
	func on_incinerate(_ev): await gain({Q = 1})
	func on_scheme_start(_ev): await adjust_potency(-1)

class Inv extends Ability:  # Corrupted Inquisitor
	func on_round_end(_ev):
		if me.stat(&"incinerated") >= 2: await gain_keys()
