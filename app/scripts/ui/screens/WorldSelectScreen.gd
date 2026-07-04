extends CanvasLayer

signal world_selected(universe_id: String, world_id: String)
signal return_requested

@onready var grid = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/GridContainer
@onready var btn_return = $PanelContainer/MarginContainer/VBoxContainer/Header/BtnReturn
@onready var title_label = $PanelContainer/MarginContainer/VBoxContainer/Header/Title

var active_universe_id: String = "history"
var _is_setup_ready: bool = false

var world_meta = {
	"ancient_egypt": {"name": "Ancient Egypt", "scenarios": "12 scenarios", "completion": "34%", "rec": "Recommended Today"},
	"ancient_rome": {"name": "Ancient Rome", "scenarios": "10 scenarios", "completion": "0%", "rec": "Optimal Alignment"},
	"medieval_europe": {"name": "Medieval Europe", "scenarios": "15 scenarios", "completion": "52%", "rec": "Moderate Alignment"},
	"renaissance": {"name": "Renaissance", "scenarios": "8 scenarios", "completion": "100%", "rec": "Mastered"},
	"industrial_revolution": {"name": "Industrial Revolution", "scenarios": "14 scenarios", "completion": "15%", "rec": "High Potential"},
	"arctic": {"name": "Arctic", "scenarios": "10 scenarios", "completion": "40%", "rec": "Recommended Today"},
	"aviation": {"name": "Aviation", "scenarios": "12 scenarios", "completion": "10%", "rec": "High Potential"},
	"disaster": {"name": "Disaster Response", "scenarios": "15 scenarios", "completion": "80%", "rec": "Advanced Alignment"},
	"wilderness": {"name": "Wilderness", "scenarios": "14 scenarios", "completion": "25%", "rec": "Recommended Today"}
}

func setup(universe_id: String):
	active_universe_id = universe_id
	if title_label: title_label.text = universe_id.capitalize().replace("_", " ") + " - WORLDS"
	_apply_universe_manifest(universe_id)
	if is_inside_tree():
		_populate_grid()
	else:
		_is_setup_ready = true

func _ready():
	print("WORLD SELECT SCREEN READY")
	print("Size: ", $PanelContainer.size)
	if title_label: title_label.text = active_universe_id.capitalize().replace("_", " ") + " - WORLDS"
	if AdManager: AdManager.show_banner()
	btn_return.pressed.connect(func(): return_requested.emit())
	if get_viewport() and not get_viewport().size_changed.is_connected(_apply_responsive_layout):
		get_viewport().size_changed.connect(_apply_responsive_layout)
	_apply_responsive_layout()
	_apply_universe_manifest(active_universe_id)
	if _is_setup_ready:
		_populate_grid()

func _to_color(value: Variant, fallback: Color) -> Color:
	if value is Color:
		return value
	if typeof(value) == TYPE_STRING:
		var text = str(value).strip_edges()
		if text != "":
			return Color(text)
	return fallback

func _apply_universe_manifest(universe_id: String):
	var vim = VisualIdentityManager if VisualIdentityManager else get_tree().root.get_node_or_null("VisualIdentityManager")
	if vim and vim.has_method("apply_screen_identity"):
		vim.apply_screen_identity(self, universe_id, "", false)
	else:
		var bg = get_node_or_null("ColorRect") if get_node_or_null("ColorRect") else get_node_or_null("VoidBG")
		if bg and bg is ColorRect: bg.color = Color(0.04, 0.07, 0.12, 0.15)

func _apply_responsive_layout():
	var panel = get_node_or_null("PanelContainer")
	if panel and panel is Control:
		var viewport_size = get_viewport().get_visible_rect().size if get_viewport() else Vector2(1280, 720)
		var inset_x = clamp(viewport_size.x * 0.035, 24.0, 64.0)
		var inset_y = clamp(viewport_size.y * 0.04, 20.0, 48.0)
		panel.offset_left = inset_x
		panel.offset_top = inset_y
		panel.offset_right = -inset_x
		panel.offset_bottom = -inset_y
	if grid:
		var panel_width = panel.size.x if panel and panel is Control else get_viewport().get_visible_rect().size.x
		var usable_width = max(260.0, panel_width - 80.0)
		grid.columns = clamp(int(usable_width / 286.0), 1, 4)

func _populate_grid():
	_apply_responsive_layout()
	var registry = ContentRegistry if ContentRegistry else get_tree().root.get_node_or_null("ContentRegistry")
	var _profile = PlayerProfile if PlayerProfile else get_tree().root.get_node_or_null("PlayerProfile")
	var vim = VisualIdentityManager if VisualIdentityManager else get_tree().root.get_node_or_null("VisualIdentityManager")
	var def = vim.get_universe_identity(active_universe_id) if vim else {"palette": {"bg": Color("#0B1320"), "primary": Color("#00D4FF")}}
	var default_palette = def.get("palette", {})
	var default_bg = _to_color(default_palette.get("bg", Color("#0B1320")), Color("#0B1320"))
	var default_primary = _to_color(default_palette.get("primary", Color("#00D4FF")), Color("#00D4FF"))
	
	var worlds = registry.get_all_worlds_in_universe(active_universe_id) if registry else []
	var fallback_worlds = []
	match active_universe_id:
		"history": fallback_worlds = ["ancient_egypt", "ancient_rome", "medieval_europe", "renaissance", "industrial_revolution"]
		"science_lab": fallback_worlds = ["cognitive_bias", "neural_mapping", "ai", "quantum_mechanics", "optics"]
		"life_sciences": fallback_worlds = ["genetics", "cellular_biology", "virology", "botany", "neuroscience"]
		"tech_ops": fallback_worlds = ["cyber_matrix", "subliminal_code", "protocols", "encryption", "firewalls"]
		"creative_arts": fallback_worlds = ["color_theory", "composition", "harmony", "sculpture", "architecture"]
		"society_mind": fallback_worlds = ["behavioral_economics", "sociology", "psychology", "linguistics", "group_dynamics"]
		"frontier": fallback_worlds = ["arctic", "aviation", "disaster", "wilderness", "space_exploration", "deep_sea", "mountain_summit", "desert_crossing", "subterranean", "jungle_canopy"]
		_: fallback_worlds = ["foundations", "advanced_concepts", "synthesis"]
	if worlds.is_empty():
		worlds = fallback_worlds
	worlds.sort()

	print("Universe:", active_universe_id)
	print("Loaded ", worlds.size(), " worlds")
	print(worlds)
		
	for child in grid.get_children():
		child.queue_free()
		
	for w_id in worlds:
		print("Created card: ", w_id)
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(270, 124)
		btn.mouse_filter = Control.MOUSE_FILTER_STOP
		
		var w_def = vim.get_world_identity(active_universe_id, w_id) if vim else def
		var palette = w_def.get("palette", {})
		var bg_color = _to_color(palette.get("bg", default_bg), default_bg)
		var primary_color = _to_color(palette.get("primary", default_primary), default_primary)
		var pretty_name = w_id.capitalize().replace("_", " ")
		var meta = world_meta.get(w_id, {"name": pretty_name, "scenarios": "10 scenarios", "completion": "20%", "rec": "Recommended Today"})
		
		var interp = Engine.get_main_loop().root.get_node_or_null("ProgressionInterpreter") if Engine.get_main_loop() else null
		var w_ctx = interp.get_world_progression_context(active_universe_id, w_id) if (interp and interp.has_method("get_world_progression_context")) else {}
		var s_ctx = interp.get_scenario_progression_context("rapid_classification") if (interp and interp.has_method("get_scenario_progression_context")) else {}
		
		var wm_str = w_ctx.get("world_mastery", "WORLD MASTERY: " + meta["completion"])
		var wr_str = w_ctx.get("recency", meta["scenarios"])
		var sp_str = s_ctx.get("recent_perf", "★ " + meta["rec"])
		
		btn.text = meta["name"].to_upper() + "\n" + wr_str + " | " + wm_str + "\n" + sp_str
		btn.add_theme_font_size_override("font_size", 14)
		btn.clip_text = true
		
		var style = StyleBoxFlat.new()
		style.bg_color = bg_color
		style.border_width_bottom = 4
		style.border_color = primary_color
		style.corner_radius_top_left = 12
		style.corner_radius_top_right = 12
		style.corner_radius_bottom_left = 12
		style.corner_radius_bottom_right = 12
		
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style.duplicate())
		btn.add_theme_stylebox_override("pressed", style.duplicate())
		btn.add_theme_color_override("font_color", primary_color.lightened(0.6))
		
		btn.pressed.connect(func():
			print("WORLD CARD CLICKED:", w_id)
			if AudioManager: AudioManager.play_sfx("ui_click")
			var orch = ExperienceOrchestrator if ExperienceOrchestrator else get_tree().root.get_node_or_null("ExperienceOrchestrator")
			if orch and orch.has_method("request_world_selection"):
				orch.request_world_selection(active_universe_id, w_id)
			else:
				world_selected.emit(active_universe_id, w_id)
		)
		grid.add_child(btn)

func hide_screen():
	if AdManager: AdManager.hide_banner()
	queue_free()
