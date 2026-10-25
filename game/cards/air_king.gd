# King of Swords
extends RefCounted

class Top extends Ability:  # Dubious Demonologist
	func on_roll(ev): await potency_for(ev, "A")
	func acts(): return {quint = {when = "scheme", cost = {A = 3}, label = "3A: replace a crystal face with Q"}}
	func act_quint():
		var d: Die = await g.pick(me, "Which die?", me.dice.filter(func(d): return d.kind == GK.Kind.ELEMENTAL and d.faces.any(func(f): return f is String and f != "" and f != "Q")), self, &"die")
		var crystal := range(d.faces.size()).filter(func(i): return d.faces[i] is String and d.faces[i] != "" and d.faces[i] != "Q")
		await g.set_face(me, d, await g.pick_face(me, "Replace which face?", crystal, self), "Q", self)

class Inv extends Ability:  # Failed Exorcist
	# Copies the live ability of the card to its left in the cadre. The copy is bound to
	# this card, so "this card" in the copied text means the Exorcist.
	var _copy: Ability
	func resolve() -> Ability:
		var i := me.cadre.find(card) if me else -1
		if i <= 0: return self
		var left := me.cadre[i - 1].ability
		if left.implemented and (not _copy or _copy.get_script() != left.get_script()):
			_copy = left.get_script().new()
			_copy.card = card
			_copy.g = g
			_copy.title = "%s (as %s)" % [title, left.title]
			_copy.text = left.text
		return _copy if _copy and _copy.get_script() == left.get_script() else self
