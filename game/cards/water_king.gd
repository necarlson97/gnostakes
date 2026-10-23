# King of Cups
extends RefCounted

class Top extends Ability:  # Sulfurous Sage
	func on_score_set(ev):
		if ev.id == &"all_colors" and GK.ELEMENTS.any(func(t): return me.tokens[t] == 0):
			await gain({E = 1, W = 1, F = 1, A = 1})

class Inv extends Ability:  # Socratic Self-Slayer
	# "The player with the most keys" read as the opponent with the most keys.
	func acts(): return {key = {cost = {teeth = 2, burn = true}, label = "Lose 2 teeth, incinerate: take a key from the leader"}}
	func can_key(): return opponents().any(func(p): return p.keys > 0)
	func act_key():
		var top: int = opponents().map(func(p): return p.keys).max()
		var o: Player = await g.pick(me, "Take a key from whom?", opponents().filter(func(p): return p.keys == top), self, &"target")
		await g.lose_keys(o, 1, self)
		await gain_keys()
