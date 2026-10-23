# Prince of Wands
extends RefCounted

class Top extends Ability:  # Strawman
	func mod_cost(p, cost, _c):
		if p != me: return cost
		return {A = 1} if g.has(p, {A = 1}) else {teeth = 2}

class Inv extends Ability:  # Burnt Effigy
	func on_leave(_ev): me.spare_faces.append("F")
