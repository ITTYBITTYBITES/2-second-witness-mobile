extends Node
class_name UniverseRenderer

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# UNIVERSE PRESENTATION MANIFOLD (REGISTRY-DRIVEN)
# All universe visual definitions are sourced from ContentRegistry.
# ---------------------------------------------------------

enum EmotionProfile { CLINICAL, WARM, UNCANNY, SATURATED, NATURAL, DEEP_SPACE }
enum TypographicDensity { SPARSE, TECHNICAL, HEAVY }

func _registry() -> Node:
	return ContentRegistry if ContentRegistry else get_tree().root.get_node_or_null("ContentRegistry")

func _map_emotion(emotion_str: String) -> int:
	match emotion_str.to_upper():
		"WARM": return EmotionProfile.WARM
		"UNCANNY": return EmotionProfile.UNCANNY
		"SATURATED": return EmotionProfile.SATURATED
		"NATURAL": return EmotionProfile.NATURAL
		"DEEP_SPACE": return EmotionProfile.DEEP_SPACE
		_: return EmotionProfile.CLINICAL

func _map_typography(type_str: String) -> int:
	match type_str.to_upper():
		"SPARSE": return TypographicDensity.SPARSE
		"HEAVY": return TypographicDensity.HEAVY
		_: return TypographicDensity.TECHNICAL

func get_render_profile(universe_id: String) -> Dictionary:
	var reg = _registry()
	if reg and reg.has_method("get_universe_render_profile"):
		return reg.get_universe_render_profile(universe_id)
	return {
		"emotion": "CLINICAL",
		"typography": "TECHNICAL",
		"feedback_tone": "diagnostic",
		"motion_scale": 1.0,
		"lens_profile": "particle_accelerator"
	}

func apply_manifold(target_ui: CanvasLayer, universe_id: String):
	var profile = get_render_profile(universe_id)
	var def = {
		"emotion": _map_emotion(profile.get("emotion", "CLINICAL")),
		"typography": _map_typography(profile.get("typography", "TECHNICAL")),
		"palette": profile.get("palette", {"bg": Color("#0B1320"), "primary": Color("#00D4FF"), "accent": Color("#80E5FF")}),
		"feedback_tone": profile.get("feedback_tone", "diagnostic"),
		"motion_scale": profile.get("motion_scale", 1.0),
		"lens_profile": profile.get("lens_profile", "particle_accelerator")
	}
	_recursively_style_nodes(target_ui, def)

func _recursively_style_nodes(node: Node, def: Dictionary):
	for child in node.get_children():
		if child is ColorRect and child.name == "VoidBG":
			child.color = Color(0,0,0,0)
		elif child is Button:
			_apply_button_aesthetics(child, def)
		_recursively_style_nodes(child, def)

func _apply_button_aesthetics(btn: Button, def: Dictionary):
	var pal = def.get("palette", {})
	var primary = pal.get("primary", Color("#00D4FF"))
	var style = StyleBoxFlat.new()
	style.bg_color = pal.get("bg", Color("#0B1320"))
	style.border_width_bottom = 4
	style.border_color = primary
	style.set_corner_radius_all(12)
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_color_override("font_color", primary.lightened(0.6))
