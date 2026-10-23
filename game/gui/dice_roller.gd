class_name DiceRoller extends Node
## Physical dice: the GUI's drop-in for the engine's face generator (Game.roller).
## Dice gather above the seat's tray, get thrown (by the human's fling, or at once for a
## bot), and whatever face ends up on top is the roll. Cocked dice get a nudge.

signal thrown(fling: Vector2)

const SETTLE_LIN := 1.2      # cm/s
const SETTLE_ANG := 0.8      # rad/s
const SETTLE_FRAMES := 14
const TIMEOUT := 3.5

var table          # Table (gui/table.gd)
var auto_all := false        # autoplay: nobody waits for a human throw
var waiting: Array = []      # dice views shaking in the hand
var _shake_t := 0.0

func roll(_g: Game, p: Player, dice: Array) -> void:
	var seat: SeatView = table.seats[p.idx]
	var views: Array = dice.map(func(d): return table.die_view(d))
	if p.idx != table.human_idx and PacedController.speed >= 4.0:
		# fast-forward: bots' dice just land (your own dice are always thrown)
		for v in views:
			v.die.up = randi() % v.die.faces.size()
			v.state = &"idle"
		table.request_sync()
		await table.get_tree().create_timer(0.12).timeout
		return
	for i in views.size():
		var v: DieView = views[i]
		v.freeze = true
		v.held = false
		v.state = &"hand"
		v.move_to(Transform3D(Basis.from_euler(Vector3(randf() * TAU, randf() * TAU, 0)), seat.hand_point(i)), 0.35)
	var fling := Vector2(randf_range(-6, 6), -22)
	if p.idx == table.human_idx and not auto_all:
		waiting = views
		table.throw_wanted(true)
		fling = await thrown
		table.throw_wanted(false)
		waiting = []
	else:
		await table.get_tree().create_timer(0.5 / PacedController.speed).timeout
	var t0 := Time.get_ticks_msec()
	_throw(seat, views, fling)
	await _settle(views)
	if table.args.has("verbose"): print("  roll of %d dice settled in %d ms" % [views.size(), Time.get_ticks_msec() - t0])
	for v in views:
		v.die.up = v.face_up()
		v.settle()
		v.state = &"rest"
	table.request_sync()

func _process(dt: float) -> void:
	if waiting.is_empty(): return
	_shake_t += dt
	for i in waiting.size():
		var v: DieView = waiting[i]
		if v.glide.active: continue
		v.rotate(Vector3(sin(_shake_t * 9 + i), cos(_shake_t * 7 + i * 2), 0.3).normalized(), dt * 6.0)

func _throw(seat: SeatView, views: Array, fling: Vector2) -> void:
	var b := seat.global_basis
	for v in views:
		var from: Vector3 = v.global_position
		var vel := b * Vector3(fling.x + randf_range(-7, 7), randf_range(-6, 2), fling.y + randf_range(-6, 6))
		var spin := Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized() * randf_range(18, 34)
		v.launch(from, vel, spin)

func _settle(views: Array) -> void:
	for attempt in 4:
		var calm := 0
		var t := 0.0
		while t < TIMEOUT and calm < SETTLE_FRAMES:
			await table.get_tree().physics_frame
			t += 1.0 / Engine.physics_ticks_per_second
			# a die leaning on another keeps wobbling: count it as done, it gets nudged below
			var still := views.all(func(v): return v.sleeping or (v.linear_velocity.length() < SETTLE_LIN and v.angular_velocity.length() < SETTLE_ANG) 				or (v.flatness() < 0.96 and v.linear_velocity.length() < 5.0 and v.angular_velocity.length() < 3.0))
			calm = calm + 1 if still else 0
		var cocked := views.filter(func(v): return v.flatness() < 0.96)
		if table.args.has("verbose"):
			print("    settle pass %d: %.2fs, calm=%d, cocked=%d" % [attempt, t, calm, cocked.size()])
			if calm < SETTLE_FRAMES:
				for v in views: print("      %s pos %s lin %.2f ang %.2f flat %.2f sleep %s" % [v.name, v.global_position.snapped(Vector3.ONE * 0.1), v.linear_velocity.length(), v.angular_velocity.length(), v.flatness(), v.sleeping])
		if cocked.is_empty() or attempt == 3: return
		for v in cocked:   # nudge it off whatever it is leaning on
			v.sleeping = false
			v.linear_velocity = Vector3(randf_range(-15, 15), 55, randf_range(-15, 15))
			v.angular_velocity = Vector3(randf_range(-8, 8), randf_range(-8, 8), randf_range(-8, 8))
