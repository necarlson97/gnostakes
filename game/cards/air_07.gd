# Seven of Swords
extends RefCounted

class Top extends Ability:  # Reliquary Larcenist
	func on_score_set(ev):
		if ev.id == &"four_of_a_color": await gain({A = 3})
		elif ev.id == &"five_of_a_color": await gain({A = 6})

class Inv extends Ability:  # Finger-Bone Forager
	func acts(): return {
		key = {cost = {Q = 2, burn = true}, label = "2Q, incinerate: gain a key"},
		quint = {when = "scheme", cost = {A = 3}, label = "3A: replace a crystal face with Q"},
	}
	func act_key(): await gain_keys()
	func act_quint(): await swap_face("Q", func(d): return d.kind == GK.Kind.ELEMENTAL, func(f): return f is String and f != "" and f != "Q")
