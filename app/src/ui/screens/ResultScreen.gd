extends Control
## ResultScreen – Premium result feedback
## Matches Home / Tutorial visual language
## Gameplay / scoring logic unchanged

@onready var result_icon: Label = $MainMargin/Content/ResultCard/Margin/VBox/ResultIcon
@onready var result_title: Label = $MainMargin/Content/ResultCard/Margin/VBox/Title
@onready var result_desc: Label = $MainMargin/Content/ResultCard/Margin/VBox/Description
@onready var detail_label: Label = $MainMargin/Content/ResultCard/Margin/VBox/Detail
@onready var continue_btn: Button = $MainMargin/Content/Actions/ContinueButton
@onready var replay_btn: Button = $MainMargin/Content/Actions/ReplayButton
@onready var menu_btn: Button = $MainMargin/Content/Actions/MenuButton
@onready var result_card: PanelContainer = $MainMargin/Content/ResultCard
@onready var background_rect: ColorRect = $Background

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
	var bg_col := tokens.get("background", Color("#0F0F12")) if not tokens.is_empty() else Color("#0F0F12")
	if background_rect:
		background_rect.color = bg_col
	
	# Result card – premium, matches ExperienceCard
	if result_card:
		var style := StyleBoxFlat.new()
		style.bg_color = tokens.get("surface", Color("#1E1E26")) if not tokens.is_empty() else Color("#1E1E26")
		var r := tokens.get("radius_lg", 20) if not tokens.is_empty() else 20
		style.corner_radius_top_left = r; style.corner_radius_top_right = r
		style.corner_radius_bottom_left = r; style.corner_radius_bottom_right = r
		style.border_color = tokens.get("border", Color("#2E2E3A")) if not tokens.is_empty() else Color("#2E2E3A")
		style.border_width_left = 1; style.border_width_right = 1; style.border_width_top = 1; style.border_width_bottom = 1
		result_card.add_theme_stylebox_override("panel", style)
	
	if result_title and ThemeService:
		ThemeService.apply_label_style(result_title, "display", "text_primary")
		result_title.add_theme_font_size_override("font_size", 36)
	if result_desc and ThemeService:
		ThemeService.apply_label_style(result_desc, "body", "text_secondary")
	if detail_label and ThemeService:
		ThemeService.apply_label_style(detail_label, "body_small", "text_tertiary")
	
	_style_button(continue_btn, true, tokens)
	_style_button(replay_btn, false, tokens)
	_style_button(menu_btn, false, tokens, true)

func _style_button(btn: Button, primary: bool, tokens: Dictionary, ghost: bool = false) -> void:
	if not btn:
		return
	var radius := tokens.get("radius_lg", 18) if not tokens.is_empty() else 18
	var normal := StyleBoxFlat.new()
	normal.corner_radius_top_left = radius; normal.corner_radius_top_right = radius
	normal.corner_radius_bottom_left = radius; normal.corner_radius_bottom_right = radius
	normal.content_margin_left = 24; normal.content_margin_right = 24
	normal.content_margin_top = 18; normal.content_margin_bottom = 18
	
	if primary:
		var primary_col := tokens.get("primary", Color("#6A3DFF")) if not tokens.is_empty() else Color("#6A3DFF")
		normal.bg_color = primary_col
		btn.add_theme_color_override("font_color", Color.WHITE)
		var hover := normal.duplicate()
		hover.bg_color = tokens.get("primary_variant", Color("#8A68FF")) if not tokens.is_empty() else Color("#8A68FF")
		btn.add_theme_stylebox_override("hover", hover)
		btn.add_theme_stylebox_override("pressed", hover)
		btn.custom_minimum_size.y = 72
	elif ghost:
		normal.bg_color = Color.TRANSPARENT
		btn.add_theme_color_override("font_color", tokens.get("text_tertiary", Color("#8A8AA3")) if not tokens.is_empty() else Color("#8A8AA3"))
		btn.add_theme_stylebox_override("hover", normal)
		btn.add_theme_stylebox_override("pressed", normal)
		btn.custom_minimum_size.y = 48
	else:
		normal.bg_color = tokens.get("surface_elevated", Color("#2A2A36")) if not tokens.is_empty() else Color("#2A2A36")
		normal.border_color = tokens.get("border", Color("#2E2E3A")) if not tokens.is_empty() else Color("#2E2E3A")
		normal.border_width_left = 1; normal.border_width_right = 1; normal.border_width_top = 1; normal.border_width_bottom = 1
		btn.add_theme_color_override("font_color", tokens.get("text_primary", Color.WHITE) if not tokens.is_empty() else Color.WHITE)
		var hover := normal.duplicate()
		hover.bg_color = Color("#333340")
		btn.add_theme_stylebox_override("hover", hover)
		btn.add_theme_stylebox_override("pressed", hover)
		btn.custom_minimum_size.y = 56
	
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("focus", normal)
	if ThemeService:
		btn.add_theme_font_size_override("font_size", ThemeService.get_font_size("button"))
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

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
			result_icon.text = "✓"
			result_icon.add_theme_color_override("font_color", Color("#2EE6A6"))
		else:
			result_icon.text = "✗"
			result_icon.add_theme_color_override("font_color", Color("#FF4D5E"))
		if ThemeService:
			ThemeService.apply_typography(result_icon, "display")
			result_icon.add_theme_font_size_override("font_size", 64)

	if result_title:
		result_title.text = "CORRECT!" if _is_correct else "NOT QUITE"
	if result_desc:
		if _is_correct:
			result_desc.text = "%s\n%s" % [title, round_label] if round_label != "" else title
		else:
			var prefix := "%s\n" % title if title != "" else ""
			var suffix := "\n%s" % round_label if round_label != "" else ""
			var feedback := "You selected %s, correct was %s."
			result_desc.text = "%s%s%s" % [prefix, feedback % [selected, correct], suffix]

	if detail_label:
		detail_label.text = detail
		detail_label.visible = detail != ""

	if continue_btn:
		if ChallengeRegistry and ChallengeRegistry.count() > 1:
			continue_btn.text = "NEXT CHALLENGE  →"
		else:
			continue_btn.text = "PLAY AGAIN  ▶"
	if replay_btn:
		replay_btn.text = "Replay"
		replay_btn.visible = true
	if menu_btn:
		menu_btn.text = "HOME"
		menu_btn.visible = true

	_play_feedback()
	_animate_in()

func _play_feedback() -> void:
	if AccessibilityService and AccessibilityService.is_haptics_enabled():
		AccessibilityService.vibrate(50 if _is_correct else 100)
	if AudioService:
		AudioService.play_ui("ui_click")

func _animate_in() -> void:
	if not _should_animate() or not result_icon:
		return
	result_icon.scale = Vector2.ZERO
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var dur := _get_anim_duration(0.35)
	var scale_tween := tween.tween_property(result_icon, "scale", Vector2.ONE, dur)
	scale_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _on_replay() -> void:
	if AudioService: AudioService.play_ui("ui_click")
	if AnalyticsService:
		AnalyticsService.log_event("replay_challenge", {"challenge_id": _result_data.get("challenge_id", "")})
	if ChallengeRegistry:
		ChallengeRegistry.replay_current()

func _on_continue() -> void:
	if AudioService: AudioService.play_ui("ui_click")
	_check_first_run_completion()
	if AnalyticsService:
		AnalyticsService.log_event("next_challenge", {"challenge_id": _result_data.get("challenge_id", "")})
	if ChallengeRegistry:
		ChallengeRegistry.go_to_next_challenge()

func _on_menu() -> void:
	if AudioService: AudioService.play_ui("ui_click")
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
	if needs_save and ProfileService:
		ProfileService.save()

func on_navigated_to(params: Dictionary) -> void:
	_result_data = params
	_apply_theme()
	_display_result(params)
	modulate.a = 1.0
