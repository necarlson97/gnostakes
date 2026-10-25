# Princess of Swords
extends RefCounted

class Top extends Ability:  # Driveling Chemist
	# Ties for fewest count as "the fewest".
	func on_scheme_start(_ev):
		if me.keys <= g.players.map(func(p): return p.keys).min(): await gain({E = 1, W = 1, F = 1, A = 1})

class Inv extends Ability:  # Feverish Scribe
	func acts(): return {scribble = {when = "roll", cost = {discard = 2}, label = "Discard two dice: bury 1A here"}}
	func act_scribble(): bury("A")
	func mod_win_keys(_p, v, _c): return buried("A") if buried("A") > 7 else v
