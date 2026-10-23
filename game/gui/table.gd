class_name Table extends Node3D
## The diegetic 3D table: builds the room, seats you against three AdaptiveBots, and
## keeps every 3D object in step with the engine's state. The engine runs unchanged:
##   - your seat is a Controller.Async, answered by Interaction (drag, click, prompts);
##   - bots are wrapped in PacedController so their moves are watchable;
##   - Game.roller = DiceRoller.roll, so dice are thrown physically and read off the table.
## Views never drive the rules: after any engine event the table re-derives where each
## card, die and token belongs (sync) and glides it there.
##
## Command line (after --): autoplay | selftest  seed=N  fast=X  games=N  verbose
##   shot=<png path> shot_after=S shots=N  quit_after=S

const SEAT_R_HUMAN := 40.0
const SEAT_R := 60.0
const BOT_NAMES := ["Sister Agathe", "Brother Ulric", "Widow Maud", "Deacon Fell", "Old Tobias"]
const CENTER := Vector3(0, 0, -4)

var game: Game
var human: Controller.Async
var human_idx := 0
var seats: Array = []          # SeatView per player index
var square: SquareView
var cards := {}                # Card -> CardView
var dice := {}                 # Die -> DieView
var commit_order := {}         # Player -> Array[Die] (stable commit-row order)
var hud: Hud
var roller: DiceRoller
var inter: Interaction
var cam: Camera3D
var views_root: Node3D
var args := {}
var selftest: Node
var _dirty := true
var _last_phase := -1

# camera: head position, base look target, offsets from right-drag
var head := Vector3(0, 46, 76)
var look_target := Vector3(0, 0, 21)
var look_goal := Vector3(0, 0, 21)
var yaw_off := 0.0
var pitch_off := 0.0
var fov_goal := 52.0

func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=")
		args[kv[0]] = kv[1] if kv.size() > 1 else true
	_build_room()
	hud = Hud.new()
	add_child(hud)
	roller = DiceRoller.new()
	roller.table = self
	roller.auto_all = args.has("autoplay")
	add_child(roller)
	inter = Interaction.new()
	inter.table = self
	add_child(inter)
	if args.has("selftest"):
		selftest = preload("res://gui/selftest.gd").new()
		selftest.table = self
		selftest.inter = inter
		add_child(selftest)
	if args.has("shot"): _screenshots(args.shot, float(args.get("shot_after", 6)), int(args.get("shots", 1)))
	if args.has("quit_after"): get_tree().create_timer(float(args.quit_after), true, false, true).timeout.connect(func(): get_tree().quit())
	new_game()

# =============================================================================
# Game lifecycle
# =============================================================================
func new_game() -> void:
	if views_root: views_root.queue_free()
	views_root = Node3D.new()
	views_root.name = "Views"
	add_child(views_root)
	seats.clear()
	cards.clear()
	dice.clear()
	commit_order.clear()
	hud.end_panel.visible = false
	inter.hovered = null
	inter._reset()
	game = Game.new()
	var seed_ := int(args.get("seed", 0))
	var ctrls := []
	human = Controller.Async.new()
	var n := 4
	for i in n:
		if i == human_idx and not args.has("autoplay"): ctrls.append(human)
		else: ctrls.append(PacedController.new(Bots.make("adaptive", (seed_ if seed_ else randi()) + i * 7919), get_tree(), 0.5))
	game.setup(ctrls, seed_)
	for i in n:
		game.players[i].name = "You" if i == human_idx else BOT_NAMES[(i - 1) % BOT_NAMES.size()]
	game.roller = roller.roll
	game.event.connect(_on_event)
	game.asking.connect(_on_asking)
	human.asked.connect(inter.begin)
	square = SquareView.new().setup(game)
	views_root.add_child(square)
	for i in n:
		var a := -TAU * i / n
		var r := SEAT_R_HUMAN if i == human_idx else SEAT_R
		var s := SeatView.new()
		views_root.add_child(s)
		s.position = Vector3(sin(a), 0, cos(a)) * r
		s.rotation.y = a
		s.setup(game.players[i], i == human_idx)
		seats.append(s)
	for c in game.deck + game.square.filter(func(x): return x != null):
		var v := CardView.new().setup(c)
		views_root.add_child(v)
		v.global_transform = Transform3D(Basis(Vector3.BACK, PI), square.deck_point())
		cards[c] = v
	_sync(true)
	hud.log_line("[color=#e8d8b0]A new game. Four seats, %d keys to win.[/color]" % game.win_keys())
	_play.call_deferred()

func _play() -> void:
	var g := game
	await g.play()
	if g != game: return
	_sync()
	var names := g.winners.map(func(p): return p.name)
	var why := String(g.ending if g.ending else "the end")
	var text := "Nobody wins." if names.is_empty() else ("You win!" if names.has("You") and names.size() == 1 else "%s win%s." % [" & ".join(names), "" if names.size() > 1 else "s"])
	hud.show_end("%s\n(%s, round %d)" % [text, why.capitalize(), g.round_no], new_game)
	hud.log_line("[color=#ffd080]Game over: %s[/color]" % text)
	print("GAME OVER: %s (%s) after %d rounds; invalid answers %d" % [text, why, g.round_no, g.invalid_answers])
	if selftest: print("SELFTEST interactions: ", selftest.steps)
	if args.has("games"):
		args.games = int(args.games) - 1
		if args.games > 0: new_game()
		else: get_tree().quit()

func die_view(d: Die) -> DieView:
	if not dice.has(d):
		var v := DieView.new().setup(d)
		views_root.add_child(v)
		var seat: SeatView = seats[d.owner.idx] if d.owner else seats[0]
		v.global_transform = DieView.rest_at(seat.tray_point(dice.size() % 14), d.up, seat.yaw())
		dice[d] = v
	return dice[d]

func request_sync() -> void: _dirty = true

func throw_wanted(on: bool) -> void:
	if on:
		hud.prompt("Your roll. Drag upward across the table and let go to throw the dice, or press Space.", [{label = "Throw", cb = func(): roller.thrown.emit(Vector2(randf_range(-5, 5), -24)), primary = true}])
	else:
		hud.clear_prompt()

# =============================================================================
# Engine signals
# =============================================================================
func _on_event(ev: Dictionary) -> void:
	_dirty = true
	var s := _describe(ev)
	if s:
		hud.log_line(s)
		if args.has("autoplay") and args.has("verbose"): print(s)

func _on_asking(c: Choice) -> void:
	if c.player.idx == human_idx and not args.has("autoplay"):
		hud.status.text = ""
	else:
		hud.status.text = "%s: %s" % [c.player.name, c.prompt]

func _pn(p) -> String: return p.name if p else "?"

## "<name> <verb>", conjugated for "You" (verb given in third person: "claims").
func _who(p, verb: String) -> String:
	if p and p.idx == human_idx and p.name == "You":
		verb = verb.trim_suffix("es") if verb.ends_with("ches") else verb.trim_suffix("s")
	return "%s %s" % [_pn(p), verb]

func _describe(ev: Dictionary) -> String:
	var p = ev.get("player")
	match ev.name:
		&"claim": return "%s [b]%s[/b]" % [_who(p, "claims"), ev.card]
		&"incinerate": return "[color=#e07050]%s burns[/color]" % ev.card
		&"square_burn": return "[color=#e07050]%s burns off the square[/color]" % ev.card
		&"key_gained": return "[color=#ffd080]%s %d key%s[/color]" % [_who(p, "gains"), ev.amount, "s" if ev.amount > 1 else ""]
		&"key_lost": return "%s %d key" % [_who(p, "loses"), ev.amount]
		&"tooth_lost": return "[color=#ff9090]%s a tooth[/color]" % _who(p, "loses")
		&"tooth_gained": return "%s %d tooth" % [_who(p, "regains"), ev.amount]
		&"token_gained": return "%s %d%s%s" % [_who(p, "gains"), ev.amount, ev.type, (" (%s)" % ev.src.title) if ev.get("src") else ""]
		&"spent":
			var parts := []
			for t in ev.tokens: parts.append("%d%s" % [ev.tokens[t], t])
			return "%s %s" % [_who(p, "spends"), " ".join(parts)] if parts else ""
		&"score_set": return "%s [b]%s[/b]" % [_who(p, "scores"), ev.def.name]
		&"score_nothing": return "%s nothing" % _who(p, "scores")
		&"wager_won": return "%s the wager" % _who(p, "wins")
		&"act": return "%s [i]%s[/i]" % [_who(p, "uses"), ev.ability.title]
		&"face_swap": return "%s a %s face for %s" % [_who(p, "swaps"), Look.face_text(ev.old), Look.face_text(ev.new)]
		&"relinquish": return "%s %s to %s" % [_who(p, "attaches"), ev.card, ev.target]
		&"rolled": return "%s %s" % [_who(p, "rolls"), " ".join(ev.dice.map(func(d): return Look.face_text(d.face())))]
	return ""

# =============================================================================
# Sync: put every view where the game state says it belongs
# =============================================================================
var _fps_t := 0.0

func _process(dt: float) -> void:
	if args.has("verbose"):
		_fps_t += dt
		if _fps_t > 5.0:
			_fps_t = 0.0
			print("  fps %d, speed %.1f" % [Engine.get_frames_per_second(), PacedController.speed])
	if _dirty: _sync()
	_camera(dt)
	# fast-forward shortens the pauses between moves; physics always runs in real time
	# (a scaled physics step keeps the dice from ever settling)
	PacedController.speed = 4.0 if Input.is_key_pressed(KEY_TAB) else float(args.get("fast", 1.0))

func _sync(snap := false) -> void:
	_dirty = false
	if game == null or seats.is_empty(): return
	if game.phase != _last_phase:
		_last_phase = game.phase
		inter.phase_changed()
	var ph: String = ["Setup", "Swig", "Scry", "Scheme", "Game over"][game.phase]
	hud.banner.text = "Round %d · %s" % [game.round_no, ph] if game.round_no > 0 else "Gnostakes"
	hud.update_scores(game, human_idx)
	_sync_cards(snap)
	_sync_dice(snap)
	for s in seats: s.sync_resources(CENTER)
	square.light_sets(inter.lit_sets())
	inter.after_sync()

func _sync_cards(snap: bool) -> void:
	var attach_count := {}
	for a in game.attached: attach_count[a.attached_to] = attach_count.get(a.attached_to, 0) + 1
	var placed := {}
	for c in cards:
		var v: CardView = cards[c]
		var tr := Transform3D()
		var vis := true
		match c.loc:
			GK.Loc.SQUARE:
				var s := game.square.find(c)
				tr = square.slot_tr(maxi(s, 0))
			GK.Loc.DECK:
				var i := game.deck.find(c)
				tr = Transform3D(Basis(Vector3.BACK, PI), square.deck_point() + Vector3(0, 0.07 * maxi(i, 0) + Look.CARD_T, 0))
			GK.Loc.PYRE:
				var i := game.pyre.find(c)
				var jitter := float(hash(c.id) % 100) / 100.0 - 0.5
				tr = Transform3D(Basis(Vector3.UP, jitter * 0.5), square.pyre_point() + Vector3(0, 0.07 * maxi(i, 0), 0))
			GK.Loc.CADRE:
				tr = _cadre_tr(c, attach_count)
			GK.Loc.ATTACHED:
				pass   # placed below, relative to the card it hangs from
			GK.Loc.GONE:
				vis = false
				tr = Transform3D(Basis(), Vector3(0, -20, 0))
		if c.loc == GK.Loc.ATTACHED: continue
		placed[c] = tr
		v.visible = vis
		if snap: v.glide.snap(tr)
		else: v.move_to(tr)
		v.refresh_note()
		v.set_glow(inter.card_glow(c))
	var stack := {}
	for a in game.attached:
		var base: Transform3D = placed.get(a.attached_to, Transform3D())
		var holder := a.holder()
		var seat_b := Basis(Vector3.UP, seats[holder.idx].yaw()) if holder else Basis()
		var j: int = stack.get(a.attached_to, 0) + 1
		stack[a.attached_to] = j
		var tr := Transform3D(base.basis, base.origin + seat_b * Vector3(0, -0.07 * j, -2.4 * j))
		placed[a] = tr
		var v: CardView = cards[a]
		v.visible = true
		v.move_to(tr)
		v.refresh_note()
		v.set_glow(inter.card_glow(a))

func _cadre_tr(c: Card, attach_count: Dictionary) -> Transform3D:
	var owner := c.owner
	var seat: SeatView = seats[owner.idx]
	var i := owner.cadre.find(c)
	var tr := seat.cadre_tr(i, owner.cadre.size(), inter.shown_inverted(c))
	tr.origin.y += 0.08 * attach_count.get(c, 0)
	return tr

func _sync_dice(snap: bool) -> void:
	var live := {}
	for p in game.players:
		var seat: SeatView = seats[p.idx]
		var mine := p.dice.duplicate()
		for d in p.swig_dice:
			if not mine.has(d): mine.append(d)
		for d in mine: live[d] = true
		# stable commit-row order
		var order: Array = commit_order.get(p, [])
		order = order.filter(func(d): return mine.has(d) and d.committed())
		for d in mine:
			if d.committed() and not order.has(d): order.append(d)
		commit_order[p] = order
		var row: Array = order + inter.pending_commits(p)
		var arrange := inter.arranged_points(p)   # Die -> Vector3, during your Scry arrangement
		var tray_i := 0
		var disc_i := 0
		var unscored := inter.unscored(p)
		for d in mine:
			var v := die_view(d)
			v.refresh()
			v.set_glow(inter.die_glow(d))
			v.set_ring(inter.die_ring(d))
			v.set_tag(p.idx == human_idx and not d.discarded())
			if v.held or v.state == &"hand" or v.state == &"rolling": continue
			var zone: StringName = inter.zone_for(d)
			var pos: Vector3
			match zone:
				&"commit":
					if arrange.has(d): pos = arrange[d]
					elif unscored.has(d): pos = seat.unscored_point(unscored.find(d), unscored.size())
					else: pos = seat.commit_point(row.find(d), row.size())
					v.state = &"placed"
				&"discard":
					pos = seat.discard_point(disc_i)
					disc_i += 1
					v.state = &"placed"
				_:
					if v.state == &"rest":
						if v.face_up() != d.up and not v.glide.active:
							v.move_to(DieView.rest_at(v.global_position, d.up, v.yaw()), 0.25, 1.5)
						continue
					pos = seat.tray_point(tray_i)
					tray_i += 1
					v.state = &"rest"
			var tr := DieView.rest_at(pos, d.up, seat.yaw())
			if snap: v.glide.snap(tr)
			else: v.move_to(tr, 0.4)
	for d in dice.keys():
		if not live.has(d):
			dice[d].queue_free()
			dice.erase(d)

# =============================================================================
# Room, camera, screenshots
# =============================================================================
func _build_room() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.02, 0.015, 0.012)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.55, 0.45, 0.38)
	e.ambient_light_energy = 0.35
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.glow_enabled = true
	e.glow_intensity = 0.6
	e.glow_bloom = 0.05
	e.ssao_enabled = true
	e.ssao_radius = 2.0
	e.fog_enabled = true
	e.fog_light_color = Color(0.05, 0.035, 0.03)
	e.fog_density = 0.0025
	env.environment = e
	add_child(env)

	var lamp := OmniLight3D.new()
	lamp.position = Vector3(0, 95, 10)
	lamp.omni_range = 260
	lamp.omni_attenuation = 0.6
	lamp.light_energy = 2.8
	lamp.light_color = Color(1.0, 0.85, 0.65)
	lamp.shadow_enabled = true
	add_child(lamp)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-60, 20, 0)
	fill.light_energy = 0.25
	fill.light_color = Color(0.7, 0.75, 1.0)
	add_child(fill)
	for cx in [-1, 1]:   # two candles at your corners
		var candle := Node3D.new()
		candle.position = Vector3(cx * 62, 0, 30)
		var wax := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.top_radius = 1.4
		cm.bottom_radius = 1.6
		cm.height = 9
		wax.mesh = cm
		wax.position.y = 4.5
		wax.material_override = Look.mat("tooth")
		candle.add_child(wax)
		var flame := OmniLight3D.new()
		flame.position.y = 11
		flame.omni_range = 70
		flame.light_energy = 1.1
		flame.light_color = Color(1.0, 0.6, 0.3)
		flame.set_script(preload("res://gui/flicker.gd"))
		candle.add_child(flame)
		add_child(candle)

	var table := StaticBody3D.new()
	table.collision_layer = 1
	var tm := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(220, 4, 220)
	tm.mesh = bm
	tm.position.y = -2
	var wood: StandardMaterial3D = Look.mat("wood")
	wood.uv1_scale = Vector3(3, 2, 1)
	tm.material_override = wood
	table.add_child(tm)
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(220, 4, 220)
	cs.shape = bs
	cs.position.y = -2
	table.add_child(cs)
	add_child(table)

	cam = Camera3D.new()
	cam.fov = fov_goal
	cam.near = 1.0
	cam.far = 1000.0
	add_child(cam)
	cam.position = head
	cam.look_at(look_target)

## Seat views for the 1-4 keys: where your head turns to.
func look_at_seat(i: int) -> void:
	if i == human_idx or i >= seats.size():
		look_goal = Vector3(0, 0, 21)
	else:
		look_goal = seats[i].global_position * 0.85 + Vector3(0, 0, 8)
	yaw_off = 0
	pitch_off = 0

func _camera(dt: float) -> void:
	var k := 1.0 - exp(-dt * 6.0)
	look_target = look_target.lerp(look_goal, k)
	cam.fov = lerpf(cam.fov, fov_goal, k)
	cam.position = head
	cam.look_at(look_target)
	cam.rotate_object_local(Vector3.UP, yaw_off)
	cam.rotate_object_local(Vector3.RIGHT, pitch_off)

## `shots` screenshots, `after` seconds apart (path gets _1, _2... when more than one).
func _screenshots(path: String, after: float, shots: int) -> void:
	for i in shots:
		await get_tree().create_timer(after, true, false, true).timeout
		await RenderingServer.frame_post_draw
		var out := path if shots == 1 else path.get_basename() + "_%d.png" % (i + 1)
		get_viewport().get_texture().get_image().save_png(out)
		print("screenshot saved: ", out, "  (round %d, phase %d)" % [game.round_no, game.phase])
