extends Node
class_name UniverseRenderer

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# UNIVERSE PRESENTATION MANIFOLD
# ---------------------------------------------------------

enum EmotionProfile { CLINICAL, WARM, UNCANNY, SATURATED, NATURAL, DEEP_SPACE }
enum TypographicDensity { SPARSE, TECHNICAL, HEAVY }

var universe_definitions = {
	"science_lab": {
		"emotion": EmotionProfile.CLINICAL,
		"typography": TypographicDensity.TECHNICAL,
		"palette": {"bg": Color("#0B1320"), "primary": Color("#00D4FF")},
		"feedback_tone": "diagnostic",
		"motion_scale": 1.0 
	},
	"tech_ops": {
		"emotion": EmotionProfile.UNCANNY,
		"typography": TypographicDensity.HEAVY,
		"palette": {"bg": Color("#050505"), "primary": Color("#00FF41")},
		"feedback_tone": "mechanical",
		"motion_scale": 0.8 
	},
	"life_sciences": {
		"emotion": EmotionProfile.NATURAL,
		"typography": TypographicDensity.SPARSE,
		"palette": {"bg": Color("#0A1A10"), "primary": Color("#2ECC71")},
		"feedback_tone": "organic",
		"motion_scale": 1.2 
	},
	"creative_arts": {
		"emotion": EmotionProfile.SATURATED,
		"typography": TypographicDensity.SPARSE,
		"palette": {"bg": Color("#1A0B1C"), "primary": Color("#F72585")},
		"feedback_tone": "poetic",
		"motion_scale": 1.5 
	},
	"frontier": {
		"emotion": EmotionProfile.DEEP_SPACE,
		"typography": TypographicDensity.TECHNICAL,
		"palette": {"bg": Color("#110B11"), "primary": Color("#FFBC42")},
		"feedback_tone": "diagnostic",
		"motion_scale": 0.9 
	},
	"society_mind": {
		"emotion": EmotionProfile.WARM,
		"typography": TypographicDensity.HEAVY,
		"palette": {"bg": Color("#1A120C"), "primary": Color("#E5E5CB")},
		"feedback_tone": "poetic",
		"motion_scale": 1.1 
	}
}

func apply_manifold(target_ui: CanvasLayer, universe_id: String):
	var def = universe_definitions.get(universe_id, universe_definitions["science_lab"])
	_recursively_style_nodes(target_ui, def)

func _recursively_style_nodes(node: Node, def: Dictionary):
	for child in node.get_children():
		if child is ColorRect and child.name == "VoidBG":
			child.color = def["palette"]["bg"]
		elif child is Button:
			_apply_button_aesthetics(child, def)
		elif child is Label:
			_apply_typography_rules(child, def)
			
		_recursively_style_nodes(child, def)

func _apply_button_aesthetics(btn: Button, def: Dictionary):
	var style = StyleBoxFlat.new()
	style.bg_color = def["palette"]["primary"]
	style.bg_color.a = 0.2
	style.border_width_bottom = 2
	style.border_color = def["palette"]["primary"]
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_color_override("font_color", def["palette"]["primary"].lightened(0.5))

func _apply_typography_rules(lbl: Label, def: Dictionary):
	lbl.add_theme_color_override("font_color", def["palette"]["primary"])
