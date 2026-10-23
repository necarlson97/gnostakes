class_name Card extends RefCounted
## A villager card. It holds two Abilities (upright / inverted). Inverting spins the
## card 180 degrees to switch which one is live; it is never flipped face-down.

var id: String               # stable tarot id, e.g. "major_00", "cups_queen"
var info: Dictionary         # row from data/cards.json (names, text, suit...)
var faces: Array[Ability]    # [upright, inverted]
var inverted := false
var loc := GK.Loc.DECK
var owner: Player            # "you" for this card's text (the relinquisher, if attached)
var attached_to: Card        # set while relinquished onto another card
var buried := {}             # token/tooth -> count buried on this card

var ability: Ability:
	get: return faces[1 if inverted else 0]
var title: String:
	get: return ability.title

## The player whose cadre physically holds this card (differs from owner when attached).
func holder() -> Player: return attached_to.holder() if attached_to else owner
func in_play() -> bool: return loc == GK.Loc.CADRE or loc == GK.Loc.ATTACHED
func buried_n(k: String) -> int: return buried.get(k, 0)
func bury(k: String, n := 1) -> void: buried[k] = buried.get(k, 0) + n
func unbury(k: String, n := -1) -> int:
	var have := buried_n(k)
	var take := have if n < 0 else mini(n, have)
	buried[k] = have - take
	return take

func _to_string() -> String: return "%s%s" % [title, " (inv)" if inverted else ""]
