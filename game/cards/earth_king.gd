# King of Disks
extends RefCounted

class Top extends Ability:  # Iatrochemist
	func on_commit(ev):
		if ev.dice.size() >= 7 and await may("Iatrochemist: bury an E here?", {gain = {E = 1}}): bury("E")
	func acts(): return {rotate = {label = "1 buried E: rotate a committed die to any face"}}
	func can_rotate(): return buried("E") > 0 and not me.committed().is_empty()
	func act_rotate():
		unbury("E", 1)
		await rotate_any(func(d): return d.committed())

class Inv extends Ability:  # Mercury-Blooded
	func on_tooth_lost(_ev): bury("E", 4)
	func acts(): return {rotate = {label = "1 buried E: rotate a committed die to any face"}}
	func can_rotate(): return buried("E") > 0 and not me.committed().is_empty()
	func act_rotate():
		unbury("E", 1)
		await rotate_any(func(d): return d.committed())
