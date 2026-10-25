class_name CardDB
## Loads card text from data/cards.json and behaviour from res://cards/<id>.gd.
## A card script defines inner classes `Top` and `Inv` (both extend Ability). Faces
## without a script still load, as text-only abilities (implemented = false).

const DATA := "res://data/cards.json"
const SCRIPTS := "res://cards/%s.gd"
## Card-design experiments: res://cards/variants/<variant>/<id>.gd replaces the card's script
## while <variant> is listed in `variants` (sims pass variant=a,b). A variant script may define
##   const TEXT := {rule = "...", inv_rule = "..."}               new wording (for reports)
##   const FEATURES := {top = {...}, inv = {...}}                 strategy features (for bots)
## Faces it doesn't mention keep the sheet's text and features.
const VARIANTS := "res://cards/variants/%s/%s.gd"

static var _rows: Array = []
static var variants: Array = []

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
	var path := SCRIPTS % id
	for v in variants:
		if ResourceLoader.exists(VARIANTS % [v, id]):
			path = VARIANTS % [v, id]
			r = _variant_row(r, load(path), v)
	var c := Card.new()
	c.id = id
	c.info = r
	var s: Script = load(path) if ResourceLoader.exists(path) else null
	c.faces.assign([_face(g, c, s, &"Top", r.name, r.rule), _face(g, c, s, &"Inv", r.inv_name, r.inv_rule)])
	return c

static func _variant_row(r: Dictionary, s: Script, v: String) -> Dictionary:
	var out := r.duplicate(true)
	var consts := s.get_script_constant_map()
	for k in consts.get("TEXT", {}): out[k] = consts.TEXT[k]
	for side in consts.get("FEATURES", {}): out.features[side] = consts.FEATURES[side]
	out.variant = v
	return out

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
