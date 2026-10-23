# Ace of Wands
extends RefCounted

class Top extends Ability:  # Promethean Pyro
	func on_roll(ev):
		if not ev.die.shows("A"): return
		var n := empty_slots()
		if n >= 3: await gain({W = 1, E = 1, F = 1})
		elif n == 2: await gain({W = 1, E = 1})
		elif n == 1: await gain({W = 1})

class Inv extends Ability:  # Doomed Pandorite
	func on_scheme_start(_ev):
		await g.burn_top()
		await gain({F = 1})
	func on_score_set(ev):
		if color_set(ev, &"four_of_a_color", "F"):
			await gain_keys()
			await incinerate_self()
