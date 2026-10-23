# Eight of Cups
extends RefCounted

class Top extends Ability:  # Hairshirt Bearer
	func on_pre_score(_ev):
		if await may_pay({A = 1}, "Hairshirt Bearer: spend 1A to score straights with one fewer die?", {control = 1}): once(&"short", &"scry")
	func mod_score_rules(p, r, _c):
		if p == me and used(&"short", &"scry"): r.short_straight = true
		return r

class Inv extends Ability:  # Fleabitten Penitent
	func on_score_set(ev):
		if ev.id == &"five_straight": await gain_keys()
		else: await lose_teeth(1)
	func on_score_nothing(_ev): await lose_teeth(1)
