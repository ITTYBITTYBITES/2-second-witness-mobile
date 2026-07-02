extends Control
class_name ProgressionHUDPlatesNode

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# PROGRESSION HUD PLATES — STRATUM 3 EDGE INSTRUMENTATION
# ---------------------------------------------------------
# RULES:
# - MAX 2 plates at any time
# - MUST live ONLY in Stratum 3 (14pt muted cool gray #667799)
# - MUST be anchored to cockpit edges (y=58, outside central area)
# - NEVER appear in question, stimulus, or central screen regions
# - Update ONLY on discrete progression events
# - NEVER animate continuously or move position dynamically
# ---------------------------------------------------------

var active_universe_id: String = "history"
var active_world_id: String = "ancient_egypt"

var _plate_mastery: PanelContainer = null
var _lbl_mastery: RichTextLabel = null

var _plate_streak: PanelContainer = null
var _lbl_streak: RichTextLabel = null

func _init():
	name = "ProgressionHUDPlates"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)

func _ready():
	_build_plates()
	var interp = Engine.get_main_loop().root.get_node_or_null("ProgressionInterpreter") if Engine.get_main_loop() else null
	if interp and interp.has_signal("progression_event_processed"):
		interp.progression_event_processed.connect(_on_progression_event)
	_refresh_plates()

func setup(u_id: String, w_id: String):
	active_universe_id = u_id
	active_world_id = w_id
	_refresh_plates()

func _build_plates():
	# Plate 2: World Mastery / Progression (Top-Left edge, y=58)
	_plate_mastery = PanelContainer.new()
	_plate_mastery.name = "PlateMastery"
	_plate_mastery.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_plate_mastery.position = Vector2(24, 58)
	
	var style_m = StyleBoxFlat.new()
	style_m.bg_color = Color("#080D16")
	style_m.bg_color.a = 0.85
	style_m.border_width_bottom = 1
	style_m.border_color = Color("#223344")
	style_m.corner_radius_bottom_left = 4
	style_m.corner_radius_bottom_right = 4
	_plate_mastery.add_theme_stylebox_override("panel", style_m)
	
	var margin_m = MarginContainer.new()
	margin_m.add_theme_constant_override("margin_left", 12)
	margin_m.add_theme_constant_override("margin_right", 12)
	margin_m.add_theme_constant_override("margin_top", 4)
	margin_m.add_theme_constant_override("margin_bottom", 4)
	_plate_mastery.add_child(margin_m)
	
	_lbl_mastery = RichTextLabel.new()
	_lbl_mastery.bbcode_enabled = true
	_lbl_mastery.fit_content = true
	_lbl_mastery.autowrap_mode = TextServer.AUTOWRAP_OFF
	_lbl_mastery.add_theme_font_size_override("normal_font_size", 14)
	_lbl_mastery.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin_m.add_child(_lbl_mastery)
	add_child(_plate_mastery)
	
	# Plate 1: Continuity / Streak (Top-Right edge, y=58)
	_plate_streak = PanelContainer.new()
	_plate_streak.name = "PlateStreak"
	_plate_streak.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_plate_streak.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_plate_streak.position = Vector2(-160, 58)
	_plate_streak.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	
	var style_s = StyleBoxFlat.new()
	style_s.bg_color = Color("#080D16")
	style_s.bg_color.a = 0.85
	style_s.border_width_bottom = 1
	style_s.border_color = Color("#223344")
	style_s.corner_radius_bottom_left = 4
	style_s.corner_radius_bottom_right = 4
	_plate_streak.add_theme_stylebox_override("panel", style_s)
	
	var margin_s = MarginContainer.new()
	margin_s.add_theme_constant_override("margin_left", 12)
	margin_s.add_theme_constant_override("margin_right", 12)
	margin_s.add_theme_constant_override("margin_top", 4)
	margin_s.add_theme_constant_override("margin_bottom", 4)
	_plate_streak.add_child(margin_s)
	
	_lbl_streak = RichTextLabel.new()
	_lbl_streak.bbcode_enabled = true
	_lbl_streak.fit_content = true
	_lbl_streak.autowrap_mode = TextServer.AUTOWRAP_OFF
	_lbl_streak.add_theme_font_size_override("normal_font_size", 14)
	_lbl_streak.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin_s.add_child(_lbl_streak)
	add_child(_plate_streak)
	
	_update_streak_position()

func _update_streak_position():
	if is_instance_valid(_plate_streak) and is_inside_tree():
		var w = get_viewport_rect().size.x
		if w > 0:
			_plate_streak.position = Vector2(w - _plate_streak.size.x - 24, 58)

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		_update_streak_position()

func _on_progression_event(event_type: int, _value: Variant, _context: Dictionary, _timestamp: float):
	# Discrete events only — never continuous input updates
	if event_type == 0 or event_type == 1 or event_type == 2 or event_type == 4: # SESSION_COMPLETE, STREAK_EXTENDED, WORLD_PROGRESS, MASTERY_INCREASE
		_refresh_plates()

func _refresh_plates():
	var interp = Engine.get_main_loop().root.get_node_or_null("ProgressionInterpreter") if Engine.get_main_loop() else null
	
	var mastery_val = 0
	var streak_val = 1
	if interp and interp.has_method("get_world_mastery_percentage"):
		mastery_val = interp.get_world_mastery_percentage(active_universe_id, active_world_id)
		streak_val = interp.get_current_streak()
	else:
		var profile = Engine.get_main_loop().root.get_node_or_null("PlayerProfile") if Engine.get_main_loop() else null
		if profile and "world_affinity" in profile:
			var world_key = active_universe_id + "_" + active_world_id
			var aff = profile.world_affinity.get(world_key, 0)
			mastery_val = clampi(int((float(aff) / 500.0) * 100.0), 0, 100)
			streak_val = profile.current_streak
			
	if is_instance_valid(_lbl_mastery):
		var w_name = active_world_id.capitalize().replace("_", " ").to_upper()
		_lbl_mastery.text = "[color=#667799]%s:[/color] [b][color=#00D4FF]%d%%[/color][/b]" % [w_name, mastery_val]
		
	if is_instance_valid(_lbl_streak):
		_lbl_streak.text = "[color=#667799]STREAK:[/color] [b][color=#E6B800]%d[/color][/b]" % [streak_val]
		
	call_deferred("_update_streak_position")
