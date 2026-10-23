# Ten of Disks
extends RefCounted

class Top extends Ability:  # Solifactory Smith
	func on_incinerate(_ev): await gain({E = 1})
	func on_score_set(ev):
		if ev.dice.all(func(d): return d.shows("E")) or ev.dice.all(func(d): return d.pips() >= 4): await gain({Q = 1})

class Inv extends Ability:  # Brawny Striker
	# 2026-10-22: triggers on Scheme start (was "On rolling an E", ~5 keys per claim).
	func on_scheme_start(_ev):
		var opts := [{teeth = 2}, {E = 8}, {Q = 4}, {inc = 2}].filter(func(c): return g.can_pay(me, c))
		for c in await either("Brawny Striker: pay for a key?", opts, true, opts.map(func(c): return {cost = c, gain = {keys = 1}})):
			if await pay(c): await gain_keys()
