# The Fool
extends RefCounted

class Top extends Ability:  # Hollowhead
	func on_key_gained(ev):
		if not ev.additional and me.cadre.size() - 1 == 2: await gain_keys(1, true)

class Inv extends Ability:  # God-Struck Fool
	var die := Die.uniform(1)
	func mod_bonus_dice(p, v, _c): return with_die(p, v, die)
	# "On Scry, if you did not score any Potency dice: incinerate this card."
	func on_scored(_ev):
		if not me.scoring_dice().any(func(d): return d.pips() > 0): await incinerate_self()
