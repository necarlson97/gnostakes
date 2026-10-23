class_name Valuer extends RefCounted
## Prices everything in expected keys ("key-equivalents") for one bot.
##
## The common currency is what makes decisions comparable: "spend 2W to score a set
## again" is worth it when price(extra request) > 2 * price(W). Prices come from three
## places, in increasing specificity:
##   1. static baselines (the constants below)
##   2. the bot's strategy mix (Strategy.tokens / sets / teeth / features)
##   3. the bot's cadre: a card that turns 6W into a key makes W worth ~1/6 key
## Every number here is a tuning knob; sims and tuning should replace the guesses.

const KEY := 1.0
const TOKEN := 0.12          # baseline price of one E/W/F/A
const Q_PREMIUM := 1.25      # Q is wild, so it's worth a bit more than the best element
const CONVERSION := 0.9      # share of a token->key conversion rate counted as price
const ONE_SHOT := 0.5        # conversions that incinerate their card set prices only half as much
const BURN_SELF := 0.25      # incinerating a card for its own payoff loses only its other value
const TOOTH := 0.25          # a comfortable tooth
const LAST_TOOTH := 3.0      # dying forfeits the game: worth this many keys plus all you hold
const TOOTH_URGENCY := 4.0   # tooth x is worth TOOTH * (1 + TOOTH_URGENCY / x)
const TOOTH_DRAIN := 0.35    # calibrated 2026-10-22 (drain 0 dies ~15%; 1.0 too timid); calibration run sim/results/20261022-233041
const CARD_POWER := 0.2      # card value floor before features / learned power
const CLAIM_BONUS := 0.1     # churn: claiming feeds trims, burn payoffs and denies rivals
const HOARD := 6             # tokens held beyond this lose value (diminishing returns)
## Feature weights every strategy shares: a strategy-free sense of what a face is worth.
## A face's power = CARD_POWER + tanh(base dot features); learned power overrides it.
const BASE := {keys = 0.5, win = 0.6, teeth = 0.35, teeth_cost = 0.1, teeth_payoff = 0.1, teeth_guard = 0.2, aggro = 0.15, bonus_die = 0.15,
	dice_control = 0.1, relinquish = 0.1, nothing = 0.1}
const FIT := 0.6             # how much strategy fit adds to a card's value
const OVER_PREF := 0.25      # penalty per card above the strategy's preferred cadre size
const CONTROL := 0.1         # one die manipulation (rotate, uncommit, undiscard)
const FACE := 0.15           # one permanent face edit
const DIE := 0.4             # one extra permanent die
const DISCARD := 0.06        # one die thrown away mid-Swig
const SET := 0.35            # forgoing one scoring set
const HURT := 0.15           # an opponent loses a tooth
const DENY := 0.3            # an opponent loses a card
const OPTION := 0.2          # taking an extra "or" option (Toothless Grinner)
const INFO := 0.03
const POTENTIAL := 0.6       # weight on partial sets while dice can still be rerolled
const TIER := [0.0, 0.5, 0.8, 1.2]   # value of a set's tier for partial-progress scoring
const SET_FLAVOR := 0.08     # strategy taste for a set family, per tier
const CADRE_SET := 0.3       # cadre faces that reward/punish a set family

## What an activated ability yields, by act id, when the act doesn't say (acts may add
## `gain = {...}` to their definition to override).
const ACT_GAINS := {
	key = {keys = 1}, q = {Q = 1}, rotate = {control = 1}, nudge = {control = 1}, mimic = {control = 1},
	uncommit = {control = 1}, undiscard = {control = 2}, leech = {control = 1}, quint = {face = 1},
	earth = {face = 1}, relinquish = {hurt = 2}, attach = {hurt = 2}, invert = {option = 1},
	again = {claim_any = 1}, resurrect = {claim_best_pyre = 1}, stoke = {claim_pyre_top = 1},
	snatch = {claim_pyre_top = 1}, slot = {option = 1}, die = {die = 1}, bury = {option = 0.5},
	feed = {E = 1}, purge = {option = 0.5}, blast = {hurt = 3}, cash = {E = 1},
	take = {F = 1}, drink = {W = 2}, scribble = {A = 0.5}, reserve = {option = 1},
}

var bot
var _cache := {}
## Tooth-caution knobs: defaults are the constants above; Bots.make("x@drain=0.5/last=2")
## overrides them per bot, which is how calibration leagues compare caution levels.
var tooth := TOOTH
var last_tooth := LAST_TOOTH
var tooth_urgency := TOOTH_URGENCY
var tooth_drain := TOOTH_DRAIN
const KNOBS := {tooth = "tooth", last = "last_tooth", urgency = "tooth_urgency", drain = "tooth_drain"}
static var _power := {}

func _init(b) -> void: bot = b

## Clear per-decision caches (card values depend on the current state).
func begin() -> void: _cache.clear()

# --- blending ---------------------------------------------------------------------
func _blend(g: Game, p: Player, f: Callable) -> float:
	var mix: Dictionary = bot.mix_for(g, p)
	var v := 0.0
	for s in mix: v += mix[s] * f.call(s)
	return v

func set_weight(g: Game, p: Player, family: String) -> float: return _blend(g, p, func(s): return s.set_weight(family))
func cadre_pref(g: Game, p: Player) -> float: return _blend(g, p, func(s): return s.cadre)

# --- resource prices ------------------------------------------------------------------
func token_price(g: Game, p: Player, t: String) -> float:
	if t == "Q":
		var best := 0.0
		for e in GK.ELEMENTS: best = maxf(best, token_price(g, p, e))
		return best * Q_PREMIUM
	var key := "tok_" + t
	if _cache.has(key): return _cache[key]
	var v := TOKEN * _blend(g, p, func(s): return s.token_weight(t))
	for c in p.cadre:   # conversions on my cards raise the price
		var ab := c.ability.resolve()
		var acts := ab.acts()
		for id in acts:
			var a: Dictionary = acts[id]
			var keys: float = act_gain(ab, id).get("keys", 0.0)
			if keys > 0 and a.get("cost", {}).has(t):
				v = maxf(v, CONVERSION * keys / a.cost[t] * (ONE_SHOT if a.cost.get("burn") else 1.0))
	var held: int = p.tokens[t]
	if held > HOARD: v /= 1.0 + float(held - HOARD) / HOARD
	_cache[key] = v
	return v

## Value of having tooth number x (x = 1 is your last). Players with no teeth at game end
## die and cannot win, so the last tooth is worth the game; the next few carry a safety
## margin; comfortable teeth are cheap, and cheaper still when you're ahead (ending the
## game sooner helps a leader, as long as they survive it).
func tooth_value(g: Game, p: Player, x: int) -> float:
	if x <= 0: return 0.0
	if x == 1: return last_tooth + p.keys
	var rival = g.opponents_of(p).map(func(o): return o.keys).max()
	var lead: int = p.keys - (rival if rival != null else 0)
	var ahead := 0.6 if lead > 0 and x >= 4 else 1.0
	return tooth * _blend(g, p, func(s): return s.teeth) * (1.0 + tooth_urgency / x) * ahead

## Price of losing n teeth from where I am now (includes dying if n >= teeth).
func teeth_loss(g: Game, p: Player, n: int) -> float:
	var v := 0.0
	for i in mini(n, p.teeth): v += tooth_value(g, p, p.teeth - i)
	return v

## Price of gaining n teeth (capped). At 0 teeth, the first one is coming back to life.
func teeth_gain(g: Game, p: Player, n: int) -> float:
	var cap: int = g.query(&"max_teeth", p, g.cfg.max_teeth)
	var v := 0.0
	for i in range(1, n + 1):
		if p.teeth + i <= cap: v += tooth_value(g, p, p.teeth + i)
	return v

## Average price of one tooth right now (kept for callers that want a single number).
func tooth_price(g: Game, p: Player) -> float: return tooth_value(g, p, maxi(1, p.teeth))

# --- cards ----------------------------------------------------------------------------
static func power(c: Card) -> float:
	if _power.is_empty() and FileAccess.file_exists("res://ai/data/card_power.json"):
		_power = JSON.parse_string(FileAccess.get_file_as_string("res://ai/data/card_power.json"))
	if _power.has(c.id): return _power[c.id]
	var fs: Dictionary = c.info.get("features", {})
	return CARD_POWER + maxf(base_value(fs.get("top", {})), base_value(fs.get("inv", {})))

## Strategy-free value of one face's features, in (-1, 1).
static func base_value(f: Dictionary) -> float:
	var dot := 0.0
	for k in f: dot += BASE.get(k, 0.0) * f[k]
	return tanh(dot)

## Value of having card `c` in my cadre. Marginal by default: if my cadre is full, the
## worst card I'd have to drop is subtracted.
func card_value(g: Game, p: Player, c: Card, marginal := true) -> float:
	if c == null: return 0.0
	var key := [c, marginal]
	if _cache.has(key): return _cache[key]
	var mix: Dictionary = bot.mix_for(g, p, c)
	var fs: Dictionary = c.info.get("features", {})
	var best := -INF   # the owner picks the orientation, so the better face counts
	for side in ["top", "inv"]:
		var f: Dictionary = fs.get(side, {})
		var fv := face_risk(g, p, f)
		for s in mix: fv += FIT * mix[s] * s.fit_face(f)
		best = maxf(best, fv)
	var v := power(c) + best
	if marginal and not p.cadre.has(c):
		v += CLAIM_BONUS
		v -= OVER_PREF * maxf(0.0, p.cadre.size() + 1 - cadre_pref(g, p))
		var limit: int = g.query(&"villager_limit", p, g.cfg.villager_limit) + p.extra_slots
		if p.cadre.size() >= limit:
			v -= p.cadre.map(func(x): return card_value(g, p, x, false)).min()
	_cache[key] = v
	return v

## Value of one face of a card (for orientation choices).
func face_value(g: Game, p: Player, c: Card, inverted: bool) -> float:
	var f: Dictionary = c.info.get("features", {}).get("inv" if inverted else "top", {})
	var mix: Dictionary = bot.mix_for(g, p)
	var v := base_value(f) + face_risk(g, p, f)
	for s in mix: v += FIT * mix[s] * s.fit_face(f)
	return v

## Recurring tooth drain or gain on a face (feature "teeth"), priced at what my next
## tooth is worth now: cheap at 10 teeth, ruinous on my last one (Fleabitten Penitent).
func face_risk(g: Game, p: Player, f: Dictionary) -> float:
	var t: float = f.get("teeth", 0.0)
	if t == 0.0: return 0.0
	return tooth_drain * t * (teeth_gain(g, p, 1) if t > 0 else teeth_loss(g, p, 1))

## Features of the faces currently live in my cadre, summed.
func cadre_features(p: Player) -> Dictionary:
	var out := {}
	for c in p.cadre:
		var f: Dictionary = c.info.get("features", {}).get("inv" if c.inverted else "top", {})
		for k in f: out[k] = out.get(k, 0.0) + f[k]
	return out

# --- trades -----------------------------------------------------------------------------
## Price of a cost/gain dictionary (cost vocabulary plus gain-only keys).
## `as_gain` = the dictionary is something received (teeth then price as gained, not lost).
func price(g: Game, p: Player, d: Dictionary, src: Ability = null, as_gain := false) -> float:
	var v := 0.0
	for k in d:
		var n = d[k]
		match k:
			"E", "W", "F", "A", "Q": v += n * token_price(g, p, k)
			"any": v += n * GK.ELEMENTS.map(func(t): return token_price(g, p, t)).min()
			"one_type": v += n * GK.TOKENS.filter(func(t): return p.tokens[t] >= n).map(func(t): return token_price(g, p, t)).reduce(func(a, b): return minf(a, b), 9.0)
			"keys": v += n * KEY
			"teeth": v += teeth_gain(g, p, n) if as_gain else teeth_loss(g, p, n)
			"save_teeth": v += teeth_loss(g, p, n)   # a prevented loss is worth the tooth at risk
			"burn": v += BURN_SELF * card_value(g, p, src.card, false) if src and n else 0.0
			"burn_card": v += card_value(g, p, n, false)
			"inc": v += n * p.cadre.filter(func(c): return not src or c != src.card).map(func(c): return card_value(g, p, c, false)).reduce(func(a, b): return minf(a, b), 1.0)
			"discard": v += n * DISCARD
			"control": v += n * CONTROL
			"face": v += n * FACE
			"die": v += n * DIE
			"set": v += n * SET
			"hurt": v += n * HURT
			"option": v += n * OPTION
			"info": v += n * INFO
			"claim": v += card_value(g, p, n)
			"claim_any": v += n * g.square.filter(func(c): return c != null).map(func(c): return card_value(g, p, c)).reduce(func(a, b): return maxf(a, b), 0.0)
			"claim_top": v += n * CARD_POWER
			"claim_pyre_top": v += card_value(g, p, g.pyre.back()) if g.pyre else 0.0
			"claim_best_pyre": v += g.pyre.map(func(c): return card_value(g, p, c)).reduce(func(a, b): return maxf(a, b), 0.0)
			"deny": v += DENY * (n if (n is int or n is float) else 1)
	return v

## Net value of an offer {cost = {...}, gain = {...}}.
func offer_value(g: Game, p: Player, offer: Dictionary, src: Ability = null) -> float:
	return price(g, p, offer.get("gain", {}), src, true) - price(g, p, offer.get("cost", {}), src)

func act_gain(ab: Ability, id: StringName) -> Dictionary:
	return ab.acts()[id].get("gain", ACT_GAINS.get(String(id), {option = 0.5}))

# --- dice & sets ------------------------------------------------------------------------
## Value of the request rights an arrangement grants: each right takes the best
## remaining Town Square card it may request.
func rights_value(g: Game, p: Player, rights: Array) -> float:
	var vals := {}
	for s in g.square.size():
		if g.square[s]: vals[s] = card_value(g, p, g.square[s])
	var used := {}
	var total := 0.0
	var order := rights.duplicate()
	order.sort_custom(func(a, b): return a.size() < b.size())   # specific slots first
	for r in order:
		var best := -1
		for s in r:
			if vals.has(s) and not used.has(s) and vals[s] > 0 and (best < 0 or vals[s] > vals[best]): best = s
		if best >= 0:
			used[best] = true
			total += vals[best]
	return total

## Taste for scoring a set beyond its request: strategy flavour plus what my cadre's live
## faces say about that family (Oathkeeper punishes straights, Binger rewards them, ...).
func set_flavor(g: Game, p: Player, def: Scoring.SetDef) -> float:
	var fam := Scoring.family(def.id)
	return SET_FLAVOR * (set_weight(g, p, fam) - 1.0) * def.tier + CADRE_SET * cadre_features(p).get(fam, 0.0)

func arrangement_value(g: Game, p: Player, arr: Array) -> float:
	var v := rights_value(g, p, Scoring.rights(arr, g.square.size()))
	for s in arr: v += set_flavor(g, p, s.def)
	if arr.is_empty(): v += CADRE_SET * cadre_features(p).get("nothing", 0.0)
	return v

func best_arrangement_value(g: Game, p: Player, faces: Array) -> float:
	var rules: Dictionary = g.query(&"score_rules", p, {})
	return Scoring.arrangements(faces, rules).map(func(a): return arrangement_value(g, p, a)).max()

## Value of a pool of committed faces. While dice can still be rerolled, partial sets count.
func dice_value(g: Game, p: Player, faces: Array, final: bool) -> float:
	var v := best_arrangement_value(g, p, faces)
	return v if final else v + POTENTIAL * potential(g, p, faces)

## Best partial progress toward any menu set: (fraction done)^2 * tier value * taste.
func potential(g: Game, p: Player, faces: Array) -> float:
	var ints := faces.filter(func(f): return f is int)
	var crystals := faces.filter(func(f): return f is String and f != "")
	var best := 0.0
	for d in Scoring.MENU:
		var k := 0
		match d.kind:
			&"straight": k = _longest_run(ints)
			&"of_kind": k = _max_count(ints)
			&"all_pips": k = ints.count(d.arg)
			&"of_color": k = _max_count(crystals.filter(func(x): return x != "Q") if d.arg == "" else crystals.filter(func(x): return x == d.arg)) + crystals.count("Q")
			&"all_colors": k = _distinct(crystals.filter(func(x): return x != "Q")) + crystals.count("Q")
			&"pairs": k = 2 * _pairs(crystals if d.arg else faces)
		var frac := minf(1.0, float(k) / d.size)
		best = maxf(best, frac * frac * TIER[d.tier] * set_weight(g, p, Scoring.family(d.id)))
	return best

static func _min(a: float, b: float) -> float: return minf(a, b)
static func _max(a: float, b: float) -> float: return maxf(a, b)

static func _max_count(a: Array) -> int:
	var c := {}
	var m := 0
	for x in a:
		c[x] = c.get(x, 0) + 1
		m = maxi(m, c[x])
	return m

static func _distinct(a: Array) -> int:
	var c := {}
	for x in a: c[x] = true
	return c.size()

static func _pairs(a: Array) -> int:
	var c := {}
	for x in a: c[x] = c.get(x, 0) + 1
	return c.values().filter(func(n): return n >= 2).size()

static func _longest_run(ints: Array) -> int:
	var s := {}
	for x in ints: s[x] = true
	var best := 0
	for x in s:
		if s.has(x - 1): continue
		var n := 1
		while s.has(x + n): n += 1
		best = maxi(best, n)
	return best
