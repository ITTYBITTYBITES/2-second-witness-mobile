extends Control
## MemoryQuestionScreen - Ask recall question about observed scene

@onready var question_label: Label = $Margin/VBox/QuestionLabel
@onready var options_container: VBoxContainer = $Margin/VBox/OptionsContainer

var _challenge_data: Dictionary = {}
var _challenge_id: String = "challenge_01"
var _correct_answer: String = ""
var _selected_answer: String = ""

func _ready() -> void:
	_apply_theme()
	_ensure_wired()

func _ensure_wired() -> void:
	# Wire options if they exist in scene, otherwise built dynamically
	pass

func _apply_theme() -> void:
	if not ThemeService:
		return
	var tokens = ThemeService.tokens
	if question_label:
		question_label.add_theme_color_override("font_color", tokens.get("text_primary", Color.WHITE))
		question_label.add_theme_font_size_override("font_size", 20)

func _load_question() -> void:
	# Get challenge from AppState transient
	if AppState:
		var transient = AppState.get_transient("current_challenge", {})
		if not transient.is_empty():
			_challenge_data = transient
	
	if _challenge_data.is_empty():
		# Fallback
		_challenge_data = {
			"question": "How many colored pencils were in the green mug?",
			"options": ["3", "4", "5", "6"],
			"correct": "5",
			"detail": "There were 5 pencils"
		}
	
	_correct_answer = _challenge_data.get("correct", "")
	
	if question_label:
		question_label.text = _challenge_data.get("question", "What did you see?")
	
	# Build options
	_build_options(_challenge_data.get("options", []))

func _build_options(options: Array) -> void:
	if not options_container:
		return
	# Clear existing
	for child in options_container.get_children():
		child.queue_free()
	
	for opt in options:
		var btn = Button.new()
		btn.text = str(opt)
		btn.custom_minimum_size = Vector2(0, 56)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.set_meta("answer", str(opt))
		btn.pressed.connect(_on_option_selected.bind(str(opt), btn))
		
		# Theme
		if ThemeService:
			var tokens = ThemeService.tokens
			var style = StyleBoxFlat.new()
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
			var hover = style.duplicate()
			hover.bg_color = tokens.get("surface_elevated", Color("#2A2A36"))
			btn.add_theme_stylebox_override("hover", hover)
		
		options_container.add_child(btn)

func _on_option_selected(answer: String, button: Button) -> void:
	_selected_answer = answer
	
	if AccessibilityService:
		AccessibilityService.vibrate(30)
	if AudioService:
		AudioService.play_ui("ui_click")
	
	# Disable all options briefly for feedback
	for child in options_container.get_children():
		if child is Button:
			child.disabled = true
	
	# Show correct/incorrect feedback via button colors
	var is_correct = (answer == _correct_answer)
	
	# Highlight selected
	if button:
		var style = StyleBoxFlat.new()
		if is_correct:
			style.bg_color = Color("#2EE6A6")
		else:
			style.bg_color = Color("#FF4D5E")
		style.corner_radius_top_left = 12
		style.corner_radius_top_right = 12
		style.corner_radius_bottom_left = 12
		style.corner_radius_bottom_right = 12
		button.add_theme_stylebox_override("normal", style)
	
	# Highlight correct answer if wrong
	if not is_correct:
		for child in options_container.get_children():
			if child is Button:
				var ans = child.get_meta("answer", "")
				if ans == _correct_answer:
					var correct_style = StyleBoxFlat.new()
					correct_style.bg_color = Color("#2EE6A6")
					correct_style.corner_radius_top_left = 12
					correct_style.corner_radius_top_right = 12
					correct_style.corner_radius_bottom_left = 12
					correct_style.corner_radius_bottom_right = 12
					child.add_theme_stylebox_override("normal", correct_style)
	
	# Store result and transition to result screen after delay
	var result = {
		"challenge_id": _challenge_id,
		"question": _challenge_data.get("question", ""),
		"selected": answer,
		"correct": _correct_answer,
		"is_correct": is_correct,
		"detail": _challenge_data.get("detail", ""),
		"reaction_time_ms": AppState.get_transient("observation_time_ms", 2000) if AppState else 2000
	}
	
	if AppState:
		AppState.set_transient("last_result", result)
	
	if ProfileService:
		ProfileService.record_experience_play("first_observation", {
			"score": 100 if is_correct else 0,
			"correct": is_correct,
			"reaction_ms": result.get("reaction_time_ms", 2000)
		})
	
	if AnalyticsService:
		AnalyticsService.log_event("memory_answered", result)
	
	# Delay then navigate
	get_tree().create_timer(1.2).timeout.connect(func():
		if NavigationService:
			NavigationService.navigate_to("result", result)
	)

func on_navigated_to(params: Dictionary) -> void:
	_challenge_id = params.get("challenge_id", "challenge_01")
	if params.has("challenge_data"):
		_challenge_data = params.get("challenge_data")
	elif AppState:
		_challenge_data = AppState.get_transient("current_challenge", {})
	
	# Also allow direct result data passing
	if params.has("challenge_id"):
		_challenge_id = params.get("challenge_id")
	
	modulate.a = 1.0
	_load_question()
	_animate_in()
	
	if AnalyticsService:
		AnalyticsService.log_screen_view("memory_question", {"challenge_id": _challenge_id})

func _animate_in() -> void:
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.4)
