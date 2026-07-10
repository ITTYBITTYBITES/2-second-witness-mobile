extends Control
## PrivacyTermsDialog - First-launch, blocking, responsive privacy disclosure.

signal accepted()
signal view_policy()

@onready var scrim: ColorRect = $Scrim
@onready var outer_margin: MarginContainer = $Margin
@onready var panel: PanelContainer = $Margin/Center/DialogPanel
@onready var title_label: Label = $Margin/Center/DialogPanel/InnerMargin/VBox/Title
@onready var welcome_label: Label = $Margin/Center/DialogPanel/InnerMargin/VBox/BodyScroll/Body/Welcome
@onready var intro_label: Label = $Margin/Center/DialogPanel/InnerMargin/VBox/BodyScroll/Body/Intro
@onready var bullets_label: Label = $Margin/Center/DialogPanel/InnerMargin/VBox/BodyScroll/Body/Bullets
@onready var footer_label: Label = $Margin/Center/DialogPanel/InnerMargin/VBox/BodyScroll/Body/Footer
@onready var policy_btn: Button = $Margin/Center/DialogPanel/InnerMargin/VBox/Actions/PolicyButton
@onready var accept_btn: Button = $Margin/Center/DialogPanel/InnerMargin/VBox/Actions/AcceptButton
@onready var status_label: Label = $Margin/Center/DialogPanel/InnerMargin/VBox/Status

func _ready() -> void:
	_enforce_layout()
	_apply_theme()
	_connect_actions()
	_animate_in()
	if ThemeService and not ThemeService.theme_changed.is_connected(_on_theme_changed):
		ThemeService.theme_changed.connect(_on_theme_changed)
	if not get_viewport().size_changed.is_connected(_apply_responsive_size):
		get_viewport().size_changed.connect(_apply_responsive_size)
	accept_btn.call_deferred("grab_focus")

func _enforce_layout() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_right = 0
	offset_top = 0
	offset_bottom = 0
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 100
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	_apply_responsive_size()

func _apply_responsive_size() -> void:
	if not is_instance_valid(panel):
		return
	var available := size
	if available.x <= 0.0 or available.y <= 0.0:
		available = get_viewport().get_visible_rect().size
	var safe_top := 0
	var safe_bottom := 0
	if ThemeService:
		safe_top = int(ThemeService.tokens.get("safe_area_top", 0))
		safe_bottom = int(ThemeService.tokens.get("safe_area_bottom", 0))
	outer_margin.add_theme_constant_override("margin_left", 16)
	outer_margin.add_theme_constant_override("margin_right", 16)
	outer_margin.add_theme_constant_override("margin_top", max(16, safe_top + 8))
	outer_margin.add_theme_constant_override("margin_bottom", max(16, safe_bottom + 8))
	var target_width := clampf(available.x - 32.0, 240.0, 520.0)
	var target_height := clampf(available.y - float(max(32, safe_top + safe_bottom + 16)), 380.0, 520.0)
	panel.custom_minimum_size = Vector2(target_width, target_height)
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER

func _connect_actions() -> void:
	if not accept_btn.pressed.is_connected(_on_accept):
		accept_btn.pressed.connect(_on_accept)
	if not policy_btn.pressed.is_connected(_on_policy):
		policy_btn.pressed.connect(_on_policy)

func _apply_theme() -> void:
	var tokens := ThemeService.tokens if ThemeService else {}
	scrim.color = Color(0, 0, 0, 0.72)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = tokens.get("surface_elevated", Color("#2A2A36"))
	panel_style.border_color = tokens.get("border_strong", Color("#3D3D4D"))
	panel_style.set_border_width_all(1)
	var radius: int = int(tokens.get("radius_lg", 20))
	panel_style.set_corner_radius_all(radius)
	panel.add_theme_stylebox_override("panel", panel_style)

	ThemeService.apply_label_style(title_label, "title", "text_primary")
	ThemeService.apply_label_style(welcome_label, "body", "text_primary")
	ThemeService.apply_label_style(intro_label, "body_small", "text_secondary")
	ThemeService.apply_label_style(bullets_label, "body_small", "text_secondary")
	ThemeService.apply_label_style(footer_label, "caption", "text_tertiary")
	ThemeService.apply_label_style(status_label, "caption", "error")
	for label in [title_label, welcome_label, intro_label, bullets_label, footer_label, status_label]:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	_apply_button_style(accept_btn, true)
	_apply_button_style(policy_btn, false)

func _apply_button_style(button: Button, primary: bool) -> void:
	var tokens := ThemeService.tokens
	var style := StyleBoxFlat.new()
	style.bg_color = tokens.get("primary", Color("#6A3DFF")) if primary else Color.TRANSPARENT
	style.set_corner_radius_all(int(tokens.get("radius_md", 12)))
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	if not primary:
		style.border_color = tokens.get("border", Color.GRAY)
		style.set_border_width_all(1)
	var hover := style.duplicate() as StyleBoxFlat
	hover.bg_color = tokens.get("primary_variant", Color("#8A68FF")) if primary else tokens.get("surface", Color("#1E1E26"))
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_stylebox_override("focus", hover)
	button.add_theme_color_override("font_color", tokens.get("text_on_primary", Color.WHITE) if primary else tokens.get("text_primary", Color.WHITE))
	ThemeService.apply_typography(button, "button")
	button.custom_minimum_size.y = maxf(button.custom_minimum_size.y, 48.0)
	button.focus_mode = Control.FOCUS_ALL

func _animate_in() -> void:
	if AccessibilityService and AccessibilityService.is_reduced_motion_enabled():
		modulate.a = 1.0
		return
	modulate.a = 0.0
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate:a", 1.0, 0.2).set_ease(Tween.EASE_OUT)

func show_policy_error() -> void:
	status_label.visible = true
	status_label.text = "Unable to open the policy. Check your connection and try again."
	policy_btn.grab_focus()

func _on_accept() -> void:
	if AccessibilityService:
		AccessibilityService.vibrate(30)
	accepted.emit()

func _on_policy() -> void:
	status_label.visible = false
	view_policy.emit()

func _on_theme_changed(_theme: String, _tokens: Dictionary) -> void:
	_apply_theme()
