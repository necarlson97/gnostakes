# Two of Wands
extends RefCounted

class Top extends Ability:  # Branded Protégé
	func on_discard(_ev): await gain({F = 1})
	func acts(): return {q = {cost = {F = 2}, label = "2F: gain 1Q"}}
	func act_q(): await gain({Q = 1})

class Inv extends Ability:  # Expendable Assistant
	func on_tooth_lost(_ev): await gain({Q = 1})
	func on_wager_lost(_ev): await gain({Q = 1})
	func on_score_set(ev):
		if color_set(ev, &"four_of_a_color", "F"):
			await gain_keys()
			await incinerate_self()
