# Three of Cups
extends RefCounted

class Top extends Ability:  # Gin-Soaked Gutter-Sweeper
	func on_token_gained(ev):
		if ev.type == "W" and not ev.additional and await may("Gutter-Sweeper: gain +1W?", {gain = {W = 1}}): await gain({W = 1}, true)
	func acts(): return {mimic = {when = "roll", per = &"round", cost = {W = 1}, label = "1W: rotate a die to match another rolled face"}}
	func can_mimic(): return live_dice().size() >= 2
	func act_mimic():
		var live := me.swig_dice.filter(func(d): return not d.discarded())
		var d: Die = await g.pick(me, "Rotate which die?", live, self, &"die")
		var targets := []
		for o in live:
			var i: int = d.faces.find(o.face())
			if o != d and i >= 0 and not targets.has(i): targets.append(i)
		if targets: await g.rotate(me, d, await g.pick_face(me, "Match which face?", targets, self), self)

class Inv extends Ability:  # Dependable Tosspot
	func on_score_nothing(_ev): await gain({W = 3})
	func acts(): return {key = {cost = {W = 2, burn = true}, label = "2W, incinerate: gain a key"}}
	func act_key(): await gain_keys()
