extends Node
class_name StyleInjector

# Translates ThemeResolver payload directly to CanvasLayer Nodes

static func apply(style_payload: Dictionary, target_ui: CanvasLayer):
	var palette = style_payload.get("palette", {})
	var motion = style_payload.get("motion_curve", ThemeResolver.MotionProfile.FAST_SNAP)
	var contrast = style_payload.get("computed_contrast", 1.0)
	
	# Apply Colors and Styles recursively
	_apply_to_children(target_ui, palette, contrast)
	
	# Apply Entry Motion
	_apply_entry_motion(target_ui, motion)

static func _apply_to_children(node: Node, palette: Dictionary, contrast: float):
	for child in node.get_children():
		if child is Button:
			_style_button(child, palette, contrast)
		elif child is ColorRect and child.name == "VoidBG":
			_style_background(child, palette)
		elif child is Label:
			_style_label(child, palette)
			
		_apply_to_children(child, palette, contrast)

static func _style_button(btn: Button, palette: Dictionary, contrast: float):
	var primary = palette.get("primary", Color(1, 1, 1))
	
	# Clamp alpha opacity to prevent massive opaque rectangles at high difficulty
	var base_alpha = clamp(0.15 * contrast, 0.15, 0.45)
	
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = primary
	style_box.bg_color.a = base_alpha
	style_box.border_width_bottom = 2
	style_box.border_color = primary
	
	var style_hover = style_box.duplicate()
	style_hover.bg_color.a = clamp(0.3 * contrast, 0.3, 0.6)
	
	var style_pressed = style_box.duplicate()
	style_pressed.bg_color.a = clamp(0.5 * contrast, 0.5, 0.8)
	style_pressed.bg_color = primary.lightened(0.5) 
	
	btn.add_theme_stylebox_override("normal", style_box)
	btn.add_theme_stylebox_override("hover", style_hover)
	btn.add_theme_stylebox_override("pressed", style_pressed)
	btn.add_theme_color_override("font_color", primary.lightened(0.8))

static func _style_background(rect: ColorRect, palette: Dictionary):
	var bg = palette.get("bg", Color(0, 0, 0))
	rect.color = bg

static func _style_label(lbl: Label, palette: Dictionary):
	var primary = palette.get("primary", Color(1, 1, 1))
	lbl.add_theme_color_override("font_color", primary)

static func _apply_entry_motion(ui: CanvasLayer, motion: int):
	# Calculate duration based on semantic Motion Profile
	var duration = 0.3
	match motion:
		ThemeResolver.MotionProfile.FAST_SNAP:
			duration = 0.15
		ThemeResolver.MotionProfile.SMOOTH_EASE:
			duration = 0.4
		ThemeResolver.MotionProfile.ORGANIC_DRIFT:
			duration = 0.8
			
	# Apply generic pop-in effect
	var tween = ui.get_tree().create_tween().set_parallel(true)
	
	for child in ui.get_children():
		if child is Control and child.name != "VoidBG":
			var original_scale = child.scale
			child.scale = Vector2.ZERO
			
			if motion == ThemeResolver.MotionProfile.FAST_SNAP:
				tween.tween_property(child, "scale", original_scale, duration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
			elif motion == ThemeResolver.MotionProfile.SMOOTH_EASE:
				tween.tween_property(child, "scale", original_scale, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			else:
				tween.tween_property(child, "scale", original_scale, duration).set_trans(Tween.TRANS_LINEAR)
