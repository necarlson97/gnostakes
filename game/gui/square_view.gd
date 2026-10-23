class_name SquareView extends Node3D
## The Town Square mat in the middle of the table: four villager slots with their tier-1
## sets and token prices, the tier-2/3 set menu, the village deck (right: new draws
## arrive there) and the pyre (left: the leftmost villager burns each round).

const SLOT_GAP := 10.0
const SLOT_Z := -8.0
const SIZE := Vector2(62, 31)
const CENTER_Z := -3.5

var game: Game
var set_labels := {}      # SetDef.id -> Label3D
var slot_glows: Array = []

func setup(g: Game) -> SquareView:
	game = g
	name = "TownSquare"
	var mi := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = SIZE
	mi.mesh = pm
	mi.material_override = Look.mat("mat")
	mi.position = Vector3(0, 0.015, CENTER_Z)
	add_child(mi)
	var title := Look.flat_label("THE TOWN SQUARE", 56, 0.022, Color(0.3, 0.18, 0.1))
	title.position = Vector3(0, 0.03, CENTER_Z - SIZE.y / 2 + 1.4)
	add_child(title)
	for s in g.square.size():
		var x := slot_x(s)
		var outline := MeshInstance3D.new()
		var op := PlaneMesh.new()
		op.size = Vector2(Look.CARD + 0.6, Look.CARD + 0.6)
		outline.mesh = op
		outline.material_override = Look.mat("slot")
		outline.position = Vector3(x, 0.02, SLOT_Z)
		add_child(outline)
		var d := _tier1(s)
		var nl := Look.flat_label(d.name if d else "Slot %d" % (s + 1), 40, 0.02)
		nl.position = Vector3(x, 0.03, SLOT_Z - Look.CARD / 2 - 1.0)
		add_child(nl)
		if d: set_labels[d.id] = nl
		var t: String = g.cfg.slot_tokens[s] if s < g.cfg.slot_tokens.size() else ""
		var pl := Look.flat_label("or %d %s" % [g.cfg.token_request_cost, Look.NAMES.get(t, t)], 32, 0.02, Look.COLORS.get(t, Color.BLACK).darkened(0.25))
		pl.position = Vector3(x, 0.03, SLOT_Z + Look.CARD / 2 + 0.9)
		add_child(pl)
		var num := Look.flat_label(str(s + 1), 30, 0.02, Color(0.45, 0.4, 0.35))
		num.position = Vector3(x, 0.03, SLOT_Z + Look.CARD / 2 + 2.1)
		add_child(num)
	var deck_l := Look.flat_label("village", 28, 0.02, Color(0.4, 0.3, 0.2))
	deck_l.position = deck_point() + Vector3(0, 0.03, Look.CARD / 2 + 0.9)
	add_child(deck_l)
	var pyre_l := Look.flat_label("pyre", 28, 0.02, Color(0.5, 0.2, 0.1))
	pyre_l.position = pyre_point() + Vector3(0, 0.03, Look.CARD / 2 + 0.9)
	add_child(pyre_l)
	_menu(2, Vector3(-15, 0.03, 4.0), "Any one villager:")
	_menu(3, Vector3(15, 0.03, 4.0), "Any two villagers:")
	return self

func _tier1(slot: int) -> Scoring.SetDef:
	for d in Scoring.MENU:
		if d.tier == 1 and d.slot == slot: return d
	return null

func _menu(tier: int, at: Vector3, head: String) -> void:
	var hl := Look.flat_label(head, 34, 0.02, Color(0.3, 0.18, 0.1))
	hl.position = at
	add_child(hl)
	var i := 0
	for d in Scoring.MENU:
		if d.tier != tier: continue
		var l := Look.flat_label(d.name, 34, 0.02)
		l.position = at + Vector3(0, 0, 1.6 + i * 1.35)
		add_child(l)
		set_labels[d.id] = l
		i += 1

func slot_x(s: int) -> float: return (s - (game.square.size() - 1) * 0.5) * SLOT_GAP
func slot_tr(s: int) -> Transform3D: return Transform3D(Basis(), Vector3(slot_x(s), 0.03, SLOT_Z))
func deck_point() -> Vector3: return Vector3(slot_x(game.square.size() - 1) + SLOT_GAP + 1.0, 0.03, SLOT_Z)
func pyre_point() -> Vector3: return Vector3(slot_x(0) - SLOT_GAP - 1.0, 0.03, SLOT_Z)

## Light up menu entries: id -> Color (others fade back to ink).
func light_sets(colors: Dictionary) -> void:
	for id in set_labels:
		var l: Label3D = set_labels[id]
		if colors.has(id):
			l.modulate = colors[id]
			l.outline_size = 10
			l.outline_modulate = Color(0.1, 0.05, 0.02, 0.9)
		else:
			l.modulate = Color(0.15, 0.1, 0.06)
			l.outline_size = 0
