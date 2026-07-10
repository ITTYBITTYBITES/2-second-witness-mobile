extends Control
## ResultScreen - Feedback after each recall question.
## Every challenge is launched from the main menu, so there is no longer a
## special "first run onboarding result" path.

@onready var result_icon: Label = $Margin/VBox/ResultIcon
@onready var result_title: Label = $Margin/VBox/Title
@onready var result_desc: Label = $Margin/VBox/Description
@onready var detail_label: Label = $Margin/VBox/Detail
@onready var replay_btn: Button = $Margin/VBox/ReplayButton
@onready var continue_btn: Button = $Margin/VBox/ContinueButton
@onready var menu_btn: Button = $Margin/VBox/MenuButton

var _result_data: Dictionary = {}
var _is_correct: bool = false

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
		ThemeService.apply_label_style(result_title, "headline", "text_primary")
		result_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if result_desc:
		ThemeService.apply_label_style(result_desc, "body", "text_secondary")
		result_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		result_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if detail_label:
		ThemeService.apply_label_style(detail_label, "body_small", "text_tertiary")
		detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if result_icon:
		ThemeService.apply_typography(result_icon, "display")
	# Style buttons
	for btn in [replay_btn, continue_btn, menu_btn]:
		if btn is Button and ThemeService:
			ThemeService.apply_typography(btn, "button")
			btn.custom_minimum_size.y = max(btn.custom_minimum_size.y, tokens.get("touch_target_min", 48))
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func _display_result(data: Dictionary) -> void:
	_result_data = data
	_is_correct = bool(data.get("is_correct", false))

	var selected := str(data.get("selected", ""))
	var correct := str(data.get("correct", ""))
	var detail := str(data.get("detail", ""))
	var title := str(data.get("title", "Challenge"))
	var run_position := {"index": 0, "total": 0}
	if ChallengeRegistry:
		run_position = ChallengeRegistry.get_run_position()
	var round_label := ""
	if int(run_position.get("total", 0)) > 1:
		var round_index := int(run_position.get("index", 0)) + 1
		var round_total := int(run_position.get("total", 0))
		round_label = "Challenge %d of %d" % [round_index, round_total]

	if result_icon:
		if _is_correct:
			result_icon.text = "OK"
			result_icon.add_theme_color_override("font_color", Color("#2EE6A6"))
		else:
			result_icon.text = "X"
			result_icon.add_theme_color_override("font_color", Color("#FF4D5E"))

	if result_title:
		result_title.text = "Correct!" if _is_correct else "Not quite"

	if result_desc:
		if _is_correct:
			result_desc.text = "%s\n%s" % [title, round_label] if round_label != "" else title
		else:
			var prefix := "%s\n" % title if title != "" else ""
			var suffix := "\n%s" % round_label if round_label != "" else ""
			var feedback := "You selected %s, but the correct answer was %s."
			result_desc.text = "%s%s%s" % [prefix, feedback % [selected, correct], suffix]

	if detail_label:
		detail_label.text = detail if detail != "" else ""
		detail_label.visible = detail != ""

	if continue_btn:
		if ChallengeRegistry and ChallengeRegistry.count() > 1:
			continue_btn.text = "Next Challenge"
		else:
			continue_btn.text = "Play Again"
	if menu_btn:
		menu_btn.visible = true

	_play_feedback()
	_animate_in()

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
		var tween := create_tween()
		var scale_tween := tween.tween_property(result_icon, "scale", Vector2.ONE, 0.3)
		scale_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _on_replay() -> void:
	if AudioService:
		AudioService.play_ui("ui_click")
	if AnalyticsService:
		var replay_params := {"challenge_id": _result_data.get("challenge_id", "")}
		AnalyticsService.log_event("replay_challenge", replay_params)
	if ChallengeRegistry:
		ChallengeRegistry.replay_current()

func _on_continue() -> void:
	if AudioService:
		AudioService.play_ui("ui_click")
	_check_first_run_completion()
	if AnalyticsService:
		var next_params := {"challenge_id": _result_data.get("challenge_id", "")}
		AnalyticsService.log_event("next_challenge", next_params)
	if ChallengeRegistry:
		ChallengeRegistry.go_to_next_challenge()

func _on_menu() -> void:
	if AudioService:
		AudioService.play_ui("ui_click")
	_check_first_run_completion()
	if ChallengeRegistry:
		ChallengeRegistry.clear_run()
	if NavigationService:
		NavigationService.navigate_to("home")

func _check_first_run_completion() -> void:
	var needs_save := false
	if ProfileService:
		var prefs: Dictionary = ProfileService.profile.get("preferences", {})
		if not prefs.get("onboarding_completed", false):
			prefs["onboarding_completed"] = true
			ProfileService.profile["preferences"] = prefs
			needs_save = true
	if SettingsService:
		if not SettingsService.get_value("first_launch_completed", false):
			SettingsService.set_value("first_launch_completed", true)
			# SettingsService usually saves automatically on set_value if implemented that way
	if needs_save and ProfileService:
		ProfileService.save()

func on_navigated_to(params: Dictionary) -> void:
	_result_data = params
	_display_result(params)
	modulate.a = 1.0
	# Screen-view analytics are centralized in NavigationService.navigate_to.
