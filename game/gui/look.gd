class_name Look
## Shared art for the 3D table: meshes, materials, colours and text helpers.
## Units are centimetres (project gravity is 981).

const CARD := 8.0            # square card edge
const CARD_T := 0.06         # card thickness
const DIE_APOTHEM := 0.848   # half the width across flats: a die lying on a side has its centre this high
const COLORS := {
	"E": Color(0.33, 0.62, 0.26), "W": Color(0.25, 0.48, 0.82), "F": Color(0.82, 0.27, 0.2),
	"A": Color(0.9, 0.72, 0.25), "Q": Color(0.7, 0.5, 0.92),
}
const NAMES := {"E": "Earth", "W": "Water", "F": "Fire", "A": "Air", "Q": "Quintessence"}
const SET_COLORS := [Color(1.0, 0.55, 0.15), Color(0.3, 0.85, 1.0), Color(0.75, 1.0, 0.3), Color(1.0, 0.35, 0.75), Color(0.65, 0.55, 1.0), Color(1.0, 0.95, 0.4)]
const GLOW_PICK := Color(1.0, 0.78, 0.3)
const GLOW_SOURCE := Color(0.45, 0.7, 1.0)
const GLOW_ALERT := Color(1.0, 0.3, 0.25)

static var _meshes := {}
static var _mats := {}
static var _tex := {}
static var _shapes := {}

static func mesh(name: String) -> Mesh:
	if not _meshes.has(name):
		var path := "res://assets/models/%s.obj" % name
		_meshes[name] = load(path) if ResourceLoader.exists(path) else null
	return _meshes[name]

## Mesh for a die face value (int pips, crystal letter, "" blank); null when no insert exists.
static func face_mesh(v) -> Mesh:
	if v is int: return mesh("face_%d" % v) if v >= 1 and v <= 9 else mesh("face_blank")
	if v == "": return mesh("face_blank")
	return mesh("face_%s" % v)

static func face_color(v) -> Color:
	if v is int: return Color(0.93, 0.89, 0.8)
	if v == "": return Color(0.35, 0.33, 0.32)
	return COLORS.get(v, Color.WHITE)

static func face_text(v) -> String:
	if v is int: return str(v)
	if v == "": return "blank"
	return NAMES.get(v, str(v))

static func mat(key: String) -> Material:
	if _mats.has(key): return _mats[key]
	var m := StandardMaterial3D.new()
	match key:
		"glass_potency", "glass_elemental":
			m.albedo_color = Color(0.95, 0.75, 0.45, 0.28) if key == "glass_potency" else Color(0.6, 0.85, 0.8, 0.28)
			m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			m.roughness = 0.05
			m.metallic_specular = 0.9
			m.rim_enabled = true
			m.rim = 0.6
		"cork":
			m.albedo_color = Color(0.55, 0.38, 0.22)
			m.roughness = 0.9
		"card_edge":
			m.albedo_color = Color(0.86, 0.82, 0.72)
			m.roughness = 0.8
		"card_back":
			m.albedo_texture = card_back()
			m.roughness = 0.7
		"tooth":
			m.albedo_color = Color(0.95, 0.92, 0.8)
			m.roughness = 0.35
			m.clearcoat_enabled = true
		"brass":
			m.albedo_color = Color(0.8, 0.62, 0.28)
			m.metallic = 0.85
			m.roughness = 0.35
		"tray":
			m.albedo_color = Color(0.2, 0.12, 0.08)
			m.roughness = 0.6
		"felt":
			m.albedo_color = Color(0.12, 0.2, 0.15)
			m.roughness = 1.0
		"mat":
			m.albedo_color = Color(0.82, 0.76, 0.62)
			m.albedo_texture = _noise_tex(0.02, Color(0.78, 0.71, 0.56), Color(0.9, 0.85, 0.72))
			m.roughness = 0.95
		"wood":
			m.albedo_texture = _wood_tex()
			m.roughness = 0.55
			m.uv1_scale = Vector3(1, 1, 1)
		"slot":
			m.albedo_color = Color(0.35, 0.28, 0.2, 0.35)
			m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_:
			if key.begins_with("face_"):
				var v = key.substr(5)
				var c := face_color(int(v) if v.is_valid_int() else ("" if v == "blank" else v))
				m.albedo_color = c
				m.roughness = 0.3
				m.emission_enabled = true
				m.emission = c * 0.25
			elif key.begins_with("token_"):
				var c: Color = COLORS[key.substr(6)]
				m.albedo_color = c
				m.metallic = 0.4
				m.roughness = 0.35
	_mats[key] = m
	return m

static func face_mat(v) -> Material:
	return mat("face_%s" % ("blank" if (v is String and v == "") else str(v)))

static func card_tex(id: String) -> Texture2D:
	if not _tex.has(id):
		var path := "res://assets/cards/%s.png" % id
		_tex[id] = load(path) if ResourceLoader.exists(path) else null
	return _tex[id]

static func card_face_mat(id: String) -> Material:
	var key := "card:" + id
	if not _mats.has(key):
		var m := StandardMaterial3D.new()
		m.albedo_texture = card_tex(id)
		m.roughness = 0.75
		m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
		_mats[key] = m
	return _mats[key]

## Convex collision shape for a mesh, cached.
static func convex(name: String) -> Shape3D:
	if not _shapes.has(name):
		var pts := PackedVector3Array()
		for n in (["vial_body", "vial_cork"] if name == "die" else [name]):
			var m := mesh(n)
			if m: pts.append_array(m.get_faces())
		var hull := ConvexPolygonShape3D.new()
		hull.points = _hull_sample(pts)
		_shapes[name] = hull
	return _shapes[name]

## Keep the extreme points in many directions: plenty for a hull, far fewer than the mesh.
static func _hull_sample(pts: PackedVector3Array) -> PackedVector3Array:
	var out := {}
	var dirs := []
	for i in 160:   # Fibonacci sphere
		var y := 1.0 - 2.0 * (i + 0.5) / 160.0
		var r := sqrt(1.0 - y * y)
		var a := i * 2.399963
		dirs.append(Vector3(cos(a) * r, y, sin(a) * r))
	for d in dirs:
		var best := 0
		var bv := -INF
		for j in pts.size():
			var v: float = pts[j].dot(d)
			if v > bv:
				bv = v
				best = j
		out[pts[best]] = true
	return PackedVector3Array(out.keys())

static func glow_shader() -> Shader:
		if not _mats.has("_glow_shader"):
			var s := Shader.new()
			s.code = """
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, shadows_disabled;
instance uniform vec4 glow_color : source_color = vec4(1.0, 0.8, 0.3, 1.0);
instance uniform float glow_round = 0.0;
instance uniform float glow_pulse = 1.0;
void fragment() {
	vec2 d = abs(UV - 0.5) * 2.0;
	float e = mix(max(d.x, d.y), length(d), glow_round);
	float band = smoothstep(0.55, 0.8, e) * (1.0 - smoothstep(0.85, 1.0, e));
	float p = mix(1.0, 0.65 + 0.35 * sin(TIME * 5.0), glow_pulse);
	ALBEDO = glow_color.rgb * band * p * 1.6;
	ALPHA = band * p * glow_color.a;
}
"""
			_mats["_glow_shader"] = s
		return _mats["_glow_shader"]

## A flat glow quad (lies on XZ). round = disc instead of rectangle.
static func glow_quad(size: Vector2, round := false) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = size
	mi.mesh = pm
	var sm := ShaderMaterial.new()
	sm.shader = glow_shader()
	mi.material_override = sm
	mi.set_instance_shader_parameter("glow_round", 1.0 if round else 0.0)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.visible = false
	return mi

static func set_glow(mi: MeshInstance3D, c, pulse := true) -> void:
	if c == null:
		mi.visible = false
		return
	mi.visible = true
	mi.set_instance_shader_parameter("glow_color", c)
	mi.set_instance_shader_parameter("glow_pulse", 1.0 if pulse else 0.0)

static func label(text: String, size := 48, px := 0.02, color := Color(0.15, 0.1, 0.06)) -> Label3D:
	var l := Label3D.new()
	l.text = text
	l.font_size = size
	l.pixel_size = px
	l.modulate = color
	l.outline_size = 0
	l.double_sided = false
	l.shaded = false
	return l

## A label lying flat on the table, readable from the +Z side of its parent.
static func flat_label(text: String, size := 48, px := 0.02, color := Color(0.15, 0.1, 0.06)) -> Label3D:
	var l := label(text, size, px, color)
	l.rotation_degrees.x = -90
	return l

# --- procedural textures -----------------------------------------------------------
static func card_back() -> Texture2D:
	if _tex.has("_back"): return _tex["_back"]
	var n := 256
	var img := Image.create(n, n, false, Image.FORMAT_RGB8)
	var bg := Color(0.18, 0.06, 0.08)
	var gold := Color(0.78, 0.6, 0.3)
	for y in n:
		for x in n:
			var u := (x + 0.5) / n * 2.0 - 1.0
			var v := (y + 0.5) / n * 2.0 - 1.0
			var r := sqrt(u * u + v * v)
			var c := bg.lerp(Color(0.1, 0.03, 0.05), clampf(r * 0.7, 0, 1))
			var edge := maxf(absf(u), absf(v))
			if edge > 0.9 and edge < 0.94: c = gold
			if absf(r - 0.55) < 0.02 or absf(r - 0.42) < 0.012: c = gold
			# a hexagon (the vial) in the middle
			var a := atan2(v, u)
			var hex := r * cos(fmod(absf(a) + PI / 6.0, PI / 3.0) - PI / 6.0)
			if absf(hex - 0.28) < 0.015: c = gold
			img.set_pixel(x, y, c)
	img.generate_mipmaps()
	var t := ImageTexture.create_from_image(img)
	_tex["_back"] = t
	return t

static func _noise_tex(freq: float, a: Color, b: Color) -> Texture2D:
	var nt := NoiseTexture2D.new()
	var fn := FastNoiseLite.new()
	fn.frequency = freq
	nt.noise = fn
	nt.width = 512
	nt.height = 512
	nt.seamless = true
	var g := Gradient.new()
	g.set_color(0, a)
	g.set_color(1, b)
	nt.color_ramp = g
	nt.generate_mipmaps = true
	return nt

static func _wood_tex() -> Texture2D:
	var nt := NoiseTexture2D.new()
	var fn := FastNoiseLite.new()
	fn.noise_type = FastNoiseLite.TYPE_PERLIN
	fn.frequency = 0.004
	fn.fractal_octaves = 3
	fn.domain_warp_enabled = true
	fn.domain_warp_amplitude = 40.0
	nt.noise = fn
	nt.width = 1024
	nt.height = 1024
	nt.seamless = true
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.45, 0.55, 1.0])
	g.colors = PackedColorArray([Color(0.16, 0.08, 0.04), Color(0.3, 0.16, 0.08), Color(0.24, 0.12, 0.06), Color(0.36, 0.2, 0.1)])
	nt.color_ramp = g
	nt.generate_mipmaps = true
	return nt
