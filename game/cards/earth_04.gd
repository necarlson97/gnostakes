# Four of Disks
extends RefCounted

class Top extends Ability:  # Bezoar Seeker
	func on_roll(ev):
		await potency_for(ev, "E")
		if ev.die.crystal() in ["W", "F", "A"] and me.ready_dice() and await may_pay({E = 1}, "Bezoar Seeker: spend 1E to turn a ready die one face?", {control = 1}):
			await rotate_step(func(d): return d.ready())

class Inv extends Ability:  # Sadistic Shepherd
	func acts(): return {
		feed = {cost = {inc = 1}, label = "Incinerate a card: bury 1E here"},
		key = {cost = {E = 2, burn = true}, label = "2E, incinerate: gain a key"},
	}
	func act_feed(): bury("E")
	func act_key(): await gain_keys()
	func on_scheme_start(_ev):
		if buried("E") >= 5 and await may("Sadistic Shepherd: spend 5 buried E to gain an E face?", {cost = {E = 2.5}, gain = {face = 1}}):
			card.unbury("E", 5)
			me.spare_faces.append("E")
