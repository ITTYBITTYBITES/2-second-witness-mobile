extends Control
## TutorialScreen - 3-step animated tutorial (Observe, Remember, Recall)
## Part of the first-run experience before the first gameplay challenge.

@onready var step_container: Control = $Margin/StepContainer
@onready var title_label: Label = $Margin/VBox/Title
@onready var desc_label: Label = $Margin/VBox/Description
@onready var next_button: Button = $Margin/VBox/Actions/NextButton
@onready var skip_button: Button = $Margin/VBox/Actions/SkipButton
@onready var page_indicator: HBoxContainer = $Margin/VBox/PageIndicator

var _current_step: int = 0
var _steps := [
	{
		"title": "Step 1: Observe",
		"desc": "You have exactly two seconds to study the scene. Every detail matters.",
		"icon": "eye"
	},
	{
		"title": "Step 2: Remember",
		"desc": "The image disappears. Focus on what you saw — colors, numbers, positions.",
		"icon": "brain"
	},
	{
		"title": "Step 3: Recall",
		"desc": "Answer a single question correctly to prove your witness status.",
		"icon": "check"
	}
]

func _ready() -> void:
	_apply_theme()
	_update_step()
	_animate_in()

func _apply_theme() -> void:
	if not ThemeService:
		return
	var tokens = ThemeService.tokens
	if title_label:
		ThemeService.apply_label_style(title_label, "headline", "text_primary")
	if desc_label:
		ThemeService.apply_label_style(desc_label, "body", "text_secondary")
		desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	if next_button:
		# Use a style similar to AppButton (which isn't a node but a script)
		# Actually we can just use the button style from ThemeService
		pass

func _update_step() -> void:
	var data = _steps[_current_step]
	if title_label:
		title_label.text = data["title"]
	if desc_label:
		desc_label.text = data["desc"]

	if has_node("Margin/VBox/StepContainer/PlaceholderIcon"):
		var icon_label = get_node("Margin/VBox/StepContainer/PlaceholderIcon") as Label
		match data["icon"]:
			"eye": icon_label.text = "👁"
			"brain": icon_label.text = "🧠"
			"check": icon_label.text = "✓"

	if next_button:
		next_button.text = "Next" if _current_step < _steps.size() - 1 else "Start Challenge"

	_update_indicators()

func _update_indicators() -> void:
	if not page_indicator:
		return
	for i in range(page_indicator.get_child_count()):
		var dot = page_indicator.get_child(i)
		if dot is ColorRect:
			dot.color = ThemeService.get_color("primary") if i == _current_step else ThemeService.get_color("border")

func _on_next_pressed() -> void:
	if AudioService:
		AudioService.play_ui("ui_click")

	if _current_step < _steps.size() - 1:
		_current_step += 1
		_animate_step_transition()
	else:
		_finish_tutorial()

func _on_skip_pressed() -> void:
	if AudioService:
		AudioService.play_ui("ui_click")
	_finish_tutorial()

func _animate_in() -> void:
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.4)

func _animate_step_transition() -> void:
	var tween = create_tween()
	tween.tween_property(step_container, "modulate:a", 0.0, 0.15)
	tween.tween_callback(_update_step)
	tween.tween_property(step_container, "modulate:a", 1.0, 0.2)

func _finish_tutorial() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.finished.connect(func():
		if ChallengeRegistry:
			ChallengeRegistry.start_run("challenge_01")
		elif NavigationService:
			NavigationService.navigate_to("observation", {"challenge_id": "challenge_01"})
	)

func on_navigated_to(_params: Dictionary) -> void:
	_current_step = 0
	_update_step()
	modulate.a = 1.0
	if AnalyticsService:
		AnalyticsService.log_screen_view("tutorial")
