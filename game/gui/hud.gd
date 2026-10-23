class_name Hud extends CanvasLayer
## Screen overlay: phase banner, the current prompt and its buttons, pop-up choices,
## the set ledger (Swig/Scry), the card inspector, a scoreboard and an event log.

var banner: Label
var status: Label
var prompt_panel: PanelContainer
var prompt_label: Label
var prompt_buttons: HBoxContainer
var popup: PanelContainer
var popup_box: VBoxContainer
var ledger: PanelContainer
var ledger_box: VBoxContainer
var log_box: RichTextLabel
var inspector: PanelContainer
var insp_tex: TextureRect
var insp_text: Label
var scores: Label
var help: Label
var end_panel: PanelContainer
var primary: Callable = Callable()   # Space / Enter
var _log_lines: Array = []

const INK := Color(0.93, 0.87, 0.74)
const DIM := Color(0.7, 0.64, 0.55)

func _ready() -> void:
	layer = 5
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	banner = _label(26, INK)
	banner.set_anchors_preset(Control.PRESET_CENTER_TOP)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.position = Vector2(-400, 10)
	banner.size = Vector2(800, 36)
	root.add_child(banner)
	status = _label(17, DIM)
	status.set_anchors_preset(Control.PRESET_CENTER_TOP)
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.position = Vector2(-400, 46)
	status.size = Vector2(800, 26)
	root.add_child(status)

	prompt_panel = _panel()
	prompt_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	prompt_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	prompt_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	prompt_panel.position = Vector2(0, -20)
	var pv := VBoxContainer.new()
	pv.alignment = BoxContainer.ALIGNMENT_CENTER
	prompt_panel.add_child(pv)
	prompt_label = _label(20, INK)
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt_label.custom_minimum_size = Vector2(820, 0)
	pv.add_child(prompt_label)
	prompt_buttons = HBoxContainer.new()
	prompt_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	prompt_buttons.add_theme_constant_override("separation", 12)
	pv.add_child(prompt_buttons)
	prompt_panel.visible = false
	root.add_child(prompt_panel)

	popup = _panel()
	popup.set_anchors_preset(Control.PRESET_CENTER)
	popup.grow_horizontal = Control.GROW_DIRECTION_BOTH
	popup.grow_vertical = Control.GROW_DIRECTION_BOTH
	var ps := ScrollContainer.new()
	ps.custom_minimum_size = Vector2(460, 0)
	ps.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	popup_box = VBoxContainer.new()
	popup_box.add_theme_constant_override("separation", 6)
	popup_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ps.add_child(popup_box)
	popup.add_child(ps)
	popup.visible = false
	root.add_child(popup)

	ledger = _panel()
	ledger.position = Vector2(14, 250)
	ledger_box = VBoxContainer.new()
	ledger.add_child(ledger_box)
	ledger.visible = false
	root.add_child(ledger)

	var lp := _panel()
	lp.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	lp.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	lp.position = Vector2(-14, 14)
	log_box = RichTextLabel.new()
	log_box.custom_minimum_size = Vector2(380, 230)
	log_box.bbcode_enabled = true
	log_box.scroll_following = true
	log_box.add_theme_font_size_override("normal_font_size", 14)
	log_box.add_theme_color_override("default_color", DIM)
	log_box.mouse_filter = Control.MOUSE_FILTER_PASS
	lp.add_child(log_box)
	root.add_child(lp)

	var sp := _panel()
	sp.position = Vector2(14, 14)
	scores = _label(15, INK)
	sp.add_child(scores)
	root.add_child(sp)

	inspector = _panel()
	inspector.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	inspector.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	inspector.grow_vertical = Control.GROW_DIRECTION_BOTH
	inspector.position = Vector2(-14, 0)
	inspector.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var iv := VBoxContainer.new()
	inspector.add_child(iv)
	insp_tex = TextureRect.new()
	insp_tex.custom_minimum_size = Vector2(340, 340)
	insp_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	insp_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	insp_tex.pivot_offset = Vector2(170, 170)
	iv.add_child(insp_tex)
	insp_text = _label(15, INK)
	insp_text.custom_minimum_size = Vector2(340, 0)
	insp_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	iv.add_child(insp_text)
	inspector.visible = false
	root.add_child(inspector)

	help = _label(13, Color(0.6, 0.55, 0.5))
	help.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	help.grow_vertical = Control.GROW_DIRECTION_BEGIN
	help.position = Vector2(14, -14)
	help.text = "Right-drag: look around · Wheel: lean in · 1/2/3/4: look at a seat · Space: confirm · F: face tags · Hold Tab: fast-forward\nClick a die to commit it, right-click to discard; drag dice, cards and tokens"
	root.add_child(help)

	end_panel = _panel()
	end_panel.set_anchors_preset(Control.PRESET_CENTER)
	end_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	end_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	end_panel.visible = false
	root.add_child(end_panel)

# --- builders -----------------------------------------------------------------------
## Remove children now (queue_free alone leaves them counted in minimum sizes this frame).
static func _clear(n: Node) -> void:
	for c in n.get_children():
		n.remove_child(c)
		c.queue_free()

func _label(size: int, color: Color) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	l.add_theme_constant_override("outline_size", 4)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

func _panel() -> PanelContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.05, 0.04, 0.82)
	sb.border_color = Color(0.55, 0.42, 0.25, 0.8)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(6)
	sb.set_content_margin_all(10)
	p.add_theme_stylebox_override("panel", sb)
	return p

func _button(text: String, cb: Callable, enabled := true, tint := Color(0, 0, 0, 0)) -> Button:
	var b := Button.new()
	b.text = text
	b.disabled = not enabled
	b.add_theme_font_size_override("font_size", 17)
	b.custom_minimum_size = Vector2(110, 34)
	if tint.a > 0: b.add_theme_color_override("font_color", tint)
	b.pressed.connect(cb)
	b.focus_mode = Control.FOCUS_NONE
	return b

# --- prompt -------------------------------------------------------------------------
## buttons: [{label, cb, enabled = true, primary = false}]
func prompt(text: String, buttons: Array = []) -> void:
	prompt_label.text = text
	_clear(prompt_buttons)
	primary = Callable()
	for b in buttons:
		var en: bool = b.get("enabled", true)
		prompt_buttons.add_child(_button(b.label, b.cb, en))
		if b.get("primary", false) and en: primary = b.cb
	if primary.is_null() and buttons.size() == 1 and buttons[0].get("enabled", true): primary = buttons[0].cb
	prompt_panel.visible = true
	prompt_panel.reset_size()

func clear_prompt() -> void:
	prompt_panel.visible = false
	primary = Callable()

# --- pop-ups ------------------------------------------------------------------------
func _open_popup(title: String) -> void:
	_clear(popup_box)
	var t := _label(19, INK)
	t.text = title
	t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	t.custom_minimum_size = Vector2(440, 0)
	popup_box.add_child(t)
	popup.visible = true

func _fit_popup() -> void:
	var sc: ScrollContainer = popup.get_child(0)
	sc.custom_minimum_size.y = minf(popup_box.get_combined_minimum_size().y + 8, 560)
	popup.reset_size()

## items: [{label, cb, hover = Card or null, tint}]
func popup_options(title: String, items: Array) -> void:
	_open_popup(title)
	for it in items:
		var b := _button(it.label, it.cb, it.get("enabled", true), it.get("tint", Color(0, 0, 0, 0)))
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		if it.get("hover") is Card:
			var card: Card = it.hover
			b.mouse_entered.connect(func(): inspect(card))
			b.mouse_exited.connect(func(): inspect(null))
		popup_box.add_child(b)
	_fit_popup()

## Tick between lo and hi of the labels; cb(Array of indices).
func popup_many(title: String, labels: Array, lo: int, hi: int, cb: Callable, hovers: Array = []) -> void:
	_open_popup("%s  (choose %s)" % [title, str(lo) if lo == hi else "%d-%d" % [lo, hi]])
	var boxes := []
	var ok := _button("Confirm", func():
		var idx := []
		for i in boxes.size():
			if boxes[i].button_pressed: idx.append(i)
		cb.call(idx))
	var check := func():
		var n := boxes.filter(func(x): return x.button_pressed).size()
		ok.disabled = n < lo or n > hi
	for i in labels.size():
		var cbx := CheckBox.new()
		cbx.text = labels[i]
		cbx.add_theme_font_size_override("font_size", 16)
		cbx.toggled.connect(func(_on): check.call())
		if i < hovers.size() and hovers[i] is Card:
			var card: Card = hovers[i]
			cbx.mouse_entered.connect(func(): inspect(card))
			cbx.mouse_exited.connect(func(): inspect(null))
		popup_box.add_child(cbx)
		boxes.append(cbx)
	popup_box.add_child(ok)
	check.call()
	_fit_popup()

func popup_number(title: String, lo: int, hi: int, cb: Callable) -> void:
	_open_popup(title)
	var sb := SpinBox.new()
	sb.min_value = lo
	sb.max_value = hi
	sb.value = lo
	popup_box.add_child(sb)
	popup_box.add_child(_button("Confirm", func(): cb.call(int(sb.value))))
	_fit_popup()

## Amounts per token type, each within `have`; cb(Dictionary).
func popup_tokens(title: String, have: Dictionary, cb: Callable) -> void:
	_open_popup(title)
	var spins := {}
	for t in have:
		if have[t] <= 0: continue
		var row := HBoxContainer.new()
		var l := _label(16, Look.COLORS.get(t, INK).lightened(0.2))
		l.text = "%s (have %d)" % [Look.NAMES.get(t, t), have[t]]
		l.custom_minimum_size = Vector2(220, 0)
		row.add_child(l)
		var sb := SpinBox.new()
		sb.max_value = have[t]
		row.add_child(sb)
		spins[t] = sb
		popup_box.add_child(row)
	popup_box.add_child(_button("Confirm", func():
		var out := {}
		for t in spins:
			if spins[t].value > 0: out[t] = int(spins[t].value)
		cb.call(out)))
	_fit_popup()

func close_popup() -> void:
	popup.visible = false
	inspect(null)

# --- ledger -------------------------------------------------------------------------
## entries: [{label, color, hover: Callable(bool), click: Callable}]
func set_ledger(title: String, entries: Array) -> void:
	_clear(ledger_box)
	if entries.is_empty() and title == "":
		ledger.visible = false
		return
	var t := _label(16, INK)
	t.text = title
	ledger_box.add_child(t)
	for e in entries:
		var b := Button.new()
		b.text = "■ " + e.label
		b.flat = true
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.focus_mode = Control.FOCUS_NONE
		b.add_theme_font_size_override("font_size", 15)
		b.add_theme_color_override("font_color", e.color)
		b.add_theme_color_override("font_hover_color", e.color.lightened(0.35))
		if e.has("hover"):
			b.mouse_entered.connect(func(): e.hover.call(true))
			b.mouse_exited.connect(func(): e.hover.call(false))
		if e.has("click"): b.pressed.connect(e.click)
		else: b.disabled = true
		ledger_box.add_child(b)
	ledger.visible = true
	ledger.reset_size()

# --- inspector, log, scores, end ----------------------------------------------------
func inspect(c: Card) -> void:
	if c == null:
		inspector.visible = false
		return
	insp_tex.texture = Look.card_tex(c.id)
	insp_tex.rotation = PI if c.inverted else 0.0
	var ab := c.ability
	var other: Ability = c.faces[0 if c.inverted else 1]
	var where := ""
	match c.loc:
		GK.Loc.SQUARE: where = "In the Town Square"
		GK.Loc.CADRE: where = "%s's cadre" % c.owner.name
		GK.Loc.ATTACHED: where = "Attached to %s (relinquished by %s)" % [c.attached_to, c.owner.name]
		GK.Loc.PYRE: where = "In the pyre"
	insp_text.text = "%s%s\n%s\n\n(other face: %s)%s" % [ab.title, "  [inverted]" if c.inverted else "", ab.text, other.title, ("\n" + where) if where else ""]
	inspector.visible = true

func log_line(s: String) -> void:
	_log_lines.append(s)
	if _log_lines.size() > 80: _log_lines.pop_front()
	log_box.text = "\n".join(_log_lines)

func update_scores(g: Game, human_idx: int) -> void:
	var s := ""
	for p in g.players:
		var tok := []
		for t in GK.TOKENS:
			if p.tokens[t] > 0: tok.append("%d%s" % [p.tokens[t], t])
		s += "%s%s   %d keys  %d teeth  %s\n" % ["▶ " if p.idx == human_idx else "   ", p.name, p.keys, p.teeth, " ".join(tok)]
	s += "deck %d · pyre %d · keys to win %d" % [g.deck.size(), g.pyre.size(), g.win_keys()]
	scores.text = s

func show_end(text: String, again: Callable) -> void:
	_clear(end_panel)
	var v := VBoxContainer.new()
	var l := _label(28, INK)
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(l)
	v.add_child(_button("Play again", again))
	end_panel.add_child(v)
	end_panel.visible = true
