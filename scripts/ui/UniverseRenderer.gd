extends Node
class_name UniverseRenderer

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# UNIVERSE PRESENTATION MANIFOLD (ZERO-LOGIC RENDER LAYER)
# ---------------------------------------------------------

enum EmotionProfile { CLINICAL, WARM, UNCANNY, SATURATED }
enum TypographicDensity { SPARSE, TECHNICAL, HEAVY }

var universe_definitions = {
	"science_lab": {
		"emotion": EmotionProfile.CLINICAL,
		"typography": TypographicDensity.TECHNICAL,
		"palette": {"bg": Color("#0B1320"), "primary": Color("#00D4FF")},
		"feedback_tone": "diagnostic",
		"motion_scale": 1.0 # Baseline snap
	},
	"creative_arts": {
		"emotion": EmotionProfile.SATURATED,
		"typography": TypographicDensity.SPARSE,
		"palette": {"bg": Color("#1A0B1C"), "primary": Color("#F72585")},
		"feedback_tone": "poetic",
		"motion_scale": 1.5 # Softer easing
	},
	"tech_ops": {
		"emotion": EmotionProfile.UNCANNY,
		"typography": TypographicDensity.HEAVY,
		"palette": {"bg": Color("#050505"), "primary": Color("#00FF41")},
		"feedback_tone": "mechanical",
		"motion_scale": 0.8 # Harsher, robotic snap
	}
}

func apply_manifold(target_ui: CanvasLayer, universe_id: String):
	# 1. Look up pure visual rules
	var def = universe_definitions.get(universe_id, universe_definitions["science_lab"])
	
	# 2. Project rules onto UI (No logic mutation allowed)
	_recursively_style_nodes(target_ui, def)

func _recursively_style_nodes(node: Node, def: Dictionary):
	for child in node.get_children():
		# Aesthetic framing of identical stimuli
		if child is ColorRect and child.name == "VoidBG":
			child.color = def["palette"]["bg"]
		elif child is Button:
			_apply_button_aesthetics(child, def)
		elif child is Label:
			_apply_typography_rules(child, def)
			
		_recursively_style_nodes(child, def)

func _apply_button_aesthetics(btn: Button, def: Dictionary):
	# Applies pure color and border styling, never touches hitboxes or disabled states
	var style = StyleBoxFlat.new()
	style.bg_color = def["palette"]["primary"]
	style.bg_color.a = 0.2
	style.border_width_bottom = 2
	style.border_color = def["palette"]["primary"]
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_color_override("font_color", def["palette"]["primary"].lightened(0.5))

func _apply_typography_rules(lbl: Label, def: Dictionary):
	lbl.add_theme_color_override("font_color", def["palette"]["primary"])
	if lbl.name == "FeedbackLabel":
		# We can alter the aesthetic presentation of the text, but the raw event was already logged.
		pass
