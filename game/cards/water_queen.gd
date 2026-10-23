# Queen of Cups
extends RefCounted

class Top extends Ability:  # Broken Martyr
	func on_scry_start(_ev):
		await lose_teeth(1)
		await g.gain_teeth(me, 1, self)
	func on_scheme_start(_ev): await adjust_potency(1)

class Inv extends Ability:  # Tarred Prophet
	func acts(): return {relinquish = {label = "Relinquish onto an opponent's card"}}
	func on_any_key_gained(ev):
		if attached() and ev.player == victim() and not ev.additional: await gain_keys(1, true)
