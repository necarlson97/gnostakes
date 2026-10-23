class_name Bot extends RandomBot
## Base strategy bot: shared tactics driven by a strategy mix and a Valuer.
##
## Routing: decide() sends each Choice to `choose_<tag>()` if this class (or a subclass)
## defines it; otherwise RandomBot's legal random answer is used. So a new Choice tag in
## the engine never breaks a bot, and a smarter tactic is one method.
##
## Extension points for subclasses:
##   observe(g, p)            called before every decision (AdaptiveBot re-weights here)
##   mix_for(g, p, card)      strategy weights used to value `card` (null = right now)
##   choose_<tag>(g, c)       replace or add one tactic
## A fixed-strategy bot is just Bot.new([Strategy.named("straights")]).

const EPS := 0.01
const SOLVER_MAX_DICE := 11   # above this many ready dice, fall back to the greedy commit

var label := ""
var mix := {}          # Strategy -> weight, sums to 1
var valuer: Valuer
var _next_face := -1   # rotate_die picks the die and face together; rotate_face replays it

func _init(strategies: Array = [], seed_ := 0) -> void:
	super(seed_)
	var ss: Array = strategies if strategies else [Strategy.named("balanced")]
	for s in ss: mix[s] = 1.0 / ss.size()
	label = "+".join(ss.map(func(s): return s.name))
	valuer = Valuer.new(self)

func observe(_g: Game, _p: Player) -> void: pass
func mix_for(_g: Game, _p: Player, _card: Card = null) -> Dictionary: return mix

func decide(g: Game, c: Choice):
	valuer.begin()
	observe(g, c.player)
	var m := "choose_" + String(c.tag)
	if has_method(m): return call(m, g, c)
	return super.decide(g, c)

## The strategy with the most weight right now (for reports).
func main_strategy() -> Strategy:
	var best: Strategy = null
	for s in mix:
		if best == null or mix[s] > mix[best]: best = s
	return best

# =============================================================================
# Swig: dice
# =============================================================================
## Commit/discard with the expectimax DiceSolver; the final roll's value is my Valuer's
## arrangement value (request rights x Town Square cards, set taste, cadre synergies).
func choose_assign(g: Game, c: Choice) -> Dictionary:
	if c.options.size() > SOLVER_MAX_DICE: return greedy_assign(g, c)
	var p := c.player
	return DiceSolver.new(g, p, func(arr): return valuer.arrangement_value(g, p, arr)).decide(c.options, c.lo)

## Greedy fallback: commit a die if it adds dice_value (full sets, or partial progress
## while rerolls remain), discard it if committing would hurt, else leave it to reroll.
func greedy_assign(g: Game, c: Choice) -> Dictionary:
	var p := c.player
	var pool: Array = c.options.duplicate()
	var need: int = c.lo
	var final := pool.size() <= need
	var keep := p.committed().map(func(d): return d.face())
	var out := {commit = [], discard = []}
	var cur := valuer.dice_value(g, p, keep, final)
	while pool:
		var best: Die = null
		var gain := -INF
		for d in pool:
			var v := valuer.dice_value(g, p, keep + [d.face()], final) - cur
			if v > gain:
				gain = v
				best = d
		var must: bool = out.commit.size() + out.discard.size() < need
		if gain > EPS or (must and gain >= -EPS):
			out.commit.append(best)
			keep.append(best.face())
			cur += gain
		elif must:
			out.discard.append(best)   # forced to resolve a die, and committing it would hurt
		else:
			break
		pool.erase(best)
	return out

## Rotations: choose the die and face together, by the best resulting dice value.
func choose_rotate_die(g: Game, c: Choice):
	var p := c.player
	var live := p.swig_dice.filter(func(d): return not d.discarded())
	var best = c.options[0]
	var best_v := -INF
	_next_face = -1
	for d in c.options:
		var others := live.filter(func(x): return x != d).map(func(x): return x.face())
		for i in d.faces.size():
			var v := valuer.dice_value(g, p, others + [d.faces[i]], false)
			if v > best_v:
				best_v = v
				best = d
				_next_face = i
	return best

func choose_rotate_face(_g: Game, c: Choice):
	return _next_face if c.options.has(_next_face) else c.options[rng.randi_range(0, c.options.size() - 1)]

# =============================================================================
# Scry: sets, requests, wagers
# =============================================================================
func choose_arrangement(g: Game, c: Choice):
	return _argmax(c.options, func(a): return valuer.arrangement_value(g, c.player, a))

func choose_request(g: Game, c: Choice):
	var p := c.player
	var best = null
	var best_v := EPS
	for o in c.options:
		if o == null: continue
		var v := valuer.card_value(g, p, o.card) - valuer.price(g, p, o.tokens)
		if v > best_v:
			best_v = v
			best = o
	return best

## Bid cheapest tokens first, up to ~80% of what the card is worth to me (with noise,
## so a sealed bid isn't perfectly predictable).
func choose_wager(g: Game, c: Choice) -> Dictionary:
	var p := c.player
	var have: Dictionary = c.options[0]
	var budget := valuer.card_value(g, p, c.data.get("card")) * (0.8 + rng.randf_range(-0.2, 0.2))
	var types := have.keys().filter(func(t): return have[t] > 0)
	types.sort_custom(func(a, b): return valuer.token_price(g, p, a) < valuer.token_price(g, p, b))
	var bid := {}
	for t in types:
		var price := valuer.token_price(g, p, t)
		var n := mini(have[t], int(budget / price)) if price > 0 else 0
		if n > 0:
			bid[t] = n
			budget -= n * price
	return bid

# =============================================================================
# Scheme & cards
# =============================================================================
func choose_orient(g: Game, c: Choice) -> Array:
	var p := c.player
	return c.options.filter(func(card): return valuer.face_value(g, p, card, true) > valuer.face_value(g, p, card, false) + EPS)

func choose_trim(g: Game, c: Choice): return _worst_card(g, c)
func choose_cost_inc(g: Game, c: Choice): return _worst_card(g, c)

## Card targets: the most valuable option (claim / resurrect / bury / attach).
func choose_target(g: Game, c: Choice):
	if not c.options.all(func(o): return o is Card): return super.decide(g, c)
	return _argmax(c.options, func(card): return valuer.card_value(g, c.player, card))

# =============================================================================
# Abilities and optional effects
# =============================================================================
## Activated abilities: take the best positive trade (declared gain vs declared cost).
func choose_act(g: Game, c: Choice):
	var p := c.player
	var best = null
	var best_v := EPS
	for o in c.options:
		if o == null: continue
		var a: Dictionary = o.ability.acts()[o.id]
		var v := valuer.price(g, p, valuer.act_gain(o.ability, o.id), o.ability, true) - valuer.price(g, p, a.get("cost", {}), o.ability)
		if v > best_v:
			best_v = v
			best = o
	return best

## "You may ..." prompts carry an offer {cost, gain}; take it if it's worth it.
func choose_may(g: Game, c: Choice) -> bool:
	if c.data.is_empty(): return rng.randf() < 0.5
	return valuer.offer_value(g, c.player, c.data, c.source) > EPS

## "X or Y" choices (Ability.either): each option carries an offer; take the best, or
## decline (null) when optional and nothing is worth it.
func choose_either(g: Game, c: Choice):
	var offers: Array = c.data.get("offers", [])
	if offers.size() != c.options.size(): return super.decide(g, c)
	var best = c.options[0]
	var best_v := -INF
	for i in c.options.size():
		var v := 0.0 if c.options[i] == null else valuer.offer_value(g, c.player, offers[i], c.source)
		if v > best_v:
			best_v = v
			best = c.options[i]
	return best

## Alternative payments (Strawman, Anesthetist): the cheapest one.
func choose_cost(g: Game, c: Choice):
	return _argmax(c.options, func(o): return -INF if o == null else -valuer.price(g, c.player, o, c.source))

# --- helpers ------------------------------------------------------------------
func _worst_card(g: Game, c: Choice):
	return _argmax(c.options, func(card): return -valuer.card_value(g, c.player, card, false))

func _argmax(options: Array, f: Callable):
	var best = options[0]
	var best_v := -INF
	for o in options:
		var v: float = f.call(o)
		if v > best_v:
			best_v = v
			best = o
	return best

func _to_string() -> String: return label
