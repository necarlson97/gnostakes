# Five of Swords
extends RefCounted

class Top extends Ability:  # Bodysnatcher
	func on_incinerate(_ev): await gain({A = 1})
	func acts(): return {snatch = {cost = {A = 4}, label = "4A: claim the top card of the pyre"}}
	func can_snatch(): return not g.pyre.is_empty()
	func act_snatch(): await g.claim(me, g.pyre.back(), self)

class Inv extends Ability:  # Overworked Gravedigger
	var named: StringName
	func on_swig_start(_ev):
		named = (await g.pick(me, "Overworked Gravedigger: name a set", Scoring.MENU, self, &"set")).id
		once(&"named", &"round")
		await gain({A = 1})
	func mod_score_rules(p, r, _c):
		if p == me and used(&"named", &"round"): r.only = [named]
		return r
	func acts(): return {key = {cost = {A = 5}, label = "5A: gain a key"}}
	func act_key(): await gain_keys()
