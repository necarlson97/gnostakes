extends Node
## `selftest` on the command line: plays your seat through the real input path. It sends
## synthetic mouse clicks and drags at the dice, cards and tokens on screen (or presses
## the prompt's buttons), so Interaction's picking, dragging and answers all get exercised.

var table   # Table
var inter: Interaction
var busy := false
var rng := RandomNumberGenerator.new()
var steps := {}

func _ready() -> void:
	rng.seed = 99

func _process(_dt: float) -> void:
	if busy or table == null: return
	if not table.roller.waiting.is_empty():
		busy = true
		_throw()
	elif inter.c != null:
		busy = true
		_answer()

func _count(k: String) -> void: steps[k] = steps.get(k, 0) + 1

func _wait(t := 0.15) -> void:
	await get_tree().create_timer(t, true, false, true).timeout

func _screen(p: Vector3) -> Vector2: return table.cam.unproject_position(p)

func _press(pos: Vector2, button := MOUSE_BUTTON_LEFT, down := true) -> void:
	var e := InputEventMouseButton.new()
	e.position = pos
	e.global_position = pos
	e.button_index = button
	e.pressed = down
	e.button_mask = MOUSE_BUTTON_MASK_LEFT if (down and button == MOUSE_BUTTON_LEFT) else 0
	Input.parse_input_event(e)

func _move(pos: Vector2, rel := Vector2.ZERO) -> void:
	var e := InputEventMouseMotion.new()
	e.position = pos
	e.global_position = pos
	e.relative = rel
	Input.parse_input_event(e)

func click(p: Vector3, button := MOUSE_BUTTON_LEFT) -> void:
	var s := _screen(p)
	_move(s)
	await _wait(0.05)
	_press(s, button, true)
	await _wait(0.05)
	_press(s, button, false)
	await _wait(0.1)

func drag(from: Vector3, to: Vector3) -> void:
	var a := _screen(from)
	var b := _screen(to)
	_move(a)
	await _wait(0.05)
	_press(a, MOUSE_BUTTON_LEFT, true)
	for i in range(1, 9):
		_move(a.lerp(b, i / 8.0), (b - a) / 8.0)
		await _wait(0.03)
	_press(b, MOUSE_BUTTON_LEFT, false)
	await _wait(0.15)

func _throw() -> void:
	print("selftest: throw")
	await _wait(0.3)
	var s := get_viewport().get_visible_rect().size
	var a := Vector2(s.x * 0.5, s.y * 0.6)
	_press(a, MOUSE_BUTTON_LEFT, true)
	_move(a + Vector2(30, -200))
	_press(a + Vector2(30, -200), MOUSE_BUTTON_LEFT, false)
	_count("throw")
	await _wait(0.3)
	busy = false

func _answer() -> void:
	print("selftest: answer ", inter.mode, " ", inter.c)
	await _wait(0.35)
	var c: Choice = inter.c
	if c == null:
		busy = false
		return
	var seat: SeatView = table.seats[table.human_idx]
	_count(String(inter.mode))
	match inter.mode:
		&"assign":
			# drag one die to the commit row, click another, right-click a third, then let
			# the advisor finish if that wasn't enough
			var ds: Array = c.options.duplicate()
			if ds.size() >= 1: await drag(table.die_view(ds[0]).global_position, seat.commit_point(0, 1))
			if ds.size() >= 2: await click(table.die_view(ds[1]).global_position)
			if ds.size() >= 4 and rng.randf() < 0.3: await click(table.die_view(ds[2]).global_position, MOUSE_BUTTON_RIGHT)
			if inter.c == c and inter.pending.size() < c.lo: inter._advise_assign()
			if inter.c == c: _primary()
		&"arrange":
			var dice: Array = []
			for g in inter.groups: dice.append_array(g)
			if dice.size() >= 2 and rng.randf() < 0.5:   # drag a die out, and back via browsing
				await drag(table.die_view(dice[0]).global_position, seat.unscored_point(0, 1))
				if inter.c == c and not inter._matching(): inter._apply_option(0)
			if inter.c == c: _primary()
		&"request":
			var cards: Array = inter.card_opts.keys()
			if cards and rng.randf() < 0.85:
				var card: Card = cards[rng.randi_range(0, cards.size() - 1)]
				await drag(table.cards[card].global_position, seat.world(Vector3(0, 0, SeatView.CADRE_Z)))
				if inter.c == c and table.hud.popup.visible: _first_popup_button()
			if inter.c == c: _primary()
		&"wager":
			for t in seat.piles:
				var pile: Array = seat.piles[t]
				if pile and rng.randf() < 0.6:
					await drag(pile.back().global_position, seat.dish_point())
			if inter.c == c: _primary()
		&"orient":
			for card in c.options:
				if rng.randf() < 0.3: await click(table.cards[card].global_position)
			if inter.c == c: _primary()
		&"act":
			var cards: Array = inter.card_opts.keys()
			if cards and rng.randf() < 0.4:
				await click(table.cards[cards[0]].global_position)
				if inter.c == c and table.hud.popup.visible: _first_popup_button()
			if inter.c == c: _primary()
		&"pick_card":
			var cards: Array = inter.card_opts.keys()
			if cards: await click(table.cards[cards[rng.randi_range(0, cards.size() - 1)]].global_position)
			if inter.c == c: _primary()
		&"pick_die":
			var ds: Array = inter.die_opts.keys()
			if ds: await click(table.die_view(ds[rng.randi_range(0, ds.size() - 1)]).global_position)
			if inter.c == c: _primary()
		&"yes_no":
			if rng.randf() < 0.5: _primary()
			else: inter.submit(false)
		_:
			if table.hud.popup.visible: _first_popup_button(true)
	await _wait(0.2)
	if inter.c == c:   # nothing above answered it: fall back to a legal default
		_count("fallback_" + String(inter.mode))
		inter.submit(Controller.default_answer(c))
	busy = false

func _primary() -> void:
	if table.hud.primary.is_valid(): table.hud.primary.call()

## Press a pop-up button (a random one when `any`), skipping Cancel.
func _first_popup_button(any := false) -> void:
	var btns: Array = table.hud.popup_box.get_children().filter(func(n): return n is Button and n.text != "Cancel" and not n.disabled)
	var boxes: Array = table.hud.popup_box.get_children().filter(func(n): return n is CheckBox)
	for b in boxes:
		if rng.randf() < 0.5: b.button_pressed = true
	if btns.is_empty(): return
	var b: Button = btns[rng.randi_range(0, btns.size() - 1)] if any else btns[0]
	if b.disabled: return
	b.pressed.emit()
