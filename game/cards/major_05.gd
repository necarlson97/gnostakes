# The Priest
extends RefCounted

class Top extends Ability:  # Plate-Plundering Deacon
	# The extra claim resolves immediately. "Automatically loses against wagers" would only
	# matter if someone requested that card in the same request round (not modelled).
	func on_claim(ev):
		if ev.src == self: return
		var others := g.square.filter(func(c): return c != null)
		if others and await may_pay({Q = 2}, "Deacon: spend 2Q to claim another villager?", {claim_any = 1}):
			await g.claim(me, await g.pick(me, "Claim which?", others, self, &"target"), self)

class Inv extends Ability:  # Pious Parishioner
	func on_incinerate(ev):
		if ev.card != card and me.stat(&"incinerated") >= 2:
			await gain_keys()
			await incinerate_self()
