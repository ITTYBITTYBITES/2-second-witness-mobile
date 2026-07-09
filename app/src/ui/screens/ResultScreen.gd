extends Control
## ResultScreen - Feedback after memory question

@onready var result_icon: Label = $Margin/VBox/ResultIcon
@onready var result_title: Label = $Margin/VBox/Title
@onready var result_desc: Label = $Margin/VBox/Description
@onready var detail_label: Label = $Margin/VBox/Detail
@onready var replay_btn: Button = $Margin/VBox/ReplayButton
@onready var continue_btn: Button = $Margin/VBox/ContinueButton

var _result_data: Dictionary = {}
var _is_correct: bool = false

func _ready() -> void:
	_apply_theme()
	_ensure_wired()

func _ensure_wired() -> void:
	if has_node("Margin/VBox/ReplayButton"):
		var btn = $Margin/VBox/ReplayButton
		if not btn.pressed.is_connected(_on_replay):
			btn.pressed.connect(_on_replay)
	if has_node("Margin/VBox/ContinueButton"):
		var btn2 = $Margin/VBox/ContinueButton
		if not btn2.pressed.is_connected(_on_continue):
			btn2.pressed.connect(_on_continue)

func _apply_theme() -> void:
	if not ThemeService:
		return
	var tokens = ThemeService.tokens
	if result_title:
		result_title.add_theme_color_override("font_color", tokens.get("text_primary", Color.WHITE))
		result_title.add_theme_font_size_override("font_size", 28)
	if result_desc:
		result_desc.add_theme_color_override("font_color", tokens.get("text_secondary", Color.GRAY))

func _display_result(data: Dictionary) -> void:
	_result_data = data
	_is_correct = data.get("is_correct", false)
	
	var selected = data.get("selected", "")
	var correct = data.get("correct", "")
	var detail = data.get("detail", "")
	var question = data.get("question", "")
	
	if result_icon:
		if _is_correct:
			result_icon.text = "✓"
			result_icon.add_theme_color_override("font_color", Color("#2EE6A6"))
		else:
			result_icon.text = "✕"
			result_icon.add_theme_color_override("font_color", Color("#FF4D5E"))
	
	if result_title:
		if _is_correct:
			result_title.text = "Correct!"
		else:
			result_title.text = "Not quite"
	
	if result_desc:
		if _is_correct:
			result_desc.text = "Excellent observation. You noticed the detail in just 2 seconds."
		else:
			result_desc.text = "You selected %s, but the correct answer was %s." % [selected, correct]
	
	if detail_label:
		detail_label.text = detail if detail != "" else ""
		detail_label.visible = detail != ""
	
	# Haptics
	if AccessibilityService:
		if _is_correct:
			AccessibilityService.vibrate(50)
		else:
			AccessibilityService.vibrate(100)
	
	# Audio placeholder
	if AudioService:
		if _is_correct:
			AudioService.play_ui("ui_click")
		else:
			AudioService.play_ui("ui_click")
	
	_animate_in()

func _animate_in() -> void:
	if AccessibilityService and AccessibilityService.is_reduced_motion_enabled():
		return
	if result_icon:
		result_icon.scale = Vector2.ZERO
		var tween = create_tween()
		tween.tween_property(result_icon, "scale", Vector2.ONE, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _on_replay() -> void:
	if AudioService:
		AudioService.play_ui("ui_click")
	if AnalyticsService:
		AnalyticsService.log_event("replay_challenge", {"challenge_id": _result_data.get("challenge_id", "")})
	if NavigationService:
		NavigationService.navigate_to("observation", {"challenge_id": _result_data.get("challenge_id", "challenge_01")})

func _on_continue() -> void:
	if AudioService:
		AudioService.play_ui("ui_click")
	
	# Mark onboarding completed on first run
	if ProfileService:
		var prefs = ProfileService.profile.get("preferences", {})
		if not prefs.get("onboarding_completed", false):
			prefs["onboarding_completed"] = true
			ProfileService.profile["preferences"] = prefs
			ProfileService.save()
			print("[Result] Onboarding marked completed")
	
	if SettingsService:
		SettingsService.set_value("first_launch_completed", true)
	
	if AnalyticsService:
		AnalyticsService.log_event("first_run_completed", _result_data)
	
	if NavigationService:
		NavigationService.navigate_to("home")

func on_navigated_to(params: Dictionary) -> void:
	_result_data = params
	_display_result(params)
	modulate.a = 1.0
	if AnalyticsService:
		AnalyticsService.log_screen_view("result", {"is_correct": params.get("is_correct", false)})
