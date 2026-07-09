extends Control
## HomeScreen - Polished placeholder with brand identity

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
	if ExperienceRegistry:
		ExperienceRegistry.registry_updated.connect(_on_registry_updated)

func _ensure_ui() -> void:
	if has_node("Margin/Scroll/VBox"):
		# Wire actions
		if has_node("Margin/Scroll/VBox/QuickPlayButton"):
			var btn: Button = $Margin/Scroll/VBox/QuickPlayButton
			if not btn.pressed.is_connected(_on_quick_play):
				btn.pressed.connect(_on_quick_play)
		if has_node("Margin/Scroll/VBox/SectionExp/ExperienceCard"):
			var card = $Margin/Scroll/VBox/SectionExp/ExperienceCard
			if card.has_signal("experience_selected"):
				if not card.experience_selected.is_connected(_on_experience_selected):
					card.experience_selected.connect(_on_experience_selected)
		return
	
	# Build programmatically
	var margin := MarginContainer.new()
	margin.name = "Margin"
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 80)
	margin.add_theme_constant_override("margin_bottom", 90)
	add_child(margin)
	
	var scroll_container := ScrollContainer.new()
	scroll_container.name = "Scroll"
	scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(scroll_container)
	
	var vbox := VBoxContainer.new()
	vbox.name = "VBox"
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 20)
	scroll_container.add_child(vbox)
	
	var hero := _create_hero_card()
	vbox.add_child(hero)
	
	var qp_btn := Button.new()
	qp_btn.name = "QuickPlayButton"
	qp_btn.text = "Quick Play • 2 Seconds"
	qp_btn.custom_minimum_size = Vector2(0, 56)
	qp_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(qp_btn)
	qp_btn.pressed.connect(_on_quick_play)
	
	var section_label := Label.new()
	section_label.text = "Featured Experience"
	section_label.add_theme_font_size_override("font_size", 20)
	vbox.add_child(section_label)
	
	# Experience card placeholder (will be replaced via registry)
	var exp_card_placeholder := Control.new()
	exp_card_placeholder.name = "ExperienceCardPlaceholder"
	exp_card_placeholder.custom_minimum_size = Vector2(0, 180)
	vbox.add_child(exp_card_placeholder)
	
	scroll = scroll_container
	content_vbox = vbox

func _create_hero_card() -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 160)
	
	if ThemeService:
		var tokens := ThemeService.tokens
		var style := StyleBoxFlat.new()
		style.bg_color = tokens.get("primary", Color("#7C5CFF"))
		style.corner_radius_top_left = 24
		style.corner_radius_top_right = 24
		style.corner_radius_bottom_left = 24
		style.corner_radius_bottom_right = 24
		card.add_theme_stylebox_override("panel", style)
	
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	card.add_child(margin)
	
	var vbox := VBoxContainer.new()
	margin.add_child(vbox)
	
	var title := Label.new()
	title.text = "YOU ARE\nTHE WITNESS"
	title.add_theme_color_override("font_color", Color.WHITE)
	title.add_theme_font_size_override("font_size", 28)
	vbox.add_child(title)
	
	var sub := Label.new()
	sub.text = "Short, replayable tests of observation, memory & reaction"
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD
	sub.add_theme_color_override("font_color", Color(1,1,1,0.8))
	sub.add_theme_font_size_override("font_size", 14)
	vbox.add_child(sub)
	
	return card

func _apply_theme() -> void:
	if not ThemeService:
		return
	var tokens := ThemeService.tokens
	# Background handled by shell
	if has_node("Margin/Scroll/VBox"):
		for child in $Margin/Scroll/VBox.get_children():
			if child is PanelContainer and ThemeService:
				ThemeService.apply_theme_to_control(child)

func _refresh_data() -> void:
	if not has_node("Margin/Scroll/VBox"):
		return
	
	var vbox: VBoxContainer = $Margin/Scroll/VBox
	
	# Update streak / level display if exists
	if ProfileService:
		var profile := ProfileService.profile
		var level: int = profile.get("level", 1)
		var xp: int = profile.get("xp", 0)
		var stats: Dictionary = profile.get("stats", {})
		var streak: int = stats.get("streak_current", 0)
		
		# Find or create stats row
		var stats_row_name := "StatsRow"
		var stats_row: Control = null
		if vbox.has_node(stats_row_name):
			stats_row = vbox.get_node(stats_row_name)
		else:
			stats_row = _create_stats_row()
			stats_row.name = stats_row_name
			# Insert after hero (index 0, then stats)
			if vbox.get_child_count() >= 1:
				vbox.add_child(stats_row)
				vbox.move_child(stats_row, 1)
			else:
				vbox.add_child(stats_row)
		
		_update_stats_row(stats_row, level, xp, streak)
	
	# Featured experience
	_refresh_featured_experience()

func _create_stats_row() -> Control:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	
	for i in range(3):
		var card := PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.custom_minimum_size = Vector2(0, 80)
		var m := MarginContainer.new()
		m.add_theme_constant_override("margin_left", 12)
		m.add_theme_constant_override("margin_right", 12)
		m.add_theme_constant_override("margin_top", 12)
		m.add_theme_constant_override("margin_bottom", 12)
		card.add_child(m)
		var vb := VBoxContainer.new()
		m.add_child(vb)
		var val := Label.new()
		val.name = "Value"
		val.text = "--"
		val.add_theme_font_size_override("font_size", 20)
		vb.add_child(val)
		var lab := Label.new()
		lab.name = "Label"
		lab.text = "Stat"
		lab.add_theme_font_size_override("font_size", 11)
		vb.add_child(lab)
		hbox.add_child(card)
	
	return hbox

func _update_stats_row(row: Control, level: int, xp: int, streak: int) -> void:
	if not row is HBoxContainer:
		return
	var hbox := row as HBoxContainer
	if hbox.get_child_count() >= 3:
		var c0: PanelContainer = hbox.get_child(0)
		if c0.get_child(0).get_child(0).has_node("Value"):
			c0.get_child(0).get_child(0).get_node("Value").text = str(level)
			c0.get_child(0).get_child(0).get_node("Label").text = "Level"
		var c1: PanelContainer = hbox.get_child(1)
		if c1.get_child(0).get_child(0).has_node("Value"):
			c1.get_child(0).get_child(0).get_node("Value").text = str(xp)
			c1.get_child(0).get_child(0).get_node("Label").text = "XP"
		var c2: PanelContainer = hbox.get_child(2)
		if c2.get_child(0).get_child(0).has_node("Value"):
			c2.get_child(0).get_child(0).get_node("Value").text = str(streak)
			c2.get_child(0).get_child(0).get_node("Label").text = "Streak"

func _refresh_featured_experience() -> void:
	if not has_node("Margin/Scroll/VBox"):
		return
	var vbox: VBoxContainer = $Margin/Scroll/VBox
	
	# Remove old featured placeholder if any
	for child in vbox.get_children():
		if child.name == "FeaturedExperienceCard" or child.name == "ExperienceCardPlaceholder":
			vbox.remove_child(child)
			child.queue_free()
	
	# Create latest experience card from registry
	if ExperienceRegistry and ExperienceRegistry.count() > 0:
		var exps: Array = ExperienceRegistry.get_all_experiences()
		if exps.size() > 0:
			var featured: Dictionary = exps[0]
			var exp_card_script = load("res://src/ui/components/ExperienceCard.gd")
			var card := Control.new()
			if exp_card_script:
				card.set_script(exp_card_script)
			card.name = "FeaturedExperienceCard"
			card.custom_minimum_size = Vector2(0, 200)
			vbox.add_child(card)
			if card.has_method("set_experience"):
				card.call("set_experience", featured)
			if card.has_signal("experience_selected"):
				if not card.experience_selected.is_connected(_on_experience_selected):
					card.experience_selected.connect(_on_experience_selected)

func on_navigated_to(_params: Dictionary) -> void:
	_refresh_data()
	if AnalyticsService:
		AnalyticsService.log_screen_view("home")

func _on_quick_play() -> void:
	if AccessibilityService:
		AccessibilityService.vibrate(30)
	if AudioService:
		AudioService.play_ui("ui_click")
	
	if ExperienceRegistry:
		var unlocked := ExperienceRegistry.get_unlocked_experiences()
		if unlocked.size() > 0:
			var random_exp: Dictionary = unlocked[randi() % unlocked.size()]
			var exp_id: String = random_exp.get("id", "flashword")
			EventBus.publish_navigation("experiences", {"highlight": exp_id})
			if NavigationService:
				NavigationService.navigate_to("experiences", {"auto_play": exp_id})
		else:
			if NavigationService:
				NavigationService.navigate_to("experiences")
	else:
		if NavigationService:
			NavigationService.navigate_to("experiences")

func _on_experience_selected(exp_id: String) -> void:
	print("[HomeScreen] Experience selected %s" % exp_id)
	if NavigationService:
		NavigationService.navigate_to("experiences", {"highlight": exp_id, "auto_play": exp_id})

func _on_theme_changed(_theme: String, _tokens: Dictionary) -> void:
	_apply_theme()

func _on_profile_updated(_field: String, _value: Variant) -> void:
	_refresh_data()

func _on_registry_updated(_exps: Array) -> void:
	_refresh_featured_experience()
