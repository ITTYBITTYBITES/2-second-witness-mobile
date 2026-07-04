extends Node
# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# PRESENTATION TOOLKIT (GOLD STANDARD UI ENGINE)
# ---------------------------------------------------------
# This toolkit provides standardized methods to create "Clinical Futurism"
# UI elements. It ensures visual consistency across all scenarios
# while maintaining high performance on Android.
# ---------------------------------------------------------

# DESIGN TOKENS (Centralized for easy global adjustment)
const GLASS_BG_COLOR = Color(0.05, 0.05, 0.10, 0.70)
const GLASS_BORDER_COLOR = Color(0.80, 0.80, 1.00, 0.40)
const ACCENT_GLOW_COLOR = Color(0.00, 0.80, 1.00, 0.60)
const SUCCESS_COLOR = Color(0.20, 1.00, 0.40, 0.85)
const FAILURE_COLOR = Color(1.00, 0.20, 0.20, 0.85)
const TEXT_PRIMARY = Color(0.90, 0.90, 1.00)
const TEXT_SECONDARY = Color(0.60, 0.60, 0.80)
const TEXT_MUTED = Color(0.38, 0.44, 0.58)
const COCKPIT_GLASS_BG = Color(0.03, 0.05, 0.10, 0.78)
const COCKPIT_SECONDARY_BORDER = Color(0.18, 0.28, 0.42, 0.55)
const CORNER_RADIUS = 12

## Creates a reusable glass StyleBoxFlat from the canonical design tokens.
func make_glass_style(
	bg_color: Color = GLASS_BG_COLOR,
	accent_color: Color = GLASS_BORDER_COLOR,
	border_width: int = 2,
	corner_radius: int = CORNER_RADIUS,
	content_margin: int = 10
) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = accent_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(corner_radius)
	style.content_margin_left = content_margin
	style.content_margin_right = content_margin
	style.content_margin_top = content_margin
	style.content_margin_bottom = content_margin
	return style

## Creates or reuses a sibling background panel for Controls that do not draw StyleBox panels.
func _ensure_background_panel(node: Control) -> Panel:
	if node == null:
		return null
	var parent = node.get_parent()
	if parent == null:
		var child_bg = node.get_node_or_null("__GlassFrame")
		if child_bg and child_bg is Panel:
			return child_bg as Panel
		var new_child_bg = Panel.new()
		new_child_bg.name = "__GlassFrame"
		new_child_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		new_child_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		new_child_bg.show_behind_parent = true
		node.add_child(new_child_bg)
		node.move_child(new_child_bg, 0)
		return new_child_bg

	var bg_name = "__GlassFrame_%s" % str(node.name)
	var existing = parent.get_node_or_null(bg_name)
	if existing and existing is Panel:
		return existing as Panel

	var bg = Panel.new()
	bg.name = bg_name
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.anchor_left = node.anchor_left
	bg.anchor_top = node.anchor_top
	bg.anchor_right = node.anchor_right
	bg.anchor_bottom = node.anchor_bottom
	bg.offset_left = node.offset_left - 8
	bg.offset_top = node.offset_top - 8
	bg.offset_right = node.offset_right + 8
	bg.offset_bottom = node.offset_bottom + 8
	bg.grow_horizontal = node.grow_horizontal
	bg.grow_vertical = node.grow_vertical
	bg.z_index = node.z_index - 1
	parent.add_child(bg)
	parent.move_child(bg, node.get_index())
	return bg

## Applies the canonical glass panel treatment to a Panel/PanelContainer.
## For generic Controls, a non-interactive sibling backdrop is created behind the control.
func apply_glass_style(
	node: Control,
	accent_color: Color = GLASS_BORDER_COLOR,
	bg_color: Color = GLASS_BG_COLOR,
	border_width: int = 2,
	corner_radius: int = CORNER_RADIUS
) -> Control:
	if node == null:
		return null

	var target: Control = node
	if not (node is PanelContainer or node is Panel):
		target = _ensure_background_panel(node)
		if target == null:
			return null

	var style = make_glass_style(bg_color, accent_color, border_width, corner_radius, 10)
	target.add_theme_stylebox_override("panel", style)
	return target

## Applies the full-width cockpit/HUD bar treatment used by BaseScenario.
func apply_cockpit_bar_style(panel: PanelContainer, edge: String = "bottom", accent_color: Color = ACCENT_GLOW_COLOR) -> void:
	if panel == null:
		return
	var style = make_glass_style(COCKPIT_GLASS_BG, COCKPIT_SECONDARY_BORDER, 1, 0, 0)
	style.border_color = accent_color
	style.border_width_left = 0
	style.border_width_right = 0
	style.border_width_top = 1
	style.border_width_bottom = 1
	if edge == "top":
		style.border_width_top = 2
	elif edge == "bottom":
		style.border_width_bottom = 2
	style.content_margin_left = 0
	style.content_margin_right = 0
	style.content_margin_top = 0
	style.content_margin_bottom = 0
	panel.add_theme_stylebox_override("panel", style)

## Sets cockpit bar accent state without leaking StyleBox details into scenario code.
func set_cockpit_bar_state(panel: PanelContainer, edge: String = "bottom", state: String = "neutral") -> void:
	var accent = ACCENT_GLOW_COLOR
	if state == "success":
		accent = SUCCESS_COLOR
	elif state == "failure":
		accent = FAILURE_COLOR
	apply_cockpit_bar_style(panel, edge, accent)

## Standard typography for RichTextLabel telemetry and cockpit text.
func style_rich_text_label(lbl: RichTextLabel, font_size: int = 14, min_width: float = 0.0, expand: bool = false) -> void:
	if lbl == null:
		return
	lbl.bbcode_enabled = true
	lbl.fit_content = true
	lbl.scroll_active = false
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.add_theme_font_size_override("normal_font_size", font_size)
	lbl.add_theme_color_override("default_color", TEXT_PRIMARY)
	lbl.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.70))
	lbl.add_theme_constant_override("outline_size", 1)
	if min_width > 0.0:
		lbl.custom_minimum_size = Vector2(min_width, max(lbl.custom_minimum_size.y, float(font_size + 10)))
	if expand:
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL

## Transforms a standard Button into a "Response Card".
func make_response_card(btn: Button, label_text: String, accent_color: Color = ACCENT_GLOW_COLOR) -> void:
	if btn == null:
		return
	btn.text = label_text
	btn.custom_minimum_size = Vector2(200, 80)

	var style_normal = make_glass_style(Color(GLASS_BG_COLOR.r, GLASS_BG_COLOR.g, GLASS_BG_COLOR.b, 0.40), accent_color, 1, CORNER_RADIUS, 8)
	var style_hover = style_normal.duplicate()
	style_hover.bg_color = Color(GLASS_BG_COLOR.r, GLASS_BG_COLOR.g, GLASS_BG_COLOR.b, 0.60)
	style_hover.set_border_width_all(3)
	style_hover.border_color = Color(1.0, 1.0, 1.0, 0.80)

	var style_pressed = style_normal.duplicate()
	style_pressed.bg_color = accent_color
	style_pressed.border_color = Color.WHITE

	btn.add_theme_stylebox_override("normal", style_normal)
	btn.add_theme_stylebox_override("hover", style_hover)
	btn.add_theme_stylebox_override("pressed", style_pressed)
	btn.add_theme_color_override("font_color", TEXT_PRIMARY)
	btn.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.70))
	btn.add_theme_constant_override("outline_size", 2)
	btn.add_theme_font_size_override("font_size", 22)

## Standardizes the "Prompt Banner" for scenario instructions without reparenting scene nodes.
func make_prompt_banner(lbl: Label, text: String) -> Control:
	if lbl == null:
		return null
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_color_override("font_color", TEXT_PRIMARY)
	lbl.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.75))
	lbl.add_theme_constant_override("outline_size", 3)
	lbl.add_theme_font_size_override("font_size", 28)
	return apply_glass_style(lbl, Color(0.40, 0.40, 0.60, 0.50), Color(GLASS_BG_COLOR.r, GLASS_BG_COLOR.g, GLASS_BG_COLOR.b, 0.45), 1, CORNER_RADIUS)

## Creates a "Telemetry" label for RT, Consistency, etc.
func make_telemetry_label(lbl: Label, prefix: String, value: String) -> void:
	if lbl == null:
		return
	lbl.text = "%s : %s" % [prefix.to_upper(), value]
	lbl.add_theme_color_override("font_color", TEXT_SECONDARY)
	lbl.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.70))
	lbl.add_theme_constant_override("outline_size", 1)
	lbl.add_theme_font_size_override("font_size", 16)
