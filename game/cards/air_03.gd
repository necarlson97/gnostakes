# Three of Swords
extends RefCounted

class Top extends Ability:  # Persecuted Paranoiac
	func on_token_gained(ev):
		if ev.type == "A" and not ev.additional and await may("Persecuted Paranoiac: gain +1A?", {gain = {A = 1}}): await gain({A = 1}, true)
	func acts(): return {purge = {cost = {F = 1}, label = "1F: incinerate and redraw a Town Square villager"}}
	func can_purge(): return g.square.any(func(c): return c != null)
	func act_purge():
		await g.incinerate(await g.pick(me, "Incinerate which villager?", g.square.filter(func(c): return c != null), self, &"target"), me, self)

class Inv extends Ability:  # Psychotic Christ
	func on_score_set(ev):
		if set_has(ev, "F") and await may_pay({teeth = 1}, "Psychotic Christ: lose a tooth to make an opponent lose one?", {hurt = 1}):
			await g.lose_teeth(await g.pick(me, "Who loses a tooth?", opponents(), self, &"target"), 1, self)
	func acts(): return {key = {cost = {A = 2, burn = true}, label = "2A, incinerate: gain a key"}}
	func act_key(): await gain_keys()
