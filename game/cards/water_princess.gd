# Princess of Cups
extends RefCounted

class Top extends Ability:  # Nubile Nymph
	func on_pre_score(_ev):
		var faces := me.committed().map(func(d): return d.face())
		var only := {only = [&"four_straight", &"five_straight"]}
		if Scoring.arrangements(faces, g.query(&"score_rules", me, only)) == [[]]: return
		if not await may("Nubile Nymph: uncommit a die and bury 1W instead of a long straight?", {cost = {set = 1}, gain = {W = 1, keys = 1 if buried("W") >= 2 else 0}}): return
		await g.uncommit(me, await g.pick(me, "Uncommit which die?", me.committed(), self, &"die"), self)
		bury("W")
		if buried("W") >= 3:
			await incinerate_self()
			await gain_keys()

class Inv extends Ability:  # Virgin Pure
	func on_leave(_ev): me.spare_faces.append("W")
