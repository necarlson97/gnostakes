class_name Strategy extends RefCounted
## What a bot *wants*, as data. One JSON file per strategy in res://ai/strategies/:
##   features   weights on card features (tools/card_features.py) -> how well a card fits
##   sets       multipliers on set families (straight / kind / pairs / color) when arranging
##   tokens     multipliers on baseline token prices
##   teeth      tooth-fear multiplier
##   cadre      preferred cadre size (open_slots strategies want fewer cards)
##   viability  prior weight when an AdaptiveBot blends strategies (learned from sims later)
## Strategies never contain behaviour; the shared tactics in Bot read these numbers.

const DIR := "res://ai/strategies"
const VIABILITY := "res://ai/data/viability.json"
const FIT_SCALE := 0.5   # squashes dot products into (-1, 1) with tanh

var name := ""
var doc := ""
var viability := 1.0
var features := {}
var sets := {}
var tokens := {}
var teeth := 1.0
var cadre := 4

static var _all: Array = []

static func from_dict(d: Dictionary) -> Strategy:
	var s := Strategy.new()
	for k in ["name", "doc", "viability", "features", "sets", "tokens", "teeth", "cadre"]:
		if d.has(k): s.set(k, d[k])
	s.cadre = int(s.cadre)
	return s

func to_dict() -> Dictionary:
	return {name = name, doc = doc, viability = viability, features = features, sets = sets, tokens = tokens, teeth = teeth, cadre = cadre}

static func named(n: String) -> Strategy:
	for s in all():
		if s.name == n: return s
	push_error("no strategy " + n)
	return null

static func all() -> Array:
	if _all.is_empty():
		for f in DirAccess.get_files_at(DIR):
			if f.ends_with(".json"):
				_all.append(from_dict(JSON.parse_string(FileAccess.get_file_as_string(DIR.path_join(f)))))
		_all.sort_custom(func(a, b): return a.name < b.name)
		# learned viabilities (tools/league.py --learn) override the JSON prior
		if FileAccess.file_exists(VIABILITY):
			var v: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(VIABILITY))
			for st in _all: st.viability = v.get(st.name, st.viability)
	return _all

## Fit of one card face (its feature dict) to this strategy, in (-1, 1).
func fit_face(f: Dictionary) -> float:
	var dot := 0.0
	for k in f:
		dot += features.get(k, 0.0) * f[k]
	return tanh(dot * FIT_SCALE)

## A card fits as well as its better face (its owner picks the orientation).
func fit_card(c: Card) -> float:
	var fs: Dictionary = c.info.get("features", {})
	return maxf(fit_face(fs.get("top", {})), fit_face(fs.get("inv", {})))

func set_weight(family: String) -> float: return sets.get(family, 1.0)
func token_weight(t: String) -> float: return tokens.get(t, 1.0)

## A jittered copy, for weight tuning.
func mutated(rng: RandomNumberGenerator, sigma := 0.15) -> Strategy:
	var s := Strategy.from_dict(to_dict().duplicate(true))
	for table in [s.features, s.sets, s.tokens]:
		for k in table: table[k] = table[k] + rng.randfn(0.0, sigma)
	s.teeth = maxf(0.1, s.teeth + rng.randfn(0.0, sigma))
	return s

func _to_string() -> String: return name
