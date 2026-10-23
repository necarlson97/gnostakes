class_name Player extends RefCounted

var idx: int
var name: String
var teeth: int
var keys := 0
var tokens := {"E": 0, "W": 0, "F": 0, "A": 0, "Q": 0}
var dice: Array[Die] = []          # permanent dice
var swig_dice: Array[Die] = []     # permanent + bonus dice in play this Swig
var cadre: Array[Card] = []        # left-to-right order matters (Failed Exorcist)
var extra_slots := 0
var spare_faces := []              # faces gained but not yet swapped onto a die
var scored: Array = []             # this Scry's arrangement: [{def: SetDef, dice: Array[Die]}]
var stats := {}                    # per-round counters, cleared each round

func _init(idx_: int, name_: String, teeth_: int) -> void:
	idx = idx_
	name = name_
	teeth = teeth_

func ready_dice() -> Array: return swig_dice.filter(func(d): return d.ready())
func committed() -> Array: return swig_dice.filter(func(d): return d.committed())
func discarded() -> Array: return swig_dice.filter(func(d): return d.discarded())
func scoring_dice() -> Array:
	var out := []
	for s in scored: out.append_array(s.dice)
	return out
func token_total() -> int:
	var n := 0
	for t in tokens: n += tokens[t]
	return n
func bump(stat: StringName, n := 1) -> void: stats[stat] = stats.get(stat, 0) + n
func stat(s: StringName) -> int: return stats.get(s, 0)

func _to_string() -> String: return name
