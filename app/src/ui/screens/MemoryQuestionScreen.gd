extends Control
## MemoryQuestionScreen - Ask recall question about the current challenge

@onready var question_label: Label = $Margin/VBox/QuestionLabel
@onready var options_container: VBoxContainer = $Margin/VBox/OptionsContainer

var _challenge_data: Dictionary = {}
var _challenge_id: String = "challenge_01"
var _correct_answer: String = ""
var _selected_answer: String = ""

func _ready() -> void:
	_apply_theme()

func _apply_theme() -> void:
	if not ThemeService:
		return
	var tokens = ThemeService.tokens
	if question_label:
		question_label.add_theme_color_override("font_color", tokens.get("text_primary", Color.WHITE))
		question_label.add_theme_font_size_override("font_size", 20)

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
		btn.custom_minimum_size = Vector2(0, 56)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.set_meta("answer", str(opt))
		btn.pressed.connect(_on_option_selected.bind(str(opt), btn))
		_apply_option_theme(btn)
		options_container.add_child(btn)

func _apply_option_theme(btn: Button) -> void:
	if not ThemeService:
		return
	var tokens = ThemeService.tokens
	var style := StyleBoxFlat.new()
	style.bg_color = tokens.get("surface", Color("#1E1E26"))
	style.corner_radius_top_left = tokens.get("radius_md", 12)
	style.corner_radius_top_right = tokens.get("radius_md", 12)
	style.corner_radius_bottom_left = tokens.get("radius_md", 12)
	style.corner_radius_bottom_right = tokens.get("radius_md", 12)
	style.border_color = tokens.get("border", Color("#2E2E3A"))
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	btn.add_theme_stylebox_override("normal", style)
	var hover := style.duplicate()
	hover.bg_color = tokens.get("surface_elevated", Color("#2A2A36"))
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", hover)

func _on_option_selected(answer: String, button: Button) -> void:
	_selected_answer = answer

	if AccessibilityService:
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
	if selected_button:
		var selected_color := Color("#2EE6A6") if is_correct else Color("#FF4D5E")
		selected_button.add_theme_stylebox_override("normal", _feedback_style(selected_color))

	if not is_correct:
		for child in options_container.get_children():
			if child is Button and str(child.get_meta("answer", "")) == _correct_answer:
				child.add_theme_stylebox_override("normal", _feedback_style(Color("#2EE6A6")))

func _feedback_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 12
	style.content_margin_bottom = 12
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
	_load_question()
	_animate_in()

	if AnalyticsService:
		AnalyticsService.log_screen_view("memory_question", {"challenge_id": _challenge_id})

func _animate_in() -> void:
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.4)
