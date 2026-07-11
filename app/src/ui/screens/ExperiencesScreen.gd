extends Control
## ExperiencesScreen – Challenge Selection
## Premium UI, matches Home / Boot / Tutorial
## Internally still "ExperiencesScreen" for stability – user-facing is "Challenges"

@onready var scroll: ScrollContainer = $MainMargin/Scroll
@onready var content_vbox: VBoxContainer = $MainMargin/Scroll/Content
@onready var brand_label: Label = $MainMargin/Scroll/Content/Header/BrandLabel
@onready var title_label: Label = $MainMargin/Scroll/Content/Header/TitleLabel
@onready var subtitle_label: Label = $MainMargin/Scroll/Content/Header/SubtitleLabel
@onready var count_label: Label = $MainMargin/Scroll/Content/CountLabel
@onready var challenge_list: VBoxContainer = $MainMargin/Scroll/Content/ChallengeList

var _highlight_id: String = ""

func _ready() -> void:
	_apply_theme()
	_refresh_list()
	if ThemeService:
		ThemeService.theme_changed.connect(_on_theme_changed)
	if ChallengeRegistry:
		ChallengeRegistry.registry_updated.connect(_on_registry_updated)

func _apply_theme() -> void:
	var tokens := ThemeService.tokens if ThemeService else {}
	var bg := get_node_or_null("Background") as ColorRect
	if bg:
		bg.color = tokens.get("background", Color("#0F0F12")) if not tokens.is_empty() else Color("#0F0F12")
	
	if brand_label:
		if ThemeService:
			ThemeService.apply_label_style(brand_label, "label", "text_tertiary")
			brand_label.add_theme_font_size_override("font_size", 14)
	if title_label:
		if ThemeService:
			ThemeService.apply_label_style(title_label, "display", "text_primary")
			title_label.add_theme_font_size_override("font_size", 36)
		title_label.text = "CHALLENGES"
	if subtitle_label:
		if ThemeService:
			ThemeService.apply_label_style(subtitle_label, "body_small", "text_secondary")
		subtitle_label.text = "Pick a scenario. Test your observation."
	if count_label:
		if ThemeService:
			ThemeService.apply_label_style(count_label, "label_small", "text_tertiary")
		count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _refresh_list() -> void:
	if not challenge_list:
		return
	# Clear existing challenge cards
	for child in challenge_list.get_children():
		challenge_list.remove_child(child)
		child.queue_free()
	
	var challenges: Array[Dictionary] = []
	if ChallengeRegistry:
		challenges = ChallengeRegistry.get_all_challenges()
	
	# Update count
	if count_label:
		var n := challenges.size()
		count_label.text = "%d playable challenge%s" % [n, "" if n == 1 else "s"]
		count_label.visible = n > 0
	
	if challenges.is_empty():
		var empty := Label.new()
		empty.name = "ChallengeEmpty"
		empty.text = "No challenges are available right now."
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if ThemeService:
			ThemeService.apply_label_style(empty, "body", "text_secondary")
		challenge_list.add_child(empty)
		return
	
	for challenge in challenges:
		var challenge_id: String = challenge.get("id", "")
		var card := _create_challenge_card(challenge)
		card.name = "Challenge_%s" % challenge_id
		challenge_list.add_child(card)
	
	if _highlight_id != "":
		call_deferred("_focus_highlighted")

func _create_challenge_card(challenge: Dictionary) -> Control:
	var card: Control = null
	var scene_path := "res://src/ui/components/ExperienceCard.tscn"
	if ResourceLoader.exists(scene_path):
		var scene := load(scene_path) as PackedScene
		if scene:
			card = scene.instantiate()
	if card == null:
		var script = load("res://src/ui/components/ExperienceCard.gd")
		card = PanelContainer.new()
		if script:
			card.set_script(script)
	if card.has_method("set_experience"):
		card.call("set_experience", challenge)
	if card.has_signal("experience_selected"):
		if not card.experience_selected.is_connected(_on_challenge_selected):
			card.experience_selected.connect(_on_challenge_selected)
	return card

func _focus_highlighted() -> void:
	if not challenge_list or _highlight_id == "":
		return
	var target_name := "Challenge_%s" % _highlight_id
	var target := challenge_list.get_node_or_null(target_name) as Control
	if target and scroll:
		scroll.scroll_vertical = int(target.position.y)

func on_navigated_to(params: Dictionary) -> void:
	_highlight_id = str(params.get("highlight", ""))
	_refresh_list()

func _on_challenge_selected(challenge_id: String) -> void:
	if AccessibilityService:
		AccessibilityService.vibrate(30)
	if AudioService:
		AudioService.play_ui("ui_click")
	if ChallengeRegistry:
		ChallengeRegistry.start_run(challenge_id)

func _on_theme_changed(_theme: String, _tokens: Dictionary) -> void:
	_apply_theme()
	_refresh_list()

func _on_registry_updated(_challenges: Array) -> void:
	_refresh_list()
