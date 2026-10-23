# Seven of Disks
extends RefCounted

class Top extends Ability:  # Perennial Pruner
	func on_swig_start(_ev):
		if me.ready_dice() and await may_pay({E = 2}, "Perennial Pruner: spend 2E to rotate and commit a ready die?", {control = 2}):
			await rotate_and_commit()
	func on_wager_won(_ev): await g.gain_teeth(me, 1, self)

class Inv extends Ability:  # Haphazard Herbalist
	func on_score_set(ev):
		if not is_set(ev, [&"two_color_pairs", &"triplet", &"quadruplet"]): return
		var opts := [{E = 8}, {keys = 1}].filter(func(c): return g.can_pay(me, c))
		for c in await either("Haphazard Herbalist: pay to regain 2 teeth?", opts, true, opts.map(func(c): return {cost = c, gain = {teeth = 2}})):
			if await pay(c): await g.gain_teeth(me, 2, self)
