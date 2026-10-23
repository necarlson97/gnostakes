# Two of Cups
extends RefCounted

class Top extends Ability:  # Noble Ghostwriter
	func on_incinerate(_ev): await gain({W = 1})
	func acts(): return {nudge = {when = "roll", per = &"round", cost = {W = 1}, label = "1W: rotate a die one face over"}}
	func act_nudge(): await rotate_step()

class Inv extends Ability:  # Pilfered Penname
	func on_scheme_start(_ev):
		if g.deck.is_empty() or not await may("Pilfered Penname: look at the top card of the deck?", {gain = {info = 1}}): return
		var top: Card = g.deck.back()
		if await may("Incinerate Pilfered Penname to take %s?" % top, {cost = {burn = true}, gain = {claim = top}}):
			await incinerate_self()
			await g.claim(me, g.draw(), self)
	func on_score_set(ev):
		if is_straight(ev):
			await gain_keys()
			await incinerate_self()
