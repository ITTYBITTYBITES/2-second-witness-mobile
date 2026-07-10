extends Control
## TutorialScreen - Optional three-step explanation of the gameplay loop.

@onready var background: ColorRect = $Background
@onready var step_container: PanelContainer = $Margin/VBox/StepContainer
@onready var step_label: Label = $Margin/VBox/StepContainer/StepLabel
@onready var title_label: Label = $Margin/VBox/Title
@onready var desc_label: Label = $Margin/VBox/Description
@onready var next_button: Button = $Margin/VBox/Actions/NextButton
@onready var skip_button: Button = $Margin/VBox/Actions/SkipButton
@onready var page_indicator: HBoxContainer = $Margin/VBox/PageIndicator

var _current_step := 0
var _steps := [
	{"title": "Step 1: Observe", "desc": "You have exactly two seconds to study the scene. Every detail matters.", "marker": "OBSERVE"},
	{"title": "Step 2: Remember", "desc": "The image disappears. Hold on to colors, numbers, and positions.", "marker": "REMEMBER"},
	{"title": "Step 3: Recall", "desc": "Answer one focused question about what you saw.", "marker": "RECALL"}
]

func _ready() -> void:
	_apply_theme()
	_update_step()
	_animate_in()
	if ThemeService and not ThemeService.theme_changed.is_connected(_on_theme_changed):
		ThemeService.theme_changed.connect(_on_theme_changed)

func _apply_theme() -> void:
	if not ThemeService:
		return
	background.color = ThemeService.get_color("background")
	ThemeService.apply_label_style(title_label, "headline", "text_primary")
	ThemeService.apply_label_style(desc_label, "body", "text_secondary")
	ThemeService.apply_label_style(step_label, "headline", "primary_text")
	var card_style := StyleBoxFlat.new()
	card_style.bg_color = ThemeService.get_color("surface")
	card_style.border_color = ThemeService.get_color("border")
	card_style.set_border_width_all(1)
	card_style.set_corner_radius_all(20)
	step_container.add_theme_stylebox_override("panel", card_style)
	_style_button(next_button, true)
	_style_button(skip_button, false)
	_update_indicators()

func _style_button(button: Button, primary: bool) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = ThemeService.get_color("primary") if primary else Color.TRANSPARENT
	style.set_corner_radius_all(12)
	if not primary:
		style.border_color = ThemeService.get_color("border")
		style.set_border_width_all(1)
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("focus", style)
	button.add_theme_color_override("font_color", ThemeService.get_color("text_on_primary") if primary else ThemeService.get_color("text_secondary"))
	ThemeService.apply_typography(button, "button")
	button.custom_minimum_size.y = maxf(button.custom_minimum_size.y, 48.0)
	button.focus_mode = Control.FOCUS_ALL

func _update_step() -> void:
	var data: Dictionary = _steps[_current_step]
	title_label.text = str(data["title"])
	desc_label.text = str(data["desc"])
	step_label.text = str(data["marker"])
	next_button.text = "Next" if _current_step < _steps.size() - 1 else "Start Challenge"
	_update_indicators()

func _update_indicators() -> void:
	if not page_indicator or not ThemeService:
		return
	for index in range(page_indicator.get_child_count()):
		var dot := page_indicator.get_child(index)
		if dot is ColorRect:
			dot.color = ThemeService.get_color("primary_text") if index == _current_step else ThemeService.get_color("border")

func _on_next_pressed() -> void:
	if _current_step < _steps.size() - 1:
		_current_step += 1
		_animate_step_transition()
	else:
		_finish_tutorial()

func _on_skip_pressed() -> void:
	_finish_tutorial()

func _animate_in() -> void:
	if AccessibilityService and AccessibilityService.is_reduced_motion_enabled():
		modulate.a = 1.0
		return
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.25)

func _animate_step_transition() -> void:
	if AccessibilityService and AccessibilityService.is_reduced_motion_enabled():
		_update_step()
		return
	var tween := create_tween()
	tween.tween_property(step_container, "modulate:a", 0.0, 0.12)
	tween.tween_callback(_update_step)
	tween.tween_property(step_container, "modulate:a", 1.0, 0.16)

func _finish_tutorial() -> void:
	if AccessibilityService and AccessibilityService.is_reduced_motion_enabled():
		_open_first_challenge()
		return
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.finished.connect(_open_first_challenge)

func _open_first_challenge() -> void:
	if ChallengeRegistry:
		ChallengeRegistry.start_run("challenge_01")
	elif NavigationService:
		NavigationService.navigate_to("observation", {"challenge_id": "challenge_01"})

func on_navigated_to(_params: Dictionary) -> void:
	_current_step = 0
	modulate.a = 1.0
	_update_step()

func _on_theme_changed(_theme: String, _tokens: Dictionary) -> void:
	_apply_theme()
