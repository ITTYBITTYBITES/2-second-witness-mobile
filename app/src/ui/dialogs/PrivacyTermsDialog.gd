extends Control
## PrivacyTermsDialog - Centered modal presented over the loading screen on first launch
## Lightweight, editorial style. Blocks interaction with content beneath until accepted.

signal accepted()
signal view_policy()

@onready var scrim: ColorRect = $Scrim
@onready var panel: PanelContainer = $Margin/Center/DialogPanel
@onready var title_label: Label = $Margin/Center/DialogPanel/InnerMargin/VBox/Title
@onready var welcome_label: Label = $Margin/Center/DialogPanel/InnerMargin/VBox/Body/Welcome
@onready var bullets_label: Label = $Margin/Center/DialogPanel/InnerMargin/VBox/Body/Bullets
@onready var footer_label: Label = $Margin/Center/DialogPanel/InnerMargin/VBox/Body/Footer
@onready var policy_btn: Button = $Margin/Center/DialogPanel/InnerMargin/VBox/Actions/PolicyButton
@onready var accept_btn: Button = $Margin/Center/DialogPanel/InnerMargin/VBox/Actions/AcceptButton

func _ready() -> void:
	_apply_theme()
	_connect()
	_animate_in()

func _connect() -> void:
	if accept_btn and not accept_btn.pressed.is_connected(_on_accept):
		accept_btn.pressed.connect(_on_accept)
	if policy_btn and not policy_btn.pressed.is_connected(_on_policy):
		policy_btn.pressed.connect(_on_policy)

func _apply_theme() -> void:
	var tokens := ThemeService.tokens if ThemeService else {}
	if scrim:
		scrim.color = Color(0,0,0,0.55)
	# Panel
	if panel:
		var style := StyleBoxFlat.new()
		style.bg_color = tokens.get("surface_elevated", Color("#2A2A36"))
		style.border_color = tokens.get("border_strong", Color("#3D3D4D"))
		style.border_width_left = 1
		style.border_width_right = 1
		style.border_width_top = 1
		style.border_width_bottom = 1
		style.corner_radius_top_left = tokens.get("radius_lg", 20)
		style.corner_radius_top_right = tokens.get("radius_lg", 20)
		style.corner_radius_bottom_left = tokens.get("radius_lg", 20)
		style.corner_radius_bottom_right = tokens.get("radius_lg", 20)
		# Padding handled by the InnerMargin MarginContainer in the scene.
		panel.add_theme_stylebox_override("panel", style)

	if title_label:
		title_label.text = "Privacy & Terms"
		title_label.add_theme_color_override("font_color", tokens.get("text_primary", Color.WHITE))
		title_label.add_theme_font_size_override("font_size", 20)
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	if welcome_label:
		welcome_label.text = "Welcome to Two Second Witness."
		welcome_label.add_theme_color_override("font_color", tokens.get("text_primary", Color.WHITE))
		welcome_label.add_theme_font_size_override("font_size", 15)
		welcome_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		welcome_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	if bullets_label:
		bullets_label.text = "\n".join([
			"• Progress is stored locally on your device.",
			"• No account is required.",
			"• No personal information is collected.",
			"• No advertising is currently included."
		])
		bullets_label.add_theme_color_override("font_color", tokens.get("text_secondary", Color.GRAY))
		bullets_label.add_theme_font_size_override("font_size", 14)
		bullets_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	if footer_label:
		footer_label.text = "By continuing, you acknowledge these terms."
		footer_label.add_theme_color_override("font_color", tokens.get("text_tertiary", Color.GRAY))
		footer_label.add_theme_font_size_override("font_size", 12)
		footer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		footer_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	# Buttons
	if accept_btn:
		accept_btn.text = "Accept"
		_apply_button_style(accept_btn,
			tokens.get("primary", Color("#7C5CFF")),
			tokens.get("primary_variant", Color("#9B83FF")),
			tokens.get("text_on_primary", Color.WHITE),
			tokens.get("radius_md", 12))
	if policy_btn:
		policy_btn.text = "Privacy Policy"
		_apply_button_style(policy_btn,
			Color.TRANSPARENT,
			Color(tokens.get("surface_elevated", Color("#2A2A36"))),
			tokens.get("text_secondary", Color.GRAY),
			tokens.get("radius_md", 12),
			true)

func _apply_button_style(
	btn: Button,
	bg: Color,
	bg_hover: Color,
	fg: Color,
	radius: int,
	ghost: bool = false
) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = bg
	normal.corner_radius_top_left = radius
	normal.corner_radius_top_right = radius
	normal.corner_radius_bottom_left = radius
	normal.corner_radius_bottom_right = radius
	normal.content_margin_left = 20
	normal.content_margin_right = 20
	normal.content_margin_top = 12
	normal.content_margin_bottom = 12
	if ghost:
		normal.bg_color = Color.TRANSPARENT

	var hover := normal.duplicate()
	hover.bg_color = bg_hover if not ghost else Color(bg_hover).lerp(Color.WHITE, -0.4)
	var pressed := normal.duplicate()
	pressed.bg_color = bg.darkened(0.1)

	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", hover)
	btn.add_theme_color_override("font_color", fg)
	btn.add_theme_font_size_override("font_size", 14)
	btn.custom_minimum_size = Vector2(0, 48)

func _animate_in() -> void:
	modulate.a = 0.0
	if panel:
		panel.scale = Vector2(0.95, 0.95)
		var tween := create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		if AccessibilityService and AccessibilityService.is_reduced_motion_enabled():
			modulate.a = 1.0
			panel.scale = Vector2.ONE
			return
		tween.tween_property(self, "modulate:a", 1.0, 0.25).set_ease(Tween.EASE_OUT)
		var panel_tween := tween.parallel().tween_property(panel, "scale", Vector2.ONE, 0.3)
		panel_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _on_accept() -> void:
	if AccessibilityService:
		AccessibilityService.vibrate(30)
	if AudioService:
		AudioService.play_ui("ui_click")
	accepted.emit()

func _on_policy() -> void:
	if AudioService:
		AudioService.play_ui("ui_click")
	view_policy.emit()
