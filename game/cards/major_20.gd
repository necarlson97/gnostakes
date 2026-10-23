# Judgment
extends RefCounted

class Top extends Ability:  # Wailing Confessor
	var die := Die.uniform("A")
	func mod_bonus_dice(p, v, _c): return with_die(p, v, die)
	func on_score_set(ev):
		if not set_has(ev, "A") and me.teeth > me.discarded().size(): await lose_teeth(1)

class Inv extends Ability:  # Voiceless Accused
	var die := Die.uniform("E")
	func mod_bonus_dice(p, v, _c): return with_die(p, v, die)
	func mod_score_rules(p, r, _c):
		if p == me: r.min_size = maxi(r.get("min_size", 0), 5)
		return r
