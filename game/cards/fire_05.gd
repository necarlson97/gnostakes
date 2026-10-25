# Five of Wands
extends RefCounted

class Top extends Ability:  # Fingerless Sapper
	func on_roll(ev): await potency_for(ev, "F")
	# For bots: each discarded elemental rolls again (about 1.5 more rolls this Swig), and an F
	# on it discards a Potency die for ~4.5F, so about 1.1F per elemental brought back.
	func acts():
		var elem := me.discarded().filter(func(d): return d.kind == GK.Kind.ELEMENTAL).size() if me else 0
		return {undiscard = {when = "roll", per = &"round", cost = {F = 2}, label = "2F: undiscard all discarded dice",
			gain = {control = 2, F = int(round(elem * 1.1))}}}
	func can_undiscard(): return not me.discarded().is_empty()
	func act_undiscard():
		for d in me.discarded(): await g.undiscard(me, d, self)

class Inv extends Ability:  # Powder Monkey
	func acts(): return {
		blast = {cost = {burn = true}, label = "Incinerate: all opponents lose a tooth"},
		key = {cost = {F = 5}, label = "5F: gain a key"},
	}
	func can_blast(): return opponents().any(func(o): return o.teeth > 0)
	func act_blast():
		for o in opponents(): await g.lose_teeth(o, 1, self)
	func act_key(): await gain_keys()
