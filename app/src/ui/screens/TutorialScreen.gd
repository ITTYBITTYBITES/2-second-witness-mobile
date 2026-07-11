extends Control
## TutorialScreen - Witness onboarding, premium
## 3-step: Observe / Remember / Recall
## Matches HomeScreen / TitleSplash visual language

@onready var brand_label: Label = $MainMargin/Content/Hero/BrandLabel
@onready var step_title: Label = $MainMargin/Content/Hero/StepTitle
@onready var eye_rect: TextureRect = $MainMargin/Content/Hero/EyeWrap/Eye
@onready var description_label: Label = $MainMargin/Content/Hero/Description
@onready var page_indicator: HBoxContainer = $MainMargin/Content/PageIndicator
@onready var next_button: Button = $MainMargin/Content/Actions/NextButton
@onready var skip_button: Button = $MainMargin/Content/Actions/SkipButton

var _current_step: int = 0
var _eye_tween: Tween = null

var _steps := [
	{
		"title": "OBSERVE",
		"desc": "You have exactly two seconds to study the scene. Every detail matters.",
		"eye_alpha": 1.0,
		"eye_scale": 1.0,
		"pulse": true
	},
	{
		"title": "REMEMBER",
		"desc": "The image disappears. Focus on what you saw — colors, numbers, positions.",
		"eye_alpha": 0.55,
		"eye_scale": 0.97,
		"pulse": false
	},
	{
		"title": "RECALL",
		"desc": "Answer a single question correctly to prove your witness status.",
		"eye_alpha": 1.0,
		"eye_scale": 1.0,
		"pulse": false
	}
]

func _ready() -> void:
	_apply_theme()
	_update_step(false)
	_animate_in()
	_wire_buttons()

func _wire_buttons() -> void:
	if next_button and not next_button.pressed.is_connected(_on_next_pressed):
		next_button.pressed.connect(_on_next_pressed)
	if skip_button and not skip_button.pressed.is_connected(_on_skip_pressed):
		skip_button.pressed.connect(_on_skip_pressed)

func _get_anim_duration(base: float) -> float:
	if AccessibilityService and AccessibilityService.has_method("get_animation_duration"):
		return AccessibilityService.get_animation_duration(base)
	return base

func _should_animate() -> bool:
	if AccessibilityService and AccessibilityService.has_method("should_animate"):
		return AccessibilityService.should_animate()
	return true

func _apply_theme() -> void:
	var tokens := {}
	if ThemeService and not ThemeService.tokens.is_empty():
		tokens = ThemeService.tokens

	var bg := get_node_or_null("Background") as ColorRect
	if bg:
		bg.color = tokens.get("background", Color("#0F0F12")) if not tokens.is_empty() else Color("#0F0F12")

	if brand_label:
		if ThemeService:
			ThemeService.apply_label_style(brand_label, "label", "text_tertiary")
			brand_label.add_theme_font_size_override("font_size", 16)
	if step_title:
		if ThemeService:
			ThemeService.apply_label_style(step_title, "display", "text_primary")
			step_title.add_theme_font_size_override("font_size", 42)
	if description_label:
		if ThemeService:
			ThemeService.apply_label_style(description_label, "body_small", "text_secondary")
		description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	_style_buttons(tokens)
	_update_indicators()

func _style_buttons(tokens: Dictionary) -> void:
	if not next_button:
		return
	var primary := tokens.get("primary", Color("#6A3DFF")) if not tokens.is_empty() else Color("#6A3DFF")
	var radius := tokens.get("radius_lg", 18) if not tokens.is_empty() else 18
	
	var normal := StyleBoxFlat.new()
	normal.bg_color = primary
	normal.corner_radius_top_left = radius
	normal.corner_radius_top_right = radius
	normal.corner_radius_bottom_left = radius
	normal.corner_radius_bottom_right = radius
	normal.content_margin_left = 24
	normal.content_margin_right = 24
	normal.content_margin_top = 18
	normal.content_margin_bottom = 18
	
	var hover := normal.duplicate()
	hover.bg_color = tokens.get("primary_variant", Color("#8A68FF")) if not tokens.is_empty() else Color("#8A68FF")
	var pressed := normal.duplicate()
	pressed.bg_color = primary.darkened(0.15)
	
	next_button.add_theme_stylebox_override("normal", normal)
	next_button.add_theme_stylebox_override("hover", hover)
	next_button.add_theme_stylebox_override("pressed", pressed)
	next_button.add_theme_stylebox_override("focus", hover)
	next_button.add_theme_color_override("font_color", Color.WHITE)
	if ThemeService:
		next_button.add_theme_font_size_override("font_size", ThemeService.get_font_size("button"))
	next_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	next_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	if skip_button:
		skip_button.add_theme_color_override("font_color", tokens.get("text_tertiary", Color("#8A8AA3")) if not tokens.is_empty() else Color("#8A8AA3"))
		if ThemeService:
			skip_button.add_theme_font_size_override("font_size", ThemeService.get_font_size("label"))
		skip_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func _update_step(animate: bool = true) -> void:
	if _current_step < 0 or _current_step >= _steps.size():
		return
	var data = _steps[_current_step]
	
	if step_title:
		step_title.text = data["title"]
	if description_label:
		description_label.text = data["desc"]
	
	# Eye state per step – Observe = pulsing open, Remember = dimmed/closed, Recall = steady open
	_apply_eye_state(data, animate)
	
	if next_button:
		if _current_step < _steps.size() - 1:
			next_button.text = "NEXT  →"
		else:
			next_button.text = "START CHALLENGE  ▶"
	
	_update_indicators()

func _apply_eye_state(data: Dictionary, animate: bool) -> void:
	if not eye_rect:
		return
	if _eye_tween and _eye_tween.is_valid():
		_eye_tween.kill()
	
	var target_alpha: float = data.get("eye_alpha", 1.0)
	var target_scale: float = data.get("eye_scale", 1.0)
	var pulse: bool = data.get("pulse", false) and _should_animate()
	
	if not animate or not _should_animate():
		eye_rect.modulate.a = target_alpha
		eye_rect.scale = Vector2(target_scale, target_scale)
		if pulse:
			_start_eye_pulse()
		return
	
	var t := create_tween()
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_property(eye_rect, "modulate:a", target_alpha, _get_anim_duration(0.25))
	t.parallel().tween_property(eye_rect, "scale", Vector2(target_scale, target_scale), _get_anim_duration(0.25))
	t.finished.connect(func():
		if pulse:
			_start_eye_pulse()
	)
	
func _start_eye_pulse() -> void:
	if not eye_rect or not _should_animate():
		return
	if _eye_tween and _eye_tween.is_valid():
		_eye_tween.kill()
	var breathe := _get_anim_duration(1.2)
	_eye_tween = create_tween()
	_eye_tween.set_loops()
	_eye_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_eye_tween.tween_property(eye_rect, "modulate:a", 0.92, breathe)
	_eye_tween.tween_property(eye_rect, "modulate:a", 1.0, breathe)
	_eye_tween.parallel()
	_eye_tween.tween_property(eye_rect, "scale", Vector2(1.015, 1.015), breathe)
	_eye_tween.tween_property(eye_rect, "scale", Vector2.ONE, breathe)

func _stop_eye_pulse() -> void:
	if _eye_tween and _eye_tween.is_valid():
		_eye_tween.kill()
	_eye_tween = null
	if eye_rect:
		eye_rect.modulate.a = 1.0
		eye_rect.scale = Vector2.ONE

func _update_indicators() -> void:
	if not page_indicator:
		return
	var tokens := ThemeService.tokens if ThemeService else {}
	var primary := tokens.get("primary", Color("#6A3DFF")) if not tokens.is_empty() else Color("#6A3DFF")
	var border := tokens.get("border", Color("#2E2E3A")) if not tokens.is_empty() else Color("#2E2E3A")
	
	var dots := [
		page_indicator.get_node_or_null("Dot1"),
		page_indicator.get_node_or_null("Dot2"),
		page_indicator.get_node_or_null("Dot3")
	]
	for i in range(dots.size()):
		var dot = dots[i]
		if dot is PanelContainer:
			var sb := StyleBoxFlat.new()
			sb.bg_color = primary if i == _current_step else border
			sb.corner_radius_top_left = 99
			sb.corner_radius_top_right = 99
			sb.corner_radius_bottom_left = 99
			sb.corner_radius_bottom_right = 99
			dot.add_theme_stylebox_override("panel", sb)

func _on_next_pressed() -> void:
	if AccessibilityService:
		AccessibilityService.vibrate(30)
	if AudioService:
		AudioService.play_ui("ui_click")
	
	if _current_step < _steps.size() - 1:
		_current_step += 1
		_animate_step_transition()
	else:
		_finish_tutorial()

func _on_skip_pressed() -> void:
	if AccessibilityService:
		AccessibilityService.vibrate(20)
	if AudioService:
		AudioService.play_ui("ui_click")
	_finish_tutorial()

func _animate_in() -> void:
	modulate.a = 0.0
	if not _should_animate():
		modulate.a = 1.0
		return
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate:a", 1.0, _get_anim_duration(0.35))

func _animate_step_transition() -> void:
	if not _should_animate():
		_update_step(false)
		return
	var hero := get_node_or_null("MainMargin/Content/Hero")
	if not hero:
		_update_step(false)
		return
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(hero, "modulate:a", 0.0, _get_anim_duration(0.15))
	tween.tween_callback(func(): _update_step(true))
	tween.tween_property(hero, "modulate:a", 1.0, _get_anim_duration(0.2))

func _finish_tutorial() -> void:
	_stop_eye_pulse()
	# Mark tutorial seen in Profile – onboarding_completed is set at first Result, preserving original flow
	if ProfileService:
		var prefs: Dictionary = ProfileService.profile.get("preferences", {})
		prefs["tutorial_seen"] = true
		ProfileService.profile["preferences"] = prefs
		ProfileService.save()
	if SettingsService:
		SettingsService.set_value("show_tutorials", false)
	
	var fade_dur := _get_anim_duration(0.3)
	if not _should_animate():
		_go_to_first_challenge()
		return
	
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate:a", 0.0, fade_dur)
	tween.finished.connect(_go_to_first_challenge)

func _go_to_first_challenge() -> void:
	if ChallengeRegistry:
		ChallengeRegistry.start_run("challenge_01")
	elif NavigationService:
		NavigationService.navigate_to("observation", {"challenge_id": "challenge_01"})

func on_navigated_to(_params: Dictionary) -> void:
	_current_step = 0
	_update_step(false)
	modulate.a = 1.0
	_apply_theme()
	if AnalyticsService:
		AnalyticsService.log_screen_view("tutorial")
