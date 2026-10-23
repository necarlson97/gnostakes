# Temperance
extends RefCounted

class Top extends Ability:  # Binger
	func mod_score_rules(p, r, _c):
		if p == me: r.straight_gap = 1
		return r

class Inv extends Ability:  # Purger
	func on_scheme_start(_ev): await adjust_potency(-1)
	func replace_claim(ev):
		if ev.player == me or not g.can_pay(me, {teeth = 1, burn = true}): return false
		if not await may("Lose a tooth and incinerate Purger to claim %s instead?" % ev.card, {cost = {teeth = 1, burn = true}, gain = {claim = ev.card}}): return false
		await pay({teeth = 1, burn = true})
		ev.player = me
		return true
