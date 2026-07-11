extends Control
## HomeScreen - Redesigned premium landing, UI only
## Maintains all existing gameplay / navigation functionality

@onready var scroll: ScrollContainer = $MainMargin/Scroll
@onready var content_vbox: VBoxContainer = $MainMargin/Scroll/Content

# Hero nodes
@onready var brand_label: Label = $MainMargin/Scroll/Content/Hero/BrandLabel
@onready var you_are_label: Label = $MainMargin/Scroll/Content/Hero/YouAreLabel
@onready var witness_label: Label = $MainMargin/Scroll/Content/Hero/WitnessLabel
@onready var eye_rect: TextureRect = $MainMargin/Scroll/Content/Hero/EyeWrap/Eye
@onready var tagline_label: Label = $MainMargin/Scroll/Content/Hero/Tagline

# Stats
@onready var stat_level_card: PanelContainer = $MainMargin/Scroll/Content/StatsRow/StatLevel
@onready var stat_xp_card: PanelContainer = $MainMargin/Scroll/Content/StatsRow/StatXP
@onready var stat_streak_card: PanelContainer = $MainMargin/Scroll/Content/StatsRow/StatStreak

# CTA
@onready var play_now_button: Button = $MainMargin/Scroll/Content/PlayNowButton

# Featured
@onready var featured_header: Label = $MainMargin/Scroll/Content/FeaturedHeader
@onready var featured_host: VBoxContainer = $MainMargin/Scroll/Content/FeaturedChallengeHost

func _ready() -> void:
	_apply_theme()
	_refresh_data()
	_wire_buttons()

	if ThemeService:
		ThemeService.theme_changed.connect(_on_theme_changed)
	if ProfileService:
		ProfileService.profile_updated.connect(_on_profile_updated)
	if ChallengeRegistry:
		ChallengeRegistry.registry_updated.connect(_on_registry_updated)

func _wire_buttons() -> void:
	if play_now_button and not play_now_button.pressed.is_connected(_on_quick_play):
		play_now_button.pressed.connect(_on_quick_play)

func _apply_theme() -> void:
	if not ThemeService:
		return
	var tokens := ThemeService.tokens
	if tokens.is_empty():
		return

	# Background
	var bg: ColorRect = get_node_or_null("Background")
	if bg:
		bg.color = tokens.get("background", Color("#0F0F12"))

	# Hero
	if brand_label:
		ThemeService.apply_label_style(brand_label, "label", "text_tertiary")
		brand_label.add_theme_font_size_override("font_size", 16)
		brand_label.add_theme_color_override("font_color", tokens.get("text_tertiary", Color.GRAY))
		# Letter spacing approx via upper case already
	if you_are_label:
		ThemeService.apply_label_style(you_are_label, "body", "text_secondary")
	if witness_label:
		ThemeService.apply_label_style(witness_label, "display", "text_primary")
		witness_label.add_theme_font_size_override("font_size", 42)
	if tagline_label:
		ThemeService.apply_label_style(tagline_label, "body_small", "text_secondary")
		tagline_label.add_theme_color_override("font_color", tokens.get("text_secondary", Color.GRAY))

	# Stats
	_style_stat_cards(tokens)

	# Play Now
	_style_play_now(tokens)

	# Featured header
	if featured_header:
		ThemeService.apply_label_style(featured_header, "label_small", "text_tertiary")
		featured_header.text = "FEATURED CHALLENGE"

func _style_stat_cards(tokens: Dictionary) -> void:
	var cards = [stat_level_card, stat_xp_card, stat_streak_card]
	for card in cards:
		if not card: continue
		var sb := StyleBoxFlat.new()
		sb.bg_color = tokens.get("surface", Color("#1E1E26"))
		var r := tokens.get("radius_lg", 16)
		sb.corner_radius_top_left = r
		sb.corner_radius_top_right = r
		sb.corner_radius_bottom_left = r
		sb.corner_radius_bottom_right = r
		sb.border_color = tokens.get("border", Color("#2E2E3A"))
		sb.border_width_left = 1
		sb.border_width_top = 1
		sb.border_width_right = 1
		sb.border_width_bottom = 1
		card.add_theme_stylebox_override("panel", sb)

	# Level
	_style_stat_text(stat_level_card, "LEVEL", tokens, Color("#7C5CFF"))
	# XP
	_style_stat_text(stat_xp_card, "XP", tokens, Color("#5DA9E9"))
	# Streak
	_style_stat_text(stat_streak_card, "STREAK", tokens, Color("#FF6B6B"))

func _style_stat_text(card: PanelContainer, label_upper: String, tokens: Dictionary, icon_color: Color) -> void:
	if not card: return
	var label_node := card.get_node_or_null("Margin/HBox/TextVBox/Label") as Label
	var value_node := card.get_node_or_null("Margin/HBox/TextVBox/Value") as Label
	var icon_node := card.get_node_or_null("Margin/HBox/Icon") as Label
	if label_node:
		ThemeService.apply_label_style(label_node, "label_small", "text_tertiary")
		label_node.text = label_upper
	if value_node:
		ThemeService.apply_label_style(value_node, "title", "text_primary")
	if icon_node:
		icon_node.add_theme_color_override("font_color", icon_color)
		icon_node.add_theme_font_size_override("font_size", 20)

	# Streak best label subtle
	var best := card.get_node_or_null("Margin/HBox/TextVBox/BestLabel") as Label
	if best:
		ThemeService.apply_label_style(best, "label_small", "text_tertiary")
		best.add_theme_font_size_override("font_size", 11)

func _style_play_now(tokens: Dictionary) -> void:
	if not play_now_button: return
	var primary: Color = tokens.get("primary", Color("#6A3DFF"))
	var radius: int = tokens.get("radius_lg", 18)
	var normal := StyleBoxFlat.new()
	normal.bg_color = primary
	normal.corner_radius_top_left = radius
	normal.corner_radius_top_right = radius
	normal.corner_radius_bottom_left = radius
	normal.corner_radius_bottom_right = radius
	normal.content_margin_left = 24
	normal.content_margin_right = 24
	normal.content_margin_top = 18
	normal.content_margin_bottom = 18

	var hover := normal.duplicate()
	hover.bg_color = tokens.get("primary_variant", Color("#8A68FF"))
	var pressed := normal.duplicate()
	pressed.bg_color = primary.darkened(0.15)

	play_now_button.add_theme_stylebox_override("normal", normal)
	play_now_button.add_theme_stylebox_override("hover", hover)
	play_now_button.add_theme_stylebox_override("pressed", pressed)
	play_now_button.add_theme_stylebox_override("focus", hover)
	play_now_button.add_theme_color_override("font_color", tokens.get("text_on_primary", Color.WHITE))
	play_now_button.add_theme_font_size_override("font_size", ThemeService.get_font_size("button"))
	play_now_button.text = "▶  PLAY NOW\nStart a New Round"
	play_now_button.alignment = HORIZONTAL_ALIGNMENT_CENTER

func _refresh_data() -> void:
	_refresh_stats_row()
	_refresh_featured_challenge()

func _refresh_stats_row() -> void:
	if not ProfileService:
		return
	var profile := ProfileService.profile
	var level: int = profile.get("level", 1)
	var xp: int = profile.get("xp", 0)
	var stats: Dictionary = profile.get("stats", {})
	var streak: int = stats.get("streak_current", 0)
	var best_streak: int = stats.get("streak_best", streak)

	_set_stat_value(stat_level_card, str(level))
	_set_stat_value(stat_xp_card, str(xp))
	_set_stat_value(stat_streak_card, str(streak))

	# Update best streak label if present
	if stat_streak_card:
		var best_lbl := stat_streak_card.get_node_or_null("Margin/HBox/TextVBox/BestLabel") as Label
		if best_lbl:
			best_lbl.text = "BEST: %d" % best_streak

func _set_stat_value(card: PanelContainer, value_str: String) -> void:
	if not card: return
	var value_node := card.get_node_or_null("Margin/HBox/TextVBox/Value") as Label
	if value_node:
		value_node.text = value_str

func _refresh_featured_challenge() -> void:
	if not featured_host:
		return
	# Clear old
	for child in featured_host.get_children():
		featured_host.remove_child(child)
		child.queue_free()

	var featured: Dictionary = ChallengeRegistry.get_featured_challenge() if ChallengeRegistry else {}
	if featured.is_empty():
		return

	var card := _create_featured_card(featured)
	card.name = "FeaturedChallengeCard"
	featured_host.add_child(card)

func _create_featured_card(challenge: Dictionary) -> Control:
	var card: Control = null
	var scene_path := "res://src/ui/components/ExperienceCard.tscn"
	if ResourceLoader.exists(scene_path):
		var scene := load(scene_path) as PackedScene
		if scene:
			card = scene.instantiate() as Control
	if card == null:
		var script = load("res://src/ui/components/ExperienceCard.gd")
		# ExperienceCard extends PanelContainer
		card = PanelContainer.new()
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
