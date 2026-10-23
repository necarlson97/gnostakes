# Ace of Disks
extends RefCounted

class Top extends Ability:  # Primed Pomologist
	func on_scry_start(_ev):
		var best := 0
		for d in me.discarded(): best = maxi(best, d.pips())
		if best <= 0: return
		if best >= 6 and await may("Primed Pomologist: take 2Q instead of %dE?" % best, {cost = {E = best}, gain = {Q = 2}}): await gain({Q = 2})
		else: await gain({E = best})

class Inv extends Ability:  # Charitable Ciderist
	func on_token_gained(ev):
		if ev.type in ["E", "W"] and not ev.additional and await may("Charitable Ciderist: gain one more %s?" % ev.type, {gain = {ev.type: 1}}):
			await gain({ev.type: 1}, true)
	func on_score_set(ev):
		if color_set(ev, &"four_of_a_color", "E"):
			await gain_keys()
			await incinerate_self()
