extends Control
## MemoryQuestionScreen – Recall phase – premium UI
## Matches Home / Tutorial visual language
## Gameplay logic unchanged

@onready var brand_label: Label = $MainMargin/Content/Header/BrandLabel
@onready var subtitle_label: Label = $MainMargin/Content/Header/SubtitleLabel
@onready var question_label: Label = $MainMargin/Content/QuestionLabel
@onready var options_container: VBoxContainer = $MainMargin/Content/OptionsContainer
@onready var background_rect: ColorRect = $Background

var _challenge_data: Dictionary = {}
var _challenge_id: String = "challenge_01"
var _correct_answer: String = ""
var _selected_answer: String = ""

func _ready() -> void:
	_apply_theme()

func _get_anim_duration(base: float) -> float:
	if AccessibilityService and AccessibilityService.has_method("get_animation_duration"):
		return AccessibilityService.get_animation_duration(base)
	return base

func _should_animate() -> bool:
	if AccessibilityService and AccessibilityService.has_method("should_animate"):
		return AccessibilityService.should_animate()
	return true

func _apply_theme() -> void:
	var tokens := ThemeService.tokens if ThemeService else {}
	if background_rect:
		background_rect.color = tokens.get("background", Color("#0F0F12")) if not tokens.is_empty() else Color("#0F0F12")
	
	if brand_label:
		if ThemeService:
			ThemeService.apply_label_style(brand_label, "display", "text_primary")
			brand_label.add_theme_font_size_override("font_size", 42)
		brand_label.text = "RECALL"
		brand_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if subtitle_label:
		if ThemeService:
			ThemeService.apply_label_style(subtitle_label, "body_small", "text_secondary")
		subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if question_label:
		if ThemeService:
			ThemeService.apply_label_style(question_label, "title", "text_primary")
		question_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		question_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	# Restyle any existing option buttons
	if options_container:
		for child in options_container.get_children():
			if child is Button:
				_apply_option_theme(child)

func _load_question() -> void:
	if _challenge_data.is_empty() and AppState:
		var transient = AppState.get_transient("current_challenge", {})
		if transient is Dictionary and not transient.is_empty():
			_challenge_data = transient

	if _challenge_data.is_empty() and ChallengeRegistry:
		_challenge_data = ChallengeRegistry.get_challenge(_challenge_id)

	if _challenge_data.is_empty():
		_challenge_data = {
			"id": "challenge_01",
			"question": "How many colored pencils were in the green mug?",
			"options": ["3", "4", "5", "6"],
			"correct": "5",
			"detail": "There were 5 writing tools in the green mug."
		}

	_challenge_id = str(_challenge_data.get("id", _challenge_id))
	_correct_answer = str(_challenge_data.get("correct", ""))

	if question_label:
		question_label.text = str(_challenge_data.get("question", "What did you see?"))

	_build_options(_challenge_data.get("options", []))

	if AppState:
		AppState.set_transient("question_started_ms", Time.get_ticks_msec())

func _build_options(options: Array) -> void:
	if not options_container:
		return
	for child in options_container.get_children():
		options_container.remove_child(child)
		child.queue_free()

	for opt in options:
		var btn := Button.new()
		btn.text = str(opt)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.set_meta("answer", str(opt))
		btn.pressed.connect(_on_option_selected.bind(str(opt), btn))
		_apply_option_theme(btn)
		options_container.add_child(btn)

func _apply_option_theme(btn: Button) -> void:
	var tokens := ThemeService.tokens if ThemeService else {}
	
	var normal := StyleBoxFlat.new()
	normal.bg_color = tokens.get("surface", Color("#1E1E26")) if not tokens.is_empty() else Color("#1E1E26")
	var r := tokens.get("radius_lg", 16) if not tokens.is_empty() else 16
	normal.corner_radius_top_left = r
	normal.corner_radius_top_right = r
	normal.corner_radius_bottom_left = r
	normal.corner_radius_bottom_right = r
	normal.border_color = tokens.get("border", Color("#2E2E3A")) if not tokens.is_empty() else Color("#2E2E3A")
	normal.border_width_left = 1
	normal.border_width_right = 1
	normal.border_width_top = 1
	normal.border_width_bottom = 1
	normal.content_margin_left = 20
	normal.content_margin_right = 20
	normal.content_margin_top = 18
	normal.content_margin_bottom = 18
	
	var hover := normal.duplicate()
	hover.bg_color = tokens.get("surface_elevated", Color("#2A2A36")) if not tokens.is_empty() else Color("#2A2A36")
	hover.border_color = tokens.get("primary", Color("#6A3DFF")) if not tokens.is_empty() else Color("#6A3DFF")
	
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", hover)
	btn.add_theme_stylebox_override("focus", hover)
	
	if ThemeService:
		ThemeService.apply_typography(btn, "button")
		btn.add_theme_color_override("font_color", ThemeService.get_color("text_primary"))
	else:
		btn.add_theme_font_size_override("font_size", 18)
	
	var touch_min := 64
	if ThemeService:
		touch_min = max(64, ThemeService.tokens.get("touch_target_min", 48))
	btn.custom_minimum_size.y = touch_min
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func _on_option_selected(answer: String, button: Button) -> void:
	_selected_answer = answer

	if AccessibilityService and AccessibilityService.is_haptics_enabled():
		AccessibilityService.vibrate(30)
	if AudioService:
		AudioService.play_ui("ui_click")

	for child in options_container.get_children():
		if child is Button:
			child.disabled = true

	var is_correct := (answer == _correct_answer)
	_highlight_answers(button, is_correct)

	var question_start_ms := Time.get_ticks_msec()
	if AppState:
		question_start_ms = int(AppState.get_transient("question_started_ms", question_start_ms))
	var reaction_ms: int = max(Time.get_ticks_msec() - question_start_ms, 0)
	var score: int = 100 if is_correct else 0
	var result := {
		"challenge_id": _challenge_id,
		"title": _challenge_data.get("title", "Challenge"),
		"question": _challenge_data.get("question", ""),
		"selected": answer,
		"correct": _correct_answer,
		"is_correct": is_correct,
		"detail": _challenge_data.get("detail", ""),
		"score": score,
		"reaction_ms": reaction_ms
	}

	if AppState:
		AppState.set_transient("last_result", result)

	if ProfileService:
		ProfileService.record_experience_play(_challenge_id, {
			"score": score,
			"correct": is_correct,
			"reaction_ms": reaction_ms
		})

	if AnalyticsService:
		AnalyticsService.log_event("memory_answered", result)

	get_tree().create_timer(1.0).timeout.connect(func():
		if NavigationService:
			NavigationService.navigate_to("result", result)
	)

func _highlight_answers(selected_button: Button, is_correct: bool) -> void:
	if not ThemeService:
		return
	var tokens = ThemeService.tokens
	var success := tokens.get("success", Color("#2EE6A6")) if not tokens.is_empty() else Color("#2EE6A6")
	var error := tokens.get("error", Color("#FF4D5E")) if not tokens.is_empty() else Color("#FF4D5E")
	var radius := tokens.get("radius_lg", 16) if not tokens.is_empty() else 16
	
	if selected_button:
		var col := success if is_correct else error
		selected_button.add_theme_stylebox_override("normal", _feedback_style(col, radius))
		selected_button.add_theme_color_override("font_color", Color.WHITE)
	
	if not is_correct:
		for child in options_container.get_children():
			if child is Button and str(child.get_meta("answer", "")) == _correct_answer:
				child.add_theme_stylebox_override("normal", _feedback_style(success, radius))
				child.add_theme_color_override("font_color", Color.WHITE)

func _feedback_style(color: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 18
	style.content_margin_bottom = 18
	return style

func on_navigated_to(params: Dictionary) -> void:
	var fallback_id := "challenge_01"
	if AppState:
		fallback_id = AppState.get_transient("current_challenge_id", fallback_id)
	_challenge_id = str(params.get("challenge_id", fallback_id))
	if params.has("challenge_data") and params.get("challenge_data") is Dictionary:
		_challenge_data = params.get("challenge_data")
	else:
		_challenge_data = {}

	modulate.a = 1.0
	_apply_theme()
	_load_question()
	_animate_in()

func _animate_in() -> void:
	if not _should_animate():
		modulate.a = 1.0
		return
	modulate.a = 0.0
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate:a", 1.0, _get_anim_duration(0.3))
