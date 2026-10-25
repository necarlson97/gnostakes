# Seven of Cups
extends RefCounted

class Top extends Ability:  # Worm-Brained Absinthard
	func on_score_set(ev):
		if is_straight(ev): bury("W", 2)
		else: unbury("W", 1)
	func on_score_nothing(_ev): unbury("W", 1)

class Inv extends Ability:  # Fairy-Chaser
	# "Exactly 5" is checked on the amount gained.
	func acts(): return {drink = {label = "Gain all W buried here"}}
	func can_drink(): return buried("W") > 0
	func act_drink():
		var n := unbury("W")
		await gain({W = n})
		if n == 5:
			await g.gain_teeth(me, 1, self)
			await incinerate_self()
