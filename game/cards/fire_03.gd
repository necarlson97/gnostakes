# Three of Wands
extends RefCounted

class Top extends Ability:  # Academic Artillerist
	func on_token_gained(ev):
		if ev.type == "F" and not ev.additional and await may("Academic Artillerist: gain +1F?", {gain = {F = 1}}): await gain({F = 1}, true)
	func mod_request_order(_p, order, _c):
		order.erase(me)
		order.push_front(me)
		return order

class Inv extends Ability:  # Craven Cannoneer
	func mod_can_lose_teeth(p, v, ev):
		return false if p == me and ev.get("by") != null and ev.by != me else v
	func acts(): return {key = {cost = {F = 2, burn = true}, label = "2F, incinerate: gain a key"}}
	func act_key(): await gain_keys()
