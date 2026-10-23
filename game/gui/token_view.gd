class_name TokenView extends RigidBody3D
## One element token: a physics piece that drops onto its pile. Frozen while dragged,
## sitting in the wager dish, or flying off to be spent.

var type: String
var glide: Glide
var held := false
var in_dish := false
var glow: MeshInstance3D

func setup(t: String) -> TokenView:
	type = t
	name = "Token_" + t
	glide = Glide.new(self)
	collision_layer = 8
	collision_mask = 1 | 8
	mass = 0.25
	var pm := PhysicsMaterial.new()
	pm.bounce = 0.1
	pm.friction = 0.8
	physics_material_override = pm
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	var mi := MeshInstance3D.new()
	mi.mesh = Look.mesh("token_" + t)
	mi.material_override = Look.mat("token_" + t)
	add_child(mi)
	var cs := CollisionShape3D.new()
	cs.shape = Look.convex("token_" + t)
	add_child(cs)
	glow = Look.glow_quad(Vector2(2.6, 2.6), true)
	glow.position.y = -0.2
	add_child(glow)
	set_meta("view", self)
	return self

func _process(dt: float) -> void:
	if not held and freeze: glide.step(dt)

func drop_at(pos: Vector3) -> void:
	freeze = false
	global_transform = Transform3D(Basis(Vector3.UP, randf() * TAU) * Basis(Vector3.RIGHT, randf_range(-0.3, 0.3)), pos)
	linear_velocity = Vector3(randf_range(-3, 3), -10, randf_range(-3, 3))

func pin(tr: Transform3D, dur := 0.35) -> void:
	freeze = true
	glide.go(tr, dur)

## Fly to `to` and disappear.
func spend_to(to: Vector3) -> void:
	freeze = true
	collision_layer = 0
	glide.go(Transform3D(global_basis, to), 0.6, 6.0)
	var tw := create_tween()
	tw.tween_interval(0.55)
	tw.tween_callback(queue_free)

func set_glow(c, pulse := true) -> void: Look.set_glow(glow, c, pulse)
