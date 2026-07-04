extends CanvasLayer

signal subcategory_selected(universe_id: String, world_id: String, subcategory_id: String, manual_activity: bool)
signal return_requested

@onready var grid = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/GridContainer
@onready var btn_return = $PanelContainer/MarginContainer/VBoxContainer/Header/BtnReturn
@onready var title_label = $PanelContainer/MarginContainer/VBoxContainer/Header/Title
@onready var header = $PanelContainer/MarginContainer/VBoxContainer/Header
@onready var subtitle_label = $PanelContainer/MarginContainer/VBoxContainer/Subtitle

var active_universe_id: String = "creative_arts"
var active_world_id: String = "painting"
var _is_setup_ready: bool = false
var _manual_activity_mode: bool = false
var _btn_activity_mode: Button = null

func setup(universe_id: String, world_id: String):
	active_universe_id = universe_id
	active_world_id = world_id
	
	# GOLD STANDARD: Force ContentLoader to index if it hasn't already
	var loader = Engine.get_main_loop().root.get_node_or_null("ContentLoader")
	if loader and loader.has_method("ensure_indexed"):
		loader.ensure_indexed()
		
	# FORCE LOAD: Ensure the world content is loaded so subcategories/scenarios are registered
	var registry = Engine.get_main_loop().root.get_node_or_null("ContentRegistry")
	if registry and registry.has_method("_ensure_content_loaded_for"):
		registry._ensure_content_loaded_for(universe_id, world_id)
		
	if title_label:
		title_label.text = world_id.capitalize().replace("_", " ") + " - SUBCATEGORIES"
	if subtitle_label:
		subtitle_label.text = "Choose a content bank. The best rapid-fire scenario is selected automatically."
	_apply_universe_manifest(universe_id, world_id)
	if is_inside_tree():
		_populate_grid()
	else:
		_is_setup_ready = true

func _ready():
	print("SUBCATEGORY SELECT SCREEN READY")
	if btn_return and not btn_return.pressed.is_connected(_on_return_pressed):
		btn_return.pressed.connect(_on_return_pressed)
	if get_viewport() and not get_viewport().size_changed.is_connected(_apply_responsive_layout):
		get_viewport().size_changed.connect(_apply_responsive_layout)
	_mount_activity_mode_button()
	_apply_responsive_layout()
	_apply_universe_manifest(active_universe_id, active_world_id)
	if _is_setup_ready:
		_populate_grid()


func _mount_activity_mode_button():
	if _btn_activity_mode or not header:
		return
	_btn_activity_mode = Button.new()
	_btn_activity_mode.name = "BtnActivityMode"
	_btn_activity_mode.custom_minimum_size = Vector2(190, 44)
	_btn_activity_mode.text = "AUTO ACTIVITY"
	_btn_activity_mode.add_theme_font_size_override("font_size", 14)
	_btn_activity_mode.pressed.connect(func():
		_manual_activity_mode = not _manual_activity_mode
		_btn_activity_mode.text = "CHOOSE ACTIVITY" if _manual_activity_mode else "AUTO ACTIVITY"
		_populate_grid()
	)
	header.add_child(_btn_activity_mode)

func _on_return_pressed():
	if AudioManager: AudioManager.play_sfx("ui_click")
	return_requested.emit()

func _to_color(value: Variant, fallback: Color) -> Color:
	if value is Color:
		return value
	if typeof(value) == TYPE_STRING:
		var text = str(value).strip_edges()
		if text != "": return Color(text)
	return fallback

func _apply_universe_manifest(universe_id: String, world_id: String):
	var vim = VisualIdentityManager if VisualIdentityManager else get_tree().root.get_node_or_null("VisualIdentityManager")
	if vim and vim.has_method("apply_screen_identity"):
		vim.apply_screen_identity(self, universe_id, world_id, false)

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
		grid.columns = clamp(int(usable_width / 296.0), 1, 4)

func _populate_grid():
	_apply_responsive_layout()
	var registry = ContentRegistry if ContentRegistry else get_tree().root.get_node_or_null("ContentRegistry")
	var vim = VisualIdentityManager if VisualIdentityManager else get_tree().root.get_node_or_null("VisualIdentityManager")
	var identity = vim.get_world_identity(active_universe_id, active_world_id) if vim else {"palette": {"bg": Color("#0B1320"), "primary": Color("#00D4FF")}}
	var palette = identity.get("palette", {})
	var bg_color = _to_color(palette.get("bg", Color("#0B1320")), Color("#0B1320"))
	var primary_color = _to_color(palette.get("primary", Color("#00D4FF")), Color("#00D4FF"))
	for child in grid.get_children(): child.queue_free()
	var subcategories = registry.get_subcategories_in_world(active_universe_id, active_world_id) if (registry and registry.has_method("get_subcategories_in_world")) else []
	if subcategories.is_empty():
		_create_pending_card(bg_color, primary_color)
		return
	for sub in subcategories:
		_create_subcategory_card(sub, bg_color, primary_color)

func _create_subcategory_card(sub: Dictionary, bg_color: Color, primary_color: Color):
	var sub_id = str(sub.get("id", ""))
	var display_name = str(sub.get("display_name", sub_id.capitalize().replace("_", " ")))
	var implemented = int(sub.get("implemented_observations", 0))
	var target = int(sub.get("target_observations", 100))
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(280, 138)
	btn.mouse_filter = Control.MOUSE_FILTER_STOP
	btn.clip_text = true
	var mode_text = "Choose activity" if _manual_activity_mode else "Begin observation"
	btn.text = display_name.to_upper() + "\n" + str(implemented) + " / " + str(target) + " observations\n" + mode_text
	btn.add_theme_font_size_override("font_size", 14)
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.bg_color.a = 0.92 if implemented > 0 else 0.45
	style.border_width_bottom = 4
	style.border_color = primary_color if implemented > 0 else Color(0.35, 0.35, 0.35)
	style.set_corner_radius_all(12)
	btn.add_theme_stylebox_override("normal", style)
	var hover = style.duplicate()
	hover.bg_color = bg_color.lightened(0.12) if implemented > 0 else style.bg_color
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", style.duplicate())
	btn.add_theme_color_override("font_color", primary_color.lightened(0.6) if implemented > 0 else Color(0.55, 0.55, 0.60))
	btn.disabled = implemented <= 0
	if implemented > 0:
		btn.pressed.connect(func():
			print("SUBCATEGORY CARD CLICKED:", sub_id)
			if AudioManager: AudioManager.play_sfx("ui_click")
			subcategory_selected.emit(active_universe_id, active_world_id, sub_id, _manual_activity_mode)
		)
	grid.add_child(btn)

func _create_pending_card(_bg_color: Color, _primary_color: Color):
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(360, 120)
	btn.disabled = true
	btn.text = "OBSERVATION BANK PENDING\nThis world has metadata but no installed bank yet."
	btn.add_theme_font_size_override("font_size", 14)
	grid.add_child(btn)
