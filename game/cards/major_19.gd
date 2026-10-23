# The Sun
extends RefCounted

class Top extends Ability:  # Reservoir of Sunshine
	func acts(): return {bury = {cost = {discard = 1, Q = 1}, label = "Discard a die + 1Q: bury any token on any card"}}
	func act_bury():
		var c: Card = await g.pick(me, "Bury on which card?", g.live_cards(), self, &"target")
		c.bury(await g.pick(me, "Bury which token?", GK.TOKENS, self, &"token"))

class Inv extends Ability:  # Beloved Homunculus
	func has_crystal(d) -> bool: return d.faces.any(func(f): return f is String and f != "")
	func on_scheme_start(_ev):
		if not me.dice.any(has_crystal) or not await may("Incinerate Beloved Homunculus to turn a die's crystals into one number?", {cost = {burn = true}, gain = {face = 2}}): return
		var d: Die = await g.pick(me, "Which die?", me.dice.filter(has_crystal), self, &"die")
		var n: int = await g.pick(me, "Which number?", GK.POTENCY_FACES, self, &"face")
		await incinerate_self()
		for i in d.faces.size():
			if d.faces[i] is String and d.faces[i] != "": await g.set_face(me, d, i, n, self)
