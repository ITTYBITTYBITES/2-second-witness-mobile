extends Control
## ResultScreen - Clear, accessible recall feedback and next actions.

@onready var background: ColorRect = $Background
@onready var result_icon: Label = $Margin/Scroll/VBox/ResultIcon
@onready var result_title: Label = $Margin/Scroll/VBox/Title
@onready var result_desc: Label = $Margin/Scroll/VBox/Description
@onready var detail_label: Label = $Margin/Scroll/VBox/Detail
@onready var continue_btn: Button = $Margin/Scroll/VBox/ContinueButton
@onready var replay_btn: Button = $Margin/Scroll/VBox/ReplayButton
@onready var menu_btn: Button = $Margin/Scroll/VBox/MenuButton

var _result_data: Dictionary = {}
var _is_correct := false

func _ready() -> void:
	_wire_actions()
	_apply_theme()
	if ThemeService and not ThemeService.theme_changed.is_connected(_on_theme_changed):
		ThemeService.theme_changed.connect(_on_theme_changed)

func _wire_actions() -> void:
	if not replay_btn.pressed.is_connected(_on_replay):
		replay_btn.pressed.connect(_on_replay)
	if not continue_btn.pressed.is_connected(_on_continue):
		continue_btn.pressed.connect(_on_continue)
	if not menu_btn.pressed.is_connected(_on_menu):
		menu_btn.pressed.connect(_on_menu)

func _apply_theme() -> void:
	if not ThemeService:
		return
	background.color = ThemeService.get_color("background")
	ThemeService.apply_label_style(result_title, "headline", "text_primary")
	ThemeService.apply_label_style(result_desc, "body", "text_secondary")
	ThemeService.apply_label_style(detail_label, "body_small", "text_tertiary")
	ThemeService.apply_typography(result_icon, "display")
	result_icon.add_theme_color_override("font_color", ThemeService.get_color("success") if _is_correct else ThemeService.get_color("error"))
	for label in [result_title, result_desc, detail_label]:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_style_button(continue_btn, "primary")
	_style_button(replay_btn, "secondary")
	_style_button(menu_btn, "ghost")

func _style_button(button: Button, variant: String) -> void:
	var tokens := ThemeService.tokens
	var style := StyleBoxFlat.new()
	match variant:
		"primary":
			style.bg_color = tokens.get("primary", Color("#6A3DFF"))
		"secondary":
			style.bg_color = tokens.get("surface_elevated", Color("#2A2A36"))
		_:
			style.bg_color = Color.TRANSPARENT
	style.set_corner_radius_all(12)
	style.border_color = tokens.get("border", Color.GRAY)
	style.set_border_width_all(1)
	var hover := style.duplicate() as StyleBoxFlat
	hover.bg_color = tokens.get("primary_variant", Color("#8A68FF")) if variant == "primary" else tokens.get("surface", Color("#1E1E26"))
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_stylebox_override("focus", hover)
	button.add_theme_color_override("font_color", tokens.get("text_on_primary", Color.WHITE) if variant == "primary" else tokens.get("text_primary", Color.WHITE))
	ThemeService.apply_typography(button, "button")
	button.custom_minimum_size.y = maxf(button.custom_minimum_size.y, 48.0)
	button.focus_mode = Control.FOCUS_ALL

func _display_result(data: Dictionary) -> void:
	_result_data = data
	_is_correct = bool(data.get("is_correct", false))
	var selected := str(data.get("selected", ""))
	var correct := str(data.get("correct", ""))
	var detail := str(data.get("detail", ""))
	var challenge_title := str(data.get("title", "Challenge"))
	var run_position := ChallengeRegistry.get_run_position() if ChallengeRegistry else {"index": 0, "total": 0}
	var round_label := ""
	if int(run_position.get("total", 0)) > 1:
		round_label = "Challenge %d of %d" % [
			int(run_position.get("index", 0)) + 1,
			int(run_position.get("total", 0))
		]

	result_icon.text = "✓" if _is_correct else "✕"
	result_title.text = "Correct!" if _is_correct else "Not quite"
	if _is_correct:
		result_desc.text = challenge_title + ("\n" + round_label if round_label != "" else "")
	else:
		result_desc.text = "%s\nYou chose %s. The correct answer was %s.%s" % [
			challenge_title, selected, correct,
			"\n" + round_label if round_label != "" else ""
		]
	detail_label.text = detail
	detail_label.visible = detail != ""
	continue_btn.text = "Next Challenge" if ChallengeRegistry and ChallengeRegistry.count() > 1 else "Play Again"
	_apply_theme()
	_play_feedback()
	_animate_in()

func _play_feedback() -> void:
	if AccessibilityService:
		AccessibilityService.vibrate(50 if _is_correct else 100)

func _animate_in() -> void:
	result_icon.scale = Vector2.ONE
	if AccessibilityService and AccessibilityService.is_reduced_motion_enabled():
		return
	result_icon.pivot_offset = result_icon.size * 0.5
	result_icon.scale = Vector2(0.7, 0.7)
	var tween := create_tween()
	tween.tween_property(result_icon, "scale", Vector2.ONE, 0.22).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _on_replay() -> void:
	if AnalyticsService:
		AnalyticsService.log_event("replay_challenge", {"challenge_id": _result_data.get("challenge_id", "")})
	if ChallengeRegistry:
		ChallengeRegistry.replay_current()

func _on_continue() -> void:
	_check_first_run_completion()
	if AnalyticsService:
		AnalyticsService.log_event("next_challenge", {"challenge_id": _result_data.get("challenge_id", "")})
	if ChallengeRegistry:
		ChallengeRegistry.go_to_next_challenge()

func _on_menu() -> void:
	_check_first_run_completion()
	if ChallengeRegistry:
		ChallengeRegistry.clear_run()
	if NavigationService:
		NavigationService.navigate_to("home")

func _check_first_run_completion() -> void:
	var needs_save := false
	if ProfileService:
		var preferences: Dictionary = ProfileService.profile.get("preferences", {})
		if not preferences.get("onboarding_completed", false):
			preferences["onboarding_completed"] = true
			ProfileService.profile["preferences"] = preferences
			needs_save = true
	if SettingsService and not SettingsService.get_value("first_launch_completed", false):
		SettingsService.set_value("first_launch_completed", true)
	if needs_save and ProfileService:
		ProfileService.save()

func on_navigated_to(params: Dictionary) -> void:
	modulate.a = 1.0
	_display_result(params)

func _on_theme_changed(_theme: String, _tokens: Dictionary) -> void:
	_apply_theme()
