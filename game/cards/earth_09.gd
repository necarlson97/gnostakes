# Nine of Disks
extends RefCounted

class Top extends Ability:  # Oathbreaker
	func replace_lose_tooth(ev):
		if ev.player != me: return false
		var opts := [{E = 5}, {burn = true}].filter(func(c): return g.can_pay(me, c))
		var pick := await either("Oathbreaker: prevent losing a tooth?", opts, true, opts.map(func(c): return {cost = c, gain = {save_teeth = 1}}))
		return pick.size() > 0 and await pay(pick[0])

class Inv extends Ability:  # Oathkeeper
	func on_score_set(ev):
		if is_set(ev, [&"triplet", &"quadruplet"]): await gain({Q = 1})
		elif Scoring.is_straight(ev.id): await incinerate_self()
