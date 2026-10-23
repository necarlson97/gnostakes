# The Empress
extends RefCounted

class Top extends Ability:  # Gargoyle Mother
	func mod_commit_min(p, v, _c): return mini(v, 4) if p == me else v

class Inv extends Ability:  # Famed Freemason
	var die := Die.potency()
	func mod_bonus_dice(p, v, _c): return with_die(p, v, die)
	func mod_score_rules(p, r, _c):
		if p == me: r.banned = r.get("banned", []) + [&"three_straight", &"two_color_pairs", &"triplet", &"four_of_a_color"]
		return r
