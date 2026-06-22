extends ColorRect

var _material: ShaderMaterial

func _ready():
	_material = ShaderMaterial.new()
	_material.shader = load("res://assets/shaders/tunnel_core.gdshader")
	
	# Fix for empty shader: Inject pre-computed noise texture natively
	var noise_tex = load("res://assets/textures/optimized_noise.tres")
	_material.set_shader_parameter("noise_tex", noise_tex)
	
	self.material = _material

func apply_theme(theme_data: Dictionary):
	var tunnel = theme_data.get("tunnel", {})
	var palette = tunnel.get("tunnel_palette", ["#000000", "#000000", "#000000"])
	var flow_str = tunnel.get("flow_type", "linear")
	
	# Map schema strings to shader integers
	var flow_int = 0
	if flow_str == "vortex": flow_int = 1
	elif flow_str == "branching": flow_int = 2
	elif flow_str == "wave": flow_int = 3

	_material.set_shader_parameter("color_primary", Color(palette[0]))
	_material.set_shader_parameter("color_secondary", Color(palette[1]))
	
	if palette.size() > 2:
		_material.set_shader_parameter("color_tertiary", Color(palette[2]))

	_material.set_shader_parameter("flow_speed", tunnel.get("speed_multiplier", 1.0))
	_material.set_shader_parameter("density", tunnel.get("density", 0.6))
	_material.set_shader_parameter("flow_type", flow_int)
	
	print("[TIER 1 - SHADER] Field environment synchronized with theme.")
