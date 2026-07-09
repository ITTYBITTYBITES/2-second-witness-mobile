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
				bg_rect.stretch_mode = TextureRect.STRETCH_SCALE
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
		btn.text = "Play Now • Start a Round"
		if not btn.pressed.is_connected(_on_quick_play):
			btn.pressed.connect(_on_quick_play)

	if has_node("Margin/Scroll/VBox/SectionLabel"):
		$Margin/Scroll/VBox/SectionLabel.text = "Featured Challenge"

func _apply_theme() -> void:
	if not ThemeService:
		return
	if has_node("Margin/Scroll/VBox"):
		for child in $Margin/Scroll/VBox.get_children():
			if child is PanelContainer:
				ThemeService.apply_theme_to_control(child)

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
	if AnalyticsService:
		AnalyticsService.log_screen_view("home")

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
