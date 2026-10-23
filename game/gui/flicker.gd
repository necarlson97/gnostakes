extends OmniLight3D
## Candle flame flicker.

var _base := 0.0
var _t := 0.0

func _ready() -> void:
	_base = light_energy
	_t = randf() * 10.0

func _process(dt: float) -> void:
	_t += dt
	light_energy = _base * (0.88 + 0.08 * sin(_t * 11.0) + 0.05 * sin(_t * 23.0 + 1.3) + 0.03 * randf())
