# Variant: Powder Monkey's blast needs 3F of powder (so Sapper builds F first).
extends RefCounted

const TEXT := {inv_rule = "Spend 3F and incinerate this card to force all opponents to lose a tooth.\nSpend 5F to gain 1 key."}
const FEATURES := {inv = {aggro = 1.0, keys = 1.0, use_F = 2.0}}

class Top extends Ability:  # Fingerless Sapper
	func on_roll(ev): await potency_for(ev, "F")
	func acts(): return {undiscard = {when = "roll", per = &"round", cost = {F = 2}, label = "2F: undiscard all discarded dice"}}
	func can_undiscard(): return not me.discarded().is_empty()
	func act_undiscard():
		for d in me.discarded(): await g.undiscard(me, d, self)

class Inv extends Ability:  # Powder Monkey
	func acts(): return {
		blast = {cost = {F = 3, burn = true}, label = "3F, incinerate: all opponents lose a tooth"},
		key = {cost = {F = 5}, label = "5F: gain a key"},
	}
	func can_blast(): return opponents().any(func(o): return o.teeth > 0)
	func act_blast():
		for o in opponents(): await g.lose_teeth(o, 1, self)
	func act_key(): await gain_keys()
