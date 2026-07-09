extends Control
## ProfileScreen - Player progress, stats, polished placeholder

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

func _ensure_ui() -> void:
	if has_node("Margin/Scroll/VBox"):
		_wire_actions()
		return

	var margin := MarginContainer.new()
	margin.name = "Margin"
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 80)
	margin.add_theme_constant_override("margin_bottom", 90)
	add_child(margin)

	var s := ScrollContainer.new()
	s.name = "Scroll"
	margin.add_child(s)

	var vb := VBoxContainer.new()
	vb.name = "VBox"
	vb.add_theme_constant_override("separation", 20)
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.add_child(vb)

	# Avatar card
	var avatar_card := _create_avatar_card()
	vb.add_child(avatar_card)

	# Level card
	var level_card := PanelContainer.new()
	level_card.name = "LevelCard"
	level_card.custom_minimum_size = Vector2(0, 100)
	vb.add_child(level_card)

	# Stats grid
	var stats_grid := GridContainer.new()
	stats_grid.name = "StatsGrid"
	stats_grid.columns = 2
	stats_grid.add_theme_constant_override("h_separation", 12)
	stats_grid.add_theme_constant_override("v_separation", 12)
	vb.add_child(stats_grid)

	# Experiences progress
	var exp_label := Label.new()
	exp_label.text = "Progress"
	exp_label.add_theme_font_size_override("font_size", 18)
	vb.add_child(exp_label)

	var exp_vbox := VBoxContainer.new()
	exp_vbox.name = "ExperienceProgress"
	vb.add_child(exp_vbox)

	# Actions
	var reset_btn := Button.new()
	reset_btn.name = "ResetButton"
	reset_btn.text = "Reset Profile (Debug)"
	reset_btn.custom_minimum_size = Vector2(0, 44)
	vb.add_child(reset_btn)
	reset_btn.pressed.connect(_on_reset_pressed)

	scroll = s
	vbox = vb

func _wire_actions() -> void:
	if has_node("Margin/Scroll/VBox/ResetButton"):
		var btn: Button = $Margin/Scroll/VBox/ResetButton
		if not btn.pressed.is_connected(_on_reset_pressed):
			btn.pressed.connect(_on_reset_pressed)

func _create_avatar_card() -> Control:
	var card := PanelContainer.new()
	card.name = "AvatarCard"
	card.custom_minimum_size = Vector2(0, 120)

	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_left", 16)
	m.add_theme_constant_override("margin_right", 16)
	m.add_theme_constant_override("margin_top", 16)
	m.add_theme_constant_override("margin_bottom", 16)
	card.add_child(m)

	var hbox := HBoxContainer.new()
	m.add_child(hbox)

	var icon_wrap := PanelContainer.new()
	icon_wrap.custom_minimum_size = Vector2(64,64)
	hbox.add_child(icon_wrap)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)

	var name_lbl := Label.new()
	name_lbl.name = "NameLabel"
	name_lbl.text = "Witness"
	name_lbl.add_theme_font_size_override("font_size", 20)
	vbox.add_child(name_lbl)

	var id_lbl := Label.new()
	id_lbl.name = "IdLabel"
	id_lbl.text = "ID: witness_..."
	id_lbl.add_theme_font_size_override("font_size", 12)
	vbox.add_child(id_lbl)

	var since_lbl := Label.new()
	since_lbl.name = "SinceLabel"
	since_lbl.text = "Since today"
	since_lbl.add_theme_font_size_override("font_size", 11)
	vbox.add_child(since_lbl)

	return card

func _apply_theme() -> void:
	if not ThemeService:
		return
	var tokens = ThemeService.tokens
	if has_node("Margin/Scroll/VBox"):
		for child in $Margin/Scroll/VBox.get_children():
			if child is PanelContainer:
				var style := StyleBoxFlat.new()
				style.bg_color = tokens.get("surface", Color("#1E1E26"))
				style.corner_radius_top_left = tokens.get("radius_lg", 20)
				style.corner_radius_top_right = tokens.get("radius_lg", 20)
				style.corner_radius_bottom_left = tokens.get("radius_lg", 20)
				style.corner_radius_bottom_right = tokens.get("radius_lg", 20)
				style.border_color = tokens.get("border", Color("#2E2E3A"))
				style.border_width_left = 1
				style.border_width_right = 1
				style.border_width_top = 1
				style.border_width_bottom = 1
				child.add_theme_stylebox_override("panel", style)

func _refresh() -> void:
	if not ProfileService:
		return
	var profile: Dictionary = ProfileService.profile

	# Avatar
	var avatar_path := "Margin/Scroll/VBox/AvatarCard/Margin/HBox/VBox"
	if has_node("%s/NameLabel" % avatar_path):
		var avatar_vbox := get_node(avatar_path)
		avatar_vbox.get_node("NameLabel").text = profile.get("display_name", "Witness")
		avatar_vbox.get_node("IdLabel").text = "ID: %s" % profile.get("id", "---")
		var created_at: String = profile.get("created_at", "")
		var total_sessions: int = profile.get("total_sessions", 0)
		avatar_vbox.get_node("SinceLabel").text = "Member since %s - %d sessions" % [
			created_at,
			total_sessions
		]
	elif has_node("Margin/Scroll/VBox/AvatarCard"):
		# Programmatic fallback wire?
		pass

	# Level
	_refresh_level_card()

	# Stats
	_refresh_stats()

	# Challenge progress
	if has_node("Margin/Scroll/VBox/ProgressHeader"):
		$Margin/Scroll/VBox/ProgressHeader.text = "Challenge Progress"
	_refresh_experience_progress()

func _refresh_level_card() -> void:
	if not has_node("Margin/Scroll/VBox/LevelCard"):
		return
	var card: PanelContainer = $Margin/Scroll/VBox/LevelCard

	# Clear children
	for child in card.get_children():
		child.queue_free()

	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_left", 16)
	m.add_theme_constant_override("margin_right", 16)
	m.add_theme_constant_override("margin_top", 16)
	m.add_theme_constant_override("margin_bottom", 16)
	card.add_child(m)

	var vbox := VBoxContainer.new()
	m.add_child(vbox)

	var profile: Dictionary = ProfileService.profile if ProfileService else {}
	var level: int = profile.get("level", 1)
	var xp: int = profile.get("xp", 0)
	var xp_next: int = profile.get("xp_to_next", 100)

	var level_hbox := HBoxContainer.new()
	vbox.add_child(level_hbox)

	var lvl_lbl := Label.new()
	lvl_lbl.text = "Level %d" % level
	lvl_lbl.add_theme_font_size_override("font_size", 20)
	level_hbox.add_child(lvl_lbl)

	var xp_lbl := Label.new()
	xp_lbl.text = "%d / %d XP" % [xp, xp_next]
	xp_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	xp_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	level_hbox.add_child(xp_lbl)

	var progress := ProgressBar.new()
	progress.max_value = xp_next
	progress.value = xp
	progress.custom_minimum_size = Vector2(0, 8)
	progress.show_percentage = false
	vbox.add_child(progress)

func _refresh_stats() -> void:
	if not has_node("Margin/Scroll/VBox/StatsGrid"):
		return
	var grid: GridContainer = $Margin/Scroll/VBox/StatsGrid
	for child in grid.get_children():
		child.queue_free()

	var stats: Dictionary = ProfileService.get_stats() if ProfileService else {}

	var stat_defs := [
		{"key": "observations_made", "label": "Observed", "icon": "OBS"},
		{"key": "correct_observations", "label": "Correct", "icon": "OK"},
		{"key": "fastest_reaction_ms", "label": "Fastest", "icon": "MS", "format": "%d ms"},
		{"key": "streak_best", "label": "Best Streak", "icon": "BEST"},
		{"key": "streak_current", "label": "Current Streak", "icon": "NOW"},
	]

	for def in stat_defs:
		var k: String = def["key"]
		var v = stats.get(k, 0)
		if k == "fastest_reaction_ms" and int(v) == 9999:
			v = "--"

		var value_text := str(v)
		if def.has("format") and v is int:
			value_text = def["format"] % v

		var card = _create_stat_card(def["label"], value_text, def.get("icon", ""))
		grid.add_child(card)

func _create_stat_card(label: String, value: String, icon: String) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 80)

	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_left", 12)
	m.add_theme_constant_override("margin_right", 12)
	m.add_theme_constant_override("margin_top", 12)
	m.add_theme_constant_override("margin_bottom", 12)
	card.add_child(m)

	var vbox := VBoxContainer.new()
	m.add_child(vbox)

	var top_hbox := HBoxContainer.new()
	vbox.add_child(top_hbox)
	var icon_lbl := Label.new()
	icon_lbl.text = icon
	top_hbox.add_child(icon_lbl)
	var val_lbl := Label.new()
	val_lbl.text = value
	val_lbl.add_theme_font_size_override("font_size", 18)
	top_hbox.add_child(val_lbl)

	var lab_lbl := Label.new()
	lab_lbl.text = label
	lab_lbl.add_theme_font_size_override("font_size", 11)
	vbox.add_child(lab_lbl)

	return card

func _refresh_experience_progress() -> void:
	if not has_node("Margin/Scroll/VBox/ExperienceProgress"):
		return
	var vp: VBoxContainer = $Margin/Scroll/VBox/ExperienceProgress
	for child in vp.get_children():
		child.queue_free()

	var challenges: Array[Dictionary] = []
	if ChallengeRegistry:
		challenges = ChallengeRegistry.get_all_challenges()

	var progress_dict: Dictionary = {}
	if ProfileService:
		progress_dict = ProfileService.profile.get("experiences_progress", {})

	if challenges.is_empty():
		var empty := Label.new()
		empty.text = "Play a round to begin tracking your challenge history."
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD
		vp.add_child(empty)
		return

	for challenge in challenges:
		var challenge_id: String = challenge.get("id", "")
		var prog: Dictionary = progress_dict.get(challenge_id, {"played": 0, "best_score": 0})

		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 50)
		vp.add_child(row)

		var title_lbl := Label.new()
		title_lbl.text = challenge.get("title", challenge_id)
		title_lbl.custom_minimum_size = Vector2(120, 0)
		row.add_child(title_lbl)

		var played_lbl := Label.new()
		played_lbl.text = "Played %d" % prog.get("played", 0)
		played_lbl.add_theme_font_size_override("font_size", 12)
		row.add_child(played_lbl)

		var best_lbl := Label.new()
		best_lbl.text = "Best: %d" % prog.get("best_score", 0)
		best_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		best_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		best_lbl.add_theme_font_size_override("font_size", 12)
		row.add_child(best_lbl)

func on_navigated_to(_params: Dictionary) -> void:
	_refresh()
	# Screen-view analytics are centralized in NavigationService.navigate_to.

func _on_profile_updated(_field: String, _value: Variant) -> void:
	_refresh()

func _on_stats_updated(_stats: Dictionary) -> void:
	_refresh_stats()

func _on_theme_changed(_theme: String, _tokens: Dictionary) -> void:
	_apply_theme()

func _on_registry_updated(_challenges: Array) -> void:
	_refresh_experience_progress()

func _on_reset_pressed() -> void:
	if ProfileService:
		ProfileService.reset_profile()
	_refresh()
	if AudioService:
		AudioService.play_ui("ui_click")
