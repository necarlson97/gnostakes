# The Emperor
extends RefCounted

class Top extends Ability:  # Incorruptible Judge
	var die := Die.uniform("E")
	func mod_bonus_dice(p, v, _c): return with_die(p, v, die)
	func on_score_set(ev):
		if set_has(ev, "E"): return
		var kinds := ["W", "F", "A", "Q"].filter(func(t): return me.tokens[t] > 0)
		if kinds.is_empty():
			await lose_teeth(1)
			return
		var t: String = await g.pick(me, "Convert all of which token to E?", kinds, self, &"token")
		me.tokens.E += me.tokens[t]
		me.tokens[t] = 0
		await g.emit(&"convert", {player = me, from = t, to = "E"})

class Inv extends Ability:  # Hardnosed Idealist
	func on_scheme_start(_ev):
		if not await may("Incinerate Hardnosed Idealist to make a die all one colour?", {cost = {burn = true}, gain = {face = 2}}): return
		var d: Die = await g.pick(me, "Which die?", me.dice.filter(func(d): return d.kind == GK.Kind.ELEMENTAL), self, &"die")
		var col: String = await g.pick(me, "Which colour?", GK.ELEMENTS, self, &"token")
		await incinerate_self()
		for i in d.faces.size():
			if d.faces[i] is String and d.faces[i] != "": await g.set_face(me, d, i, col, self)
