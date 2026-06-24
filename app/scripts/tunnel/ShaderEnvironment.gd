extends ColorRect

var _material: ShaderMaterial

func _ready():
	_material = ShaderMaterial.new()
	_material.shader = load("res://assets/shaders/tunnel_core.gdshader")
	self.material = _material

func apply_theme(theme_data: Dictionary, universe_id: String = "science_lab"):
	var tunnel = theme_data.get("tunnel", {})
	var palette = theme_data.get("palette", {"primary": Color(1,1,1), "bg": Color(0,0,0)})
	var flow_str = tunnel.get("flow_type", "linear")
	
	var flow_int = 0
	if flow_str == "vortex": flow_int = 1
	elif flow_str == "branching": flow_int = 2
	elif flow_str == "wave": flow_int = 3

	_material.set_shader_parameter("color_primary", palette["bg"])
	_material.set_shader_parameter("color_secondary", palette["primary"].darkened(0.5))
	_material.set_shader_parameter("color_tertiary", palette["primary"])

	_material.set_shader_parameter("flow_speed", tunnel.get("speed_multiplier", 1.0))
	_material.set_shader_parameter("density", tunnel.get("density", 0.6))
	_material.set_shader_parameter("flow_type", flow_int)
	
	var asset_registry = AssetManifestRegistry.new()
	var manifest = asset_registry.get_manifest(universe_id)
	var noise_tex = load(manifest["bg_noise"])
	if noise_tex:
		_material.set_shader_parameter("noise_tex", noise_tex)
		
	print("[TIER 1 - SHADER] Field environment synchronized with universe: ", universe_id)
