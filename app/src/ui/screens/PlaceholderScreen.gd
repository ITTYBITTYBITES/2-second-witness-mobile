extends Control
## Safe mobile fallback for registered routes without a production scene.

@export var route_name: String = "unknown"

func _ready() -> void:
	if has_node("Center"):
		return
	var center := CenterContainer.new()
	center.name = "Center"
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	center.add_child(margin)
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 16)
	margin.add_child(column)
	var label := Label.new()
	label.name = "Message"
	label.text = "This experience is not available yet."
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if ThemeService:
		ThemeService.apply_label_style(label, "body", "text_secondary")
	column.add_child(label)
	var back := Button.new()
	back.text = "Back to Home"
	back.custom_minimum_size = Vector2(240, 52)
	back.focus_mode = Control.FOCUS_ALL
	if ThemeService:
		ThemeService.apply_typography(back, "button")
	back.pressed.connect(func():
		if NavigationService:
			NavigationService.navigate_to("home")
	)
	column.add_child(back)

func on_navigated_to(params: Dictionary) -> void:
	route_name = str(params.get("route", route_name))
