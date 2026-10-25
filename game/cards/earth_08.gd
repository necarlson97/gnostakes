# Eight of Disks
extends RefCounted

class Top extends Ability:  # Venomous Vessel
	func on_roll(ev):
		if ev.die.discarded(): return
		if ev.die.shows("E") and await may("Venomous Vessel: discard that E to bury 1E here?", {cost = {discard = 1}, gain = {E = 1}}):
			await g.discard(me, ev.die, self)
			bury("E")
		elif ev.die.shows("W") and buried("E") > 0 and await may("Venomous Vessel: discard that W to gain the %d buried E?" % buried("E"), {cost = {discard = 1}, gain = {E = buried("E")}}):
			await g.discard(me, ev.die, self)
			await gain({E = unbury("E")})
	func on_rolled(ev):
		var airs: Array = ev.dice.filter(func(d): return d.shows("A") and d.ready())
		if airs.size() >= 2 and buried("E") > 0 and await may("Venomous Vessel: discard two A to double the buried E?", {cost = {discard = 2}, gain = {E = buried("E")}}):
			for d in airs.slice(0, 2): await g.discard(me, d, self)
			bury("E", buried("E"))

class Inv extends Ability:  # Sinuous Acolyte
	func on_roll(ev):
		if ev.die.shows("E") and not ev.die.discarded() and await may("Sinuous Acolyte: discard that E to bury 1E here?", {cost = {discard = 1}, gain = {E = 1}}):
			await g.discard(me, ev.die, self)
			bury("E")
	func on_swig_start(_ev):
		if buried("E") > 0 and me.ready_dice() and await may("Sinuous Acolyte: spend 1 buried E to rotate and commit a ready die?", {cost = {E = 0.5}, gain = {control = 2}}):
			unbury("E", 1)
			await rotate_and_commit()
