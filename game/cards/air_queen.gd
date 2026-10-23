# Queen of Swords
extends RefCounted

class Top extends Ability:  # Placenta Purloiner
	func on_any_tooth_lost(ev):
		if ev.player != me: bury("Q")
	func on_scheme_start(_ev):
		if buried("Q") >= 2 and await may("Placenta Purloiner: spend 2 buried Q to regain a tooth?", {cost = {Q = 1}, gain = {teeth = 1}}):
			card.unbury("Q", 2)
			await g.gain_teeth(me, 1, self)

class Inv extends Ability:  # Viscera Monger
	func on_incinerate(_ev):
		if await may_pay({E = 4}, "Viscera Monger: spend 4E to get 4A?", {A = 4}): await gain({A = 4})
