extends Control
## SettingsScreen - Production mobile preferences.
## Only controls backed by working runtime behavior are presented.

@onready var scroll: ScrollContainer = $Margin/Scroll
@onready var vbox: VBoxContainer = $Margin/Scroll/VBox

var _reset_button: Button = null
var _reset_armed := false
var _reset_timer: SceneTreeTimer = null

func _ready() -> void:
	_refresh()
	if SettingsService and not SettingsService.setting_changed.is_connected(_on_setting_changed):
		SettingsService.setting_changed.connect(_on_setting_changed)
	if ThemeService and not ThemeService.theme_changed.is_connected(_on_theme_changed):
		ThemeService.theme_changed.connect(_on_theme_changed)

func _refresh() -> void:
	if not vbox or not SettingsService:
		return
	for child in vbox.get_children():
		vbox.remove_child(child)
		child.queue_free()

	var title := Label.new()
	title.text = "Settings"
	ThemeService.apply_label_style(title, "headline", "text_primary")
	vbox.add_child(title)

	vbox.add_child(_create_section_header("Appearance"))
	vbox.add_child(_create_setting_row_toggle(
		"Dark mode", "theme_mode", SettingsService.get_theme_mode() == "dark", _on_theme_toggle
	))
	vbox.add_child(_create_setting_row_toggle(
		"Reduce motion", "reduced_motion", SettingsService.is_reduced_motion(), _on_generic_toggle
	))
	vbox.add_child(_create_setting_row_slider(
		"Text size", "font_scale", SettingsService.get_font_scale(), 0.8, 1.4, 0.1
	))
	vbox.add_child(_create_setting_row_toggle(
		"High contrast", "high_contrast",
		SettingsService.get_value("high_contrast", false), _on_generic_toggle
	))

	vbox.add_child(_create_section_header("Feedback"))
	vbox.add_child(_create_setting_row_toggle(
		"Haptic feedback", "haptics_enabled",
		SettingsService.get_value("haptics_enabled", true), _on_generic_toggle
	))

	vbox.add_child(_create_section_header("Privacy & data"))
	var privacy_note := Label.new()
	privacy_note.text = "Optional usage diagnostics stay on this device and are never uploaded."
	privacy_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ThemeService.apply_label_style(privacy_note, "caption", "text_secondary")
	vbox.add_child(privacy_note)
	vbox.add_child(_create_setting_row_toggle(
		"On-device diagnostics", "analytics_enabled",
		SettingsService.get_value("analytics_enabled", false), _on_generic_toggle
	))

	vbox.add_child(_create_section_header("About"))
	var version := "4.0.0"
	if ConfigService:
		version = str(ConfigService.get_value("app_version", version))
	vbox.add_child(_create_info_row("Version", version))

	var about_btn := _create_action_button("About & privacy", true)
	about_btn.pressed.connect(_on_about_pressed)
	vbox.add_child(about_btn)

	_reset_button = _create_action_button("Restore default settings", false)
	_reset_button.pressed.connect(_on_reset_settings)
	vbox.add_child(_reset_button)

func _create_section_header(text: String) -> Label:
	var label := Label.new()
	label.text = text
	ThemeService.apply_label_style(label, "label", "primary_text")
	return label

func _create_card() -> PanelContainer:
	var card := PanelContainer.new()
	var style := StyleBoxFlat.new()
	var tokens := ThemeService.tokens
	style.bg_color = tokens.get("surface", Color("#1E1E26"))
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.border_color = tokens.get("border", Color.GRAY)
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	card.add_theme_stylebox_override("panel", style)
	return card

func _create_setting_row_toggle(
	label_text: String, key: String, value: bool, callback: Callable
) -> Control:
	var card := _create_card()
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 56)
	card.add_child(row)

	var label := Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ThemeService.apply_label_style(label, "body_small", "text_primary")
	row.add_child(label)

	var toggle := CheckButton.new()
	toggle.custom_minimum_size = Vector2(48, 48)
	toggle.button_pressed = value
	toggle.focus_mode = Control.FOCUS_ALL
	toggle.set_meta("key", key)
	toggle.toggled.connect(func(enabled: bool): callback.call(key, enabled))
	row.add_child(toggle)
	return card

func _create_setting_row_slider(
	label_text: String, key: String, value: float, min_value: float, max_value: float, step: float
) -> Control:
	var card := _create_card()
	var column := VBoxContainer.new()
	card.add_child(column)

	var heading := HBoxContainer.new()
	column.add_child(heading)
	var label := Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ThemeService.apply_label_style(label, "body_small", "text_primary")
	heading.add_child(label)
	var value_label := Label.new()
	value_label.text = _format_slider_value(key, value)
	ThemeService.apply_label_style(value_label, "body_small", "text_secondary")
	heading.add_child(value_label)

	var slider := HSlider.new()
	slider.custom_minimum_size = Vector2(0, 48)
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = step
	slider.value = value
	slider.focus_mode = Control.FOCUS_ALL
	slider.set_meta("dragging", false)
	slider.drag_started.connect(func(): slider.set_meta("dragging", true))
	slider.value_changed.connect(func(new_value: float):
		value_label.text = _format_slider_value(key, new_value)
		# Keyboard/assistive input has no drag-ended signal.
		if not bool(slider.get_meta("dragging", false)) and SettingsService:
			SettingsService.call_deferred("set_value", key, new_value)
	)
	slider.drag_ended.connect(func(value_changed: bool):
		slider.set_meta("dragging", false)
		if value_changed and SettingsService:
			SettingsService.set_value(key, slider.value)
	)
	column.add_child(slider)
	return card

func _format_slider_value(key: String, value: float) -> String:
	if key == "font_scale":
		return "%d%%" % int(round(value * 100.0))
	return "%.1f" % value

func _create_info_row(label_text: String, value_text: String) -> Control:
	var card := _create_card()
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 48)
	card.add_child(row)
	var label := Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ThemeService.apply_label_style(label, "body_small", "text_primary")
	row.add_child(label)
	var value := Label.new()
	value.text = value_text
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	ThemeService.apply_label_style(value, "caption", "text_secondary")
	row.add_child(value)
	return card

func _create_action_button(text: String, primary: bool) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 52)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.focus_mode = Control.FOCUS_ALL
	ThemeService.apply_typography(button, "button")
	var style := StyleBoxFlat.new()
	style.bg_color = ThemeService.get_color("primary") if primary else ThemeService.get_color("surface")
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.border_color = ThemeService.get_color("border")
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("focus", style)
	button.add_theme_color_override(
		"font_color", ThemeService.get_color("text_on_primary") if primary else ThemeService.get_color("text_primary")
	)
	return button

func on_navigated_to(_params: Dictionary) -> void:
	_refresh()

func _on_generic_toggle(key: String, value: bool) -> void:
	if SettingsService:
		SettingsService.set_value(key, value)
	if AccessibilityService:
		AccessibilityService.vibrate(20)

func _on_theme_toggle(_key: String, is_dark: bool) -> void:
	if SettingsService:
		SettingsService.set_value("theme_mode", "dark" if is_dark else "light")
	if AccessibilityService:
		AccessibilityService.vibrate(20)

func _on_about_pressed() -> void:
	if NavigationService:
		NavigationService.navigate_to("about")

func _on_reset_settings() -> void:
	if not _reset_armed:
		_reset_armed = true
		if _reset_button:
			_reset_button.text = "Tap again to confirm"
		_reset_timer = get_tree().create_timer(4.0)
		_reset_timer.timeout.connect(_disarm_reset)
		return
	_reset_armed = false
	if SettingsService:
		SettingsService.reset_to_defaults()
	_refresh()

func _disarm_reset() -> void:
	_reset_armed = false
	if is_instance_valid(_reset_button):
		_reset_button.text = "Restore default settings"

func _on_setting_changed(_key: String, _value: Variant) -> void:
	# Rows update their own state. Full rebuilds while a slider is being dragged
	# would destroy the active control and make the slider unusable.
	pass

func _on_theme_changed(_theme: String, _tokens: Dictionary) -> void:
	_refresh()
