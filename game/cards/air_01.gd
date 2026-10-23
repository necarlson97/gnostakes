# Ace of Swords
extends RefCounted

class Top extends Ability:  # Glass-Eyed Alchemist
	func on_score_nothing(_ev):
		var best := 0
		for d in me.discarded(): best = maxi(best, d.pips())
		if best: await gain({A = best})
	func acts(): return {uncommit = {when = "roll", cost = {A = 1}, label = "1A: uncommit 2 dice"}}
	func can_uncommit(): return me.committed().size() >= 1
	func act_uncommit():
		for d in await g.pick_many(me, "Uncommit up to 2 dice", me.committed(), 1, 2, self, &"dice"):
			await g.uncommit(me, d, self)

class Inv extends Ability:  # Sun-Blinded Prismist
	# "If all your dice are committed and show either A or 6: you win." (2026-10-22 wording)
	func on_scored(_ev):
		if me.swig_dice.all(func(d): return d.committed() and (d.shows("A") or d.shows(6))): g.win(me, &"prismist")
	func on_score_set(ev):
		if set_has(ev, "A"):
			await gain_keys()
			await incinerate_self()
