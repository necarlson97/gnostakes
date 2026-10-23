# The Hermit
extends RefCounted

class Top extends Ability:  # Pillar-top Hermit
	var die := Die.uniform(6)
	func mod_bonus_dice(p, v, _c): return with_die(p, v, die)
	func mod_gain_amount(p, n, _c): return n - 1 if p == me else n

class Inv extends Ability:  # Bird-Fouled Hagia
	func on_scheme_start(_ev):
		bury("Q")
		if buried("Q") >= 5:
			await gain_keys()
			await incinerate_self()
	func on_token_gained(ev):
		if ev.type == "Q" and ev.src != self and buried("Q") > 0: await gain({Q = card.unbury("Q")})
