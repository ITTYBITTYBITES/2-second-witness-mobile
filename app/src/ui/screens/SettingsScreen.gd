extends Control
## SettingsScreen - App preferences, accessibility, polished placeholder

@onready var scroll: ScrollContainer = $Margin/Scroll
@onready var vbox: VBoxContainer = $Margin/Scroll/VBox


func _ready() -> void:
	_ensure_ui()
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


func _apply_theme() -> void:
	# no custom per now
	pass


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
			"Font Scale", "font_scale", SettingsService.get_value("font_scale", 1.0), 0.8, 1.4, 0.1
		)
	)

	# Audio Section
	vb.add_child(_create_section_header("Audio"))
	vb.add_child(
		_create_setting_row_slider(
			"Master Volume",
			"volume_master",
			SettingsService.get_value("volume_master", 1.0),
			0.0,
			1.0,
			0.1
		)
	)
	vb.add_child(
		_create_setting_row_slider(
			"BGM Volume", "volume_bgm", SettingsService.get_value("volume_bgm", 0.7), 0.0, 1.0, 0.1
		)
	)
	vb.add_child(
		_create_setting_row_slider(
			"SFX Volume", "volume_sfx", SettingsService.get_value("volume_sfx", 0.9), 0.0, 1.0, 0.1
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
			"High Contrast",
			"high_contrast",
			SettingsService.get_value("high_contrast", false),
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
	vb.add_child(
		_create_setting_row_toggle(
			"Reduce Motion (Accessibility)",
			"accessibility_reduce_motion",
			SettingsService.get_value("accessibility_reduce_motion", false),
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
			"Auto Play Next",
			"auto_play_next",
			SettingsService.get_value("auto_play_next", false),
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
	vb.add_child(
		_create_setting_row_toggle(
			"Crash Reporting",
			"crash_reporting",
			SettingsService.get_value("crash_reporting", true),
			_on_generic_toggle
		)
	)

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
	vb.add_child(_create_info_row("Build", "Playable Release • ITTYBITTYBITES"))
	vb.add_child(_create_info_row("Engine", "Godot 4.6 / GL Compatibility"))

	var about_btn := Button.new()
	about_btn.text = "About • Privacy • ITTYBITTYBITES"
	about_btn.custom_minimum_size = Vector2(0, 52)
	vb.add_child(about_btn)
	about_btn.pressed.connect(_on_about_pressed)

	var reset_btn := Button.new()
	reset_btn.text = "Reset All Settings"
	reset_btn.custom_minimum_size = Vector2(0, 48)
	vb.add_child(reset_btn)
	reset_btn.pressed.connect(_on_reset_settings)


func _create_section_header(text: String) -> Control:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.add_theme_color_override("font_color", Color("#7C5CFF") if ThemeService else Color.PURPLE)
	return lbl


func _create_setting_row_toggle(
	label: String, key: String, value: bool, callback: Callable
) -> Control:
	var hbox := HBoxContainer.new()
	hbox.custom_minimum_size = Vector2(0, 56)

	var lbl := Label.new()
	lbl.text = label
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(lbl)

	var toggle := CheckButton.new()
	toggle.button_pressed = value
	toggle.set_meta("key", key)
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
	var vbox := VBoxContainer.new()

	var hbox := HBoxContainer.new()
	vbox.add_child(hbox)

	var lbl := Label.new()
	lbl.text = label
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(lbl)

	var val_lbl := Label.new()
	val_lbl.name = "ValueLabel"
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

	var slider := HSlider.new()
	slider.min_value = min_v
	slider.max_value = max_v
	slider.step = step
	slider.value = value
	slider.set_meta("key", key)
	slider.set_meta("value_label", val_lbl)
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
	vbox.add_child(slider)

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
	card.add_child(vbox)

	return card


func _create_info_row(label: String, value: String) -> Control:
	var hbox := HBoxContainer.new()
	hbox.custom_minimum_size = Vector2(0, 40)
	var l := Label.new()
	l.text = label
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(l)
	var v := Label.new()
	v.text = value
	v.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7, 1))
	v.add_theme_font_size_override("font_size", 12)
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


func on_navigated_to(_params: Dictionary) -> void:
	_refresh()
	if AnalyticsService:
		AnalyticsService.log_screen_view("settings")


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


func _on_slider_changed(key: String, value: float) -> void:
	if SettingsService:
		SettingsService.set_value(key, value)
	# Apply audio volumes immediately
	if key.begins_with("volume_") and AudioService:
		match key:
			"volume_master":
				AudioService.set_volume(AudioService.Bus.MASTER, value)
			"volume_bgm":
				AudioService.set_volume(AudioService.Bus.BGM, value)
			"volume_sfx":
				AudioService.set_volume(AudioService.Bus.SFX, value)
			"volume_ui":
				AudioService.set_volume(AudioService.Bus.UI, value)


func _on_about_pressed() -> void:
	if AudioService:
		AudioService.play_ui("ui_click")
	if NavigationService:
		NavigationService.navigate_to("about")


func _on_reset_settings() -> void:
	if SettingsService:
		SettingsService.reset_to_defaults()
	_refresh()
	if AudioService:
		AudioService.play_ui("ui_click")


func _on_setting_changed(_key: String, _value: Variant) -> void:
	# Could refresh only needed row, but full refresh ok for foundation
	# call_deferred to avoid recursion on slider
	call_deferred("_refresh")


func _on_theme_changed(_theme: String, _tokens: Dictionary) -> void:
	_apply_theme()
