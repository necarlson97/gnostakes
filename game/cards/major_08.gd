# Strength
extends RefCounted

class Top extends Ability:  # Hard-Weathered Quarryman
	func on_scheme_start(_ev):
		if await may_pay({A = 1}, "Spend 1A to swap a 6 onto a Potency die?", {face = 1}):
			var d: Die = await g.pick(me, "Which die?", me.dice.filter(func(d): return d.kind == GK.Kind.POTENCY), self, &"die")
			await g.set_face(me, d, await g.pick_face(me, "Replace which face?", range(d.faces.size()), self), 6, self)

class Inv extends Ability:  # Stonefaced Stoic
	# Buried teeth leave your mouth (they don't count toward your total) - open question.
	func replace_lose_tooth(ev):
		if ev.player != me: return false
		me.teeth -= 1
		bury("tooth")
		if me.teeth <= 0: g.end_when(&"putrescence")
		if buried("tooth") >= 3: await incinerate_self()
		return true
	func on_leave(ev):
		if ev.src != self: await g.gain_teeth(me, buried("tooth"), self)
