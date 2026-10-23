# Prince of Disks
extends RefCounted

class Top extends Ability:  # The Tallyman
	# A new Potency die is buried here showing 1 and counts up per incineration.
	var tally := 1
	var die := Die.potency()
	func on_incinerate(ev):
		if ev.card != card: tally = mini(6, tally + 1)
	func mod_bonus_dice(p, v, _c): return with_die(p, v, die) if tally >= 6 else v

class Inv extends Ability:  # Dreaded Abacist
	func on_scheme_start(_ev):
		await adjust_potency(1)
		await adjust_potency(-1)
