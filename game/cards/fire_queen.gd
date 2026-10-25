# Queen of Wands
extends RefCounted

class Top extends Ability:  # Epileptic Metallurgist
	func on_token_gained(ev):
		if ev.type in ["A", "F"] and not ev.additional and await may("Epileptic Metallurgist: gain one more %s?" % ev.type, {gain = {ev.type: 1}}):
			await gain({ev.type: 1}, true)
	func on_scheme_start(_ev): await adjust_potency(-1)

class Inv extends Ability:  # Lithiated Assayer
	func feed() -> void:
		bury("F")
		if buried("F") >= 10:
			await incinerate_self()
			await gain_keys()
	func on_incinerate(ev):
		if ev.card != card: await feed()
	func on_discard(_ev): await feed()
	func on_tooth_lost(_ev): await feed()
	func acts(): return {take = {label = "Gain F off this card"}}
	func can_take(): return buried("F") > 0
	func act_take():
		var n: int = await g.ask(Choice.new(me, &"number", "Take how much F?", [], 1, buried("F"), self, &"amount"))
		await gain({F = unbury("F", n)})
