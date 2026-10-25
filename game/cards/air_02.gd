# Two of Swords
extends RefCounted

class Top extends Ability:  # Tongueless Traitor
	func on_face_swap(_ev): await gain({A = 2})
	func acts(): return {rotate = {when = "roll", per = &"round", cost = {W = 1}, label = "1W: rotate a die to any face"}}
	func can_rotate(): return not live_dice().is_empty()
	func act_rotate(): await rotate_any()

class Inv extends Ability:  # Candid Jester
	func on_score_set(ev):
		if color_set(ev, &"five_of_a_color", "A") or color_set(ev, &"five_of_a_color", "F"):
			await g.lose_teeth(await g.pick(me, "Candid Jester: who loses a tooth?", opponents(), self, &"target"), 1, self)
		if ev.id == &"four_air" and await may("Candid Jester: incinerate to gain a key?", {cost = {burn = true}, gain = {keys = 1}}):
			await incinerate_self()
			await gain_keys()
