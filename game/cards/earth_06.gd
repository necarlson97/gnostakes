# Six of Disks
extends RefCounted

class Top extends Ability:  # Shrewd Quaker
	func on_scheme_start(_ev): await adjust_potency(-1)
	func on_score_set(ev):
		if is_set(ev, [&"two_color_pairs", &"four_pairs"]) and await may_pay({E = 3}, "Spend 3E for 2F or 2A?", {F = 2}):
			await gain({await g.pick(me, "Gain 2 of which?", ["F", "A"], self, &"token"): 2})

class Inv extends Ability:  # Hard-Tack Baker
	func mod_score_rules(p, r, _c):
		if p == me:
			r.triplet_as_quad = true
			r.no_straights = true
		return r
