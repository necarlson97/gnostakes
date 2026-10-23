# Queen of Disks
extends RefCounted

class Top extends Ability:  # Spagyric Physician
	func on_discard(ev):
		if ev.die.kind == GK.Kind.ELEMENTAL and ev.die.crystal() != "": bury(ev.die.crystal())
	func on_score_set(ev):
		if not is_set(ev, [&"triplet", &"quadruplet"]): return
		var tok := {}
		for t in GK.TOKENS:
			if buried(t) > 0: tok[t] = card.unbury(t)
		if tok: await gain(tok)

class Inv extends Ability:  # Arsenic Apothecary
	func on_leave(_ev): me.spare_faces.append("E")
