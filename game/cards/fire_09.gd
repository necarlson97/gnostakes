# Nine of Wands
extends RefCounted

class Top extends Ability:  # Shunned Executioner
	func on_scheme_start(_ev):
		await g.incinerate(await g.pick(me, "Shunned Executioner: incinerate a card", me.cadre.duplicate(), self, &"cost_inc"), me, self)
		await gain({Q = 1})

class Inv extends Ability:  # Bloodstained Recluse
	func on_score_set(ev):
		if color_set(ev, &"four_of_a_color", "F"): await wipe_for_keys(2)
