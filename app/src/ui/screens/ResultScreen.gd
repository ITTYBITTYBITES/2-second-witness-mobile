extends Control
## ResultScreen - Feedback after each recall question

@onready var result_icon: Label = $Margin/VBox/ResultIcon
@onready var result_title: Label = $Margin/VBox/Title
@onready var result_desc: Label = $Margin/VBox/Description
@onready var detail_label: Label = $Margin/VBox/Detail
@onready var replay_btn: Button = $Margin/VBox/ReplayButton
@onready var continue_btn: Button = $Margin/VBox/ContinueButton
@onready var menu_btn: Button = $Margin/VBox/MenuButton

var _result_data: Dictionary = {}
var _is_correct: bool = false
var _is_onboarding_result: bool = false

func _ready() -> void:
	_apply_theme()
	_ensure_wired()

func _ensure_wired() -> void:
	if replay_btn and not replay_btn.pressed.is_connected(_on_replay):
		replay_btn.pressed.connect(_on_replay)
	if continue_btn and not continue_btn.pressed.is_connected(_on_continue):
		continue_btn.pressed.connect(_on_continue)
	if menu_btn and not menu_btn.pressed.is_connected(_on_menu):
		menu_btn.pressed.connect(_on_menu)

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
	_is_correct = bool(data.get("is_correct", false))
	
	var selected := str(data.get("selected", ""))
	var correct := str(data.get("correct", ""))
	var detail := str(data.get("detail", ""))
	var title := str(data.get("title", "Challenge"))
	_is_onboarding_result = _should_finish_onboarding()
	var run_position := ChallengeRegistry.get_run_position() if ChallengeRegistry else {"index": 0, "total": 0}
	var round_label := ""
	if int(run_position.get("total", 0)) > 0:
		round_label = "Challenge %d of %d" % [int(run_position.get("index", 0)) + 1, int(run_position.get("total", 0))]
	
	if result_icon:
		if _is_correct:
			result_icon.text = "✓"
			result_icon.add_theme_color_override("font_color", Color("#2EE6A6"))
		else:
			result_icon.text = "✕"
			result_icon.add_theme_color_override("font_color", Color("#FF4D5E"))
	
	if result_title:
		result_title.text = "Correct!" if _is_correct else "Not quite"
	
	if result_desc:
		if _is_correct:
			result_desc.text = "%s\n%s" % [title, round_label] if round_label != "" else title
		else:
			var prefix := "%s\n" % title if title != "" else ""
			var suffix := "\n%s" % round_label if round_label != "" else ""
			result_desc.text = "%sYou selected %s, but the correct answer was %s.%s" % [prefix, selected, correct, suffix]
	
	if detail_label:
		detail_label.text = detail if detail != "" else ""
		detail_label.visible = detail != ""
	
	if continue_btn:
		if _is_onboarding_result:
			continue_btn.text = "Continue to Main Menu"
		elif ChallengeRegistry and ChallengeRegistry.count() > 1:
			continue_btn.text = "Next Challenge"
		else:
			continue_btn.text = "Play Again"
	if menu_btn:
		menu_btn.visible = not _is_onboarding_result
	
	_mark_first_run_complete()
	_play_feedback()
	_animate_in()

func _should_finish_onboarding() -> bool:
	var onboarding_done := false
	var first_launch_done := false
	if ProfileService:
		onboarding_done = ProfileService.profile.get("preferences", {}).get("onboarding_completed", false)
	if SettingsService:
		first_launch_done = SettingsService.get_value("first_launch_completed", false)
	return not onboarding_done or not first_launch_done

func _mark_first_run_complete() -> void:
	if ProfileService:
		var prefs = ProfileService.profile.get("preferences", {})
		if not prefs.get("onboarding_completed", false):
			prefs["onboarding_completed"] = true
			ProfileService.profile["preferences"] = prefs
			ProfileService.save()
	if SettingsService and not SettingsService.get_value("first_launch_completed", false):
		SettingsService.set_value("first_launch_completed", true)

func _play_feedback() -> void:
	if AccessibilityService:
		AccessibilityService.vibrate(50 if _is_correct else 100)
	if AudioService:
		AudioService.play_ui("ui_click")

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
	if ChallengeRegistry:
		ChallengeRegistry.replay_current()

func _on_continue() -> void:
	if AudioService:
		AudioService.play_ui("ui_click")
	if _is_onboarding_result:
		if ChallengeRegistry:
			ChallengeRegistry.clear_run()
		if AnalyticsService:
			AnalyticsService.log_event("onboarding_completed", {"challenge_id": _result_data.get("challenge_id", "")})
		if NavigationService:
			NavigationService.navigate_to("home")
		return
	if AnalyticsService:
		AnalyticsService.log_event("next_challenge", {"challenge_id": _result_data.get("challenge_id", "")})
	if ChallengeRegistry:
		ChallengeRegistry.go_to_next_challenge()

func _on_menu() -> void:
	if AudioService:
		AudioService.play_ui("ui_click")
	if ChallengeRegistry:
		ChallengeRegistry.clear_run()
	if NavigationService:
		NavigationService.navigate_to("home")

func on_navigated_to(params: Dictionary) -> void:
	_result_data = params
	_display_result(params)
	modulate.a = 1.0
	if AnalyticsService:
		AnalyticsService.log_screen_view("result", {"is_correct": params.get("is_correct", false)})
