# Six of Swords
extends RefCounted

class Top extends Ability:  # Mummy Grinder
	# "'x of a color'" read as Four of a Color, Five of a Color and Four Air.
	func on_score_set(ev):
		if is_set(ev, [&"four_of_a_color", &"five_of_a_color", &"four_air"]): bury("A", 2)
	func on_swig_start(_ev):
		if buried("A") > 0 and me.ready_dice() and await may("Mummy Grinder: spend 1 buried A to rotate and commit a die?", {cost = {A = 0.5}, gain = {control = 2}}):
			unbury("A", 1)
			await rotate_and_commit()
	func replace_lose_tooth(ev):
		if ev.player != me or buried("A") < 6: return false
		await incinerate_self()
		return true

class Inv extends Ability:  # Intrepid Archaeologist
	func on_token_gained(ev):
		if ev.type in ["W", "F"] and me.tokens.A > 0:
			me.tokens.E += me.tokens.A
			me.tokens.A = 0
			await g.emit(&"convert", {player = me, from = "A", to = "E"})
	func replace_lose_tooth(ev):
		return ev.player == me and await may_pay({E = 4}, "Intrepid Archaeologist: pay 4E instead of losing a tooth?", {save_teeth = 1})
