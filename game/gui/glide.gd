class_name Glide extends RefCounted
## Moves a Node3D to a target transform over a short time, lifting it in an arc.
## Retargeting mid-flight starts a fresh glide from wherever the node is.

var node: Node3D
var from: Transform3D
var to: Transform3D
var t := 1.0
var dur := 0.45
var arc := 0.0
var active := false

func _init(n: Node3D) -> void: node = n

func go(target: Transform3D, duration := 0.45, lift := -1.0) -> void:
	if active and to.is_equal_approx(target): return
	if not active and node.global_transform.is_equal_approx(target): return
	from = node.global_transform
	to = target
	t = 0.0
	dur = maxf(duration, 0.01)
	var d := from.origin.distance_to(to.origin)
	arc = lift if lift >= 0.0 else clampf(d * 0.2, 0.0, 10.0)
	active = true

func snap(target: Transform3D) -> void:
	active = false
	node.global_transform = target

func stop() -> void: active = false

## Advance; true while still moving.
func step(dt: float) -> bool:
	if not active: return false
	t = minf(1.0, t + dt / dur)
	var e := t * t * (3.0 - 2.0 * t)
	var q := from.basis.get_rotation_quaternion().slerp(to.basis.get_rotation_quaternion(), e)
	node.global_transform = Transform3D(Basis(q), from.origin.lerp(to.origin, e) + Vector3.UP * arc * sin(PI * t))
	if t >= 1.0:
		node.global_transform = to
		active = false
	return true
