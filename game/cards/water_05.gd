# Five of Cups
extends RefCounted

class Top extends Ability:  # Enthralling Eulogist
	func on_roll(ev): await potency_for(ev, "W")
	func on_scheme_start(_ev): await adjust_potency(-1)

class Inv extends Ability:  # Paid Mourner
	func acts(): return {
		again = {when = "scry", per = &"scry", cost = {W = 2}, label = "2W: score a set again"},
		key = {cost = {W = 6}, label = "6W: gain a key"},
	}
	func can_again(): return not me.scored.is_empty()
	func act_again():
		var s = await g.pick(me, "Score which set again?", me.scored.duplicate(), self, &"set")
		me.scored.append(s)   # an extra entry = an extra villager request
		await g.announce_scored(me, [s])
	func act_key(): await gain_keys()
