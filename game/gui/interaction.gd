class_name Interaction extends Node
## Turns the engine's Choices for your seat into table interactions, and your clicks and
## drags back into answers (Controller.Async.submit).
##
##   assign (Swig)        drag dice to the commit row / discard pile, or click (commit) and
##                        right-click (discard); sets you could form are ringed and listed
##   arrangement (Scry)   your committed dice are laid out in groups; drag dice between
##                        groups or browse the legal arrangements
##   request              glowing Town Square cards: drag one to your cadre (or click)
##   wager                drag tokens into the brass dish
##   orient (Scheme)      click your villagers to spin them
##   act                  villagers whose ability can be used now glow; click one
##   card / die targets   click a glowing card or die
##   anything else        a pop-up list
## Answers are submitted deferred, after this node's state is cleared, so the engine can
## ask the next question straight away.

const TIER_VALUE := [0, 1, 3, 6]

var table          # Table
var c: Choice = null
var mode := &""
var advisor: AdaptiveBot

# assign
var pending := {}          # Die -> &"commit" | &"discard"
var hints: Array = []      # [{def, dice, color}] best arrangement over live dice
var extra_hints: Array = []
var hover_set: Array = []
# arrange
var arr_opts: Array = []
var arr_sel := 0
var groups: Array = []     # Array of Array[Die]
var unscored_dice: Array = []
var group_labels: Array = []
# request / act / pick
var card_opts := {}        # Card -> Array of options
var die_opts := {}         # Die -> option
var source_card: Card = null
var alert_card: Card = null
var orient := {}           # Card -> inverted?
var last_die: Die = null

# mouse
var press_pos := Vector2.ZERO
var press_obj = null
var press_button := 0
var dragging := false
var drag_obj = null
var hovered = null
var throw_from := Vector2.ZERO

func _ready() -> void:
	advisor = AdaptiveBot.new([], 12345)

func game() -> Game: return table.game
func me() -> Player: return table.game.players[table.human_idx]
func seat() -> SeatView: return table.seats[table.human_idx]

# =============================================================================
# Begin / submit
# =============================================================================
func begin(ch: Choice) -> void:
	_reset()
	c = ch
	if table.yaw_off != 0.0 or table.look_goal != Vector3(0, 0, 21): table.look_at_seat(table.human_idx)
	source_card = ch.source.card if ch.source and ch.source.card else null
	match ch.kind:
		&"assign": _begin_assign()
		&"tokens":
			if ch.tag == &"wager": _begin_wager()
			else:
				mode = &"popup"
				table.hud.popup_tokens(ch.prompt, ch.options[0], submit)
		&"yes_no": _begin_yes_no()
		&"number":
			mode = &"popup"
			table.hud.popup_number(ch.prompt, ch.lo, ch.hi, submit)
		&"many":
			if ch.tag == &"orient": _begin_orient()
			else: _begin_many()
		&"one":
			var real := ch.options.filter(func(o): return o != null)
			if ch.tag == &"arrangement": _begin_arrange()
			elif ch.tag == &"request": _begin_request()
			elif ch.tag == &"act": _begin_act()
			elif real.size() > 0 and real.all(func(o): return o is Card) and real.all(func(o): return _on_table(o)): _begin_pick_cards()
			elif real.size() > 0 and real.all(func(o): return o is Die): _begin_pick_dice()
			else: _popup_one()
		_: _popup_one()
	table.request_sync()

func submit(a) -> void:
	if c == null: return
	if a is Die: last_die = a
	var was := mode
	_reset()
	table.hud.clear_prompt()
	table.hud.close_popup()
	table.hud.set_ledger("", [])
	if was == &"wager": seat().clear_dish()
	table.request_sync()
	table.human.submit.call_deferred(a)

func _reset() -> void:
	c = null
	mode = &""
	pending.clear()
	hints.clear()
	extra_hints.clear()
	hover_set.clear()
	arr_opts.clear()
	groups.clear()
	unscored_dice.clear()
	card_opts.clear()
	die_opts.clear()
	orient.clear()
	source_card = null
	alert_card = null
	for l in group_labels: l.queue_free()
	group_labels.clear()

func phase_changed() -> void: pass

func _on_table(card: Card) -> bool:
	return card.loc == GK.Loc.SQUARE or card.loc == GK.Loc.CADRE or card.loc == GK.Loc.ATTACHED

# =============================================================================
# Swig: commit / discard
# =============================================================================
func _begin_assign() -> void:
	mode = &"assign"
	_update_assign()

func _update_assign() -> void:
	var nc := pending.values().count(&"commit")
	var nd := pending.values().count(&"discard")
	var left: int = c.options.size() - nc - nd
	var ok: bool = nc + nd >= c.lo
	var label := "Commit %d" % nc
	if nd: label += " · discard %d" % nd
	if left > 0: label += " · reroll %d" % left
	table.hud.prompt("Swig: commit or discard at least %d of your %d rolled dice. Click a die to commit it, right-click to discard, or drag it." % [c.lo, c.options.size()], [
		{label = label, cb = _confirm_assign, enabled = ok, primary = true},
		{label = "Advise me", cb = _advise_assign},
		{label = "Clear", cb = _clear_pending},
	])
	_compute_hints()

func _clear_pending() -> void:
	pending.clear()
	_after_pending()

func _confirm_assign() -> void:
	var a := {commit = [], discard = []}
	for d in c.options:
		match pending.get(d, &""):
			&"commit": a.commit.append(d)
			&"discard": a.discard.append(d)
	if a.commit.size() + a.discard.size() >= c.lo: submit(a)

## Ask the AdaptiveBot's dice solver what it would do.
func _advise_assign() -> void:
	var a: Dictionary = advisor.decide(game(), c)
	pending.clear()
	for d in a.commit: pending[d] = &"commit"
	for d in a.discard: pending[d] = &"discard"
	_after_pending()

func _toggle_commit(d: Die) -> void:
	if pending.get(d) == &"commit": pending.erase(d)
	else: pending[d] = &"commit"
	_after_pending()

func _toggle_discard(d: Die) -> void:
	if pending.get(d) == &"discard": pending.erase(d)
	else: pending[d] = &"discard"
	_after_pending()

func _after_pending() -> void:
	for d in pending:   # dice leaving the tray lose their resting spot
		table.die_view(d).state = &"placed"
	for d in c.options:
		if not pending.has(d) and table.die_view(d).state == &"placed": table.die_view(d).state = &"idle"
	_update_assign()
	table.request_sync()

## Best arrangement over every live die (committed + rolled), plus other sets in reach.
func _compute_hints() -> void:
	hints.clear()
	extra_hints.clear()
	var p := me()
	var live := p.swig_dice.filter(func(d): return not d.discarded() and pending.get(d) != &"discard" and not (d.face() is String and d.face() == ""))
	if live.is_empty():
		_show_ledger()
		return
	var firm := live.filter(func(d): return d.committed() or pending.get(d) == &"commit")
	var rules: Dictionary = game().query(&"score_rules", p, {})
	var best := _best(Scoring.arrangements(live.map(func(d): return d.face()), rules))
	var bound := _bind(best, live, firm)
	for i in bound.size():
		bound[i].color = Look.SET_COLORS[i % Look.SET_COLORS.size()]
		hints.append(bound[i])
	var have := hints.map(func(h): return h.def.id)
	var counts := {}
	for d in live: counts[d.face()] = counts.get(d.face(), 0) + 1
	var banned: Array = rules.get("banned", [])
	var only: Array = rules.get("only", [])
	for def in Scoring.MENU:
		if have.has(def.id) or banned.has(def.id) or (only and not only.has(def.id)): continue
		var found := false
		for n in def.sizes(rules):
			if found: break
			for sub in Scoring._sub_multisets(counts, n):
				if Scoring.test(def, sub, rules):
					var b := _bind([{def = def, faces = sub}], live, firm)
					b[0].color = Color(0.75, 0.7, 0.62)
					extra_hints.append(b[0])
					found = true
					break
	_show_ledger()

func _show_ledger() -> void:
	var entries := []
	for h in hints + extra_hints:
		var dice_h: Array = h.dice
		var firm := dice_h.all(func(d): return d.committed() or pending.get(d) == &"commit")
		var where: String = "slot %d" % (h.def.slot + 1) if h.def.tier == 1 else ("any slot" if h.def.tier == 2 else "two slots")
		var e := {
			label = "%s  %s  → %s%s" % [h.def.name, " ".join(dice_h.map(func(d): return Interaction._face_short(d.face()))), where, "  ✓" if firm else ""],
			color = h.color,
			hover = _hover_cb(dice_h),
		}
		if mode == &"assign": e.click = _commit_cb(dice_h)
		entries.append(e)
	var title := "Sets in reach (best first):" if mode == &"assign" else "Your sets:"
	table.hud.set_ledger(title if entries else "No sets in reach", entries)

func _hover_cb(ds: Array) -> Callable:
	return func(on: bool):
		hover_set = ds.duplicate() if on else []
		table.request_sync()

func _commit_cb(ds: Array) -> Callable:
	return func():
		for d in ds:
			if c and c.options.has(d): pending[d] = &"commit"
		_after_pending()

static func _face_short(f) -> String: return str(f) if f is int else ("_" if f == "" else f)

func _best(opts: Array) -> Array:
	var best: Array = opts[0]
	var bv := -1.0
	for a in opts:
		var v := 0.0
		for s in a: v += TIER_VALUE[s.def.tier] + 0.01 * s.faces.size()
		if v > bv:
			bv = v
			best = a
	return best

## Bind an arrangement's faces to actual dice, preferring `prefer` dice first.
static func _bind(arr: Array, dice_list: Array, prefer: Array) -> Array:
	var pool := prefer.duplicate()
	for d in dice_list:
		if not pool.has(d): pool.append(d)
	var out := []
	for s in arr:
		var ds := []
		for f in s.faces:
			for d in pool:
				if typeof(d.face()) == typeof(f) and d.face() == f:
					ds.append(d)
					pool.erase(d)
					break
		out.append({def = s.def, dice = ds, faces = s.faces})
	return out

# =============================================================================
# Scry: arrangement
# =============================================================================
func _begin_arrange() -> void:
	mode = &"arrange"
	arr_opts = c.options.duplicate()
	arr_opts.sort_custom(func(a, b): return _arr_value(a) > _arr_value(b))
	_apply_option(0)

func _arr_value(a: Array) -> float:
	var v := 0.0
	for s in a: v += TIER_VALUE[s.def.tier] + 0.01 * s.faces.size()
	return v

func _apply_option(i: int) -> void:
	arr_sel = posmod(i, arr_opts.size())
	var committed := me().committed()
	var bound := _bind(arr_opts[arr_sel], committed, [])
	groups = bound.map(func(b): return b.dice)
	unscored_dice = committed.filter(func(d): return not groups.any(func(g): return g.has(d)))
	_update_arrange()

func _group_key(dice_list: Array) -> String:
	var k := dice_list.map(func(d): return var_to_str(d.face()))
	k.sort()
	return ",".join(k)

## Options whose sets match the current groups exactly (as face multisets).
func _matching() -> Array:
	var mine := groups.map(func(g): return _group_key(g))
	mine.sort()
	var out := []
	for o in arr_opts:
		var ks := []
		for s in o:
			var fs: Array = s.faces.map(func(f): return var_to_str(f))
			fs.sort()
			ks.append(",".join(fs))
		ks.sort()
		if ks == mine: out.append(o)
	return out

func _update_arrange() -> void:
	groups = groups.filter(func(g): return not g.is_empty())
	var m := _matching()
	var legal := not m.is_empty()
	if legal: arr_sel = arr_opts.find(m[0])
	hints.clear()
	var names := []
	var used := []
	for gi in groups.size():
		var g: Array = groups[gi]
		var def_name := "?"
		if legal:
			for s in m[0]:
				var fs: Array = s.faces.map(func(f): return var_to_str(f))
				fs.sort()
				if ",".join(fs) == _group_key(g) and not used.has(s):
					used.append(s)
					def_name = s.def.name
					hints.append({def = s.def, dice = g, color = Look.SET_COLORS[gi % Look.SET_COLORS.size()]})
					break
		names.append(def_name)
	var text := "Scry: these sets will be scored. Drag dice between groups (or to the back row to leave them out), or browse the %d legal arrangement%s." % [arr_opts.size(), "s" if arr_opts.size() > 1 else ""]
	if not legal: text = "That grouping isn't a legal arrangement (every set you can still form must be scored). Rearrange, or browse."
	var btns := []
	if arr_opts.size() > 1:
		btns.append({label = "◀", cb = func(): _apply_option(arr_sel - 1)})
		btns.append({label = "%d / %d" % [arr_sel + 1, arr_opts.size()] if legal else "–", cb = func(): pass, enabled = false})
		btns.append({label = "▶", cb = func(): _apply_option(arr_sel + 1)})
	btns.append({label = "Score these" if hints else "Score nothing", cb = _confirm_arrange, enabled = legal, primary = true})
	table.hud.prompt(text, btns)
	_show_ledger()
	_refresh_group_labels(names, legal)
	table.request_sync()

func _confirm_arrange() -> void:
	if not _matching().is_empty(): submit(arr_opts[arr_sel])

func _refresh_group_labels(names: Array, legal: bool) -> void:
	for l in group_labels: l.queue_free()
	group_labels.clear()
	var pts := seat().group_points(groups.map(func(g): return g.size()))
	for gi in groups.size():
		var a: Vector3 = pts[gi][0]
		var b: Vector3 = pts[gi][-1]
		var col: Color = Look.SET_COLORS[gi % Look.SET_COLORS.size()] if legal else Look.GLOW_ALERT
		var l := Look.label(names[gi], 40, 0.02, col)
		l.outline_size = 8
		l.outline_modulate = Color(0, 0, 0, 0.85)
		l.rotation_degrees.x = -70
		add_child(l)
		l.global_position = (a + b) * 0.5 + seat().global_basis * Vector3(0, 0.1, 2.0)
		l.global_rotation = Vector3(deg_to_rad(-70), seat().yaw(), 0)
		group_labels.append(l)

func _drop_arrange(d: Die, at: Vector3) -> void:
	for g in groups: g.erase(d)
	unscored_dice.erase(d)
	var zone := seat().zone_at(at)
	if zone == &"unscored" or zone == &"tray":
		unscored_dice.append(d)
	else:
		var local := seat().global_transform.affine_inverse() * at
		var pts := seat().group_points(groups.map(func(g): return g.size()))
		var target := -1
		for gi in groups.size():
			if groups[gi].is_empty(): continue
			var xs: Array = pts[gi].map(func(p): return (seat().global_transform.affine_inverse() * p).x)
			if local.x >= xs.min() - 1.6 and local.x <= xs.max() + 1.6: target = gi
		if target >= 0: groups[target].append(d)
		elif groups.is_empty() or local.x > 0: groups.append([d])
		else: groups.insert(0, [d])
	_update_arrange()

# =============================================================================
# Requests and wagers
# =============================================================================
func _begin_request() -> void:
	mode = &"request"
	var rights := {}
	var buys := []
	for o in c.options:
		if o == null: continue
		if not card_opts.has(o.card): card_opts[o.card] = []
		card_opts[o.card].append(o)
		if o.right != null: rights[o.right] = true
		elif not buys.has(o.slot): buys.append(o.slot)
	var parts := []
	for r in rights:
		parts.append("slot %d" % (r[0] + 1) if r.size() == 1 else "any slot")
	var txt := "Request a villager: drag a glowing card to your cadre, or click it."
	if parts: txt += " Your sets grant: %s." % ", ".join(parts)
	if buys: txt += " You can also buy slot %s with tokens (right-click a card for options)." % ", ".join(buys.map(func(s): return str(s + 1)))
	table.hud.prompt(txt, [{label = "Pass", cb = func(): submit(null), primary = true}])

func _request(card: Card, ask_how := false) -> void:
	var opts: Array = card_opts.get(card, [])
	if opts.is_empty(): return
	var free := opts.filter(func(o): return o.right != null)
	free.sort_custom(func(a, b): return a.right.size() < b.right.size())
	if ask_how or free.is_empty() and opts.size() > 1:
		var items := []
		for o in opts:
			var lbl: String = ("Use your set right (%s)" % ("slot %d" % (o.right[0] + 1) if o.right.size() == 1 else "any slot")) if o.right != null else "Pay %s" % game().cost_str(o.tokens)
			items.append({label = lbl, cb = func(): submit(o)})
		items.append({label = "Cancel", cb = func(): table.hud.close_popup()})
		table.hud.popup_options("Request %s how?" % card, items)
		return
	submit(free[0] if free else opts[0])

func _begin_wager() -> void:
	mode = &"wager"
	alert_card = c.data.get("card")
	seat().dish.visible = true
	_update_wager()

func bid() -> Dictionary:
	var out := {}
	for t in seat().piles:
		var n: int = seat().piles[t].filter(func(tv): return tv.in_dish).size()
		if n > 0: out[t] = n
	return out

func _update_wager() -> void:
	var b := bid()
	var total := 0
	for t in b: total += b[t]
	var rivals: Array = c.data.get("rivals", []).map(func(p): return p.name)
	table.hud.prompt("Contested! Wager tokens for %s against %s: drag tokens into the brass dish (click to take one back). The highest total wins and pays; ties re-wager." % [alert_card, ", ".join(rivals)], [
		{label = "Wager %d token%s" % [total, "" if total == 1 else "s"], cb = func(): submit(bid()), primary = true},
		{label = "Type amounts…", cb = func(): table.hud.popup_tokens("Wager for %s" % alert_card, c.options[0], submit)},
	])

func _token_to_dish(tv: TokenView) -> void:
	tv.in_dish = true
	var n := 0
	for t in seat().piles:
		n += seat().piles[t].filter(func(x): return x.in_dish and x != tv).size()
	var p := seat().dish_point() + Vector3(randf_range(-1.2, 1.2), 0.35 + n * 0.32, randf_range(-1.2, 1.2))
	tv.pin(Transform3D(Basis(Vector3.UP, randf() * TAU), p))
	_update_wager()

func _token_from_dish(tv: TokenView) -> void:
	tv.in_dish = false
	tv.drop_at(seat().pile_point(tv.type) + Vector3(randf_range(-0.8, 0.8), 4, randf_range(-0.8, 0.8)))
	_update_wager()

# =============================================================================
# Scheme orientation, abilities, targets
# =============================================================================
func _begin_orient() -> void:
	mode = &"orient"
	for card in c.options: orient[card] = card.inverted
	table.hud.prompt("Scheme: choose which villagers are inverted. Click a card to spin it (hover to read both faces).", [
		{label = "Done", cb = func(): submit(c.options.filter(func(x): return orient.get(x, false))), primary = true}])

func shown_inverted(card: Card) -> bool:
	return orient.get(card, card.inverted) if mode == &"orient" else card.inverted

func _begin_act() -> void:
	mode = &"act"
	var btns := []
	for o in c.options:
		if o == null: continue
		var card: Card = o.ability.card
		if not card_opts.has(card): card_opts[card] = []
		card_opts[card].append(o)
		if btns.size() < 4: btns.append({label = o.label, cb = func(): submit(o)})
	var window := c.prompt.get_slice("(", 1).trim_suffix(")")
	btns.insert(0, {label = "Continue", cb = func(): submit(null), primary = true})
	table.hud.prompt("Your villagers can act now (%s). Click a glowing card, or continue." % window, btns)

func _act(card: Card) -> void:
	var opts: Array = card_opts.get(card, [])
	if opts.size() == 1: submit(opts[0])
	elif opts.size() > 1:
		var items := opts.map(func(o): return {label = o.label, cb = func(): submit(o)})
		items.append({label = "Cancel", cb = func(): table.hud.close_popup()})
		table.hud.popup_options("%s: which ability?" % card, items)

func _begin_pick_cards() -> void:
	mode = &"pick_card"
	for o in c.options:
		if o != null: card_opts[o] = [o]
	var btns := []
	if c.options.has(null): btns.append({label = "None", cb = func(): submit(null), primary = true})
	table.hud.prompt("%s  (click a glowing card)" % _prompt(), btns)

func _begin_pick_dice() -> void:
	mode = &"pick_die"
	for o in c.options:
		if o != null:
			die_opts[o] = o
			table.die_view(o)
	var btns := []
	if c.options.has(null): btns.append({label = "None", cb = func(): submit(null), primary = true})
	table.hud.prompt("%s  (click a glowing die)" % _prompt(), btns)

func _begin_yes_no() -> void:
	mode = &"yes_no"
	var extra := ""
	if c.data.has("cost") and c.data.cost is Dictionary and not c.data.cost.is_empty(): extra = "  [cost: %s]" % game().cost_str(c.data.cost)
	table.hud.prompt(_prompt() + extra, [
		{label = "Yes", cb = func(): submit(true), primary = true},
		{label = "No", cb = func(): submit(false)}])

func _begin_many() -> void:
	mode = &"popup"
	var labels := c.options.map(func(o): return _opt_label(o))
	table.hud.popup_many(_prompt(), labels, c.lo, c.hi, func(idx): submit(idx.map(func(i): return c.options[i])), c.options)

func _popup_one() -> void:
	mode = &"popup"
	var items := []
	for o in c.options:
		items.append({label = _opt_label(o), cb = func(): submit(o), hover = o if o is Card else null})
	table.hud.popup_options(_prompt(), items)

func _prompt() -> String:
	return ("%s: %s" % [c.source.title, c.prompt]) if c.source and not c.prompt.begins_with(c.source.title) else c.prompt

func _opt_label(o) -> String:
	if o == null: return "None / pass"
	if o is Card: return "%s  (%s)" % [o, _where(o)]
	if o is Die: return "Die showing %s  [%s]" % [Look.face_text(o.face()), " ".join(o.faces.map(func(f): return Interaction._face_short(f)))]
	if o is Dictionary:
		if o.has("label"): return o.label
		return game().cost_str(o)
	if o is String and Look.NAMES.has(o): return Look.NAMES[o]
	if o is int:
		match c.tag:
			&"dir": return "One face forward" if o > 0 else "One face back"
			&"face", &"rotate_face":
				if last_die and o < last_die.faces.size(): return "Face %d: %s" % [o + 1, Look.face_text(last_die.faces[o])]
				return "Face %d" % (o + 1)
	if o is Array: return " + ".join(o.map(func(s): return s.def.name if s is Dictionary and s.has("def") else str(s)))
	return str(o)

func _where(card: Card) -> String:
	match card.loc:
		GK.Loc.SQUARE: return "town square"
		GK.Loc.CADRE: return "%s's cadre" % card.owner.name
		GK.Loc.ATTACHED: return "attached"
		GK.Loc.PYRE: return "pyre"
		GK.Loc.DECK: return "deck"
	return "gone"

# =============================================================================
# Queries from Table.sync
# =============================================================================
func zone_for(d: Die) -> StringName:
	if mode == &"assign" and pending.has(d): return pending[d]
	if d.committed(): return &"commit"
	if d.discarded(): return &"discard"
	return &"tray"

func pending_commits(p: Player) -> Array:
	if mode != &"assign" or p != me(): return []
	return c.options.filter(func(d): return pending.get(d) == &"commit")

func arranged_points(p: Player) -> Dictionary:
	if mode != &"arrange" or p != me(): return {}
	var out := {}
	var pts := seat().group_points(groups.map(func(g): return g.size()))
	for gi in groups.size():
		for j in groups[gi].size(): out[groups[gi][j]] = pts[gi][j]
	return out

func unscored(p: Player) -> Array:
	return unscored_dice if mode == &"arrange" and p == me() else []

func card_glow(card: Card):
	if card == alert_card: return Look.GLOW_ALERT
	if card_opts.has(card): return Look.GLOW_PICK
	if card == source_card: return Look.GLOW_SOURCE
	if is_instance_valid(hovered) and hovered is CardView and hovered.card == card and mode == &"orient" and card.owner == me(): return Look.GLOW_PICK
	return null

const HOVER := Color(0.9, 0.9, 1.0, 0.6)

func die_glow(d: Die):
	if hover_set.has(d): return Color(1, 1, 1)
	if die_opts.has(d): return Look.GLOW_PICK
	if mode == &"assign" and pending.get(d) == &"discard": return Look.GLOW_ALERT
	if is_instance_valid(hovered) and hovered is DieView and hovered.die == d and c and _draggable(hovered): return HOVER
	return null

func die_ring(d: Die):
	if d.owner != me(): return null
	for h in hints:
		if h.dice.has(d): return h.color
	return null

func lit_sets() -> Dictionary:
	var out := {}
	for h in hints: out[h.def.id] = h.color
	return out

func after_sync() -> void: pass

# =============================================================================
# Mouse and keys
# =============================================================================
## Once a press started on the table, its motion and release are ours even over HUD panels.
func _input(e: InputEvent) -> void:
	if press_button == 0: return
	if e is InputEventMouseMotion:
		_mouse_motion(e)
		get_viewport().set_input_as_handled()
	elif e is InputEventMouseButton and not e.pressed and e.button_index == press_button:
		_mouse_button(e)
		get_viewport().set_input_as_handled()

func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and not e.echo:
		match e.keycode:
			KEY_SPACE, KEY_ENTER, KEY_KP_ENTER:
				if not table.roller.waiting.is_empty(): table.roller.thrown.emit(Vector2(randf_range(-5, 5), -24))
				elif table.hud.primary.is_valid(): table.hud.primary.call()
			KEY_1, KEY_2, KEY_3, KEY_4: table.look_at_seat(e.keycode - KEY_1)
			KEY_ESCAPE: table.hud.close_popup()
			KEY_F:
				DieView.show_tags = not DieView.show_tags
				table.request_sync()
	elif e is InputEventMouseButton:
		_mouse_button(e)
	elif e is InputEventMouseMotion and press_button == 0:
		_mouse_motion(e)

func _mouse_button(e: InputEventMouseButton) -> void:
	if e.button_index == MOUSE_BUTTON_WHEEL_UP and e.pressed: table.fov_goal = clampf(table.fov_goal - 3, 26, 70)
	elif e.button_index == MOUSE_BUTTON_WHEEL_DOWN and e.pressed: table.fov_goal = clampf(table.fov_goal + 3, 26, 70)
	if e.button_index != MOUSE_BUTTON_LEFT and e.button_index != MOUSE_BUTTON_RIGHT: return
	if e.pressed:
		press_pos = e.position
		press_button = e.button_index
		press_obj = pick(e.position)
		throw_from = e.position
		return
	# release
	var moved := e.position.distance_to(press_pos) > 6
	if e.button_index == MOUSE_BUTTON_LEFT:
		if not table.roller.waiting.is_empty():
			var dv := e.position - throw_from
			var fling := Vector2(randf_range(-5, 5), -24) if dv.length() < 12 else Vector2(clampf(dv.x * 0.05, -14, 14), -clampf(-dv.y * 0.09, 12, 55))
			table.roller.thrown.emit(fling)
		elif dragging: _drop(e.position)
		elif not moved and press_obj: _click(press_obj)
	elif e.button_index == MOUSE_BUTTON_RIGHT and not moved and press_obj:
		_alt_click(press_obj)
	press_obj = null
	press_button = 0
	dragging = false
	drag_obj = null

func _mouse_motion(e: InputEventMouseMotion) -> void:
	if press_button == MOUSE_BUTTON_RIGHT:
		table.yaw_off = clampf(table.yaw_off - e.relative.x * 0.004, -1.6, 1.6)
		table.pitch_off = clampf(table.pitch_off - e.relative.y * 0.004, -0.6, 0.7)
		return
	if press_button == MOUSE_BUTTON_LEFT and press_obj and not dragging and e.position.distance_to(press_pos) > 6 and _draggable(press_obj):
		dragging = true
		drag_obj = press_obj
		drag_obj.held = true
		if drag_obj is TokenView: drag_obj.freeze = true
	if dragging:
		var h := 3.5 if drag_obj is DieView else 2.0
		var p := plane_point(e.position, h)
		drag_obj.global_position = drag_obj.global_position.lerp(p, 0.6)
		return
	var h = pick(e.position)
	if h != hovered:
		if is_instance_valid(hovered) and hovered is TokenView: hovered.set_glow(null)
		if h is TokenView and _draggable(h): h.set_glow(HOVER)
		hovered = h
		if h is CardView and not (h.card.loc == GK.Loc.DECK):
			table.hud.inspect(h.card)
		else:
			table.hud.inspect(null)
		if h is DieView:
			var d: Die = h.die
			table.hud.status.text = "%s die: %s (showing %s)" % [d.owner.name if d.owner else "", " ".join(d.faces.map(func(f): return Interaction._face_short(f))), Look.face_text(d.face())]
		table.request_sync()

func pick(pos: Vector2):
	var cam: Camera3D = table.cam
	var from := cam.project_ray_origin(pos)
	var q := PhysicsRayQueryParameters3D.create(from, from + cam.project_ray_normal(pos) * 600.0, 2 | 4 | 8)
	q.collide_with_areas = true
	var r: Dictionary = table.get_world_3d().direct_space_state.intersect_ray(q)
	if r.is_empty(): return null
	var col: Object = r.collider
	return col.get_meta("view") if col.has_meta("view") else null

func plane_point(pos: Vector2, h: float) -> Vector3:
	var cam: Camera3D = table.cam
	var o := cam.project_ray_origin(pos)
	var n := cam.project_ray_normal(pos)
	if absf(n.y) < 1e-4: return o
	return o + n * ((h - o.y) / n.y)

func _draggable(o) -> bool:
	if o is DieView:
		if mode == &"assign": return c.options.has(o.die)
		if mode == &"arrange": return o.die.owner == me() and o.die.committed()
	if o is CardView: return mode == &"request" and card_opts.has(o.card)
	if o is TokenView: return mode == &"wager" and o.get_parent() == seat()
	return false

func _drop(pos: Vector2) -> void:
	var o = drag_obj
	o.held = false
	var at := plane_point(pos, 0.0)
	var zone := seat().zone_at(at)
	if o is DieView:
		var d: Die = o.die
		if mode == &"assign":
			match zone:
				&"commit", &"unscored": pending[d] = &"commit"
				&"discard": pending[d] = &"discard"
				_:
					pending.erase(d)
					if zone == &"tray":   # leave it where it was dropped
						o.state = &"rest"
						var l := seat().global_transform.affine_inverse() * at
						l.x = clampf(l.x, -SeatView.TRAY.x / 2 + 1, SeatView.TRAY.x / 2 - 1)
						l.z = clampf(l.z, SeatView.TRAY_Z - SeatView.TRAY.y / 2 + 1, SeatView.TRAY_Z + SeatView.TRAY.y / 2 - 1)
						o.move_to(DieView.rest_at(seat().global_transform * l, d.up, o.yaw()), 0.2, 0.0)
						_update_assign()
						table.request_sync()
						return
			_after_pending()
		elif mode == &"arrange":
			_drop_arrange(d, at)
	elif o is CardView:
		if zone != &"": _request(o.card)
		table.request_sync()
	elif o is TokenView:
		if zone == &"dish": _token_to_dish(o)
		else: _token_from_dish(o)
	table.request_sync()

func _click(o) -> void:
	if o is DieView:
		var d: Die = o.die
		match mode:
			&"assign": if c.options.has(d): _toggle_commit(d)
			&"pick_die": if die_opts.has(d): submit(d)
	elif o is CardView:
		var card: Card = o.card
		match mode:
			&"request": _request(card)
			&"act": _act(card)
			&"pick_card": if card_opts.has(card): submit(card)
			&"orient":
				if orient.has(card):
					orient[card] = not orient[card]
					table.hud.inspect(null)
					table.request_sync()
	elif o is TokenView and mode == &"wager" and o.get_parent() == seat():
		if o.in_dish: _token_from_dish(o)
		else: _token_to_dish(o)

func _alt_click(o) -> void:
	if o is DieView and mode == &"assign" and c.options.has(o.die): _toggle_discard(o.die)
	elif o is CardView and mode == &"request" and card_opts.has(o.card): _request(o.card, true)
