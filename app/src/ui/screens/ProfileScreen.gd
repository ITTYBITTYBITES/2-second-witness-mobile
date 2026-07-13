extends Control
## Witness Profile: observation record, history, mastery, and achievements.

@onready var name_label: Label = $Margin/Scroll/VBox/AvatarCard/Margin/HBox/Text/NameLabel
@onready var id_label: Label = $Margin/Scroll/VBox/AvatarCard/Margin/HBox/Text/IdLabel
@onready var since_label: Label = $Margin/Scroll/VBox/AvatarCard/Margin/HBox/Text/SinceLabel
@onready var level_card: PanelContainer = $Margin/Scroll/VBox/LevelCard
@onready var stats_grid: GridContainer = $Margin/Scroll/VBox/StatsGrid
@onready var family_mastery: VBoxContainer = $Margin/Scroll/VBox/ExperienceProgress
@onready var history_list: VBoxContainer = $Margin/Scroll/VBox/HistoryList
@onready var recently_played: VBoxContainer = $Margin/Scroll/VBox/RecentlyPlayed
@onready var favorites_list: VBoxContainer = $Margin/Scroll/VBox/FavoritesList
@onready var program_summary: VBoxContainer = $Margin/Scroll/VBox/ProgramSummary
@onready var achievement_card: PanelContainer = $Margin/Scroll/VBox/AchievementCard
@onready var achievement_summary: Label = $Margin/Scroll/VBox/AchievementCard/Margin/VBox/Summary
@onready var achievement_button: Button = $Margin/Scroll/VBox/AchievementCard/Margin/VBox/AchievementButton
@onready var collections_card: PanelContainer = $Margin/Scroll/VBox/CollectionsCard
@onready var reset_button: Button = $Margin/Scroll/VBox/ResetButton

var _refresh_pending: bool = false

func _ready() -> void:
	_apply_responsive_layout()
	if not resized.is_connected(_apply_responsive_layout):
		resized.connect(_apply_responsive_layout)
	if not achievement_button.pressed.is_connected(_on_achievements_pressed):
		achievement_button.pressed.connect(_on_achievements_pressed)
	reset_button.visible = OS.is_debug_build()
	if reset_button.visible and not reset_button.pressed.is_connected(_on_reset_pressed):
		reset_button.pressed.connect(_on_reset_pressed)
	_apply_theme()
	_refresh()
	if ThemeService and not ThemeService.theme_changed.is_connected(_on_theme_changed):
		ThemeService.theme_changed.connect(_on_theme_changed)
	if ProfileService and not ProfileService.profile_saved.is_connected(_on_profile_saved):
		ProfileService.profile_saved.connect(_on_profile_saved)
	if AchievementService and not AchievementService.achievement_progress_updated.is_connected(_on_achievement_progress_updated):
		AchievementService.achievement_progress_updated.connect(_on_achievement_progress_updated)
	if ChallengeFamilyRegistry:
		if not ChallengeFamilyRegistry.family_registered.is_connected(_on_family_changed):
			ChallengeFamilyRegistry.family_registered.connect(_on_family_changed)
		if not ChallengeFamilyRegistry.family_unregistered.is_connected(_on_family_changed):
			ChallengeFamilyRegistry.family_unregistered.connect(_on_family_changed)

func _apply_responsive_layout() -> void:
	ResponsiveLayout.apply_centered_margin($Margin)

func _apply_theme() -> void:
	var tokens: Dictionary = ThemeService.tokens if ThemeService else {}
	var background: ColorRect = get_node_or_null("Background") as ColorRect
	if background:
		background.color = tokens.get("background", Color("#0F0F12"))
	for card: PanelContainer in [
		$Margin/Scroll/VBox/AvatarCard,
		level_card,
		achievement_card,
		collections_card
	]:
		card.add_theme_stylebox_override("panel", _card_style(tokens))
	if ThemeService:
		ThemeService.apply_label_style(name_label, "title", "text_primary")
		ThemeService.apply_label_style(id_label, "caption", "text_secondary")
		ThemeService.apply_label_style(since_label, "caption", "text_tertiary")
		for path: String in [
			"Margin/Scroll/VBox/ObservationHeader",
			"Margin/Scroll/VBox/MasteryHeader",
			"Margin/Scroll/VBox/HistoryHeader",
			"Margin/Scroll/VBox/RecentlyPlayedHeader",
			"Margin/Scroll/VBox/FavoritesHeader",
			"Margin/Scroll/VBox/ProgramsHeader",
			"Margin/Scroll/VBox/AchievementsHeader",
			"Margin/Scroll/VBox/CollectionsHeader"
		]:
			ThemeService.apply_label_style(get_node(path) as Label, "label", "text_tertiary")
		ThemeService.apply_label_style(achievement_summary, "body_small", "text_secondary")
		ThemeService.apply_label_style($Margin/Scroll/VBox/CollectionsCard/Margin/VBox/Title, "title", "text_primary")
		ThemeService.apply_label_style($Margin/Scroll/VBox/CollectionsCard/Margin/VBox/Copy, "body_small", "text_secondary")
		ThemeService.apply_typography(achievement_button, "button")

func _refresh() -> void:
	if not ProfileService:
		return
	var profile: Dictionary = ProfileService.profile
	name_label.text = str(profile.get("display_name", "Witness"))
	id_label.text = "Witness ID · %s" % str(profile.get("id", "---"))
	since_label.text = "Member since %s · %d sessions" % [
		str(profile.get("created_at", "")),
		int(profile.get("total_sessions", 0))
	]
	_refresh_level()
	_refresh_observation_record()
	_refresh_family_mastery()
	_refresh_history()
	_refresh_recently_played()
	_refresh_favorites()
	_refresh_program_summary()
	_refresh_achievement_summary()
	_refresh_collections()

func _refresh_level() -> void:
	for child: Node in level_card.get_children():
		child.queue_free()
	var record: Dictionary = PlayerProgressService.get_observation_record() if PlayerProgressService else {}
	var total_progress: int = int(record.get("total_progress", 0))
	var margin := _margin(16)
	level_card.add_child(margin)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 8)
	margin.add_child(stack)
	var row := HBoxContainer.new()
	stack.add_child(row)
	var title := Label.new()
	title.text = "Witness Level %d" % int(record.get("witness_level", 1))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if ThemeService:
		ThemeService.apply_label_style(title, "title", "text_primary")
	row.add_child(title)
	var rank := Label.new()
	rank.text = str(record.get("witness_rank", "Observer"))
	if ThemeService:
		ThemeService.apply_label_style(rank, "label", "primary_variant")
	rank.autowrap_mode = TextServer.AUTOWRAP_OFF
	rank.custom_minimum_size.x = 140.0
	rank.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(rank)
	var progress_copy := Label.new()
	var next_rank: String = str(record.get("next_rank", "Top Rank"))
	var next_rank_level: int = int(record.get("next_rank_level", int(record.get("witness_level", 1))))
	progress_copy.text = (
		"%d total progress · %d / 100 to next level · Next rank: %s at Level %d"
		% [total_progress, total_progress % 100, next_rank, next_rank_level]
		if next_rank != "Top Rank"
		else "%d total progress · Top Witness Rank reached" % total_progress
	)
	if ThemeService:
		ThemeService.apply_label_style(progress_copy, "caption", "text_secondary")
	stack.add_child(progress_copy)
	var bar := ProgressBar.new()
	bar.max_value = 100.0
	bar.value = float(total_progress % 100)
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 8)
	stack.add_child(bar)

func _refresh_observation_record() -> void:
	for child: Node in stats_grid.get_children():
		child.queue_free()
	var record: Dictionary = PlayerProgressService.get_observation_record() if PlayerProgressService else {}
	var fastest: int = int(record.get("fastest_response_ms", -1))
	var definitions: Array[Dictionary] = [
		{"label": "Challenges Completed", "value": str(record.get("total_plays", 0))},
		{"label": "Accuracy", "value": "%d%%" % int(round(float(record.get("accuracy", 0.0)) * 100.0))},
		{"label": "Fastest Response", "value": "%d ms" % fastest if fastest >= 0 else "—"},
		{"label": "Current Streak", "value": str(record.get("current_streak", 0))},
		{"label": "Best Streak", "value": str(record.get("best_streak", 0))}
	]
	for definition: Dictionary in definitions:
		stats_grid.add_child(_stat_card(
			str(definition.get("label", "Stat")),
			str(definition.get("value", "0"))
		))

func _refresh_family_mastery() -> void:
	for child: Node in family_mastery.get_children():
		child.queue_free()
	var player_state: Dictionary = PlayerProgressService.get_player_state() if PlayerProgressService else {}
	var challenge_types: Array[Dictionary] = (
		RecommendationService.get_available_challenge_types(player_state)
		if RecommendationService
		else []
	)
	if challenge_types.is_empty():
		family_mastery.add_child(_empty_label("Challenge Type Mastery will appear here."))
		return
	for challenge_type: Dictionary in challenge_types:
		family_mastery.add_child(_mastery_card(challenge_type))

func _mastery_card(challenge_type: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _card_style(ThemeService.tokens if ThemeService else {}))
	var margin := _margin(14)
	card.add_child(margin)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 7)
	margin.add_child(stack)
	var progress: Dictionary = challenge_type.get("progress", {})
	var row := HBoxContainer.new()
	stack.add_child(row)
	var title := Label.new()
	title.text = str(challenge_type.get("title", "Challenge Type"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if ThemeService:
		ThemeService.apply_label_style(title, "label", "text_primary")
	row.add_child(title)
	var mastery := Label.new()
	mastery.text = "Mastery %d%%" % int(round(float(progress.get("mastery", 0.0))))
	if ThemeService:
		ThemeService.apply_label_style(mastery, "label_small", "primary_variant")
	mastery.autowrap_mode = TextServer.AUTOWRAP_OFF
	mastery.custom_minimum_size.x = 120.0
	mastery.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(mastery)
	var bar := ProgressBar.new()
	bar.max_value = 100.0
	bar.value = float(progress.get("mastery", 0.0))
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 7)
	stack.add_child(bar)
	var detail := Label.new()
	detail.text = "%d rounds · %d%% accuracy · best streak %d" % [
		int(progress.get("plays", 0)),
		int(round(float(progress.get("accuracy", 0.0)) * 100.0)),
		int(progress.get("best_streak", 0))
	]
	if ThemeService:
		ThemeService.apply_label_style(detail, "caption", "text_secondary")
	stack.add_child(detail)
	return card

func _refresh_history() -> void:
	for child: Node in history_list.get_children():
		child.queue_free()
	var history: Array[Dictionary] = PlayerProgressService.get_recent_history(8) if PlayerProgressService else []
	if history.is_empty():
		history_list.add_child(_empty_label("Complete a round to begin your Challenge History."))
		return
	for entry: Dictionary in history:
		history_list.add_child(_history_row(entry))

func _history_row(entry: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _card_style(ThemeService.tokens if ThemeService else {}))
	var margin := _margin(12)
	card.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	margin.add_child(row)
	var title := Label.new()
	title.text = "%s · %s" % [
		str(entry.get("family_title", "Challenge")),
		str(entry.get("template_id", "Round")).replace("_", " ").capitalize()
	]
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if ThemeService:
		ThemeService.apply_label_style(title, "body_small", "text_primary")
	row.add_child(title)
	var outcome := Label.new()
	outcome.text = "Correct" if str(entry.get("outcome", "")) == "correct" else "I missed it."
	if ThemeService:
		ThemeService.apply_label_style(
			outcome,
			"label_small",
			"success" if str(entry.get("outcome", "")) == "correct" else "text_secondary"
		)
	outcome.autowrap_mode = TextServer.AUTOWRAP_OFF
	outcome.custom_minimum_size.x = 88.0
	outcome.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(outcome)
	return card

func _refresh_recently_played() -> void:
	for child: Node in recently_played.get_children():
		child.queue_free()
	var recent: Array[Dictionary] = PlayerProgressService.get_recent_family_summaries(5) if PlayerProgressService else []
	if recent.is_empty():
		recently_played.add_child(_empty_label("Your latest Challenge Types will appear here."))
		return
	for item: Dictionary in recent:
		var outcome: String = "Correct" if str(item.get("outcome", "")) == "correct" else "I missed it."
		recently_played.add_child(_simple_record_card(
			str(item.get("family_title", "Challenge Type")),
			"%s · %s" % [outcome, str(item.get("timestamp", ""))]
		))

func _refresh_favorites() -> void:
	for child: Node in favorites_list.get_children():
		child.queue_free()
	var player_state: Dictionary = PlayerProgressService.get_player_state() if PlayerProgressService else {}
	var catalog: Array[Dictionary] = RecommendationService.get_available_challenge_types(player_state) if RecommendationService else []
	var found: bool = false
	for item: Dictionary in catalog:
		if not bool(item.get("favorite", false)):
			continue
		found = true
		var progress: Dictionary = item.get("progress", {})
		favorites_list.add_child(_simple_record_card(
			"★ %s" % str(item.get("title", "Challenge Type")),
			"%d rounds · %d%% accuracy · Mastery %d%%" % [
				int(progress.get("plays", 0)),
				int(round(float(progress.get("accuracy", 0.0)) * 100.0)),
				int(round(float(progress.get("mastery", 0.0))))
			]
		))
	if not found:
		favorites_list.add_child(_empty_label("Mark favorites in the Challenge Library to build a Favorites Run."))

func _refresh_program_summary() -> void:
	for child: Node in program_summary.get_children():
		child.queue_free()
	if not ProgramService:
		return
	var player_state: Dictionary = PlayerProgressService.get_player_state() if PlayerProgressService else {}
	var shown: bool = false
	for program: Dictionary in ProgramService.get_programs(player_state):
		var progress: Dictionary = program.get("progress", {})
		if int(progress.get("rounds_completed", 0)) == 0 and int(progress.get("current_run_round", 0)) == 0:
			continue
		shown = true
		program_summary.add_child(_simple_record_card(
			str(program.get("title", "Program")),
			"%d rounds · %d completed runs · %d%% accuracy" % [
				int(progress.get("rounds_completed", 0)),
				int(progress.get("completed_runs", 0)),
				int(round(float(progress.get("accuracy", 0.0)) * 100.0))
			]
		))
	if not shown:
		program_summary.add_child(_empty_label("Complete curated runs to build your Program Record."))

func _refresh_collections() -> void:
	var title: Label = $Margin/Scroll/VBox/CollectionsCard/Margin/VBox/Title
	var copy: Label = $Margin/Scroll/VBox/CollectionsCard/Margin/VBox/Copy
	var player_state: Dictionary = PlayerProgressService.get_player_state() if PlayerProgressService else {}
	var catalog: Array[Dictionary] = RecommendationService.get_available_challenge_types(player_state) if RecommendationService else []
	var discovered: int = 0
	for item: Dictionary in catalog:
		if int((item.get("progress", {}) as Dictionary).get("plays", 0)) > 0:
			discovered += 1
	var achievements_unlocked: int = AchievementService.get_unlocked_count() if AchievementService else 0
	var achievement_total: int = AchievementService.get_definitions().size() if AchievementService else 0
	var completed_runs: int = ProgramService.get_completed_run_count() if ProgramService else 0
	var collection_ratio := float(discovered + achievements_unlocked) / maxf(float(catalog.size() + achievement_total), 1.0)
	var collection_stack: VBoxContainer = $Margin/Scroll/VBox/CollectionsCard/Margin/VBox
	var collection_bar := collection_stack.get_node_or_null("CollectionBar") as ProgressBar
	if collection_bar == null:
		collection_bar = ProgressBar.new()
		collection_bar.name = "CollectionBar"
		collection_bar.max_value = 100.0
		collection_bar.show_percentage = false
		collection_bar.custom_minimum_size = Vector2(0, 8)
		collection_stack.add_child(collection_bar)
	collection_bar.value = collection_ratio * 100.0
	var next_goal := "Complete a round to begin your collection."
	for item: Dictionary in catalog:
		if int((item.get("progress", {}) as Dictionary).get("plays", 0)) == 0:
			next_goal = "Next: discover %s." % str(item.get("title", "a Challenge Type"))
			break
	if discovered == catalog.size() and AchievementService:
		for status: Dictionary in AchievementService.get_featured_statuses(1):
			next_goal = "Next: %s · %d / %d." % [
				str(status.get("title", "Milestone")),
				int(status.get("current", 0)),
				int(status.get("target", 1))
			]
	title.text = "COLLECTION PROGRESS · %d%%" % int(round(collection_ratio * 100.0))
	copy.text = "Challenge Types discovered: %d / %d\nAchievements collected: %d / %d\nCurated runs completed: %d\n%s" % [
		discovered,
		catalog.size(),
		achievements_unlocked,
		achievement_total,
		completed_runs,
		next_goal
	]

func _simple_record_card(title_text: String, detail_text: String) -> Control:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _card_style(ThemeService.tokens if ThemeService else {}))
	var margin := _margin(12)
	card.add_child(margin)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 4)
	margin.add_child(stack)
	var title := Label.new()
	title.text = title_text
	if ThemeService:
		ThemeService.apply_label_style(title, "body_small", "text_primary")
	stack.add_child(title)
	var detail := Label.new()
	detail.text = detail_text
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if ThemeService:
		ThemeService.apply_label_style(detail, "caption", "text_secondary")
	stack.add_child(detail)
	return card

func _refresh_achievement_summary() -> void:
	var unlocked: int = AchievementService.get_unlocked_count() if AchievementService else 0
	var total: int = AchievementService.get_definitions().size() if AchievementService else 0
	achievement_summary.text = "%d of %d achievements unlocked" % [unlocked, total]

func _stat_card(label_text: String, value_text: String) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 88)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _card_style(ThemeService.tokens if ThemeService else {}))
	var margin := _margin(14)
	card.add_child(margin)
	var stack := VBoxContainer.new()
	margin.add_child(stack)
	var value := Label.new()
	value.text = value_text
	if ThemeService:
		ThemeService.apply_label_style(value, "title", "text_primary")
	stack.add_child(value)
	var label := Label.new()
	label.text = label_text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if ThemeService:
		ThemeService.apply_label_style(label, "label_small", "text_tertiary")
	stack.add_child(label)
	return card

func _empty_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if ThemeService:
		ThemeService.apply_label_style(label, "body_small", "text_secondary")
	return label

func _margin(amount: int) -> MarginContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", amount)
	margin.add_theme_constant_override("margin_right", amount)
	margin.add_theme_constant_override("margin_top", amount)
	margin.add_theme_constant_override("margin_bottom", amount)
	return margin

func _card_style(tokens: Dictionary) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = tokens.get("surface", Color("#1E1E26"))
	style.border_color = tokens.get("border", Color("#2E2E3A"))
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_left = 14
	style.corner_radius_bottom_right = 14
	return style

func on_navigated_to(_params: Dictionary) -> void:
	_refresh_pending = false
	_apply_responsive_layout()
	_apply_theme()
	_refresh()

func _on_achievements_pressed() -> void:
	if NavigationService:
		NavigationService.navigate_to("achievements")

func _on_reset_pressed() -> void:
	if ProfileService:
		ProfileService.reset_profile()
	if PlayerProgressService:
		PlayerProgressService.initialize()
	_refresh()

func _on_theme_changed(_theme_name: String, _tokens: Dictionary) -> void:
	if is_visible_in_tree():
		_apply_theme()
		_refresh()
	else:
		_refresh_pending = true

func _on_profile_saved(_profile: Dictionary) -> void:
	_request_refresh()

func _on_achievement_progress_updated(_statuses: Array[Dictionary]) -> void:
	_request_refresh()

func _on_family_changed(_family_id: String) -> void:
	_request_refresh()

func _request_refresh() -> void:
	if is_visible_in_tree():
		call_deferred("_refresh")
	else:
		_refresh_pending = true
