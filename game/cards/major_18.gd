# The Moon
extends RefCounted

class Top extends Ability:  # Sane Sorrowful
	var die := Die.uniform("W")
	func mod_bonus_dice(p, v, _c): return with_die(p, v, die)
	func on_commit(ev):
		if ev.dice.any(func(d): return d.shows("W")):
			var d = await g.pick_die(me, "Sane Sorrowful: discard a die", func(d): return not d.discarded(), self)
			if d: await g.discard(me, d, self)

class Inv extends Ability:  # Insane Incandescent
	var die := Die.uniform("")
	func mod_bonus_dice(p, v, _c): return with_die(p, v, die)
	func mod_win_keys(_p, v, _c): return v + 1
