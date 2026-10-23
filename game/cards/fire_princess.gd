# Princess of Wands
extends RefCounted

class Top extends Ability:  # Closeted Apostate
	func on_paid(_ev): await gain({F = 1})
	func on_scheme_start(_ev): await adjust_potency(-1)

class Inv extends Ability:  # Flaming Heretic
	func on_leave(_ev): me.spare_faces.append("F")
