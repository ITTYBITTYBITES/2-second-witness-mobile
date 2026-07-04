extends CanvasLayer

signal scenario_selected(universe_id: String, world_id: String, subcategory_id: String, scenario_type: String)
signal return_requested

@onready var grid = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/GridContainer
@onready var btn_return = $PanelContainer/MarginContainer/VBoxContainer/Header/BtnReturn
@onready var title_label = $PanelContainer/MarginContainer/VBoxContainer/Header/Title
@onready var subtitle_label = $PanelContainer/MarginContainer/VBoxContainer/Subtitle

var active_universe_id: String = "creative_arts"
var active_world_id: String = "painting"
var active_subcategory_id: String = "famous_paintings"
var _is_setup_ready: bool = false

var scenario_meta = {
	"rapid_classification": {"title": "Rapid Classification", "desc": "Fast clue-to-answer recognition."},
	"stroop_test": {"title": "Color Interference", "desc": "Read the color, resist the word."},
	"signal_vs_noise": {"title": "Signal vs Noise", "desc": "Find whether the target appears."},
	"odd_one_out": {"title": "Odd One Out", "desc": "Spot the anomaly."},
	"memory_cascade": {"title": "Memory Cascade", "desc": "Recall a short sequence."},
	"sequence_reverse": {"title": "Sequence Reverse", "desc": "Reverse an observed sequence."},
	"pattern_continuation": {"title": "Pattern Continuation", "desc": "Choose the next pattern item."},
	"spatial_recall": {"title": "Spatial Recall", "desc": "Remember positions."},
	"math_surprise": {"title": "Math Surprise", "desc": "Verify fast numeric claims."},
	"speed_sort": {"title": "Speed Sort", "desc": "Sort quickly into categories."},
	"risk_selection": {"title": "Risk Selection", "desc": "Choose under uncertainty."},
	"reflex_tap": {"title": "Reflex Tap", "desc": "React to a signal."}
}

func setup(universe_id: String, world_id: String, subcategory_id: String):
	active_universe_id = universe_id
	active_world_id = world_id
	active_subcategory_id = subcategory_id
	if title_label:
		title_label.text = subcategory_id.capitalize().replace("_", " ") + " - EXERCISE"
	if subtitle_label:
		subtitle_label.text = "Optional advanced control. Choose a compatible observation exercise."
	_apply_identity()
	if is_inside_tree():
		_populate_grid()
	else:
		_is_setup_ready = true

func _ready():
	print("SCENARIO SELECT SCREEN READY")
	if btn_return and not btn_return.pressed.is_connected(_on_return_pressed):
		btn_return.pressed.connect(_on_return_pressed)
	if get_viewport() and not get_viewport().size_changed.is_connected(_apply_responsive_layout):
		get_viewport().size_changed.connect(_apply_responsive_layout)
	_apply_responsive_layout()
	_apply_identity()
	if _is_setup_ready:
		_populate_grid()

func _on_return_pressed():
	if AudioManager: AudioManager.play_sfx("ui_click")
	return_requested.emit()

func _apply_identity():
	var vim = VisualIdentityManager if VisualIdentityManager else get_tree().root.get_node_or_null("VisualIdentityManager")
	if vim and vim.has_method("apply_screen_identity"):
		vim.apply_screen_identity(self, active_universe_id, active_world_id, false)

func _to_color(value: Variant, fallback: Color) -> Color:
	if value is Color: return value
	if typeof(value) == TYPE_STRING and str(value).strip_edges() != "": return Color(str(value))
	return fallback

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
		grid.columns = clamp(int(max(260.0, panel_width - 80.0) / 296.0), 1, 4)

func _populate_grid():
	_apply_responsive_layout()
	for child in grid.get_children(): child.queue_free()
	var vim = VisualIdentityManager if VisualIdentityManager else get_tree().root.get_node_or_null("VisualIdentityManager")
	var identity = vim.get_world_identity(active_universe_id, active_world_id) if vim else {"palette": {"bg": Color("#0B1320"), "primary": Color("#00D4FF")}}
	var palette = identity.get("palette", {})
	var bg_color = _to_color(palette.get("bg", Color("#0B1320")), Color("#0B1320"))
	var primary_color = _to_color(palette.get("primary", Color("#00D4FF")), Color("#00D4FF"))
	var available = ObservationCollection.get_available_mechanics(active_universe_id, active_world_id, active_subcategory_id) if ObservationCollection else []
	if available.is_empty():
		_create_pending_card(bg_color)
		return
	for mechanic in available:
		_create_mechanic_card(mechanic, bg_color, primary_color)

func _create_mechanic_card(mechanic: String, bg_color: Color, primary_color: Color):
	var meta = scenario_meta.get(mechanic, {"title": mechanic.capitalize().replace("_", " "), "desc": "Rapid-fire observation."})
	var count = ObservationCollection.get_collection(active_universe_id, active_world_id, active_subcategory_id, mechanic).size() if ObservationCollection else 0
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(280, 138)
	btn.mouse_filter = Control.MOUSE_FILTER_STOP
	btn.clip_text = true
	btn.text = str(meta["title"]).to_upper() + "\n" + str(meta["desc"]) + "\n" + str(count) + " observations"
	btn.add_theme_font_size_override("font_size", 14)
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.bg_color.a = 0.92
	style.border_width_bottom = 4
	style.border_color = primary_color
	style.set_corner_radius_all(12)
	btn.add_theme_stylebox_override("normal", style)
	var hover = style.duplicate()
	hover.bg_color = bg_color.lightened(0.12)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", style.duplicate())
	btn.add_theme_color_override("font_color", primary_color.lightened(0.6))
	btn.pressed.connect(func():
		if AudioManager: AudioManager.play_sfx("ui_click")
		scenario_selected.emit(active_universe_id, active_world_id, active_subcategory_id, mechanic)
	)
	grid.add_child(btn)

func _create_pending_card(bg_color: Color):
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(360, 120)
	btn.disabled = true
	btn.text = "NO COMPATIBLE EXERCISES\nThis observation bank is not compiled yet."
	btn.add_theme_font_size_override("font_size", 14)
	grid.add_child(btn)
