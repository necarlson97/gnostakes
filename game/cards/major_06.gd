# The Lovers
extends RefCounted

class Top extends Ability:  # Doomed Romantic
	func on_leave(_ev):
		var o: Player = await g.pick(me, "Swap tooth count with whom?", opponents(), self, &"target")
		var t := me.teeth
		me.teeth = o.teeth
		o.teeth = t
		await g.emit(&"teeth_swapped", {player = me, other = o})
		await lose_teeth(1)

class Inv extends Ability:  # Kismet Syzygyst
	func on_scheme_start(_ev):
		if await may("Incinerate Kismet Syzygyst for an all-Fire elemental die?", {cost = {burn = true}, gain = {die = 1}}):
			await incinerate_self()
			g.give_die(me, Die.uniform("F"))
