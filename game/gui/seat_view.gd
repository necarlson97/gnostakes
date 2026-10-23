class_name SeatView extends Node3D
## One player's place at the table. Local frame: -Z points at the table centre, +X is the
## player's right. It owns the dice tray, token piles, teeth and keys, and the layout
## (where cadre cards and dice in each zone go).

# from the table centre toward the player: cadre, unscored row, commit row, dice tray
const CADRE_Z := -19.0
const CADRE_GAP := 9.6
const UNSCORED_Z := -12.6
const COMMIT_Z := -9.4
const TRAY := Vector2(31.0, 11.5)    # inner size
const TRAY_Z := 2.0
const DIE_GAP := 2.45
const TOKEN_CAP := 40
const PILES := {"E": Vector2(24, -12), "W": Vector2(29.5, -12), "F": Vector2(24, -6.5), "A": Vector2(29.5, -6.5), "Q": Vector2(26.75, -1)}
const DISH := Vector2(27.0, 6.0)

var player: Player
var human := false
var piles := {}          # type -> Array[TokenView]
var pile_labels := {}
var teeth: Array = []
var keys: Array = []
var plate: Label3D
var dish: MeshInstance3D

func setup(p: Player, is_human: bool) -> SeatView:
	player = p
	human = is_human
	name = "Seat_%d" % p.idx
	_build_tray()
	for t in GK.TOKENS:
		piles[t] = []
		var l := Look.flat_label("", 36, 0.02, Look.COLORS[t].lightened(0.3))
		l.outline_size = 6
		l.outline_modulate = Color(0, 0, 0, 0.7)
		var pv: Vector2 = PILES[t]
		l.position = Vector3(pv.x, 0.05, pv.y + 2.1)
		add_child(l)
		pile_labels[t] = l
	plate = Look.label("", 56 if not is_human else 40, 0.03, Color(0.95, 0.88, 0.7))
	plate.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	plate.outline_size = 12
	plate.outline_modulate = Color(0, 0, 0, 0.85)
	plate.position = Vector3(0, 9, -4) if not is_human else Vector3(-31, 0.05, -22.5)
	if is_human:
		plate.billboard = BaseMaterial3D.BILLBOARD_DISABLED
		plate.rotation_degrees.x = -90
	add_child(plate)
	dish = MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 3.6
	cyl.bottom_radius = 3.0
	cyl.height = 0.4
	dish.mesh = cyl
	dish.material_override = Look.mat("brass")
	dish.position = Vector3(DISH.x, 0.2, DISH.y)
	dish.visible = false
	add_child(dish)
	return self

func _build_tray() -> void:
	var floor_mi := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = TRAY + Vector2(0.4, 0.4)
	floor_mi.mesh = pm
	floor_mi.material_override = Look.mat("felt")
	floor_mi.position = Vector3(0, 0.02, TRAY_Z)
	add_child(floor_mi)
	var body := StaticBody3D.new()
	body.collision_layer = 1
	add_child(body)
	var h := 3.2
	var w := 1.0
	var walls := [
		[Vector3(0, h / 2, TRAY_Z - TRAY.y / 2 - w / 2), Vector3(TRAY.x + 2 * w, h, w)],
		[Vector3(0, h / 2, TRAY_Z + TRAY.y / 2 + w / 2), Vector3(TRAY.x + 2 * w, h, w)],
		[Vector3(-TRAY.x / 2 - w / 2, h / 2, TRAY_Z), Vector3(w, h, TRAY.y)],
		[Vector3(TRAY.x / 2 + w / 2, h / 2, TRAY_Z), Vector3(w, h, TRAY.y)],
	]
	for wl in walls:
		var mi := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = wl[1]
		mi.mesh = bm
		mi.material_override = Look.mat("tray")
		mi.position = wl[0]
		add_child(mi)
		var cs := CollisionShape3D.new()
		var bs := BoxShape3D.new()
		bs.size = wl[1]
		cs.shape = bs
		cs.position = wl[0]
		body.add_child(cs)
	# an invisible lid well above the tray keeps wild throws in
	var lid := CollisionShape3D.new()
	var lb := BoxShape3D.new()
	lb.size = Vector3(TRAY.x + 2, 1, TRAY.y + 2)
	lid.shape = lb
	lid.position = Vector3(0, 22, TRAY_Z)
	body.add_child(lid)
	_tall_walls(body, h)   # invisible walls up to the lid

func _tall_walls(body: StaticBody3D, h: float) -> void:
	var tall := 22.0 - h
	var specs := [
		[Vector3(0, h + tall / 2, TRAY_Z - TRAY.y / 2 - 0.5), Vector3(TRAY.x + 2, tall, 1)],
		[Vector3(0, h + tall / 2, TRAY_Z + TRAY.y / 2 + 0.5), Vector3(TRAY.x + 2, tall, 1)],
		[Vector3(-TRAY.x / 2 - 0.5, h + tall / 2, TRAY_Z), Vector3(1, tall, TRAY.y)],
		[Vector3(TRAY.x / 2 + 0.5, h + tall / 2, TRAY_Z), Vector3(1, tall, TRAY.y)],
	]
	for s in specs:
		var cs := CollisionShape3D.new()
		var bs := BoxShape3D.new()
		bs.size = s[1]
		cs.shape = bs
		cs.position = s[0]
		body.add_child(cs)

# --- layout (world transforms) ------------------------------------------------------
func world(local: Vector3) -> Vector3: return global_transform * local
func yaw() -> float: return global_rotation.y

func cadre_tr(i: int, n: int, inverted: bool) -> Transform3D:
	var gap := minf(CADRE_GAP, 44.0 / maxf(n - 1, 1))   # big cadres overlap like a fanned hand
	var x := (i - (n - 1) * 0.5) * gap
	var b := Basis(Vector3.UP, yaw() + (PI if inverted else 0.0))
	return Transform3D(b, world(Vector3(x, 0.07 * i * float(gap < CADRE_GAP), CADRE_Z)))

func tray_point(i: int) -> Vector3:
	var col := i % 7
	var row := (i / 7) % 2
	return world(Vector3(-13.2 + col * 4.4, 0, TRAY_Z - 2.4 + row * 4.8))

func hand_point(i: int) -> Vector3:
	return world(Vector3(-5.0 + (i % 5) * 2.4, 11.0 + (i / 5) * 2.4, TRAY_Z + 3.0))

func commit_point(i: int, n: int) -> Vector3:
	return world(Vector3((i - (n - 1) * 0.5) * DIE_GAP, 0, COMMIT_Z))

func unscored_point(i: int, n: int) -> Vector3:
	return world(Vector3((i - (n - 1) * 0.5) * DIE_GAP, 0, UNSCORED_Z))

## Positions for dice laid out in groups along the commit row (Scry arrangement).
func group_points(sizes: Array) -> Array:
	var total := 0.0
	for s in sizes: total += s * DIE_GAP
	total += maxf(0, sizes.size() - 1) * 1.6
	var x := -total * 0.5 + DIE_GAP * 0.5
	var out := []
	for s in sizes:
		var g := []
		for _i in s:
			g.append(world(Vector3(x, 0, COMMIT_Z)))
			x += DIE_GAP
		x += 1.6
		out.append(g)
	return out

func discard_point(i: int) -> Vector3:
	return world(Vector3(-27.5 + (i % 3) * 2.5, 0, -1.0 + (i / 3) * 2.5))

func dish_point() -> Vector3: return world(Vector3(DISH.x, 0.5, DISH.y))
func pile_point(t: String) -> Vector3:
	var pv: Vector2 = PILES[t]
	return world(Vector3(pv.x, 0, pv.y))

## Which zone a world point is in, for drops: commit, tray, discard, unscored, dish, seat, "".
func zone_at(p: Vector3) -> StringName:
	var l := global_transform.affine_inverse() * p
	if Vector2(l.x, l.z).distance_to(DISH) < 4.5: return &"dish"
	if l.x > -32 and l.x < -19 and l.z > -4 and l.z < 10: return &"discard"
	if absf(l.x) < 18 and l.z > COMMIT_Z - 1.6 and l.z < COMMIT_Z + 3.4: return &"commit"
	if absf(l.x) < 18 and l.z > UNSCORED_Z - 2.0 and l.z <= COMMIT_Z - 1.6: return &"unscored"
	if absf(l.x) < TRAY.x / 2 + 1 and l.z > TRAY_Z - TRAY.y / 2 - 1 and l.z < TRAY_Z + TRAY.y / 2 + 1: return &"tray"
	if absf(l.x) < 40 and l.z > -26 and l.z < 18: return &"seat"
	return &""

# --- resources ----------------------------------------------------------------------
func sync_resources(table_center: Vector3) -> void:
	_sync_tokens(table_center)
	_sync_teeth()
	_sync_keys()
	for t in GK.TOKENS:
		var n: int = player.tokens[t]
		pile_labels[t].text = ("%d %s" % [n, t]) if n > 0 else ""
	var who := player.name
	plate.text = "%s\n%d keys  %d teeth" % [who, player.keys, player.teeth] if not human else "%d keys · %d teeth" % [player.keys, player.teeth]

func _sync_tokens(center: Vector3) -> void:
	for t in GK.TOKENS:
		var arr: Array = piles[t]
		var want := mini(player.tokens[t], TOKEN_CAP)
		var added := 0
		while arr.size() < want:
			var tv := TokenView.new().setup(t)
			add_child(tv)
			var pp := pile_point(t)
			tv.drop_at(pp + Vector3(randf_range(-1.0, 1.0), 6.0 + added * 0.6, randf_range(-1.0, 1.0)))
			arr.append(tv)
			added += 1
		while arr.size() > want:
			var victim: TokenView = null
			for tv in arr:
				if tv.in_dish: victim = tv
			if victim == null: victim = arr.back()
			arr.erase(victim)
			victim.spend_to(center + Vector3(randf_range(-3, 3), 3, randf_range(-3, 3)))

## Tokens back from the dish to their piles.
func clear_dish() -> void:
	for t in piles:
		for tv in piles[t]:
			if tv.in_dish:
				tv.in_dish = false
				tv.freeze = false
				tv.drop_at(pile_point(t) + Vector3(randf_range(-0.8, 0.8), 4.0, randf_range(-0.8, 0.8)))
	dish.visible = false

func _sync_teeth() -> void:
	var want := maxi(player.teeth, 0)
	while teeth.size() < want:
		var mi := MeshInstance3D.new()
		var cm := CapsuleMesh.new()
		cm.radius = 0.42
		cm.height = 1.5
		mi.mesh = cm
		mi.material_override = Look.mat("tooth")
		var i := teeth.size()
		mi.position = Vector3(-33.5 + (i % 5) * 1.25, 0.6, -19.5 + (i / 5) * 1.5)
		mi.scale = Vector3.ONE * 0.01
		add_child(mi)
		create_tween().tween_property(mi, "scale", Vector3.ONE, 0.3)
		teeth.append(mi)
	while teeth.size() > want:
		var mi: MeshInstance3D = teeth.pop_back()
		var tw := create_tween()
		tw.tween_property(mi, "position", mi.position + Vector3(randf_range(-6, 6), 14, -10), 0.6).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(mi, "rotation", Vector3(4, 2, 1), 0.6)
		tw.tween_callback(mi.queue_free)

func _sync_keys() -> void:
	var want := player.keys
	while keys.size() < want:
		var k := _key_mesh()
		var i := keys.size()
		k.position = Vector3(-33.5 + (i % 4) * 2.5, 0.12, -14.0 + (i / 4) * 2.8)
		k.rotation.y = 0.3
		k.position.y = 10
		add_child(k)
		create_tween().tween_property(k, "position:y", 0.12, 0.45).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		keys.append(k)
	while keys.size() > want:
		var k: Node3D = keys.pop_back()
		var tw := create_tween()
		tw.tween_property(k, "position", k.position + Vector3(0, 12, -20), 0.6)
		tw.tween_callback(k.queue_free)

static func _key_mesh() -> Node3D:
	var root := Node3D.new()
	var brass := Look.mat("brass")
	var bow := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 0.3
	tm.outer_radius = 0.6
	bow.mesh = tm
	bow.position.x = -0.9
	bow.material_override = brass
	root.add_child(bow)
	var shaft := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(1.8, 0.18, 0.22)
	shaft.mesh = bm
	shaft.position.x = 0.5
	shaft.material_override = brass
	root.add_child(shaft)
	for j in 2:
		var bit := MeshInstance3D.new()
		var b2 := BoxMesh.new()
		b2.size = Vector3(0.22, 0.18, 0.5)
		bit.mesh = b2
		bit.position = Vector3(1.1 + j * 0.35, 0, 0.3)
		bit.material_override = brass
		root.add_child(bit)
	return root
