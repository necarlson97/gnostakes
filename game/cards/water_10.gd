# Ten of Cups
extends RefCounted

class Top extends Ability:  # Leech Catcher
	func on_swig_start(_ev):
		var others := me.cadre.filter(func(c): return c != card)
		if others and await may("Leech Catcher: incinerate a card to bury 3F here?", {cost = {inc = 1}, gain = {F = 2}}):
			await g.incinerate(await g.pick(me, "Incinerate which?", others, self, &"cost_inc"), me, self)
			bury("F", 3)
	func acts(): return {leech = {when = "roll", label = "1 buried F: undiscard a die"}}
	func can_leech(): return buried("F") > 0 and not me.discarded().is_empty()
	func act_leech():
		card.unbury("F", 1)
		await g.undiscard(me, await g.pick(me, "Undiscard which die?", me.discarded(), self, &"die"), self)

class Inv extends Ability:  # Bloodless Somnambulist
	func on_leave(_ev): me.spare_faces.append("W")
