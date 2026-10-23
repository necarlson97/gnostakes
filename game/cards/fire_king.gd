# King of Wands
extends RefCounted

class Top extends Ability:  # Unshakable Empiricist
	func acts(): return {relinquish = {label = "Relinquish onto an opponent's card"}}
	func replace_gain_keys(ev):
		if not attached() or ev.player != victim(): return false
		await g.gain_teeth(ev.player, ev.amount, self)
		return true

class Inv extends Ability:  # Vivisectionist
	func replace_gain_keys(ev):
		if ev.player != me or ev.src == self: return false
		var d: Die = await g.pick(me, "Vivisectionist: roll which die for your key?", me.dice, self, &"die")
		await g.toss(me, [d])
		var v := d.pips()
		var k := 0 if v <= 2 else (1 if v <= 5 else 2)
		await g.emit(&"vivisect", {player = me, die = d, keys = k})
		if k > 0: await g.gain_keys(me, k, self, ev.additional)
		return true
