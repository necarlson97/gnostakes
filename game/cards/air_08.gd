# Eight of Swords
extends RefCounted

class Top extends Ability:  # Footnoted Scholar
	func on_score_set(ev):
		if not set_has(ev, "F"): return
		for o in await either("Footnoted Scholar: choose one", ["gain 1F", "an opponent loses 3 tokens"], false, [{gain = {F = 1}}, {gain = {hurt = 1}}]):
			if o == "gain 1F": await gain({F = 1})
			else:
				var v: Player = await g.pick(me, "Which opponent?", opponents(), self, &"target")
				for _i in mini(3, v.token_total()):   # they choose which
					var t: String = await g.pick(v, "Lose which token?", GK.TOKENS.filter(func(t): return v.tokens[t] > 0), self, &"token")
					v.tokens[t] -= 1

class Inv extends Ability:  # Pedantic Pedagogue
	func acts(): return {relinquish = {label = "Relinquish onto an opponent's card"}}
	func on_any_invert(ev):
		if attached() and ev.player == victim(): await g.lose_teeth(victim(), 1, self)
