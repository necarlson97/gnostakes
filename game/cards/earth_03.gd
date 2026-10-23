# Three of Disks
extends RefCounted

class Top extends Ability:  # Alembic Servitor
	var die := _empty()
	static func _empty() -> Die:
		var d := Die.uniform("")
		d.locked_empty = true
		return d
	func mod_bonus_dice(p, v, _c): return with_die(p, v, die)

class Inv extends Ability:  # Burn-Scarred Glasswright
	func on_score_set(ev):
		if ev.dice.size() >= 5: await gain({E = 1})
	func acts(): return {key = {cost = {E = 2, burn = true}, label = "2E, incinerate: gain a key"}}
	func act_key(): await gain_keys()
