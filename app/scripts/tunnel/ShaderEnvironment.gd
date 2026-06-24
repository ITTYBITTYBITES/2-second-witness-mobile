extends ColorRect

var _material: ShaderMaterial
var active_universe_id: String = ""

func _ready():
	_material = ShaderMaterial.new()
	_material.shader = load("res://assets/shaders/tunnel_core.gdshader")
	self.material = _material
	
	NavigationEngine.transition_sequence_started.connect(_on_spike_started)
	
	# We also need a way to know when the spike ends to reverse the effect
	var router = get_node_or_null("/root/NavigationRouter")
	if router:
		# Since router dynamically creates scenes, we'll hook into a custom signal later if needed,
		# but for now we can listen to the health monitor context change
		pass

func apply_theme(theme_data: Dictionary, universe_id: String = "science_lab"):
	active_universe_id = universe_id
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

func _on_spike_started():
	# The Psychedelic Shift
	# When a scenario starts, the tunnel environment becomes part of the psychological pressure.
	print("[TIER 1 - SHADER] Spike Initiated. Morphing tunnel into hostile test environment.")
	
	var tween = get_tree().create_tween().set_parallel(true)
	
	var renderer = UniverseRenderer.new()
	var def = renderer.universe_definitions.get(active_universe_id, renderer.universe_definitions["science_lab"])
	
	# The tunnel walls morph aggressively to the primary accent color
	tween.tween_property(_material, "shader_parameter/color_primary", def["palette"]["primary"].darkened(0.8), 0.5)
	
	# The density of the fog drops to reveal the harsh geometry
	tween.tween_property(_material, "shader_parameter/density", 0.1, 0.5)
	
	# The flow warps to increase cognitive load
	_material.set_shader_parameter("flow_type", 1) # Vortex
