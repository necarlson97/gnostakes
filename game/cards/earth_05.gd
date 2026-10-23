# Five of Disks
extends RefCounted

class Top extends Ability:  # Reeking Husk
	func on_roll(ev):
		if not (ev.die.shows("E") or ev.die.shows("A")) or ev.die.discarded(): return
		var pd := me.swig_dice.filter(func(d): return d.kind == GK.Kind.POTENCY and not d.discarded())
		if pd.is_empty() or not await may("Reeking Husk: discard that die and a Potency die for tokens?", {cost = {discard = 2}, gain = {E = 3}}): return
		var p: Die = await g.pick(me, "Discard which Potency die?", pd, self, &"die")
		var tok = "E" if ev.die.shows("E") else await g.pick(me, "Gain A or E?", ["A", "E"], self, &"token")
		await g.discard(me, ev.die, self)
		await g.discard(me, p, self)
		await gain({tok: p.pips()})

class Inv extends Ability:  # Discarded Follower
	func on_commit(ev):
		if ev.src == self: return
		var counts := {}
		for d in ev.dice:
			if d.pips() > 0: counts[d.pips()] = counts.get(d.pips(), 0) + 1
		if counts.values().any(func(n): return n >= 3) and me.ready_dice(): await rotate_and_commit()
	func acts(): return {key = {cost = {one_type = 7}, label = "7 of one token: gain a key"}}
	func act_key(): await gain_keys()
