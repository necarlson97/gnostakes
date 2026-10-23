# Two of Disks
extends RefCounted

class Top extends Ability:  # Passive Puffer
	func on_commit(ev):
		if ev.dice.size() < 5: return
		var others := me.committed().filter(func(d): return not ev.dice.has(d))
		if others and await may("Passive Puffer: uncommit another die?", {gain = {control = 1}}):
			await g.uncommit(me, await g.pick(me, "Uncommit which die?", others, self, &"die"), self)
	func on_scheme_start(_ev): await adjust_potency(1)

class Inv extends Ability:  # Active Assistant
	func acts(): return {q = {cost = {any = 2}, label = "2 tokens: gain 1Q"}}
	func act_q(): await gain({Q = 1})
	func on_score_set(ev):
		if ev.id == &"triplet":
			await gain_keys()
			await incinerate_self()
