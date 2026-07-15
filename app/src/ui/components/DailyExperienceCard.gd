extends PanelContainer
## Premium focused Daily Experience card for the new Home V2.
## Consumes RecommendationService data only. Reuses styling patterns from ExperienceCard / ThemeService.
## Primary action: "Start Witness Round"

signal start_requested()
signal tutorial_requested(family_id: String)

var _data: Dictionary = {}
var _is_locked: bool = false

@onready var eye_icon: TextureRect = $Margin/VBox/Header/EyeIcon
@onready var eyebrow: Label = $Margin/VBox/Header/TitleStack/Eyebrow
@onready var title_label: Label = $Margin/VBox/Header/TitleStack/Title
@onready var reason_label: Label = $Margin/VBox/Reason
@onready var duration_label: Label = $Margin/VBox/MetaRow/Duration
@onready var mastery_label: Label = $Margin/VBox/MetaRow/Mastery
@onready var start_button: Button = $Margin/VBox/StartButton

func _ready() -> void:
	_apply_theme()
	_wire_signals()
	if ThemeService and not ThemeService.theme_changed.is_connected(_on_theme_changed):
		ThemeService.theme_changed.connect(_on_theme_changed)

func _wire_signals() -> void:
	if not start_button.pressed.is_connected(_on_start_pressed):
		start_button.pressed.connect(_on_start_pressed)

func set_recommendation(recommendation: Dictionary, available: Array = []) -> void:
	_data = recommendation.duplicate(true)
	
	# Resolve full item for extra metadata (mastery, duration)
	var full_item := _find_full_item(available)
	if not full_item.is_empty():
		_data.merge(full_item, false)
	
	_is_locked = bool(_data.get("locked", _data.get("is_locked", false)))
	_refresh_ui()

func set_continue_recommendation(continue_rec: Dictionary, available: Array = []) -> void:
	# Optional: allow parent to indicate this is primarily a "continue" action
	if not continue_rec.is_empty():
		_data = continue_rec.duplicate(true)
		var full_item := _find_full_item(available)
		if not full_item.is_empty():
			_data.merge(full_item, false)
		_data["is_continue"] = true
		_is_locked = false  # continues are usually unlocked
		_refresh_ui()

func _find_full_item(available: Array) -> Dictionary:
	var family_id := str(_data.get("family_id", ""))
	for item in available:
		if item is Dictionary and str(item.get("family_id", "")) == family_id:
			return item.duplicate(true)
	return {}

func _refresh_ui() -> void:
	if _data.is_empty():
		title_label.text = "Witness Experience"
		reason_label.text = "A new challenge is being prepared."
		start_button.text = "START"
		start_button.disabled = true
		return

	var title := str(_data.get("title", "Challenge"))
	var reason := str(_data.get("reason_text", "Your next round is ready"))
	var is_continue := bool(_data.get("is_continue", false))
	var program_title := str(_data.get("program_title", ""))
	
	title_label.text = title
	reason_label.text = reason
	
	# Duration
	var est := int(_data.get("estimated_duration_sec", 120))
	var mins := max(1, int(round(est / 60.0)))
	duration_label.text = "%d min" % mins
	
	# Mastery
	var progress: Dictionary = _data.get("progress", {})
	var mastery := clampf(float(progress.get("mastery", 0.0)), 0.0, 100.0)
	mastery_label.text = "Mastery %d%%" % int(round(mastery))
	
	# Button + eyebrow state (premium focused copy)
	start_button.disabled = _is_locked
	if _is_locked:
		var req := int(_data.get("required_level", 1))
		start_button.text = "LEVEL %d REQUIRED" % req
		eyebrow.text = "TODAY'S WITNESS EXPERIENCE"
	elif is_continue:
		start_button.text = "CONTINUE"
		eyebrow.text = "RESUME YOUR RUN" if program_title.is_empty() else ("RESUME • " + program_title).to_upper()
	else:
		start_button.text = "START WITNESS ROUND"
		eyebrow.text = "TODAY'S WITNESS EXPERIENCE"
	
	# Eye icon (reuse brand asset)
	if eye_icon:
		eye_icon.texture = load("res://assets/brand/witness_eye_glow.png") as Texture2D
		eye_icon.modulate = Color(1, 1, 1, 0.9) if not _is_locked else Color(0.6, 0.6, 0.7, 0.6)

func _apply_theme() -> void:
	var tokens: Dictionary = ThemeService.tokens if ThemeService else {}
	
	# Card style - elevated premium look
	var style := StyleBoxFlat.new()
	style.bg_color = tokens.get("surface", Color("#1E1E26"))
	style.border_color = tokens.get("primary", Color("#6A3DFF"))
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 24
	style.corner_radius_top_right = 24
	style.corner_radius_bottom_left = 24
	style.corner_radius_bottom_right = 24
	style.shadow_color = Color(0, 0, 0, 0.35)
	style.shadow_size = 18
	style.shadow_offset = Vector2(0, 8)
	add_theme_stylebox_override("panel", style)
	
	# Typography
	if ThemeService:
		ThemeService.apply_label_style(eyebrow, "label_small", "text_tertiary")
		eyebrow.add_theme_font_size_override("font_size", ThemeService.get_font_size("label_small"))
		
		ThemeService.apply_label_style(title_label, "title", "text_primary")
		title_label.add_theme_font_size_override("font_size", ThemeService.get_font_size("title"))
		
		ThemeService.apply_label_style(reason_label, "body_small", "text_secondary")
		ThemeService.apply_label_style(duration_label, "caption", "text_secondary")
		ThemeService.apply_label_style(mastery_label, "caption", "text_secondary")
	
	# Start button - dominant primary
	_style_start_button(tokens)

func _style_start_button(tokens: Dictionary) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = tokens.get("primary", Color("#6A3DFF"))
	normal.corner_radius_top_left = 16
	normal.corner_radius_top_right = 16
	normal.corner_radius_bottom_left = 16
	normal.corner_radius_bottom_right = 16
	normal.content_margin_left = 24
	normal.content_margin_right = 24
	normal.content_margin_top = 16
	normal.content_margin_bottom = 16
	
	var hover := normal.duplicate()
	hover.bg_color = normal.bg_color.lightened(0.1)
	var pressed := normal.duplicate()
	pressed.bg_color = normal.bg_color.darkened(0.12)
	
	start_button.add_theme_stylebox_override("normal", normal)
	start_button.add_theme_stylebox_override("hover", hover)
	start_button.add_theme_stylebox_override("pressed", pressed)
	start_button.add_theme_stylebox_override("focus", hover)
	start_button.add_theme_color_override("font_color", tokens.get("text_on_primary", Color.WHITE))
	start_button.add_theme_font_size_override("font_size", ThemeService.get_font_size("button") if ThemeService else 18)
	start_button.custom_minimum_size.y = 64

func _on_start_pressed() -> void:
	if _data.is_empty() or start_button.disabled:
		return
	if AccessibilityService and AccessibilityService.is_haptics_enabled():
		AccessibilityService.vibrate(35)
	if AudioService:
		AudioService.play_ui("ui_click")
	start_requested.emit()

func set_disabled(disabled: bool) -> void:
	if start_button:
		start_button.disabled = disabled or _is_locked
	if disabled:
		start_button.text = "PREPARING..."
	else:
		# Restore correct text
		if _data.is_empty():
			start_button.text = "START"
		elif _is_locked:
			var req := int(_data.get("required_level", 1))
			start_button.text = "LEVEL %d REQUIRED" % req
		else:
			start_button.text = "START WITNESS ROUND"

func _on_theme_changed(_name: String, _tokens: Dictionary) -> void:
	_apply_theme()
	_refresh_ui()

func get_family_id() -> String:
	return str(_data.get("family_id", ""))
