extends CanvasLayer

signal expedition_world_selected(universe_id: String, world_id: String)
signal return_requested
signal explore_all_requested

@onready var grid = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/GridContainer
@onready var btn_return = $PanelContainer/MarginContainer/VBoxContainer/Header/BtnReturn
@onready var title_label = $PanelContainer/MarginContainer/VBoxContainer/Header/Title
@onready var subtitle_label = $PanelContainer/MarginContainer/VBoxContainer/Subtitle
@onready var streak_label = $PanelContainer/MarginContainer/VBoxContainer/StreakLabel

func _ready():
	print("DAILY EXPEDITION SCREEN READY")
	if btn_return and not btn_return.pressed.is_connected(_on_return_pressed):
		btn_return.pressed.connect(_on_return_pressed)
	if get_viewport() and not get_viewport().size_changed.is_connected(_apply_responsive_layout):
		get_viewport().size_changed.connect(_apply_responsive_layout)
	_apply_responsive_layout()
	_mount_explore_button()
	_populate()

func _mount_explore_button():
	var vbox = $PanelContainer/MarginContainer/VBoxContainer
	var btn_explore = Button.new()
	btn_explore.name = "BtnExploreAll"
	btn_explore.custom_minimum_size = Vector2(0, 48)
	btn_explore.text = "EXPLORE ALL WORLDS"
	btn_explore.add_theme_font_size_override("font_size", 16)
	btn_explore.pressed.connect(func():
		if AudioManager: AudioManager.play_sfx("ui_click")
		explore_all_requested.emit()
	)
	vbox.add_child(btn_explore)

func _on_return_pressed():
	if AudioManager: AudioManager.play_sfx("ui_click")
	return_requested.emit()

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
		grid.columns = clamp(int(max(260.0, panel_width - 80.0) / 310.0), 1, 4)

func _populate():
	_apply_responsive_layout()
	for child in grid.get_children():
		child.queue_free()

	var expedition_mgr = DailyExpeditionManager if DailyExpeditionManager else get_tree().root.get_node_or_null("DailyExpeditionManager")
	if not expedition_mgr:
		subtitle_label.text = "Expedition system not available."
		return

	var expedition = expedition_mgr.get_expedition()
	var progress = expedition_mgr.get_progress()

	# Update header
	var today = progress.get("date", "Today")
	title_label.text = "DAILY EXPEDITION"
	streak_label.text = "Streak: %d days | Total: %d | %s" % [progress.get("streak", 0), progress.get("total_completed", 0), progress.get("completed", 0)]

	if expedition.is_empty():
		subtitle_label.text = "No worlds available yet."
		return

	subtitle_label.text = "%d / %d complete — finish all for a daily badge" % [progress.get("completed", 0), expedition.size()]

	var vim = VisualIdentityManager if VisualIdentityManager else get_tree().root.get_node_or_null("VisualIdentityManager")
	var reg = ContentRegistry if ContentRegistry else get_tree().root.get_node_or_null("ContentRegistry")

	for entry in expedition:
		var u_id = str(entry.get("universe_id", ""))
		var w_id = str(entry.get("world_id", ""))
		var key = u_id + "/" + w_id
		var is_done = progress.get("completed", 0) > 0 and expedition_mgr.completed_worlds_today.has(key)

		var w_name = w_id.capitalize().replace("_", " ")
		if reg and reg.has_method("get_world"):
			var w_spec = reg.get_world(u_id, w_id)
			w_name = str(w_spec.get("display_name", w_name))

		var u_name = u_id.capitalize().replace("_", " ")
		if reg and reg.has_method("get_universe"):
			var u_spec = reg.get_universe(u_id)
			u_name = str(u_spec.get("display_name", u_name))

		# Get palette for this universe
		var identity = vim.get_universe_identity(u_id) if vim else {"palette": {"bg": Color("#0B1320"), "primary": Color("#00D4FF")}}
		var palette = identity.get("palette", {})
		var bg_color = _to_color(palette.get("bg", Color("#0B1320")), Color("#0B1320"))
		var primary_color = _to_color(palette.get("primary", Color("#00D4FF")), Color("#00D4FF"))

		var btn = Button.new()
		btn.custom_minimum_size = Vector2(300, 100)
		btn.clip_text = true

		var status = "COMPLETE" if is_done else "EXPLORE"
		btn.text = w_name.to_upper() + "\n" + u_name + "\n" + status
		btn.add_theme_font_size_override("font_size", 14)

		var style = StyleBoxFlat.new()
		style.bg_color = bg_color
		style.bg_color.a = 0.6 if is_done else 0.92
		style.border_width_bottom = 4
		style.border_color = Color(0.3, 0.8, 0.3) if is_done else primary_color
		style.set_corner_radius_all(12)
		btn.add_theme_stylebox_override("normal", style)
		var hover = style.duplicate()
		hover.bg_color = bg_color.lightened(0.12)
		btn.add_theme_stylebox_override("hover", hover)
		btn.add_theme_stylebox_override("pressed", style.duplicate())
		btn.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5) if is_done else primary_color.lightened(0.6))

		if not is_done:
			btn.pressed.connect(func():
				if AudioManager: AudioManager.play_sfx("ui_click")
				expedition_world_selected.emit(u_id, w_id)
			)
		else:
			btn.disabled = true

		grid.add_child(btn)

func _to_color(value: Variant, fallback: Color) -> Color:
	if value is Color:
		return value
	if typeof(value) == TYPE_STRING:
		var text = str(value).strip_edges()
		if text != "":
			return Color(text)
	return fallback

func refresh():
	_populate()
