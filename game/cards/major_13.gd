# Death
extends RefCounted

class Top extends Ability:  # Toothless Grinner
	# Cards route their "or" choices through Ability.either(), which checks this.
	func mod_or_to_and(p, v, _c): return true if p == me else v

class Inv extends Ability:  # Corpse-Like Pauper
	func has_one(d) -> bool: return d.kind == GK.Kind.POTENCY and d.index_of(1) >= 0
	func on_scheme_start(_ev):
		if me.dice.any(has_one) and await may("Replace a 1 with a 9 on a Potency die?", {gain = {face = 1}}):
			await swap_face(9, has_one, func(f): return f is int and f == 1)
