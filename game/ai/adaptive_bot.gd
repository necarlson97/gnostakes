class_name AdaptiveBot extends Bot
## Starts balanced and drifts toward whichever strategies its cadre supports.
##
## Weight of strategy s = softmax over  log(viability_s) + commitment * sum fit_s(card),
## summed over the cards in my cadre. Commitment grows as on-strategy cards arrive.
## Pivoting comes for free: a Town Square card is valued with the mix I *would* have
## after taking it (mix_for(card)), so a card that shifts my cadre toward a stronger
## strategy is valued under that strategy.

var pool: Array          # candidate strategies
var commitment := 2.0    # how fast fit turns into commitment
var temperature := 1.0   # softmax temperature (higher = stays blended longer)

func _init(strategies: Array = [], seed_ := 0) -> void:
	pool = strategies if strategies else Strategy.all()
	super(pool, seed_)
	label = "adaptive"

func observe(_g: Game, p: Player) -> void: mix = weights(p.cadre)

func mix_for(_g: Game, p: Player, card: Card = null) -> Dictionary:
	if card == null or p.cadre.has(card): return mix
	return weights(p.cadre + [card])

func weights(cards: Array) -> Dictionary:
	var score := {}
	var top := -INF
	for s in pool:
		var fit := 0.0
		for c in cards: fit += s.fit_card(c)
		score[s] = (log(maxf(s.viability, 1e-6)) + commitment * fit) / temperature
		top = maxf(top, score[s])
	var total := 0.0
	for s in score:
		score[s] = exp(score[s] - top)
		total += score[s]
	for s in score: score[s] /= total
	return score
