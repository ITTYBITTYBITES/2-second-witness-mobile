extends ColorRect

var _material: ShaderMaterial
var active_universe_id: String = ""

# The 4 Tiers of Tunnel Intensity
enum TunnelIntensity { AMBIENT, FOCUS, CHALLENGE, PEAK }

func _ready():
	_material = ShaderMaterial.new()
	_material.shader = load("res://assets/shaders/tunnel_core.gdshader")
	self.material = _material
	
	NavigationEngine.transition_sequence_started.connect(_on_spike_started)
	
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
	# Determine the intensity of the incoming cognitive spike
	# In production, this reads the 'difficulty' or 'stakes' from the ContentRegistry payload.
	var spike_intensity = TunnelIntensity.FOCUS # Defaulting to Level 1
	
	# Simulate a rare Level 3 Peak state roughly 5% of the time
	if randf() > 0.95:
		spike_intensity = TunnelIntensity.PEAK
	elif randf() > 0.70:
		spike_intensity = TunnelIntensity.CHALLENGE
	
	_apply_intensity_shift(spike_intensity)

func _apply_intensity_shift(intensity: int):
	var tween = get_tree().create_tween().set_parallel(true)
	var renderer = UniverseRenderer.new()
	var def = renderer.universe_definitions.get(active_universe_id, renderer.universe_definitions["science_lab"])
	var base_density = 0.6
	
	match intensity:
		TunnelIntensity.FOCUS:
			# Level 1: Narrows slightly, 10% color shift. Player feels "Something is happening."
			tween.tween_property(_material, "shader_parameter/color_primary", def["palette"]["bg"].lightened(0.1), 0.5)
			tween.tween_property(_material, "shader_parameter/density", base_density * 1.1, 0.5)
			
		TunnelIntensity.CHALLENGE:
			# Level 2: Fog changes, rotation begins. The environment is actively participating.
			tween.tween_property(_material, "shader_parameter/color_primary", def["palette"]["primary"].darkened(0.6), 0.5)
			tween.tween_property(_material, "shader_parameter/density", base_density * 1.5, 0.5)
			_material.set_shader_parameter("flow_type", 3) # Wave
			
		TunnelIntensity.PEAK:
			# Level 3: Rare. Vortex effects, major color inversion. Absolute reality distortion.
			print("[TIER 1 - SHADER] PEAK INTENSITY REACHED. Distorting reality.")
			tween.tween_property(_material, "shader_parameter/color_primary", def["palette"]["primary"], 0.5)
			tween.tween_property(_material, "shader_parameter/density", 0.1, 0.5)
			_material.set_shader_parameter("flow_type", 1) # Vortex
