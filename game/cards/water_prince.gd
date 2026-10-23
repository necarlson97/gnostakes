# Prince of Cups
extends RefCounted

class Top extends Ability:  # Orgasmic Musician
	func on_scheme_start(_ev): await adjust_potency(1)
	func on_score_set(ev):
		if is_set(ev, [&"two_color_pairs", &"four_pairs"]): bury("W")
	func acts(): return {uncommit = {when = "roll", label = "1 buried W: uncommit a die"}}
	func can_uncommit(): return buried("W") > 0 and not me.committed().is_empty()
	func act_uncommit():
		card.unbury("W", 1)
		await g.uncommit(me, await g.pick(me, "Uncommit which die?", me.committed(), self, &"die"), self)

class Inv extends Ability:  # Brooding Composer
	func acts(): return {relinquish = {label = "Relinquish onto an opponent's card"}}
	func on_any_token_gained(ev):
		if attached() and ev.player == victim() and ev.type in ["E", "W"] and ev.src != self:
			await gain({ev.type: 1}, true)
