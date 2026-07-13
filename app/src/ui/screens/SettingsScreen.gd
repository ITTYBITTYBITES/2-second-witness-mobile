extends Control
## Complete local settings and accessibility surface.

const SETTING_HELP := {
	"theme_mode": "Switch between the dark and light interface palettes.",
	"reduced_motion": "Removes decorative movement and shortens transitions.",
	"font_scale": "Scales interface text from 0.8× to 1.4×.",
	"volume_master": "Controls every sound in the app.",
	"volume_bgm": "Controls music when a screen provides it.",
	"volume_sfx": "Controls gameplay and result cues.",
	"volume_ui": "Controls taps and navigation feedback.",
	"mute_master": "Silences all audio without changing volume levels.",
	"haptics_enabled": "Enables short touch feedback on supported devices.",
	"reading_comfort_mode": "Uses larger word presentation and steadier timing.",
	"high_contrast": "Strengthens text, borders, and gameplay evidence.",
	"color_assist_mode": "Avoids color-only questions and reinforces visual cues.",
	"accessibility_screen_reader_hints": "Uses registered accessible interaction alternatives when available.",
	"show_tutorials": "Presents a Challenge Type tutorial before its first round.",
	"comfortable_timing": "Extends observation timing without reducing progress.",
	"analytics_enabled": "Stores anonymous app activity locally. Nothing is uploaded."
}

@onready var scroll: ScrollContainer = $Margin/Scroll
@onready var vbox: VBoxContainer = $Margin/Scroll/VBox

var _refresh_pending: bool = false
var _refresh_timer: Timer = null
var _reset_dialog: ConfirmationDialog = null

func _ready() -> void:
	_refresh_timer = Timer.new()
	_refresh_timer.one_shot = true
	_refresh_timer.wait_time = 0.2
	_refresh_timer.timeout.connect(_refresh)
	add_child(_refresh_timer)
	_ensure_reset_dialog()
	_ensure_ui()
	_apply_responsive_layout()
	if not resized.is_connected(_apply_responsive_layout):
		resized.connect(_apply_responsive_layout)
	_apply_theme()
	_refresh()

	if SettingsService:
		SettingsService.setting_changed.connect(_on_setting_changed)
	if ThemeService:
		ThemeService.theme_changed.connect(_on_theme_changed)


func _ensure_ui() -> void:
	if has_node("Margin/Scroll/VBox"):
		return

	var margin := MarginContainer.new()
	margin.name = "Margin"
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 80)
	margin.add_theme_constant_override("margin_bottom", 90)
	add_child(margin)

	var s := ScrollContainer.new()
	s.name = "Scroll"
	margin.add_child(s)

	var vb := VBoxContainer.new()
	vb.name = "VBox"
	vb.add_theme_constant_override("separation", 24)
	s.add_child(vb)

	# Sections will be created in _refresh

	scroll = s
	vbox = vb


func _apply_responsive_layout() -> void:
	ResponsiveLayout.apply_centered_margin($Margin)

func _apply_theme() -> void:
	var background: ColorRect = get_node_or_null("Background") as ColorRect
	if background and ThemeService:
		background.color = ThemeService.get_color("background", Color("#0F0F12"))
	# Theme is applied per-row in _refresh; just trigger refresh.
	if is_node_ready() and is_visible_in_tree():
		_refresh()


func _refresh() -> void:
	if not has_node("Margin/Scroll/VBox"):
		return
	var vb: VBoxContainer = $Margin/Scroll/VBox
	for child in vb.get_children():
		child.queue_free()

	if not SettingsService:
		return

	var title := Label.new()
	title.text = "Settings"
	if ThemeService:
		ThemeService.apply_label_style(title, "headline", "text_primary")
	else:
		title.add_theme_font_size_override("font_size", 28)
	vb.add_child(title)

	# Appearance Section
	vb.add_child(_create_section_header("Appearance"))
	vb.add_child(
		_create_setting_row_toggle(
			"Dark Mode",
			"theme_mode",
			SettingsService.get_value("theme_mode", "dark") == "dark",
			_on_theme_toggle
		)
	)
	vb.add_child(
		_create_setting_row_toggle(
			"Reduced Motion",
			"reduced_motion",
			SettingsService.get_value("reduced_motion", false),
			_on_generic_toggle
		)
	)
	vb.add_child(
		_create_setting_row_slider(
			"Text Size", "font_scale", SettingsService.get_value("font_scale", 1.0), 0.8, 1.4, 0.1
		)
	)

	# Audio Section
	vb.add_child(_create_section_header("Audio"))
	vb.add_child(
		_create_setting_row_slider(
			"Audio Level",
			"volume_master",
			SettingsService.get_value("volume_master", 1.0),
			0.0,
			1.0,
			0.1
		)
	)
	vb.add_child(
		_create_setting_row_slider(
			"Music", "volume_bgm", SettingsService.get_value("volume_bgm", 0.7), 0.0, 1.0, 0.1
		)
	)
	vb.add_child(
		_create_setting_row_slider(
			"Sound Effects", "volume_sfx", SettingsService.get_value("volume_sfx", 0.9), 0.0, 1.0, 0.1
		)
	)
	vb.add_child(
		_create_setting_row_slider(
			"Interface Sounds", "volume_ui", SettingsService.get_value("volume_ui", 0.8), 0.0, 1.0, 0.1
		)
	)
	vb.add_child(
		_create_setting_row_toggle(
			"Mute All Audio",
			"mute_master",
			SettingsService.get_value("mute_master", false),
			_on_generic_toggle
		)
	)
	vb.add_child(
		_create_setting_row_toggle(
			"Haptics",
			"haptics_enabled",
			SettingsService.get_value("haptics_enabled", true),
			_on_generic_toggle
		)
	)

	# Accessibility Section
	vb.add_child(_create_section_header("Accessibility"))
	vb.add_child(
		_create_setting_row_toggle(
			"Reading Comfort Mode",
			"reading_comfort_mode",
			SettingsService.get_value("reading_comfort_mode", false),
			_on_generic_toggle
		)
	)
	vb.add_child(
		_create_setting_row_toggle(
			"High Contrast",
			"high_contrast",
			SettingsService.get_value("high_contrast", false),
			_on_generic_toggle
		)
	)
	vb.add_child(
		_create_setting_row_toggle(
			"Color Assistance",
			"color_assist_mode",
			SettingsService.get_value("color_assist_mode", false),
			_on_generic_toggle
		)
	)
	vb.add_child(
		_create_setting_row_toggle(
			"Screen Reader Hints",
			"accessibility_screen_reader_hints",
			SettingsService.get_value("accessibility_screen_reader_hints", false),
			_on_generic_toggle
		)
	)

	# Gameplay
	vb.add_child(_create_section_header("Gameplay"))
	vb.add_child(
		_create_setting_row_toggle(
			"Show Tutorials",
			"show_tutorials",
			SettingsService.get_value("show_tutorials", true),
			_on_generic_toggle
		)
	)
	vb.add_child(
		_create_setting_row_toggle(
			"Comfortable Timing",
			"comfortable_timing",
			SettingsService.get_value("comfortable_timing", false),
			_on_generic_toggle
		)
	)

	# Privacy
	vb.add_child(_create_section_header("Privacy & Data"))
	vb.add_child(
		_create_setting_row_toggle(
			"Analytics",
			"analytics_enabled",
			SettingsService.get_value("analytics_enabled", true),
			_on_generic_toggle
		)
	)
	vb.add_child(_create_info_row("Storage", "Progress and diagnostics stay on this device"))
	vb.add_child(_create_info_row("Offline Play", "All Challenge Types work without a connection"))

	# About
	vb.add_child(_create_section_header("About"))
	vb.add_child(
		_create_info_row(
			"App Version",
			ConfigService.get_value("app_version", "2.0.0") if ConfigService else "2.0.0"
		)
	)
	vb.add_child(
		_create_info_row(
			"Package ID",
			(
				ConfigService.get_value("package_id", "com.ittybittybites.the2secondwitness")
				if ConfigService
				else "com.ittybittybites.the2secondwitness"
			)
		)
	)
	vb.add_child(_create_info_row("Build", "Production Readiness - ITTYBITTYBITES"))
	vb.add_child(_create_info_row("Engine", "Godot 4.6 / GL Compatibility"))

	for destination: Dictionary in [
		{"label": "Privacy", "section": "privacy"},
		{"label": "Credits", "section": "credits"},
		{"label": "About", "section": "about"}
	]:
		var destination_button := Button.new()
		destination_button.text = str(destination.get("label", "About"))
		destination_button.custom_minimum_size = Vector2(0, 52)
		destination_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if ThemeService:
			ThemeService.apply_typography(destination_button, "button")
		vb.add_child(destination_button)
		destination_button.pressed.connect(
			_on_about_pressed.bind(str(destination.get("section", "about")))
		)

	var reset_btn := Button.new()
	reset_btn.text = "Reset All Settings"
	reset_btn.custom_minimum_size = Vector2(0, 48)
	reset_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if ThemeService:
		ThemeService.apply_typography(reset_btn, "button")
	vb.add_child(reset_btn)
	reset_btn.pressed.connect(_on_reset_settings)


func _create_section_header(text: String) -> Control:
	var lbl := Label.new()
	lbl.text = text
	if ThemeService:
		ThemeService.apply_label_style(lbl, "label", "primary")
	else:
		lbl.add_theme_font_size_override("font_size", 18)
		lbl.add_theme_color_override("font_color", Color("#6A3DFF"))
	return lbl


func _create_setting_row_toggle(
	label: String, key: String, value: bool, callback: Callable
) -> Control:
	var hbox := HBoxContainer.new()
	hbox.custom_minimum_size = Vector2(0, 56)

	var text_stack := VBoxContainer.new()
	text_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_stack.size_flags_stretch_ratio = 2.0
	text_stack.add_theme_constant_override("separation", 2)
	hbox.add_child(text_stack)
	var lbl := Label.new()
	lbl.text = label
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if ThemeService:
		ThemeService.apply_label_style(lbl, "body_small", "text_primary")
	text_stack.add_child(lbl)
	var help_text := str(SETTING_HELP.get(key, ""))
	if not help_text.is_empty():
		var help := Label.new()
		help.text = help_text
		help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if ThemeService:
			ThemeService.apply_label_style(help, "caption", "text_secondary")
		text_stack.add_child(help)

	var toggle := CheckButton.new()
	toggle.button_pressed = value
	toggle.set_meta("key", key)
	toggle.tooltip_text = str(SETTING_HELP.get(key, label))
	toggle.focus_mode = Control.FOCUS_ALL
	toggle.toggled.connect(func(v: bool): callback.call(key, v))
	hbox.add_child(toggle)

	var card := PanelContainer.new()
	var style := StyleBoxFlat.new()
	if ThemeService:
		style.bg_color = ThemeService.tokens.get("surface", Color("#1E1E26"))
		style.corner_radius_top_left = 12
		style.corner_radius_top_right = 12
		style.corner_radius_bottom_left = 12
		style.corner_radius_bottom_right = 12
		style.border_color = ThemeService.tokens.get("border", Color.GRAY)
		style.border_width_left = 1
		style.border_width_right = 1
		style.border_width_top = 1
		style.border_width_bottom = 1
		style.content_margin_left = 12
		style.content_margin_right = 12
		style.content_margin_top = 8
		style.content_margin_bottom = 8
	card.add_theme_stylebox_override("panel", style)
	card.add_child(hbox)

	return card


func _create_setting_row_slider(
	label: String, key: String, value: float, min_v: float, max_v: float, step: float
) -> Control:
	var slider_vbox := VBoxContainer.new()

	var hbox := HBoxContainer.new()
	slider_vbox.add_child(hbox)

	var lbl := Label.new()
	lbl.text = label
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if ThemeService:
		ThemeService.apply_label_style(lbl, "body_small", "text_primary")
	hbox.add_child(lbl)

	var val_lbl := Label.new()
	val_lbl.name = "ValueLabel"
	val_lbl.custom_minimum_size.x = 64.0
	val_lbl.autowrap_mode = TextServer.AUTOWRAP_OFF
	val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	if ThemeService:
		ThemeService.apply_label_style(val_lbl, "body_small", "text_secondary")
		val_lbl.autowrap_mode = TextServer.AUTOWRAP_OFF
	val_lbl.text = (
		"%.1f" % value
		if max_v <= 1.5
		else "%d%%" % int(value * 100) if max_v == 1.0 else "%.1f" % value
	)
	var fmt_val: String = ""
	if key.begins_with("volume"):
		fmt_val = "%d%%" % int(value * 100)
	elif key == "font_scale":
		fmt_val = "%.1fx" % value
	else:
		fmt_val = "%.1f" % value
	val_lbl.text = fmt_val
	hbox.add_child(val_lbl)
	var help_text := str(SETTING_HELP.get(key, ""))
	if not help_text.is_empty():
		var help := Label.new()
		help.text = help_text
		help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if ThemeService:
			ThemeService.apply_label_style(help, "caption", "text_secondary")
		slider_vbox.add_child(help)

	var slider := HSlider.new()
	slider.min_value = min_v
	slider.max_value = max_v
	slider.step = step
	slider.value = value
	slider.set_meta("key", key)
	slider.set_meta("value_label", val_lbl)
	slider.tooltip_text = str(SETTING_HELP.get(key, label))
	slider.focus_mode = Control.FOCUS_ALL
	slider.value_changed.connect(
		func(v: float):
			var vl: Label = slider.get_meta("value_label") as Label
			if key.begins_with("volume"):
				vl.text = "%d%%" % int(v * 100)
			elif key == "font_scale":
				vl.text = "%.1fx" % v
			else:
				vl.text = "%.1f" % v
			_on_slider_changed(key, v)
	)
	slider_vbox.add_child(slider)

	var card := PanelContainer.new()
	var style := StyleBoxFlat.new()
	if ThemeService:
		style.bg_color = ThemeService.tokens.get("surface", Color("#1E1E26"))
		style.corner_radius_top_left = 12
		style.corner_radius_top_right = 12
		style.corner_radius_bottom_left = 12
		style.corner_radius_bottom_right = 12
		style.border_color = ThemeService.tokens.get("border", Color.GRAY)
		style.border_width_left = 1
		style.border_width_right = 1
		style.border_width_top = 1
		style.border_width_bottom = 1
		style.content_margin_left = 12
		style.content_margin_right = 12
		style.content_margin_top = 8
		style.content_margin_bottom = 8
	card.add_theme_stylebox_override("panel", style)
	card.add_child(slider_vbox)

	return card


func _create_info_row(label: String, value: String) -> Control:
	var hbox := HBoxContainer.new()
	hbox.custom_minimum_size = Vector2(0, 40)
	var l := Label.new()
	l.text = label
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.size_flags_stretch_ratio = 1.0
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if ThemeService:
		ThemeService.apply_label_style(l, "body_small", "text_primary")
	hbox.add_child(l)
	var v := Label.new()
	v.text = value
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.size_flags_stretch_ratio = 2.0
	v.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	if ThemeService:
		ThemeService.apply_label_style(v, "caption", "text_secondary")
	else:
		v.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7, 1))
		v.add_theme_font_size_override("font_size", 14)
	hbox.add_child(v)

	var card := PanelContainer.new()
	var style := StyleBoxFlat.new()
	if ThemeService:
		style.bg_color = _with_alpha(ThemeService.tokens.get("surface", Color("#1E1E26")), 0.5)
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		style.corner_radius_bottom_left = 8
		style.corner_radius_bottom_right = 8
		style.content_margin_left = 12
		style.content_margin_right = 12
		style.content_margin_top = 8
		style.content_margin_bottom = 8
	card.add_theme_stylebox_override("panel", style)
	card.add_child(hbox)
	return card


func _ensure_reset_dialog() -> void:
	if _reset_dialog != null:
		return
	_reset_dialog = ConfirmationDialog.new()
	_reset_dialog.name = "ConfirmationDialog"
	_reset_dialog.title = "Reset settings?"
	_reset_dialog.dialog_text = "This restores audio, appearance, gameplay, privacy, and accessibility settings to their defaults. Your Witness Progress is not affected."
	_reset_dialog.ok_button_text = "RESET SETTINGS"
	_reset_dialog.cancel_button_text = "CANCEL"
	_reset_dialog.confirmed.connect(_perform_reset_settings)
	add_child(_reset_dialog)

func on_navigated_to(_params: Dictionary) -> void:
	_refresh_pending = false
	_apply_responsive_layout()
	_refresh()
	# Screen-view analytics are centralized in NavigationService.navigate_to.


func _with_alpha(value: Variant, alpha: float) -> Color:
	var color: Color = value if value is Color else Color.WHITE
	color.a = alpha
	return color


func _on_generic_toggle(key: String, value: bool) -> void:
	if SettingsService:
		SettingsService.set_value(key, value)
	if AccessibilityService:
		AccessibilityService.vibrate(20)
	if AudioService:
		AudioService.play_ui("ui_click")


func _on_theme_toggle(_key: String, is_dark: bool) -> void:
	var mode: String = "dark" if is_dark else "light"
	if SettingsService:
		SettingsService.set_value("theme_mode", mode)
	if ThemeService:
		ThemeService.set_theme_mode(
			ThemeService.ThemeMode.DARK if is_dark else ThemeService.ThemeMode.LIGHT
		)
	if AccessibilityService:
		AccessibilityService.vibrate(20)
	if AudioService:
		AudioService.play_ui("ui_click")


func _on_slider_changed(key: String, value: float) -> void:
	if SettingsService:
		SettingsService.set_value(key, value)


func _on_about_pressed(section: String = "about") -> void:
	if AudioService:
		AudioService.play_ui("ui_click")
	if NavigationService:
		NavigationService.navigate_to("about", {"section": section})


func _on_reset_settings() -> void:
	if AudioService:
		AudioService.play_ui("ui_click")
	_ensure_reset_dialog()
	_reset_dialog.popup_centered(Vector2i(520, 260))

func _perform_reset_settings() -> void:
	if SettingsService:
		SettingsService.reset_to_defaults()
	_refresh()
	if AccessibilityService:
		AccessibilityService.vibrate(35)


func _on_setting_changed(key: String, _value: Variant) -> void:
	if key in ["theme_mode", "high_contrast", "font_scale"]:
		_schedule_refresh()


func _on_theme_changed(_theme: String, _tokens: Dictionary) -> void:
	var background: ColorRect = get_node_or_null("Background") as ColorRect
	if background and ThemeService:
		background.color = ThemeService.get_color("background", Color("#0F0F12"))
	_schedule_refresh()

func _schedule_refresh() -> void:
	if not is_visible_in_tree():
		_refresh_pending = true
		return
	if _refresh_timer:
		_refresh_timer.start()
