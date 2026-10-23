# Ten of Wands
extends RefCounted

class Top extends Ability:  # Covert Degenerate
	func acts(): return {
		uncommit = {when = "roll", cost = {F = 1}, label = "1F: uncommit a die"},
		rotate = {when = "roll", per = &"round", cost = {E = 2}, label = "2E: rotate a die to any face"},
	}
	func can_uncommit(): return not me.committed().is_empty()
	func act_uncommit(): await g.uncommit(me, await g.pick(me, "Uncommit which die?", me.committed(), self, &"die"), self)
	func act_rotate(): await rotate_any()
	func on_scheme_start(_ev): await adjust_potency(1)

class Inv extends Ability:  # Esteemed Burgher
	# The reserving tooth leaves your mouth and sits on a slot (the slot, not the villager in it).
	# Whoever claims from that slot pays you 2 tokens of their choice (largest piles first).
	var slot := -1
	func acts(): return {reserve = {cost = {teeth = 1}, label = "Place a tooth on a Town Square slot"}}
	func can_reserve(): return slot < 0
	func act_reserve(): slot = await g.pick(me, "Reserve which slot?", range(g.square.size()), self, &"slot")
	func on_any_claim(ev):
		if slot >= 0 and ev.slot == slot and ev.player != me:
			var paid := g.spend_any(ev.player, 2)
			for t in paid: me.tokens[t] += paid[t]
			await g.emit(&"tribute", {player = ev.player, to = me, tokens = paid})
	func replace_lose_tooth(ev):
		if ev.player != me or slot < 0: return false
		slot = -1
		return true
	func on_leave(_ev): slot = -1
