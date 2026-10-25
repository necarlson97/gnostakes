# Variant: Powder Monkey's key costs 4F (was 5F).
extends RefCounted

const TEXT := {inv_rule = "Incinerate this card to force all opponents to lose a tooth.\nSpend 4F to gain 1 key."}
const FEATURES := {inv = {aggro = 1.0, keys = 1.0, use_F = 1.0}}

class Top extends Ability:  # Fingerless Sapper
	func on_roll(ev): await potency_for(ev, "F")
	func acts(): return {undiscard = {when = "roll", per = &"round", cost = {F = 2}, label = "2F: undiscard all discarded dice"}}
	func can_undiscard(): return not me.discarded().is_empty()
	func act_undiscard():
		for d in me.discarded(): await g.undiscard(me, d, self)

class Inv extends Ability:  # Powder Monkey
	func acts(): return {
		blast = {cost = {burn = true}, label = "Incinerate: all opponents lose a tooth"},
		key = {cost = {F = 4}, label = "4F: gain a key"},
	}
	func can_blast(): return opponents().any(func(o): return o.teeth > 0)
	func act_blast():
		for o in opponents(): await g.lose_teeth(o, 1, self)
	func act_key(): await gain_keys()
