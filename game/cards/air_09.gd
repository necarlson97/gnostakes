# Nine of Swords
extends RefCounted

class Top extends Ability:  # Shuar Headshrinker
	func acts(): return {relinquish = {label = "Relinquish onto an opponent's card"}}
	func on_any_scheme_start(ev):
		if attached() and ev.player == victim(): await g.lose_teeth(victim(), 1, self)

class Inv extends Ability:  # Ayahuascite
	func on_rotate(_ev): bury("A")
	func on_score_nothing(_ev):
		var n := card.unbury("A")
		if n == 0: return
		await gain({A = n})
		if n >= 5:
			await incinerate_self()
			await gain_keys()
