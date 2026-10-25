# Variant: Pot-Licking Friar gains 2W per discard.
extends RefCounted

const TEXT := {inv_rule = "Whenever you discard a die, gain 2W.\nSpend 2W to gain 1 key and incinerate this card."}
const FEATURES := {inv = {discard_payoff = 1.0, gain_W = 2.0, keys = 1.0, use_W = 1.0}}

class Top extends Ability:  # Hollow-Bellied Saint
	func on_roll(ev): await potency_for(ev, "W")
	func on_scheme_start(_ev): await adjust_potency(-1)

class Inv extends Ability:  # Pot-Licking Friar
	func on_discard(_ev): await gain({W = 2})
	func acts(): return {key = {cost = {W = 2, burn = true}, label = "2W, incinerate: gain a key"}}
	func act_key(): await gain_keys()
