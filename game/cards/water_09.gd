# Nine of Cups
extends RefCounted

class Top extends Ability:  # Epicurean Gourmand
	func on_score_set(ev):
		if not set_has(ev, "W"): return
		if me.cadre: await g.incinerate(await g.pick(me, "Epicurean Gourmand: incinerate a card", me.cadre.duplicate(), self, &"cost_inc"), me, self)
		await gain({Q = 2})

class Inv extends Ability:  # Gout-Ridden Glutton
	func on_scry_start(_ev):
		if me.discarded(): return
		var purge := {cost = {W = me.tokens.W, E = me.tokens.E, burn = true}, gain = {keys = 1}}
		for o in await either("Gout-Ridden Glutton: choose one", ["gain 2W", "purge for a key"], false, [{gain = {W = 2}}, purge]):
			if o == "gain 2W": await gain({W = 2})
			else:
				me.tokens.W = 0
				me.tokens.E = 0
				await incinerate_self()
				await gain_keys()
