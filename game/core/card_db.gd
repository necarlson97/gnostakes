class_name CardDB
## Loads card text from data/cards.json and behaviour from res://cards/<id>.gd.
## A card script defines inner classes `Top` and `Inv` (both extend Ability). Faces
## without a script still load, as text-only abilities (implemented = false).

const DATA := "res://data/cards.json"
const SCRIPTS := "res://cards/%s.gd"

static var _rows: Array = []

static func rows() -> Array:
	if _rows.is_empty():
		_rows = JSON.parse_string(FileAccess.get_file_as_string(DATA))
	return _rows

static func row(id: String) -> Dictionary:
	for r in rows():
		if r.id == id: return r
	return {}

static func make(g: Game, id: String) -> Card:
	var r := row(id)
	assert(r, "unknown card id " + id)
	var c := Card.new()
	c.id = id
	c.info = r
	var path := SCRIPTS % id
	var s: Script = load(path) if ResourceLoader.exists(path) else null
	c.faces.assign([_face(g, c, s, &"Top", r.name, r.rule), _face(g, c, s, &"Inv", r.inv_name, r.inv_rule)])
	return c

static func _face(g: Game, c: Card, s: Script, cls: StringName, title: String, text: String) -> Ability:
	var consts := s.get_script_constant_map() if s else {}
	var ab: Ability = consts[cls].new() if consts.has(cls) else Ability.new()
	ab.implemented = consts.has(cls)
	ab.card = c
	ab.g = g
	ab.title = title
	ab.text = text
	return ab

## All cards, or just the given ids (handy for tests and themed simulations).
static func build_deck(g: Game, ids := []) -> Array[Card]:
	var out: Array[Card] = []
	for r in rows():
		if ids.is_empty() or ids.has(r.id): out.append(make(g, r.id))
	return out
