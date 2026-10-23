# Five of Wands
extends RefCounted

class Top extends Ability:  # Fingerless Sapper
	func on_roll(ev): await potency_for(ev, "F")
	func acts(): return {undiscard = {when = "roll", per = &"round", cost = {F = 2}, label = "2F: undiscard all discarded dice"}}
	func can_undiscard(): return not me.discarded().is_empty()
	func act_undiscard():
		for d in me.discarded(): await g.undiscard(me, d, self)

class Inv extends Ability:  # Powder Monkey
	func acts(): return {
		blast = {cost = {burn = true}, label = "Incinerate: all opponents lose a tooth"},
		key = {cost = {F = 5}, label = "5F: gain a key"},
	}
	func act_blast():
		for o in opponents(): await g.lose_teeth(o, 1, self)
	func act_key(): await gain_keys()
