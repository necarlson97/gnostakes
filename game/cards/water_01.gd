# Ace of Cups
extends RefCounted

class Top extends Ability:  # Lead Drinker
	func on_commit(ev):
		if ev.dice.filter(func(d): return d.shows("W")).size() < 2: return
		var pd := me.swig_dice.filter(func(d): return d.kind == GK.Kind.POTENCY and not d.discarded())
		if pd and await may("Lead Drinker: discard a Potency die to gain that much W?", {cost = {discard = 1}, gain = {W = 3}}):
			var d: Die = await g.pick(me, "Discard which Potency die?", pd, self, &"die")
			await g.discard(me, d, self)
			await gain({W = d.pips()})
	func acts(): return {undiscard = {when = "roll", cost = {W = 1}, label = "1W: undiscard and reroll a die"}}
	func can_undiscard(): return not me.discarded().is_empty()
	func act_undiscard():
		var d: Die = await g.pick(me, "Undiscard which die?", me.discarded(), self, &"die")
		await g.undiscard(me, d, self)
		await g.roll(me, [d])
		if d.shows(1): await lose_teeth(1)

class Inv extends Ability:  # Bacchus Host
	func mod_wager_auto_win(p, v, _c): return true if p == me else v
	func on_score_set(ev):
		if color_set(ev, &"four_of_a_color", "W"):
			await gain_keys()
			await incinerate_self()
