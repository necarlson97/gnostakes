class_name PacedController extends Controller
## Wraps a bot so its moves are watchable: it decides at once, then waits a beat before
## answering when the answer actually does something (passes and "no" are instant).

static var speed := 1.0   # fast-forward divides every pause

var inner: Controller
var delay := 0.55
var tree: SceneTree

func _init(bot: Controller, tree_: SceneTree, delay_ := 0.55) -> void:
	inner = bot
	tree = tree_
	delay = delay_

func decide(g: Game, c: Choice):
	var a = await inner.decide(g, c)
	if _matters(c, a): await tree.create_timer(delay * (1.6 if c.tag == &"assign" else 1.0) / speed).timeout
	return a

static func _matters(c: Choice, a) -> bool:
	if a == null or (a is bool and a == false): return false
	if a is Dictionary and a.is_empty(): return false
	if a is Array and a.is_empty() and c.tag != &"orient": return false
	return c.tag != &"orient"

func _to_string() -> String: return str(inner)
