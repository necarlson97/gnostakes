class_name DieView extends RigidBody3D
## A vial die: a hexagonal glass vial (long axis = local Z) with six face inserts.
## Face k's insert sits on the side whose outward normal is Rz(60k deg) * +Y, so the die
## shows face k when that normal points up. It is frozen (kinematic) except while thrown.

var die: Die
var state := &"idle"     # idle | hand | rolling | rest (landed, ready) | placed
var glide: Glide
var held := false
var glow: MeshInstance3D
var ring: MeshInstance3D
var tag: Label3D          # face-value tag floating over the die (your dice)
static var show_tags := true
var _inserts: Array = []
var _faces_cache := []
var _kind := -1

static func normal(k: int) -> Vector3: return Vector3.UP.rotated(Vector3.BACK, deg_to_rad(60.0 * k))

func setup(d: Die) -> DieView:
	die = d
	name = "Die_%d" % d.id
	glide = Glide.new(self)
	collision_layer = 2
	collision_mask = 1 | 2
	mass = 1.0
	linear_damp = 0.4
	angular_damp = 1.2
	continuous_cd = true
	can_sleep = true
	var pm := PhysicsMaterial.new()
	pm.bounce = 0.25
	pm.friction = 0.55
	physics_material_override = pm
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	freeze = true
	var cs := CollisionShape3D.new()
	cs.shape = Look.convex("die")
	add_child(cs)
	glow = Look.glow_quad(Vector2(3.4, 3.4), true)
	glow.top_level = true
	add_child(glow)
	ring = Look.glow_quad(Vector2(2.9, 2.9), true)
	ring.top_level = true
	add_child(ring)
	tag = Look.label("", 44, 0.02, Color(1, 0.95, 0.85))
	tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	tag.outline_size = 10
	tag.outline_modulate = Color(0, 0, 0, 0.9)
	tag.no_depth_test = true
	tag.top_level = true
	tag.visible = false
	add_child(tag)
	set_meta("view", self)
	refresh()
	return self

## Rebuild the vial and inserts when faces or kind changed (Scheme face swaps).
func refresh() -> void:
	if _faces_cache == die.faces and _kind == die.kind: return
	_faces_cache = die.faces.duplicate()
	_kind = die.kind
	for n in _inserts: n.queue_free()
	_inserts.clear()
	var glass := Look.mat("glass_potency" if die.kind == GK.Kind.POTENCY else "glass_elemental")
	for m in [["vial_body", glass], ["vial_cork", Look.mat("cork")]]:
		var mi := MeshInstance3D.new()
		mi.mesh = Look.mesh(m[0])
		mi.material_override = m[1]
		add_child(mi)
		_inserts.append(mi)
	for k in die.faces.size():
		var v = die.faces[k]
		var mi := MeshInstance3D.new()
		mi.mesh = Look.face_mesh(v)
		mi.material_override = Look.face_mat(v)
		mi.rotation.z = deg_to_rad(60.0 * k)
		add_child(mi)
		_inserts.append(mi)
		var plain: bool = v is int and (v < 1 or v > 9)
		if plain or k >= 6:
			var l := Look.label(str(v), 64, 0.012, Color.BLACK)
			l.basis = Basis(Vector3.BACK, deg_to_rad(60.0 * k)) * Basis(Vector3.RIGHT, deg_to_rad(-90))
			l.position = normal(k) * 0.9
			add_child(l)
			_inserts.append(l)

func _process(dt: float) -> void:
	if not held and freeze: glide.step(dt)
	var p := global_position
	glow.global_transform = Transform3D(Basis(), Vector3(p.x, 0.04, p.z))
	ring.global_transform = Transform3D(Basis(), Vector3(p.x, 0.03, p.z))
	tag.global_position = p + Vector3(0, 1.9, 0)

func move_to(tr: Transform3D, dur := 0.4, lift := -1.0) -> void:
	if held or not freeze: return
	glide.go(tr, dur, lift)

## Index of the face pointing most nearly up, and how nearly (1 = flat).
func face_up() -> int:
	var best := 0
	var bv := -INF
	for k in die.faces.size():
		var v := (global_basis * normal(k)).y
		if v > bv:
			bv = v
			best = k
	return best

func flatness() -> float: return (global_basis * normal(face_up())).y

func yaw() -> float:
	var z := global_basis.z
	return atan2(z.x, z.z) - PI * 0.5

## Lying flat showing face k; `yaw_` is the seat's facing (the long axis lies across it).
static func basis_for(k: int, yaw_: float) -> Basis:
	return Basis(Vector3.UP, yaw_ + PI * 0.5) * Basis(Vector3.BACK, deg_to_rad(-60.0 * k))

## Resting transform at a table point showing face k.
static func rest_at(pos: Vector3, k: int, yaw_: float) -> Transform3D:
	return Transform3D(basis_for(k, yaw_), Vector3(pos.x, Look.DIE_APOTHEM + 0.01, pos.z))

func set_glow(c, pulse := true) -> void: Look.set_glow(glow, c, pulse)

## Show the up face as a small tag (only while the die is at rest).
func set_tag(on: bool) -> void:
	tag.visible = on and show_tags and (state == &"rest" or state == &"placed") and not held
	if tag.visible:
		var f = die.face()
		tag.text = str(f) if f is int else ("–" if f == "" else f)
		tag.modulate = Look.face_color(f).lightened(0.35) if not f is int else Color(1, 0.95, 0.85)
func set_ring(c) -> void: Look.set_glow(ring, c, false)

## Hand the die to physics with a throw.
func launch(from: Vector3, vel: Vector3, spin: Vector3) -> void:
	glide.stop()
	state = &"rolling"
	global_transform = Transform3D(Basis.from_euler(Vector3(randf() * TAU, randf() * TAU, randf() * TAU)), from)
	freeze = false
	sleeping = false
	linear_velocity = vel
	angular_velocity = spin

## Back to kinematic where it lies, squared up on its top face.
func settle() -> void:
	freeze = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	var k := face_up()
	glide.go(rest_at(global_position, k, yaw()), 0.12, 0.0)
