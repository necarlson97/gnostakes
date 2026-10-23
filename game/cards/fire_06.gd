# Six of Wands
extends RefCounted

class Top extends Ability:  # Short-Lived Brute
	func on_roll(ev):
		for t in ["W", "F"]:
			if ev.die.shows(t) and await may("Short-Lived Brute: bury a %s here?" % t, {gain = {E = 0.5}}): bury(t)
	# Burning clears buried tokens, so the payout is counted before paying.
	func acts(): return {cash = {label = "Incinerate: gain E equal to the lower of buried W and F"}}
	func act_cash():
		var n := mini(buried("W"), buried("F"))
		if await pay({burn = true}) and n > 0: await gain({E = n})

class Inv extends Ability:  # Timeless Warrior-Poet
	func on_incinerate(_ev): await gain({F = 1})
	func acts(): return {uncommit = {when = "roll", cost = {F = 1}, label = "1F: uncommit a die"}}
	func can_uncommit(): return not me.committed().is_empty()
	func act_uncommit(): await g.uncommit(me, await g.pick(me, "Uncommit which die?", me.committed(), self, &"die"), self)
