# The Hanged Man
extends RefCounted

class Top extends Ability:  # Self-Sacrificant
	# "Whenever you are allowed to make a swap" = whenever one of your face swaps happens.
	func replace_face_swap(ev):
		if ev.player != me or not g.can_pay(me, {one_type = 3}): return false
		if not await may("Self-Sacrificant: skip this swap and pay 3 of one token for a key?", {cost = {one_type = 3, face = 1}, gain = {keys = 1}}): return false
		await pay({one_type = 3})
		await gain_keys()
		return true

class Inv extends Ability:  # Post-Fate Oblate
	func mod_score_rules(p, r, _c):
		if p == me: r.fire_as_air = true
		return r
