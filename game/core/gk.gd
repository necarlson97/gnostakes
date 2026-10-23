class_name GK
## Shared constants. Faces are plain Variants: int = Potency, String = crystal
## ("E","W","F","A", or "Q" which counts as any crystal), "" = empty face.

const ELEMENTS := ["E", "W", "F", "A"]
const TOKENS := ["E", "W", "F", "A", "Q"]   # Q (quintessence) can be spent as any token
const POTENCY_FACES := [1, 2, 3, 4, 5, 6]
const ELEMENTAL_FACES := ["E", "E", "W", "W", "F", "A"]

enum Phase { SETUP, SWIG, SCRY, SCHEME, OVER }
enum Zone { READY, COMMITTED, DISCARDED }
enum Kind { POTENCY, ELEMENTAL, EMPTY }
enum Loc { DECK, SQUARE, CADRE, ATTACHED, PYRE, GONE }

## Tunables. Anything a card can change goes through Game.query() on top of these.
const DEFAULTS := {
	"players": 2,
	"start_teeth": 10,
	"max_teeth": 10,
	"win_keys": 10,
	"villager_limit": 4,
	"commit_min": 5,
	"potency_dice": 5,
	"elemental_dice": 5,
	"square_slots": 4,
	"token_request_cost": 3,   # "Requested with Three Straight or 3W", etc.
	"slot_tokens": ["W", "E", "F", "A"],
	"max_wager_rounds": 3,
	"max_rounds": 200,         # safety valve for simulations
}
