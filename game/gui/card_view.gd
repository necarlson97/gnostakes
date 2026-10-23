class_name CardView extends Node3D
## A villager card on the table. Origin is the centre of the card's underside; with an
## identity basis it lies face up, readable from +Z. Inverting spins it 180 degrees
## about Y; face down is a flip about Z.

var card: Card
var glide: Glide
var face: MeshInstance3D
var glow: MeshInstance3D
var area: Area3D
var note: Label3D
var held := false        # being dragged: glides pause

func setup(c: Card) -> CardView:
	card = c
	name = "Card_" + c.id
	glide = Glide.new(self)
	var s := Look.CARD
	var edge := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(s, Look.CARD_T, s)
	edge.mesh = box
	edge.position.y = Look.CARD_T * 0.5
	edge.material_override = Look.mat("card_edge")
	add_child(edge)
	face = MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(s, s)
	face.mesh = pm
	face.position.y = Look.CARD_T + 0.003
	face.material_override = Look.card_face_mat(c.id)
	add_child(face)
	var back := MeshInstance3D.new()
	back.mesh = pm
	back.position.y = -0.003
	back.rotation_degrees.z = 180
	back.material_override = Look.mat("card_back")
	add_child(back)
	glow = Look.glow_quad(Vector2(s + 1.8, s + 1.8))
	glow.position.y = 0.01
	add_child(glow)
	note = Look.flat_label("", 40, 0.018, Color(0.95, 0.85, 0.6))
	note.position = Vector3(0, Look.CARD_T + 0.02, s * 0.5 + 0.7)
	note.outline_size = 8
	note.outline_modulate = Color(0, 0, 0, 0.8)
	add_child(note)
	area = Area3D.new()
	area.collision_layer = 4
	area.collision_mask = 0
	area.input_ray_pickable = true
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(s, 0.5, s)
	cs.shape = bs
	cs.position.y = 0.2
	area.add_child(cs)
	area.set_meta("view", self)
	add_child(area)
	return self

func _process(dt: float) -> void:
	if not held: glide.step(dt)

func move_to(tr: Transform3D, dur := 0.5, lift := -1.0) -> void:
	if held: return
	glide.go(tr, dur, lift)

func set_glow(c, pulse := true) -> void: Look.set_glow(glow, c, pulse)

## Buried tokens/teeth, shown as a note beside the card.
func refresh_note() -> void:
	var parts := []
	for k in card.buried:
		if card.buried[k] > 0: parts.append("%d %s" % [card.buried[k], "tooth" if k == "tooth" else k])
	note.text = ("buried: " + ", ".join(parts)) if parts else ""
