# The World
extends RefCounted

class Top extends Ability:  # Mocking Recluse
	func on_leave(_ev): gain_face(await g.pick(me, "Mocking Recluse: gain a face of which colour?", GK.ELEMENTS, self, &"token"))
class Inv extends Ability:  # Jar Dweller
	func on_roll(ev):
		if ev.die.shows("F"): await may_rotate_to(ev, "F", "A")
		elif ev.die.shows("A"): await may_rotate_to(ev, "A", "F")
