extends Control
## TutorialScreen - Short tutorial explaining concept within 30 seconds

@onready var title_label: Label = $Margin/VBox/TitleHeader/Title
@onready var step_label: Label = $Margin/VBox/Header/StepCounter
@onready var image_rect: Control = $Margin/VBox/TutorialImage
@onready var desc_label: Label = $Margin/VBox/Description
@onready var next_btn: Button = $Margin/VBox/NextButton
@onready var skip_btn: Button = $Margin/VBox/Header/SkipButton

var _current_step: int = 0
const TUTORIAL_STEPS := [
	{
		"title": "Observe",
		"desc": "You will have exactly 2 seconds to observe a detailed scene. Focus your attention.",
		"image": "",
		"icon": "👁"
	},
	{
		"title": "Remember",
		"desc": "Notice details, objects, patterns, and subtle differences. Your memory will be tested.",
		"image": "",
		"icon": "🧠"
	},
	{
		"title": "Recall",
		"desc": "Answer a question from memory. How much can you notice in two seconds?",
		"image": "",
		"icon": "💭"
	}
]

func _ready() -> void:
	_apply_theme()
	_ensure_wired()
	_show_step(0)

func _ensure_wired() -> void:
	if has_node("Margin/VBox/NextButton"):
		var btn = $Margin/VBox/NextButton
		if not btn.pressed.is_connected(_on_next):
			btn.pressed.connect(_on_next)
	if has_node("Margin/VBox/Header/SkipButton"):
		var skip = $Margin/VBox/Header/SkipButton
		if not skip.pressed.is_connected(_on_skip):
			skip.pressed.connect(_on_skip)

func _apply_theme() -> void:
	if not ThemeService:
		return
	var tokens = ThemeService.tokens
	if title_label:
		title_label.add_theme_color_override("font_color", tokens.get("primary", Color("#7C5CFF")))
	if desc_label:
		desc_label.add_theme_color_override("font_color", tokens.get("text_secondary", Color.GRAY))

func _show_step(index: int) -> void:
	if index < 0 or index >= TUTORIAL_STEPS.size():
		return
	_current_step = index
	var step = TUTORIAL_STEPS[index]
	
	if title_label:
		title_label.text = "%s %s" % [step.get("icon",""), step.get("title","")]
	if desc_label:
		desc_label.text = step.get("desc","")
	if step_label:
		step_label.text = "%d/%d" % [index+1, TUTORIAL_STEPS.size()]
	
	if next_btn:
		if index == TUTORIAL_STEPS.size() - 1:
			next_btn.text = "Start First Challenge"
		else:
			next_btn.text = "Next"
	
	# Animate
	_animate_step_change()

func _animate_step_change() -> void:
	if AccessibilityService and AccessibilityService.is_reduced_motion_enabled():
		return
	if has_node("Margin/VBox/TutorialImage"):
		var img = $Margin/VBox/TutorialImage
		img.modulate.a = 0.0
		img.scale = Vector2(0.95, 0.95)
		var tween = create_tween()
		tween.parallel().tween_property(img, "modulate:a", 1.0, 0.3)
		tween.parallel().tween_property(img, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _on_next() -> void:
	if AccessibilityService:
		AccessibilityService.vibrate(20)
	if AudioService:
		AudioService.play_ui("ui_click")
	
	if _current_step < TUTORIAL_STEPS.size() - 1:
		_show_step(_current_step + 1)
	else:
		_finish_tutorial()

func _on_skip() -> void:
	if AudioService:
		AudioService.play_ui("ui_click")
	_finish_tutorial()

func _finish_tutorial() -> void:
	if AnalyticsService:
		AnalyticsService.log_event("tutorial_completed", {"steps": TUTORIAL_STEPS.size()})
	if ChallengeRegistry:
		ChallengeRegistry.start_run("challenge_01")
	elif NavigationService:
		NavigationService.navigate_to("observation")

func on_navigated_to(_params: Dictionary) -> void:
	_show_step(0)
	if AnalyticsService:
		AnalyticsService.log_screen_view("tutorial")
