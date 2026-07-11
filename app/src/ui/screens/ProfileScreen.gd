extends Control
## ProfileScreen – Player Progress – Premium UI
## Matches Home / Boot / Tutorial visual language
## Gameplay / save logic unchanged – ProfileService only

@onready var scroll: ScrollContainer = $Margin/Scroll
@onready var vbox: VBoxContainer = $Margin/Scroll/VBox

func _ready() -> void:
	_ensure_ui()
	_apply_theme()
	_refresh()
	if ProfileService:
		ProfileService.profile_updated.connect(_on_profile_updated)
		ProfileService.stats_updated.connect(_on_stats_updated)
	if ChallengeRegistry:
		ChallengeRegistry.registry_updated.connect(_on_registry_updated)
	if ThemeService:
		ThemeService.theme_changed.connect(_on_theme_changed)

func _get_tokens() -> Dictionary:
	if ThemeService and not ThemeService.tokens.is_empty():
		return ThemeService.tokens
	return {}

func _ensure_ui() -> void:
	# Wire existing buttons, ensure safe mobile margins
	if has_node("Margin/Scroll/VBox"):
		_wire_actions()
		return
	# Fallback – should not happen with .tscn present
	var margin := MarginContainer.new()
	margin.name = "Margin"
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)
	var s := ScrollContainer.new(); s.name = "Scroll"; margin.add_child(s)
	var vb := VBoxContainer.new(); vb.name = "VBox"; vb.add_theme_constant_override("separation", 28); s.add_child(vb)
	scroll = s; vbox = vb

func _wire_actions() -> void:
	if has_node("Margin/Scroll/VBox/ResetButton"):
		var btn: Button = $Margin/Scroll/VBox/ResetButton
		btn.visible = OS.is_debug_build()
		btn.text = "Reset Profile"
		if btn.visible and not btn.pressed.is_connected(_on_reset_pressed):
			btn.pressed.connect(_on_reset_pressed)
		_style_reset_button(btn)

func _apply_theme() -> void:
	if not ThemeService:
		return
	var tokens = ThemeService.tokens
	# Style all PanelContainers – premium card
	if has_node("Margin/Scroll/VBox"):
		for child in $Margin/Scroll/VBox.get_children():
			if child is PanelContainer:
				_style_card(child, tokens)
	# Avatar text
	var avatar_path := "Margin/Scroll/VBox/AvatarCard/Margin/HBox/VBox"
	for pair in [["NameLabel", "title", "text_primary"], ["IdLabel", "caption", "text_secondary"], ["SinceLabel", "caption", "text_tertiary"]]:
		var p := "%s/%s" % [avatar_path, pair[0]]
		if has_node(p):
			var lbl: Label = get_node(p)
			ThemeService.apply_label_style(lbl, pair[1], pair[2])
			if pair[0] == "SinceLabel":
				lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# Progress header
	if has_node("Margin/Scroll/VBox/ProgressHeader"):
		var hdr: Label = $Margin/Scroll/VBox/ProgressHeader
		ThemeService.apply_label_style(hdr, "label_small", "text_tertiary")
		hdr.text = "CHALLENGE HISTORY"
	# Reset button
	if has_node("Margin/Scroll/VBox/ResetButton"):
		_style_reset_button($Margin/Scroll/VBox/ResetButton)

func _style_card(card: PanelContainer, tokens: Dictionary) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = tokens.get("surface", Color("#1E1E26"))
	var r := tokens.get("radius_lg", 20)
	style.corner_radius_top_left = r; style.corner_radius_top_right = r
	style.corner_radius_bottom_left = r; style.corner_radius_bottom_right = r
	style.border_color = tokens.get("border", Color("#2E2E3A"))
	style.border_width_left = 1; style.border_width_right = 1; style.border_width_top = 1; style.border_width_bottom = 1
	card.add_theme_stylebox_override("panel", style)

func _style_reset_button(btn: Button) -> void:
	if not btn or not ThemeService: return
	var tokens = ThemeService.tokens
	var style := StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT
	style.border_color = tokens.get("error", Color("#FF4D5E"))
	style.border_width_left = 1; style.border_width_right = 1; style.border_width_top = 1; style.border_width_bottom = 1
	var rad := tokens.get("radius_md", 12)
	style.corner_radius_top_left = rad; style.corner_radius_top_right = rad
	style.corner_radius_bottom_left = rad; style.corner_radius_bottom_right = rad
	style.content_margin_left = 24; style.content_margin_right = 24
	style.content_margin_top = 14; style.content_margin_bottom = 14
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)
	btn.add_theme_stylebox_override("focus", style)
	btn.add_theme_color_override("font_color", tokens.get("error", Color("#FF4D5E")))
	btn.add_theme_font_size_override("font_size", ThemeService.get_font_size("button"))
	btn.custom_minimum_size.y = 56
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func _refresh() -> void:
	if not ProfileService:
		return
	var profile: Dictionary = ProfileService.profile
	# Avatar
	var avatar_path := "Margin/Scroll/VBox/AvatarCard/Margin/HBox/VBox"
	if has_node("%s/NameLabel" % avatar_path):
		var av := get_node(avatar_path)
		av.get_node("NameLabel").text = profile.get("display_name", "Witness")
		av.get_node("IdLabel").text = "ID: %s" % profile.get("id", "---")
		var created_at: String = profile.get("created_at", "")
		var total_sessions: int = profile.get("total_sessions", 0)
		av.get_node("SinceLabel").text = "Member since %s · %d sessions" % [created_at, total_sessions]
	# Level / Stats / Progress
	_refresh_level_card()
	_refresh_stats()
	if has_node("Margin/Scroll/VBox/ProgressHeader"):
		var hdr: Label = $Margin/Scroll/VBox/ProgressHeader
		if ThemeService:
			ThemeService.apply_label_style(hdr, "label_small", "text_tertiary")
		hdr.text = "CHALLENGE HISTORY"
	_refresh_experience_progress()
	_wire_actions()

func _refresh_level_card() -> void:
	if not has_node("Margin/Scroll/VBox/LevelCard"):
		return
	var card: PanelContainer = $Margin/Scroll/VBox/LevelCard
	for child in card.get_children(): child.queue_free()
	var tokens := _get_tokens()
	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_left", 16); m.add_theme_constant_override("margin_right", 16)
	m.add_theme_constant_override("margin_top", 16); m.add_theme_constant_override("margin_bottom", 16)
	card.add_child(m)
	var vbox := VBoxContainer.new(); m.add_child(vbox)
	var profile: Dictionary = ProfileService.profile if ProfileService else {}
	var level: int = profile.get("level", 1)
	var xp: int = profile.get("xp", 0)
	var xp_next: int = profile.get("xp_to_next", 100)
	var hbox := HBoxContainer.new(); vbox.add_child(hbox)
	var lvl_lbl := Label.new(); lvl_lbl.text = "Level %d" % level
	if ThemeService: ThemeService.apply_label_style(lvl_lbl, "title", "text_primary")
	hbox.add_child(lvl_lbl)
	var xp_lbl := Label.new()
	xp_lbl.text = "%d / %d XP" % [xp, xp_next]
	xp_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	xp_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	if ThemeService: ThemeService.apply_label_style(xp_lbl, "body_small", "text_secondary")
	hbox.add_child(xp_lbl)
	var progress := ProgressBar.new()
	progress.max_value = xp_next; progress.value = xp
	progress.custom_minimum_size = Vector2(0, 8)
	progress.show_percentage = false
	# Purple fill, rounded – matches TitleSplash / Observation
	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color("#24242C")
	bg_style.corner_radius_top_left = 99; bg_style.corner_radius_top_right = 99
	bg_style.corner_radius_bottom_left = 99; bg_style.corner_radius_bottom_right = 99
	progress.add_theme_stylebox_override("background", bg_style)
	var fill_style := bg_style.duplicate()
	var primary := tokens.get("primary", Color("#6A3DFF")) if not tokens.is_empty() else Color("#6A3DFF")
	fill_style.bg_color = primary
	progress.add_theme_stylebox_override("fill", fill_style)
	vbox.add_child(progress)

func _refresh_stats() -> void:
	if not has_node("Margin/Scroll/VBox/StatsGrid"):
		return
	var grid: GridContainer = $Margin/Scroll/VBox/StatsGrid
	for child in grid.get_children(): child.queue_free()
	var stats: Dictionary = ProfileService.get_stats() if ProfileService else {}
	var stat_defs := [
		{"key": "observations_made", "label": "Observed", "color": Color("#7C5CFF")},
		{"key": "correct_observations", "label": "Correct", "color": Color("#2EE6A6")},
		{"key": "fastest_reaction_ms", "label": "Fastest", "color": Color("#5DA9E9"), "format": "%d ms"},
		{"key": "streak_best", "label": "Best Streak", "color": Color("#FFC84D")},
		{"key": "streak_current", "label": "Current Streak", "color": Color("#FF6B6B")},
	]
	for def in stat_defs:
		var k: String = def["key"]
		var v = stats.get(k, 0)
		if k == "fastest_reaction_ms" and int(v) == 9999:
			v = "--"
		var value_text := str(v)
		if def.has("format") and v is int:
			value_text = def["format"] % v
		var card = _create_stat_card(def["label"], value_text, def.get("color", Color.WHITE))
		grid.add_child(card)

func _create_stat_card(label_text: String, value_text: String, icon_color: Color) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 88)
	if ThemeService:
		_style_card(card, ThemeService.tokens)
	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_left", 14)
	m.add_theme_constant_override("margin_right", 14)
	m.add_theme_constant_override("margin_top", 14)
	m.add_theme_constant_override("margin_bottom", 14)
	card.add_child(m)
	var vbox := VBoxContainer.new()
	m.add_child(vbox)
	var val_lbl := Label.new()
	val_lbl.text = value_text
	if ThemeService:
		ThemeService.apply_label_style(val_lbl, "title", "text_primary")
	vbox.add_child(val_lbl)
	var lab_lbl := Label.new()
	lab_lbl.text = label_text
	lab_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if ThemeService:
		ThemeService.apply_label_style(lab_lbl, "label_small", "text_tertiary")
		lab_lbl.add_theme_color_override("font_color", icon_color)
	vbox.add_child(lab_lbl)
	return card

func _refresh_experience_progress() -> void:
	if not has_node("Margin/Scroll/VBox/ExperienceProgress"):
		return
	var vp: VBoxContainer = $Margin/Scroll/VBox/ExperienceProgress
	for child in vp.get_children(): child.queue_free()
	var challenges: Array[Dictionary] = []
	if ChallengeRegistry:
		challenges = ChallengeRegistry.get_all_challenges()
	var progress_dict: Dictionary = {}
	if ProfileService:
		progress_dict = ProfileService.profile.get("experiences_progress", {})
	if challenges.is_empty():
		var empty := Label.new()
		empty.text = "Play a round to begin tracking your challenge history."
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if ThemeService: ThemeService.apply_label_style(empty, "body_small", "text_secondary")
		vp.add_child(empty)
		return
	var tokens := _get_tokens()
	for challenge in challenges:
		var challenge_id: String = challenge.get("id", "")
		var prog: Dictionary = progress_dict.get(challenge_id, {"played":0, "best_score":0})
		# Card wrapper – premium
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(0, 56)
		if not tokens.is_empty():
			_style_card(card, tokens)
		vp.add_child(card)
		var m := MarginContainer.new()
		m.add_theme_constant_override("margin_left", 14); m.add_theme_constant_override("margin_right", 14)
		m.add_theme_constant_override("margin_top", 12); m.add_theme_constant_override("margin_bottom", 12)
		card.add_child(m)
		var row := HBoxContainer.new()
		row.set("theme_override_constants/separation", 12)
		m.add_child(row)
		var title_lbl := Label.new()
		title_lbl.text = challenge.get("title", challenge_id)
		title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if ThemeService: ThemeService.apply_label_style(title_lbl, "body", "text_primary")
		row.add_child(title_lbl)
		var played_lbl := Label.new()
		played_lbl.text = "%d plays" % prog.get("played", 0)
		if ThemeService: ThemeService.apply_label_style(played_lbl, "label_small", "text_secondary")
		row.add_child(played_lbl)
		var best_lbl := Label.new()
		best_lbl.text = "Best %d" % prog.get("best_score", 0)
		if ThemeService: ThemeService.apply_label_style(best_lbl, "label_small", "text_tertiary")
		row.add_child(best_lbl)

func on_navigated_to(_params: Dictionary) -> void:
	_refresh()

func _on_profile_updated(_field: String, _value: Variant) -> void:
	_refresh()

func _on_stats_updated(_stats: Dictionary) -> void:
	_refresh_stats()

func _on_theme_changed(_theme: String, _tokens: Dictionary) -> void:
	_apply_theme()
	_refresh()

func _on_registry_updated(_challenges: Array) -> void:
	_refresh_experience_progress()

func _on_reset_pressed() -> void:
	if ProfileService:
		ProfileService.reset_profile()
	_refresh()
	if AudioService:
		AudioService.play_ui("ui_click")
