# The Star
extends RefCounted

class Top extends Ability:  # Silent Companion
	func on_scheme_start(_ev):
		var crystal := func(f): return f is String and f != "" and f != "Q"
		if me.dice.any(func(d): return d.kind == GK.Kind.ELEMENTAL and d.faces.any(crystal)) \
				and await may_pay({Q = 2}, "Silent Companion: spend 2Q to replace an elemental face with Q?", {face = 1}):
			await swap_face("Q", func(d): return d.kind == GK.Kind.ELEMENTAL, crystal)

class Inv extends Ability:  # Patient Confidant
	func on_roll(ev):
		if ev.die.shows("E"): await may_rotate_to(ev, "E", "W")
		elif ev.die.shows("W"): await may_rotate_to(ev, "W", "E")
