extends Control
## MemoryQuestionScreen - Recall question for the current challenge.

@onready var background: ColorRect = $Background
@onready var header_label: Label = $Margin/Scroll/VBox/Header
@onready var question_label: Label = $Margin/Scroll/VBox/QuestionLabel
@onready var options_container: VBoxContainer = $Margin/Scroll/VBox/OptionsContainer
@onready var feedback_label: Label = $Margin/Scroll/VBox/FeedbackLabel

var _challenge_data: Dictionary = {}
var _challenge_id := "challenge_01"
var _correct_answer := ""
var _selected_answer := ""
var _answer_locked := false

func _ready() -> void:
	_apply_theme()
	if ThemeService and not ThemeService.theme_changed.is_connected(_on_theme_changed):
		ThemeService.theme_changed.connect(_on_theme_changed)

func _apply_theme() -> void:
	if not ThemeService:
		return
	background.color = ThemeService.get_color("background")
	ThemeService.apply_label_style(header_label, "label_small", "primary_text")
	ThemeService.apply_label_style(question_label, "title", "text_primary")
	ThemeService.apply_label_style(feedback_label, "body_small", "text_secondary")
	question_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for child in options_container.get_children():
		if child is Button and not child.has_meta("feedback_state"):
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
			"title": "Study Desk",
			"question": "How many writing tools were in the green mug?",
			"options": ["3", "4", "5", "6"],
			"correct": "5",
			"detail": "There were 5 writing tools in the green mug."
		}
	_challenge_id = str(_challenge_data.get("id", _challenge_id))
	_correct_answer = str(_challenge_data.get("correct", ""))
	question_label.text = str(_challenge_data.get("question", "What did you see?"))
	feedback_label.visible = false
	_answer_locked = false
	_build_options(_challenge_data.get("options", []))
	if AppState:
		AppState.set_transient("question_started_ms", Time.get_ticks_msec())

func _build_options(options: Array) -> void:
	for child in options_container.get_children():
		options_container.remove_child(child)
		child.queue_free()
	for option in options:
		var button := Button.new()
		button.text = str(option)
		button.custom_minimum_size = Vector2(0, 56)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.focus_mode = Control.FOCUS_ALL
		button.set_meta("answer", str(option))
		button.set_meta("original_text", str(option))
		button.pressed.connect(_on_option_selected.bind(str(option), button))
		_apply_option_theme(button)
		options_container.add_child(button)

func _apply_option_theme(button: Button) -> void:
	var tokens := ThemeService.tokens
	var style := StyleBoxFlat.new()
	style.bg_color = tokens.get("surface", Color("#1E1E26"))
	style.set_corner_radius_all(int(tokens.get("radius_md", 12)))
	style.border_color = tokens.get("border", Color("#2E2E3A"))
	style.set_border_width_all(1)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	var hover := style.duplicate() as StyleBoxFlat
	hover.bg_color = tokens.get("surface_elevated", Color("#2A2A36"))
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_stylebox_override("focus", hover)
	button.add_theme_stylebox_override("disabled", style)
	ThemeService.apply_typography(button, "body")
	button.add_theme_color_override("font_color", tokens.get("text_primary", Color.WHITE))
	button.add_theme_color_override("font_disabled_color", tokens.get("text_primary", Color.WHITE))

func _on_option_selected(answer: String, button: Button) -> void:
	if _answer_locked:
		return
	_answer_locked = true
	_selected_answer = answer
	if AccessibilityService:
		AccessibilityService.vibrate(30)
	for child in options_container.get_children():
		if child is Button:
			child.disabled = true

	var is_correct := answer == _correct_answer
	_highlight_answers(button, is_correct)
	feedback_label.visible = true
	feedback_label.text = "Correct answer selected." if is_correct else "Correct answer: %s." % _correct_answer

	var question_start_ms := Time.get_ticks_msec()
	if AppState:
		question_start_ms = int(AppState.get_transient("question_started_ms", question_start_ms))
	var reaction_ms := maxi(Time.get_ticks_msec() - question_start_ms, 0)
	var score := 100 if is_correct else 0
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
			"score": score, "correct": is_correct, "reaction_ms": reaction_ms
		})
	if AnalyticsService:
		AnalyticsService.log_event("memory_answered", result)
	get_tree().create_timer(0.8).timeout.connect(func():
		if NavigationService:
			NavigationService.navigate_to("result", result)
	)

func _highlight_answers(selected_button: Button, is_correct: bool) -> void:
	if selected_button:
		_set_feedback_style(selected_button, is_correct)
	if not is_correct:
		for child in options_container.get_children():
			if child is Button and str(child.get_meta("answer", "")) == _correct_answer:
				_set_feedback_style(child, true)

func _set_feedback_style(button: Button, correct: bool) -> void:
	var color := Color("#2EE6A6") if correct else Color("#FF6B6B")
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(12)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		button.add_theme_stylebox_override(state, style)
	var original := str(button.get_meta("original_text", button.text))
	button.text = ("✓  " if correct else "✕  ") + original
	button.add_theme_color_override("font_color", Color("#101014"))
	button.add_theme_color_override("font_disabled_color", Color("#101014"))
	button.set_meta("feedback_state", true)

func on_navigated_to(params: Dictionary) -> void:
	var fallback_id := "challenge_01"
	if AppState:
		fallback_id = str(AppState.get_transient("current_challenge_id", fallback_id))
	_challenge_id = str(params.get("challenge_id", fallback_id))
	if params.has("challenge_data") and params.get("challenge_data") is Dictionary:
		_challenge_data = params.get("challenge_data")
	else:
		_challenge_data = {}
	modulate.a = 1.0
	_load_question()
	if not (AccessibilityService and AccessibilityService.is_reduced_motion_enabled()):
		modulate.a = 0.0
		create_tween().tween_property(self, "modulate:a", 1.0, 0.2)

func _on_theme_changed(_theme: String, _tokens: Dictionary) -> void:
	_apply_theme()
