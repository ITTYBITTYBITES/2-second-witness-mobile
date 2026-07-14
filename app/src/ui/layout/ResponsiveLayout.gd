extends RefCounted
class_name ResponsiveLayout
## Shared responsive-layout helpers for portrait phones, foldables, and tablets.
##
## Mobile-first architecture:
##   - On phones / phablets the content uses the full available width minus a
##     modest edge gutter. There is no centered "desktop column".
##   - Centering only engages above CENTERING_BREAKPOINT (tablet / foldable /
##     desktop-editor widths) so content does not stretch into an unreadable
##     super-wide column.
##
## This is a mobile game, not a responsive website. Screens must feel native.

const DEFAULT_GUTTER: float = 20.0
## Widths at or below this value get only the base edge gutter — no centering.
## 1280 sits above every common phone portrait logical width (incl. the 1080
## design viewport and large phablets) while still catching tablet / foldable
## landscape and editor windows.
const CENTERING_BREAKPOINT: float = 1280.0
## On very wide displays, keep content near the design width so cards and
## type remain comfortable. Only used when width > CENTERING_BREAKPOINT.
const MAX_CONTENT_WIDTH: float = 1080.0
const MIN_TOUCH_TARGET: float = 48.0

static func apply_centered_margin(
	margin: MarginContainer,
	base_gutter: float = DEFAULT_GUTTER,
	max_content_width: float = MAX_CONTENT_WIDTH
) -> float:
	if margin == null:
		return base_gutter
	var viewport_width: float = margin.get_viewport_rect().size.x
	if viewport_width <= 0.0:
		# Prefer the control's own laid-out width over inventing a desktop column.
		viewport_width = maxf(margin.size.x, 360.0)
	var gutter: float = horizontal_gutter(viewport_width, base_gutter, max_content_width)
	margin.add_theme_constant_override("margin_left", int(round(gutter)))
	margin.add_theme_constant_override("margin_right", int(round(gutter)))
	return gutter

static func horizontal_gutter(
	viewport_width: float,
	base_gutter: float = DEFAULT_GUTTER,
	max_content_width: float = MAX_CONTENT_WIDTH
) -> float:
	# Phones and phablets: full-bleed content with only edge padding.
	if viewport_width <= CENTERING_BREAKPOINT:
		return base_gutter
	# Tablets / foldables / wide editor: center a design-width content column.
	return maxf(base_gutter, (viewport_width - max_content_width) * 0.5)

static func scale_safe_area_insets(
	safe_area: Rect2i,
	window_size: Vector2i,
	viewport_size: Vector2
) -> Dictionary:
	if window_size.x <= 0 or window_size.y <= 0 or viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return {"left": 0, "top": 0, "right": 0, "bottom": 0}
	var scale_x: float = viewport_size.x / float(window_size.x)
	var scale_y: float = viewport_size.y / float(window_size.y)
	var physical_left: int = maxi(safe_area.position.x, 0)
	var physical_top: int = maxi(safe_area.position.y, 0)
	var physical_right: int = maxi(window_size.x - (safe_area.position.x + safe_area.size.x), 0)
	var physical_bottom: int = maxi(window_size.y - (safe_area.position.y + safe_area.size.y), 0)
	return {
		"left": int(round(float(physical_left) * scale_x)),
		"top": int(round(float(physical_top) * scale_y)),
		"right": int(round(float(physical_right) * scale_x)),
		"bottom": int(round(float(physical_bottom) * scale_y))
	}

static func enforce_touch_targets(node: Node, minimum: float = MIN_TOUCH_TARGET) -> void:
	if node is BaseButton:
		var button := node as BaseButton
		button.custom_minimum_size.x = maxf(button.custom_minimum_size.x, minimum)
		button.custom_minimum_size.y = maxf(button.custom_minimum_size.y, minimum)
	elif node is Slider:
		var slider := node as Slider
		slider.custom_minimum_size.y = maxf(slider.custom_minimum_size.y, minimum)
	for child: Node in node.get_children():
		enforce_touch_targets(child, minimum)

static func collect_touch_target_failures(node: Node, minimum: float = MIN_TOUCH_TARGET) -> Array[String]:
	var failures: Array[String] = []
	_collect_touch_target_failures(node, minimum, failures)
	return failures

static func _collect_touch_target_failures(node: Node, minimum: float, failures: Array[String]) -> void:
	if node is BaseButton:
		var button := node as BaseButton
		var effective_width: float = maxf(button.size.x, button.custom_minimum_size.x)
		var effective_height: float = maxf(button.size.y, button.custom_minimum_size.y)
		if button.is_visible_in_tree() and (effective_width < minimum or effective_height < minimum):
			failures.append(str(button.get_path()))
	for child: Node in node.get_children():
		_collect_touch_target_failures(child, minimum, failures)
