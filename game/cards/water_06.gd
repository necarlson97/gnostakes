# Six of Cups
extends RefCounted

class Top extends Ability:  # Twofold Widow
	func on_score_set(ev):
		if is_straight(ev): bury("E")
	func acts(): return {earth = {when = "scheme", label = "1 buried E: swap in an E for any face"}}
	func can_earth(): return buried("E") > 0
	func act_earth():
		card.unbury("E", 1)
		await swap_face("E")

class Inv extends Ability:  # Lethean Elder
	func on_score_nothing(_ev): await wipe_for_keys(2)
