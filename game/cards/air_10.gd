# Ten of Swords
extends RefCounted

class Top extends Ability:  # Mercurial Monomaniac
	func on_incinerate(ev):
		if ev.card == card: return
		bury("F")
		if buried("F") >= 5:
			await incinerate_self()
			await gain_keys()
	func acts(): return {rotate = {when = "roll", label = "1 buried F: rotate a die to any face"}}
	func can_rotate(): return buried("F") > 0
	func act_rotate():
		card.unbury("F", 1)
		await rotate_any()

class Inv extends Ability:  # Haunted Mind
	func acts(): return {relinquish = {label = "Relinquish onto an opponent's card"}}
	func on_any_incinerate(ev):
		var v := victim()
		if not attached() or ev.player != v or ev.src == self or v.cadre.is_empty(): return
		await g.incinerate(await g.pick(v, "Haunted Mind: incinerate an additional card", v.cadre.duplicate(), self, &"cost_inc"), v, self)
