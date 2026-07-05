extends CanvasLayer

signal world_selected(universe_id: String, world_id: String)
signal return_requested

@onready var grid = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/GridContainer
@onready var btn_return = $PanelContainer/MarginContainer/VBoxContainer/Header/BtnReturn
@onready var title_label = $PanelContainer/MarginContainer/VBoxContainer/Header/Title

var active_universe_id: String = ""
var _is_setup_ready: bool = false

func setup(universe_id: String):
	active_universe_id = universe_id
	var registry = ContentRegistry if ContentRegistry else get_tree().root.get_node_or_null("ContentRegistry")
	active_universe_id = registry.ensure_valid_selection({"universe_id": active_universe_id, "world_id": ""}).get("universe_id", "")
	if title_label:
		var spec = registry.get_universe(active_universe_id)
		title_label.text = spec.get("display_name", active_universe_id).to_upper() + " - WORLDS"
	_apply_universe_manifest(active_universe_id)
	if is_inside_tree():
		_populate_grid()
	else:
		_is_setup_ready = true

func _ready():
	print("WORLD SELECT SCREEN READY")
	print("Size: ", $PanelContainer.size)
	if title_label:
		var registry = ContentRegistry if ContentRegistry else get_tree().root.get_node_or_null("ContentRegistry")
		var spec = registry.get_universe(active_universe_id) if active_universe_id != "" else {}
		title_label.text = spec.get("display_name", active_universe_id).to_upper() + " - WORLDS" if active_universe_id != "" else "WORLDS"
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
	var _vim = VisualIdentityManager if VisualIdentityManager else get_tree().root.get_node_or_null("VisualIdentityManager")
	var def = registry.get_universe_identity(active_universe_id)
	var default_palette = def.get("palette", {})
	var default_bg = _to_color(default_palette.get("bg", Color("#0B1320")), Color("#0B1320"))
	var default_primary = _to_color(default_palette.get("primary", Color("#00D4FF")), Color("#00D4FF"))
	
	var worlds = registry.get_worlds_for_universe(active_universe_id)
	if worlds.is_empty():
		push_error("[WorldSelectScreen] No worlds found for universe: " + active_universe_id)
		return
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
		
		var w_def = registry.get_world_identity(active_universe_id, w_id)
		var palette = w_def.get("palette", {})
		var bg_color = _to_color(palette.get("bg", default_bg), default_bg)
		var primary_color = _to_color(palette.get("primary", default_primary), default_primary)
		var world_spec = registry.get_world(active_universe_id, w_id)
		var pretty_name = world_spec.get("display_name", w_id.capitalize().replace("_", " "))
		
		var interp = Engine.get_main_loop().root.get_node_or_null("ProgressionInterpreter") if Engine.get_main_loop() else null
		var w_ctx = interp.get_world_progression_context(active_universe_id, w_id) if (interp and interp.has_method("get_world_progression_context")) else {}
		var s_ctx = interp.get_scenario_progression_context("rapid_classification") if (interp and interp.has_method("get_scenario_progression_context")) else {}
		
		var completion = w_ctx.get("completion", "0%")
		var scenario_count = w_ctx.get("scenario_count", "10 scenarios")
		var rec = s_ctx.get("recent_perf", "Recommended Today")
		
		btn.text = pretty_name.to_upper() + "\n" + str(scenario_count) + " | WORLD MASTERY: " + str(completion) + "\n★ " + str(rec)
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
			world_selected.emit(active_universe_id, w_id)
		)
		grid.add_child(btn)

func hide_screen():
	if AdManager: AdManager.hide_banner()
	queue_free()
