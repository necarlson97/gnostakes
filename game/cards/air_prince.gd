# Prince of Swords
extends RefCounted

class Top extends Ability:  # Autoerotic Anesthetist
	func mod_cost_alts(p, alts, ctx):
		if p == me and not ctx.cost.has("burn_card"): alts.append({burn_card = card})
		return alts

class Inv extends Ability:  # Back-Alley Butcher
	func on_key_gained(ev):
		if ev.additional: return
		if me.token_total() > 0:
			for t in GK.TOKENS: me.tokens[t] = 0
		else:
			await lose_teeth(1)
		await gain_keys(1, true)
