extends Node
# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# PRESENTATION TOOLKIT (GOLD STANDARD UI ENGINE)
# ---------------------------------------------------------
# This toolkit provides standardized methods to create "Clinical Futurism" 
# UI elements. It ensures visual consistency across all scenarios 
# while maintaining high performance on Android.
# ---------------------------------------------------------

class_name PresentationToolkit

# DESIGN TOKENS (Centralized for easy global adjustment)
const GLASS_BG_COLOR = Color(0.05, 0.05, 0.1, 0.7)
const GLASS_BORDER_COLOR = Color(0.8, 0.8, 1.0, 0.4)
const ACCENT_GLOW_COLOR = Color(0.0, 0.8, 1.0, 0.6)
const SUCCESS_COLOR = Color(0.2, 1.0, 0.4)
const FAILURE_COLOR = Color(1.0, 0.2, 0.2)
const TEXT_PRIMARY = Color(0.9, 0.9, 1.0)
const TEXT_SECONDARY = Color(0.6, 0.6, 0.8)
const CORNER_RADIUS = 12

## Creates a "Glassmorphic" panel with a technical border.
static func apply_glass_style(node: Control, accent_color: Color = GLASS_BORDER_COLOR):
	if not node is PanelContainer or not node is Panel:
		# Fallback for generic Control nodes: Create a background panel
		var bg = PanelContainer.new()
		bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		node.add_child(bg)
		node.move_child(bg, 0)
		node = bg

	var style = StyleBoxFlat.new()
	style.bg_color = GLASS_BG_COLOR
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = accent_color
	style.set_corner_radius_all(CORNER_RADIUS)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	
	node.add_theme_stylebox_override("panel", style)

## Transforms a standard Button into a "Response Card".
static func make_response_card(btn: Button, label_text: String, accent_color: Color = ACCENT_GLOW_COLOR):
	btn.text = label_text
	btn.custom_minimum_size = Vector2(200, 80)
	
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(GLASS_BG_COLOR.r, GLASS_BG_COLOR.g, GLASS_BG_COLOR.b, 0.4)
	style_normal.border_width_all = 1
	style_normal.border_color = accent_color
	style_normal.set_corner_radius_all(CORNER_RADIUS)
	
	var style_hover = style_normal.duplicate()
	style_hover.bg_color = Color(GLASS_BG_COLOR.r, GLASS_BG_COLOR.g, GLASS_BG_COLOR.b, 0.6)
	style_hover.border_width_all = 3
	style_hover.border_color = Color(1, 1, 1, 0.8)
	
	var style_pressed = style_normal.duplicate()
	style_pressed.bg_color = accent_color
	style_pressed.border_color = Color.WHITE
	
	btn.add_theme_stylebox_override("normal", style_normal)
	btn.add_theme_stylebox_override("hover", style_hover)
	btn.add_theme_stylebox_override("pressed", style_pressed)
	btn.add_theme_color_override("font_color", TEXT_PRIMARY)
	btn.add_theme_font_size_override("font_size", 22)

## Standardizes the "Prompt Banner" for scenario instructions.
static func make_prompt_banner(lbl: Label, text: String):
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_color_override("font_color", TEXT_PRIMARY)
	lbl.add_theme_font_size_override("font_size", 28)
	
	# Wrap in a glass panel
	var container = PanelContainer.new()
	container.add_child(lbl)
	apply_glass_style(container, Color(0.4, 0.4, 0.6, 0.5))
	return container

## Creates a "Telemetry" label for RT, Consistency, etc.
static func make_telemetry_label(lbl: Label, prefix: String, value: String):
	lbl.text = "%s : %s" % [prefix.to_upper(), value]
	lbl.add_theme_color_override("font_color", TEXT_SECONDARY)
	lbl.add_theme_font_size_override("font_size", 16)
