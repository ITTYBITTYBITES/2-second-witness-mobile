extends Control
## HomeScreen - Main menu with direct access to playable challenges

@onready var scroll: ScrollContainer = $Margin/Scroll
@onready var content_vbox: VBoxContainer = $Margin/Scroll/VBox

func _ready() -> void:
	_ensure_ui()
	_apply_theme()
	_refresh_data()

	if ThemeService:
		ThemeService.theme_changed.connect(_on_theme_changed)
	if ProfileService:
		ProfileService.profile_updated.connect(_on_profile_updated)
	if ChallengeRegistry:
		ChallengeRegistry.registry_updated.connect(_on_registry_updated)

func _ensure_ui() -> void:
	if not has_node("MainMenuBackground"):
		var bg_path = "res://assets/backgrounds/main_menu_bg.png"
		if ResourceLoader.exists(bg_path):
			var bg_tex = load(bg_path) as Texture2D
			if bg_tex:
				var bg_rect := TextureRect.new()
				bg_rect.name = "MainMenuBackground"
				bg_rect.texture = bg_tex
				bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				bg_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
				bg_rect.layout_mode = 3
				bg_rect.anchors_preset = 15
				bg_rect.anchor_right = 1.0
				bg_rect.anchor_bottom = 1.0
				bg_rect.mouse_filter = 2
				bg_rect.modulate = Color(1, 1, 1, 0.6)
				add_child(bg_rect)
				move_child(bg_rect, 0)

	if has_node("Margin/Scroll/VBox/QuickPlayButton"):
		var btn: Button = $Margin/Scroll/VBox/QuickPlayButton
		btn.text = "Play Now"
		if not btn.pressed.is_connected(_on_quick_play):
			btn.pressed.connect(_on_quick_play)

	if has_node("Margin/Scroll/VBox/SectionLabel"):
		$Margin/Scroll/VBox/SectionLabel.text = "Featured Challenge"

func _apply_theme() -> void:
	if not ThemeService:
		return
	var tokens := ThemeService.tokens
	if tokens.is_empty():
		return
	# Keep decorative art subordinate to content in both color modes.
	var menu_background := get_node_or_null("MainMenuBackground") as TextureRect
	if menu_background:
		menu_background.modulate = Color(1, 1, 1, 0.18 if ThemeService.current_theme_name == "light" else 0.5)
	# Explicit editorial styling so the main menu reads as a consistent,
	# premium mobile layout instead of scattered default Godot sizing.
	_style_hero_card(tokens)
	_style_stat_cards(tokens)
	_style_quick_play(tokens)
	_style_section_label(tokens)
	# The featured challenge card owns its own styling via ExperienceCard.

func _editorial_panel_style(tokens: Dictionary, elevated: bool = false) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = tokens.get("surface_elevated" if elevated else "surface", Color("#1E1E26"))
	var radius: int = tokens.get("radius_lg", 20)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.border_color = tokens.get("border", Color("#2E2E3A"))
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	return style

func _style_hero_card(tokens: Dictionary) -> void:
	var card_path := "Margin/Scroll/VBox/HeroCard"
	if not has_node(card_path):
		return
	var card: PanelContainer = get_node(card_path)
	card.add_theme_stylebox_override("panel", _editorial_panel_style(tokens, true))
	if has_node("%s/Margin/VBox/Title" % card_path):
		var title: Label = get_node("%s/Margin/VBox/Title" % card_path)
		if ThemeService:
			ThemeService.apply_label_style(title, "headline", "text_primary")
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if has_node("%s/Margin/VBox/Subtitle" % card_path):
		var sub: Label = get_node("%s/Margin/VBox/Subtitle" % card_path)
		if ThemeService:
			ThemeService.apply_label_style(sub, "body_small", "text_secondary")
		sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _style_stat_cards(tokens: Dictionary) -> void:
	if not has_node("Margin/Scroll/VBox/StatsRow"):
		return
	for stat_card in $Margin/Scroll/VBox/StatsRow.get_children():
		if stat_card is PanelContainer:
			var panel_card: PanelContainer = stat_card
			panel_card.add_theme_stylebox_override(
				"panel", _editorial_panel_style(tokens, false)
			)
		if stat_card.has_node("Margin/VBox/Value"):
			var value_lbl: Label = stat_card.get_node("Margin/VBox/Value")
			if ThemeService:
				ThemeService.apply_label_style(value_lbl, "title", "text_primary")
			value_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if stat_card.has_node("Margin/VBox/Label"):
			var label_lbl: Label = stat_card.get_node("Margin/VBox/Label")
			if ThemeService:
				ThemeService.apply_label_style(label_lbl, "label_small", "text_tertiary")
			label_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _style_quick_play(tokens: Dictionary) -> void:
	if not has_node("Margin/Scroll/VBox/QuickPlayButton"):
		return
	var btn: Button = get_node("Margin/Scroll/VBox/QuickPlayButton")
	# Try to upgrade to AppButton for consistent styling
	var app_button_script = load("res://src/ui/components/AppButton.gd")
	if app_button_script and btn.get_script() != app_button_script:
		# Just style manually to match AppButton
		pass
	var radius: int = tokens.get("radius_md", 12)
	var primary_color: Color = tokens.get("primary", Color("#6A3DFF"))
	var normal := StyleBoxFlat.new()
	normal.bg_color = primary_color
	normal.corner_radius_top_left = radius
	normal.corner_radius_top_right = radius
	normal.corner_radius_bottom_left = radius
	normal.corner_radius_bottom_right = radius
	normal.content_margin_left = 24
	normal.content_margin_right = 24
	normal.content_margin_top = 16
	normal.content_margin_bottom = 16
	var hover := normal.duplicate()
	hover.bg_color = tokens.get("primary_variant", Color("#8A68FF"))
	var pressed := normal.duplicate()
	pressed.bg_color = primary_color.darkened(0.12)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", hover)
	btn.add_theme_color_override("font_color", tokens.get("text_on_primary", Color.WHITE))
	if ThemeService:
		btn.add_theme_font_size_override("font_size", ThemeService.get_font_size("button"))
	btn.custom_minimum_size.y = max(btn.custom_minimum_size.y, tokens.get("touch_target_min", 48))
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _style_section_label(tokens: Dictionary) -> void:
	if not has_node("Margin/Scroll/VBox/SectionLabel"):
		return
	var section: Label = get_node("Margin/Scroll/VBox/SectionLabel")
	if ThemeService:
		ThemeService.apply_label_style(section, "label", "primary_text")
	else:
		section.add_theme_color_override("font_color", tokens.get("primary", Color("#6A3DFF")))
		section.add_theme_font_size_override("font_size", 16)

func _refresh_data() -> void:
	if not has_node("Margin/Scroll/VBox"):
		return
	_refresh_stats_row()
	_refresh_featured_challenge()

func _refresh_stats_row() -> void:
	if not ProfileService or not has_node("Margin/Scroll/VBox/StatsRow"):
		return
	var profile := ProfileService.profile
	var level: int = profile.get("level", 1)
	var xp: int = profile.get("xp", 0)
	var stats: Dictionary = profile.get("stats", {})
	var streak: int = stats.get("streak_current", 0)
	_update_stat_card($Margin/Scroll/VBox/StatsRow/StatLevel, level, "Level")
	_update_stat_card($Margin/Scroll/VBox/StatsRow/StatXP, xp, "XP")
	_update_stat_card($Margin/Scroll/VBox/StatsRow/StatStreak, streak, "Streak")

func _update_stat_card(card: PanelContainer, value: Variant, label_text: String) -> void:
	if not card:
		return
	if card.has_node("Margin/VBox/Value"):
		card.get_node("Margin/VBox/Value").text = str(value)
	if card.has_node("Margin/VBox/Label"):
		card.get_node("Margin/VBox/Label").text = label_text

func _refresh_featured_challenge() -> void:
	if not has_node("Margin/Scroll/VBox"):
		return
	var vbox: VBoxContainer = $Margin/Scroll/VBox
	for child in vbox.get_children():
		if child.name == "FeaturedChallengeCard" or child.name == "ExperienceCardPlaceholder":
			vbox.remove_child(child)
			child.queue_free()

	var featured: Dictionary = ChallengeRegistry.get_featured_challenge() if ChallengeRegistry else {}
	if featured.is_empty():
		return

	var card := _create_featured_card(featured)
	card.name = "FeaturedChallengeCard"
	card.custom_minimum_size = Vector2(0, 200)
	vbox.add_child(card)
	var insert_index := 4
	if vbox.get_child_count() > insert_index:
		vbox.move_child(card, insert_index)

func _create_featured_card(challenge: Dictionary) -> Control:
	var card: Control = null
	var scene_path := "res://src/ui/components/ExperienceCard.tscn"
	if ResourceLoader.exists(scene_path):
		var scene := load(scene_path) as PackedScene
		if scene:
			card = scene.instantiate() as Control
	if card == null:
		var script = load("res://src/ui/components/ExperienceCard.gd")
		card = Control.new()
		if script:
			card.set_script(script)
	if card.has_method("set_experience"):
		card.call("set_experience", challenge)
	if card.has_signal("experience_selected"):
		if not card.experience_selected.is_connected(_on_challenge_selected):
			card.experience_selected.connect(_on_challenge_selected)
	return card

func on_navigated_to(_params: Dictionary) -> void:
	_refresh_data()
	# Screen-view analytics are centralized in NavigationService.navigate_to.

func _on_quick_play() -> void:
	if AccessibilityService:
		AccessibilityService.vibrate(30)
	if AudioService:
		AudioService.play_ui("ui_click")

	if ChallengeRegistry and ChallengeRegistry.count() > 0:
		ChallengeRegistry.start_run()
	elif NavigationService:
		NavigationService.navigate_to("experiences")

func _on_challenge_selected(challenge_id: String) -> void:
	if ChallengeRegistry:
		ChallengeRegistry.start_run(challenge_id)

func _on_theme_changed(_theme: String, _tokens: Dictionary) -> void:
	_apply_theme()

func _on_profile_updated(_field: String, _value: Variant) -> void:
	_refresh_data()

func _on_registry_updated(_challenges: Array) -> void:
	_refresh_featured_challenge()
