# Justice
extends RefCounted

class Top extends Ability:  # Clamp-Turning Examiner
	func acts(): return {relinquish = {label = "Relinquish onto an opponent's card"}}
	func on_any_claim(ev):
		if attached() and ev.player == victim() and await may("Incinerate their new %s along with the Examiner?" % ev.card, {cost = {burn = true}, gain = {deny = ev.card}}):
			await g.incinerate(ev.card, me, self)
			await incinerate_self()

class Inv extends Ability:  # Confessional Magistrate
	func on_scheme_start(_ev):
		if not await may("Swap two faces on your dice?", {gain = {face = 0.5}}): return
		var a: Die = await g.pick(me, "First die", me.dice, self, &"die")
		var i: int = await g.pick_face(me, "Which face?", range(a.faces.size()), self)
		var b: Die = await g.pick(me, "Second die", me.dice, self, &"die")
		var j: int = await g.pick_face(me, "Which face?", range(b.faces.size()), self)
		var fa = a.faces[i]
		await g.set_face(me, a, i, b.faces[j], self)
		await g.set_face(me, b, j, fa, self)
