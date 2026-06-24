extends Node
class_name WorldRenderer

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# WORLD PRESENTATION MANIFOLD (THEMATIC VARIANTS)
# ---------------------------------------------------------

# The WorldRenderer acts as a modifier on top of the Universe base.
# It defines the specific visual, audio, and thematic overlays for a World.

var world_definitions = {
	"ancient_egypt": {
		"universe_id": "history",
		"palette_override": {"accent": Color("#E6C229"), "shadow": Color("#4A2511")},
		"tunnel_modifier": {"fog_density": 1.5, "flow_type": "wave"},
		"lens_accent": "eye_of_horus_engraving" 
	},
	"roman_empire": {
		"universe_id": "history",
		"palette_override": {"accent": Color("#D90429"), "shadow": Color("#2B2D42")},
		"tunnel_modifier": {"fog_density": 0.8, "flow_type": "linear"},
		"lens_accent": "laurel_wreath_engraving"
	},
	"physics": {
		"universe_id": "science_lab",
		"palette_override": {"accent": Color("#00F5FF"), "shadow": Color("#001B2E")},
		"tunnel_modifier": {"fog_density": 1.0, "flow_type": "branching"},
		"lens_accent": "atomic_orbitals"
	},
	"astronomy": {
		"universe_id": "science_lab",
		"palette_override": {"accent": Color("#9D4EDD"), "shadow": Color("#0B090A")},
		"tunnel_modifier": {"fog_density": 0.2, "flow_type": "vortex"},
		"lens_accent": "constellation_map"
	}
}

func get_world_modifiers(world_id: String, base_universe_def: Dictionary) -> Dictionary:
	if not world_definitions.has(world_id):
		return base_universe_def # Fallback to pure Universe base
		
	var w_def = world_definitions[world_id]
	var modified_def = base_universe_def.duplicate(true)
	
	# Apply World-specific Palette Overrides
	if w_def.has("palette_override"):
		if w_def["palette_override"].has("accent"):
			modified_def["palette"]["primary"] = w_def["palette_override"]["accent"]
		if w_def["palette_override"].has("shadow"):
			modified_def["palette"]["bg"] = w_def["palette_override"]["shadow"]
			
	# Apply Tunnel Modifiers (Fog, Flow Speed, Flow Pattern)
	if w_def.has("tunnel_modifier"):
		modified_def["tunnel_modifier"] = w_def["tunnel_modifier"]
		
	# Apply Lens Accent (Passed down to AssetResolver to swap the core texture of the Iris)
	if w_def.has("lens_accent"):
		modified_def["lens_accent"] = w_def["lens_accent"]
		
	return modified_def
