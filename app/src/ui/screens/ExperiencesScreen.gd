extends Control
## ExperiencesScreen - Actual playable challenge list

@onready var scroll: ScrollContainer = $Margin/Scroll
@onready var list_vbox: VBoxContainer = $Margin/Scroll/VBox

var _highlight_id: String = ""

func _ready() -> void:
	_ensure_ui()
	_apply_theme()
	_refresh_list()

	if ThemeService:
		ThemeService.theme_changed.connect(_on_theme_changed)
	if ChallengeRegistry:
		ChallengeRegistry.registry_updated.connect(_on_registry_updated)

func _ensure_ui() -> void:
	if has_node("Margin/Scroll/VBox/Header/Title"):
		$Margin/Scroll/VBox/Header/Title.text = "Play"
	if has_node("Margin/Scroll/VBox/Header/Subtitle"):
		var subtitle := "Choose any Two Second Witness challenge and jump straight into a round."
		$Margin/Scroll/VBox/Header/Subtitle.text = subtitle
	if has_node("Margin/Scroll/VBox/FilterRow"):
		$Margin/Scroll/VBox/FilterRow.visible = false

func _apply_theme() -> void:
	if not ThemeService:
		return
	# Header styling
	if has_node("Margin/Scroll/VBox/Header/Title"):
		var title_lbl: Label = $Margin/Scroll/VBox/Header/Title
		ThemeService.apply_label_style(title_lbl, "headline", "text_primary")
	if has_node("Margin/Scroll/VBox/Header/Subtitle"):
		var sub_lbl: Label = $Margin/Scroll/VBox/Header/Subtitle
		ThemeService.apply_label_style(sub_lbl, "body_small", "text_secondary")
		sub_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _refresh_list() -> void:
	if not has_node("Margin/Scroll/VBox"):
		return
	var vbox: VBoxContainer = $Margin/Scroll/VBox

	for child in vbox.get_children():
		var is_challenge_row := child.name.begins_with("Challenge_")
		var is_summary := child.name == "ChallengeSummary"
		var is_empty_state := child.name == "ChallengeEmpty"
		if is_challenge_row or is_summary or is_empty_state:
			vbox.remove_child(child)
			child.queue_free()

	var challenges: Array[Dictionary] = []
	if ChallengeRegistry:
		challenges = ChallengeRegistry.get_all_challenges()
	if challenges.is_empty():
		var empty := Label.new()
		empty.name = "ChallengeEmpty"
		empty.text = "No challenges are available right now."
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if ThemeService:
			ThemeService.apply_label_style(empty, "body", "text_secondary")
		vbox.add_child(empty)
		return

	var summary := Label.new()
	summary.name = "ChallengeSummary"
	summary.text = "%d playable challenges" % challenges.size()
	if ThemeService:
		ThemeService.apply_label_style(summary, "label_small", "text_secondary")
	else:
		summary.add_theme_font_size_override("font_size", 14)
		summary.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8, 1.0))
	vbox.add_child(summary)
	vbox.move_child(summary, min(1, vbox.get_child_count() - 1))

	for challenge in challenges:
		var challenge_id: String = challenge.get("id", "")
		var card := _create_challenge_card(challenge)
		card.name = "Challenge_%s" % challenge_id
		vbox.add_child(card)

	if _highlight_id != "":
		call_deferred("_focus_highlighted")

func _create_challenge_card(challenge: Dictionary) -> Control:
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
	card.custom_minimum_size = Vector2(0, 200)
	if card.has_method("set_experience"):
		card.call("set_experience", challenge)
	if card.has_signal("experience_selected"):
		if not card.experience_selected.is_connected(_on_challenge_selected):
			card.experience_selected.connect(_on_challenge_selected)
	return card

func _focus_highlighted() -> void:
	if not has_node("Margin/Scroll/VBox"):
		return
	var target_name := "Challenge_%s" % _highlight_id
	if $Margin/Scroll/VBox.has_node(target_name):
		var target := $Margin/Scroll/VBox.get_node(target_name) as Control
		if target and scroll:
			scroll.scroll_vertical = int(target.position.y)

func on_navigated_to(params: Dictionary) -> void:
	_highlight_id = str(params.get("highlight", ""))
	_refresh_list()
	# Screen-view analytics are centralized in NavigationService.navigate_to.

func _on_challenge_selected(challenge_id: String) -> void:
	if ChallengeRegistry:
		ChallengeRegistry.start_run(challenge_id)

func _on_theme_changed(_theme: String, _tokens: Dictionary) -> void:
	_apply_theme()

func _on_registry_updated(_challenges: Array) -> void:
	_refresh_list()
