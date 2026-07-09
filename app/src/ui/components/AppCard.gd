extends PanelContainer
## AppCard - Elevated surface with theme tokens

@export var elevated: bool = false
@export var has_border: bool = true
@export var corner_radius: int = -1

func _ready() -> void:
	_apply_theme()
	if ThemeService:
		ThemeService.theme_changed.connect(_on_theme_changed)

func _apply_theme() -> void:
	if not ThemeService:
		return
	var tokens = ThemeService.tokens
	var bg: Color = tokens.get("surface_elevated" if elevated else "surface", Color("#1E1E26"))
	var border: Color = tokens.get("border", Color("#2E2E3A"))
	var radius: int = corner_radius if corner_radius != -1 else tokens.get("radius_lg", 20)
	
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = tokens.get("spacing_md", 16)
	style.content_margin_right = tokens.get("spacing_md", 16)
	style.content_margin_top = tokens.get("spacing_md", 16)
	style.content_margin_bottom = tokens.get("spacing_md", 16)
	
	if has_border:
		style.border_color = border
		style.border_width_left = 1
		style.border_width_right = 1
		style.border_width_top = 1
		style.border_width_bottom = 1
		style.border_blend = true
	
	style.shadow_color = tokens.get("shadow", Color(0,0,0,0.2))
	if elevated:
		style.shadow_size = 8
		style.shadow_offset = Vector2(0, 4)
	
	add_theme_stylebox_override("panel", style)

func _on_theme_changed(_theme_name: String, _tokens: Dictionary) -> void:
	_apply_theme()
