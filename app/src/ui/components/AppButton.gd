extends Button
## AppButton - Themed button with consistent styling
## Supports primary, secondary, ghost variants

enum Variant { PRIMARY, SECONDARY, GHOST, DANGER }

@export var variant: Variant = Variant.PRIMARY
@export var full_width: bool = false
@export var is_loading: bool = false:
	set = set_loading
@export var icon_name: String = ""

var _original_text: String = ""


func _ready() -> void:
	_original_text = text
	_apply_theme()
	if ThemeService:
		ThemeService.theme_changed.connect(_on_theme_changed)
	if AccessibilityService:
		AccessibilityService.accessibility_updated.connect(_on_accessibility_updated)
	# Accessibility
	focus_mode = Control.FOCUS_ALL


func _apply_theme() -> void:
	if not ThemeService:
		return
	var tokens = ThemeService.tokens

	var bg = tokens.get("primary", Color("#6A3DFF"))
	var text_color = tokens.get("text_on_primary", Color.WHITE)
	var border = tokens.get("border", Color.TRANSPARENT)
	var bg_hover = tokens.get("primary_variant", Color("#8A68FF"))
	var bg_secondary = tokens.get("surface_elevated", Color("#2A2A36"))

	var font_size := ThemeService.get_font_size("button")
	add_theme_font_size_override("font_size", font_size)
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	custom_minimum_size.y = max(custom_minimum_size.y, tokens.get("touch_target_min", 48))

	# Clear existing overrides
	var style_normal := StyleBoxFlat.new()
	var style_hover := StyleBoxFlat.new()
	var style_pressed := StyleBoxFlat.new()
	var style_disabled := StyleBoxFlat.new()

	match variant:
		Variant.PRIMARY:
			style_normal.bg_color = bg
			style_normal.corner_radius_top_left = tokens.get("radius_md", 12)
			style_normal.corner_radius_top_right = tokens.get("radius_md", 12)
			style_normal.corner_radius_bottom_left = tokens.get("radius_md", 12)
			style_normal.corner_radius_bottom_right = tokens.get("radius_md", 12)
			style_normal.content_margin_left = 24
			style_normal.content_margin_right = 24
			style_normal.content_margin_top = 14
			style_normal.content_margin_bottom = 14

			style_hover = style_normal.duplicate()
			style_hover.bg_color = bg_hover

			style_pressed = style_normal.duplicate()
			style_pressed.bg_color = bg.darkened(0.1)

			add_theme_color_override("font_color", text_color)
		Variant.SECONDARY:
			style_normal.bg_color = bg_secondary
			style_normal.border_color = border
			style_normal.border_width_left = 1
			style_normal.border_width_right = 1
			style_normal.border_width_top = 1
			style_normal.border_width_bottom = 1
			style_normal.corner_radius_top_left = tokens.get("radius_md", 12)
			style_normal.corner_radius_top_right = tokens.get("radius_md", 12)
			style_normal.corner_radius_bottom_left = tokens.get("radius_md", 12)
			style_normal.corner_radius_bottom_right = tokens.get("radius_md", 12)
			style_normal.content_margin_left = 24
			style_normal.content_margin_right = 24
			style_normal.content_margin_top = 14
			style_normal.content_margin_bottom = 14

			add_theme_color_override("font_color", tokens.get("text_primary", Color.WHITE))
			style_hover = style_normal.duplicate()
			style_hover.bg_color = bg_secondary.lightened(0.08)
			style_pressed = style_normal.duplicate()
			style_pressed.bg_color = bg_secondary.darkened(0.1)
		Variant.GHOST:
			style_normal.bg_color = Color.TRANSPARENT
			style_normal.content_margin_left = 20
			style_normal.content_margin_right = 20
			style_normal.content_margin_top = 14
			style_normal.content_margin_bottom = 14
			add_theme_color_override("font_color", tokens.get("text_secondary", Color.GRAY))
			style_hover = style_normal.duplicate()
			style_hover.bg_color = _with_alpha(tokens.get("surface_elevated", Color.GRAY), 0.5)
			style_pressed = style_hover.duplicate()
		Variant.DANGER:
			style_normal.bg_color = tokens.get("error", Color.RED)
			style_normal.corner_radius_top_left = tokens.get("radius_md", 12)
			style_normal.corner_radius_top_right = tokens.get("radius_md", 12)
			style_normal.corner_radius_bottom_left = tokens.get("radius_md", 12)
			style_normal.corner_radius_bottom_right = tokens.get("radius_md", 12)
			style_normal.content_margin_left = 24
			style_normal.content_margin_right = 24
			style_normal.content_margin_top = 14
			style_normal.content_margin_bottom = 14
			add_theme_color_override("font_color", Color("#101014"))
			style_hover = style_normal.duplicate()
			style_hover.bg_color = style_normal.bg_color.lightened(0.1)
			style_pressed = style_normal.duplicate()
			style_pressed.bg_color = style_normal.bg_color.darkened(0.1)

	style_disabled = style_normal.duplicate()
	style_disabled.bg_color = _with_alpha(style_normal.bg_color, 0.4)

	add_theme_stylebox_override("normal", style_normal)
	add_theme_stylebox_override("hover", style_hover)
	add_theme_stylebox_override("pressed", style_pressed)
	add_theme_stylebox_override("disabled", style_disabled)
	add_theme_stylebox_override("focus", style_hover)

	if full_width:
		custom_minimum_size.x = 0
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
	else:
		size_flags_horizontal = Control.SIZE_SHRINK_CENTER


func _on_theme_changed(_theme_name: String, _tokens: Dictionary) -> void:
	_apply_theme()


func _on_accessibility_updated(_settings: Dictionary) -> void:
	if AccessibilityService:
		AccessibilityService.apply_accessibility_to_control(self)


func _with_alpha(value: Variant, alpha: float) -> Color:
	var color: Color = value if value is Color else Color.WHITE
	color.a = alpha
	return color


func set_loading(loading: bool) -> void:
	is_loading = loading
	disabled = loading
	if loading:
		text = "Loading..."
	else:
		text = _original_text
