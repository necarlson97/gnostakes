class_name Die extends RefCounted
## One physical die. Faces are mutable (Scheme face swaps); `up` is the face showing.

var id: int
var kind: GK.Kind
var faces: Array
var up := 0
var zone := GK.Zone.READY
var owner: Player
var locked_empty := false   # Alembic Servitor: faces can never be filled

func _init(kind_: GK.Kind, faces_: Array, id_ := -1) -> void:
	kind = kind_
	faces = faces_.duplicate()
	id = id_

static func potency(id_ := -1) -> Die: return Die.new(GK.Kind.POTENCY, GK.POTENCY_FACES, id_)
static func elemental(id_ := -1) -> Die: return Die.new(GK.Kind.ELEMENTAL, GK.ELEMENTAL_FACES, id_)
static func uniform(face, n := 6) -> Die:
	var k := GK.Kind.POTENCY if face is int else (GK.Kind.EMPTY if face == "" else GK.Kind.ELEMENTAL)
	var f := []
	f.resize(n)
	f.fill(face)
	return Die.new(k, f)

## A die whose faces are now all numbers is a Potency die; all crystals, an Elemental die.
func refresh_kind() -> void:
	if faces.all(func(f): return f is int): kind = GK.Kind.POTENCY
	elif faces.all(func(f): return f is String and f != ""): kind = GK.Kind.ELEMENTAL

## Index of the first face showing v, or -1.
func index_of(v) -> int:
	for i in faces.size():
		if typeof(faces[i]) == typeof(v) and faces[i] == v: return i
	return -1

func face(): return faces[up]
func pips() -> int: return faces[up] if faces[up] is int else 0
func crystal() -> String: return faces[up] if faces[up] is String else ""
func shows(f) -> bool: return typeof(f) == typeof(faces[up]) and faces[up] == f
func ready() -> bool: return zone == GK.Zone.READY
func committed() -> bool: return zone == GK.Zone.COMMITTED
func discarded() -> bool: return zone == GK.Zone.DISCARDED

func _to_string() -> String:
	var f = face()
	return "[%s]" % ("_" if f is String and f == "" else str(f))
