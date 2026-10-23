# Princess of Disks
extends RefCounted

class Top extends Ability:  # Hopeful Sower
	func on_score_set(ev):
		if not is_set(ev, [&"two_color_pairs", &"triplet", &"quadruplet"]): return
		for o in await either("Hopeful Sower: choose one", ["gain 2E", "bury a token on any card"], false, [{gain = {E = 2}}, {gain = {option = 1}}]):
			if o == "gain 2E": await gain({E = 2})
			else:
				var c: Card = await g.pick(me, "Bury on which card?", g.live_cards(), self, &"target")
				c.bury(await g.pick(me, "Bury which token?", GK.TOKENS, self, &"token"))

class Inv extends Ability:  # Grain Hoarder
	func on_scheme_start(_ev):
		var crystal := func(f): return f is String and f != "" and f != "E"
		if me.dice.any(func(d): return d.faces.any(crystal)) and await may("Grain Hoarder: replace a crystal with E?", {gain = {face = 0.5}}):
			await swap_face("E", func(d): return d.faces.any(crystal), crystal)
