extends ColorRect

var _material: ShaderMaterial
var active_universe_id: String = ""

# The 4 Tiers of Tunnel Intensity
enum TunnelIntensity { AMBIENT, FOCUS, CHALLENGE, PEAK }

func _to_color(value: Variant, fallback: Color) -> Color:
	if value is Color:
		return value
	if typeof(value) == TYPE_STRING:
		var text = str(value).strip_edges()
		if text != "":
			return Color(text)
	return fallback

func _ready():
	_material = ShaderMaterial.new()
	_material.shader = load("res://assets/shaders/tunnel_core.gdshader")
	self.material = _material
	
	NavigationEngine.transition_sequence_started.connect(_on_spike_started)
	
func apply_theme(theme_data: Dictionary, universe_id: String = "", world_id: String = ""):
	if universe_id == "": universe_id = theme_data.get("id", "science_lab")
	active_universe_id = universe_id
	var tunnel = theme_data.get("tunnel", {})
	
	var world_prof = WorldProfileCustodian.get_profile(world_id) if world_id != "" and Engine.get_main_loop().root.has_node("WorldProfileCustodian") else {}
	var tunnel_prof = world_prof.get("tunnel", {})
	
	var modifiers = theme_data.get("tunnel_modifier", {})
	var flow_str = tunnel_prof.get("flow_type", modifiers.get("flow_type", tunnel.get("flow_type", "linear")))
	var density_val = tunnel_prof.get("density", modifiers.get("fog_density", tunnel.get("density", 0.6)))
	
	var palette = world_prof.get("lens", {}).get("colors", theme_data.get("palette", {"primary": Color(1,1,1), "bg": Color(0,0,0)}))
	var bg_color = _to_color(palette.get("bg", Color(0, 0, 0)), Color(0, 0, 0))
	var primary_color = _to_color(palette.get("primary", Color(1, 1, 1)), Color(1, 1, 1))
	
	var flow_int = 0
	if flow_str == "vortex": flow_int = 1
	elif flow_str == "branching": flow_int = 2
	elif flow_str == "wave": flow_int = 3

	_material.set_shader_parameter("color_primary", bg_color)
	_material.set_shader_parameter("color_secondary", primary_color.darkened(0.5))
	_material.set_shader_parameter("color_tertiary", primary_color)

	_material.set_shader_parameter("flow_speed", tunnel.get("speed_multiplier", 1.0))
	_material.set_shader_parameter("density", density_val)
	_material.set_shader_parameter("flow_type", flow_int)
	
	var asset_registry = AssetManifestRegistry
	var manifest = asset_registry.get_manifest(universe_id)
	
	var noise_tex = null
	if world_id != "":
		# Deterministic World Compiler Pipeline (replaces static manifest["worlds"][world_id])
		var world_bundle = asset_registry.get_world_bundle(universe_id, world_id, modifiers)
		if world_bundle.has("hash"):
			var cached_bundle = WorldAssetCompiler.get_bundle(world_bundle["hash"])
			if cached_bundle.has("textures") and cached_bundle["textures"].has("bg_noise"):
				noise_tex = cached_bundle["textures"]["bg_noise"]
				
	if noise_tex == null:
		var resolved_noise_path = asset_registry.resolve_asset(manifest, "bg_noise")
		noise_tex = load(resolved_noise_path)
		
	if noise_tex:
		_material.set_shader_parameter("noise_tex", noise_tex)
		
	print("[TIER 1 - SHADER] Field environment synchronized with universe: ", universe_id, " | World: ", world_id)

func _on_spike_started():
	var spike_intensity = TunnelIntensity.FOCUS
	if randf() > 0.95:
		spike_intensity = TunnelIntensity.PEAK
	elif randf() > 0.70:
		spike_intensity = TunnelIntensity.CHALLENGE
	
	_apply_intensity_shift(spike_intensity)
	
	var orch = Engine.get_main_loop().root.get_node_or_null("ExperienceOrchestrator") if Engine.get_main_loop() else null
	if orch and "active_state" in orch and orch.active_state and "current_scenario" in orch.active_state:
		var s_type = str(orch.active_state.current_scenario)
		var s_payload = orch.get("active_payload", {}) if "active_payload" in orch else {}
		if s_payload.is_empty() and "current_mission" in orch:
			s_payload = orch.current_mission
		modulate_for_scenario(s_type, s_payload)

func modulate_for_scenario(scenario_type: String, scenario_payload: Dictionary = {}):
	if not _material: return
	print("[TIER 1 - SHADER] Modulating tunnel flow and subject colors for scenario: ", scenario_type)
	var tween = get_tree().create_tween().set_parallel(true)
	match scenario_type.to_lower():
		"rapid_classification", "reflex_tap", "speed_sort":
			tween.tween_property(_material, "shader_parameter/flow_speed", 1.35, 0.6)
		"memory_cascade", "spatial_recall", "sequence_reverse":
			tween.tween_property(_material, "shader_parameter/flow_speed", 0.70, 0.6)
		"signal_vs_noise", "stroop_test", "odd_one_out", "pattern_continuation":
			tween.tween_property(_material, "shader_parameter/flow_speed", 1.0, 0.6)
		_:
			tween.tween_property(_material, "shader_parameter/flow_speed", 1.0, 0.6)
			
	var pres = scenario_payload.get("presentation", {})
	var subject_colors = pres.get("tunnel_colors", {})
	var s_id = str(scenario_payload.get("id", scenario_type)).to_lower()
	var s_title = str(scenario_payload.get("title", scenario_payload.get("mission_title", ""))).to_lower()
	if subject_colors.is_empty():
		if "nile" in s_id or "nile" in s_title or "river" in s_id:
			subject_colors = {"primary": Color("#0088FF"), "secondary": Color("#003366"), "tertiary": Color("#00FF88")}
		elif "god" in s_id or "god" in s_title or "myth" in s_id or "divine" in s_id or "pantheon" in s_title or "pharaoh" in s_title:
			subject_colors = {"primary": Color("#FFD700"), "secondary": Color("#1C39BB"), "tertiary": Color("#00D4FF")}
		elif "pyramid" in s_id or "pyramid" in s_title or "build" in s_id or "arch" in s_id:
			subject_colors = {"primary": Color("#E68000"), "secondary": Color("#552200"), "tertiary": Color("#FFCC00")}
		elif "tomb" in s_id or "tomb" in s_title or "funerary" in s_id:
			subject_colors = {"primary": Color("#8000FF"), "secondary": Color("#1A0033"), "tertiary": Color("#D400FF")}

	if not subject_colors.is_empty():
		if subject_colors.has("secondary"):
			tween.tween_property(_material, "shader_parameter/color_primary", _to_color(subject_colors["secondary"], Color("#003366")), 0.8)
		if subject_colors.has("primary"):
			var subject_primary = _to_color(subject_colors["primary"], Color("#00D4FF"))
			tween.tween_property(_material, "shader_parameter/color_secondary", subject_primary.darkened(0.4), 0.8)
			tween.tween_property(_material, "shader_parameter/color_tertiary", subject_primary, 0.8)
		print("[TIER 1 - SHADER] Applied subject tunnel coloring: ", subject_colors)

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
