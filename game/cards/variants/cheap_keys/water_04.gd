# Variant: Pot-Licking Friar keeps itself; its key costs 3W and repeats.
extends RefCounted

const TEXT := {inv_rule = "Whenever you discard a die, gain 1W.\nSpend 3W to gain 1 key."}
const FEATURES := {inv = {discard_payoff = 1.0, gain_W = 1.0, keys = 1.0, use_W = 1.0}}

class Top extends Ability:  # Hollow-Bellied Saint
	func on_roll(ev): await potency_for(ev, "W")
	func on_scheme_start(_ev): await adjust_potency(-1)

class Inv extends Ability:  # Pot-Licking Friar
	func on_discard(_ev): await gain({W = 1})
	func acts(): return {key = {cost = {W = 3}, label = "3W: gain a key"}}
	func act_key(): await gain_keys()
