extends Node
class_name VisualIdentityManagerNode

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness (Liquid Memory V2)
# VISUAL IDENTITY MANAGER (AUTHORITATIVE VISUAL BINDING LAYER)
# Bridge: ContentGraph -> Visual Assets -> UI Rendering
# ---------------------------------------------------------

signal visual_identity_applied(universe_id: String, world_id: String, identity_data: Dictionary)

# 1. Authoritative Universe Visual Binding Library
var universe_identities = {
	"science_lab": {
		"display_name": "Science Lab",
		"banner": "res://assets/textures/ui/v1/banner_science_lab.png",
		"background": "res://assets/textures/env/bg_science_lab.png",
		"palette": {"bg": Color("#0B1320"), "primary": Color("#00D4FF"), "accent": Color("#80E5FF")},
		"typography": "TECHNICAL",
		"emotion": "CLINICAL",
		"motion_scale": 1.0,
		"lens_profile": "particle_accelerator"
	},
	"history": {
		"display_name": "Historical Archives",
		"banner": "res://assets/textures/ui/v1/banner_history.png",
		"background": "res://assets/textures/env/v1/bg_society_mind.png", # Textured fallback
		"palette": {"bg": Color("#1A1400"), "primary": Color("#E6B800"), "accent": Color("#FFD700")},
		"typography": "HEAVY",
		"emotion": "WARM",
		"motion_scale": 1.2,
		"lens_profile": "eye_of_horus"
	},
	"tech_ops": {
		"display_name": "Tech Ops",
		"banner": "res://assets/textures/ui/v1/banner_tech_ops.png",
		"background": "res://assets/textures/env/bg_tech_ops.png",
		"palette": {"bg": Color("#050505"), "primary": Color("#00FF41"), "accent": Color("#66FF88")},
		"typography": "TECHNICAL",
		"emotion": "UNCANNY",
		"motion_scale": 0.8,
		"lens_profile": "cyber_matrix"
	},
	"life_sciences": {
		"display_name": "Life Sciences",
		"banner": "res://assets/textures/ui/v1/banner_life_sciences.png",
		"background": "res://assets/textures/env/v1/bg_life_sciences.png",
		"palette": {"bg": Color("#0A1A10"), "primary": Color("#2ECC71"), "accent": Color("#70DB93")},
		"typography": "SPARSE",
		"emotion": "NATURAL",
		"motion_scale": 1.2,
		"lens_profile": "cellular_membrane"
	},
	"creative_arts": {
		"display_name": "Creative Arts",
		"banner": "res://assets/textures/ui/v1/banner_creative_arts.png",
		"background": "res://assets/textures/env/v1/bg_creative_arts.png",
		"palette": {"bg": Color("#180A22"), "primary": Color("#B833FF"), "accent": Color("#D175FF")},
		"typography": "SPARSE",
		"emotion": "SATURATED",
		"motion_scale": 1.5,
		"lens_profile": "prismatic_lens"
	},
	"society_mind": {
		"display_name": "Society & Mind",
		"banner": "res://assets/textures/ui/v1/banner_society_mind.png",
		"background": "res://assets/textures/env/v1/bg_society_mind.png",
		"palette": {"bg": Color("#120818"), "primary": Color("#FF3366"), "accent": Color("#FF8099")},
		"typography": "HEAVY",
		"emotion": "UNCANNY",
		"motion_scale": 1.1,
		"lens_profile": "wormhole_singularity"
	},
	"frontier": {
		"display_name": "The Frontier",
		"banner": "res://assets/textures/ui/v1/banner_frontier.png",
		"background": "res://assets/textures/env/v1/bg_frontier.png",
		"palette": {"bg": Color("#081218"), "primary": Color("#33CCFF"), "accent": Color("#80DFFF")},
		"typography": "TECHNICAL",
		"emotion": "DEEP_SPACE",
		"motion_scale": 1.3,
		"lens_profile": "historical_astrolabe"
	}
}

# 2. Authoritative World Visual Overrides (Inherit Universe + Override Variation)
var world_overrides = {
	"ancient_egypt": {"accent_override": Color("#FFD700"), "tint_alpha": 0.2, "sub_identity": "Pharaonic Dynasties"},
	"ancient_rome": {"accent_override": Color("#FF4500"), "tint_alpha": 0.2, "sub_identity": "Imperial Legions"},
	"cognitive_bias": {"accent_override": Color("#00FFFF"), "tint_alpha": 0.15, "sub_identity": "Heuristic Faults"},
	"neural_mapping": {"accent_override": Color("#3399FF"), "tint_alpha": 0.15, "sub_identity": "Synaptic Pathways"},
	"genetics": {"accent_override": Color("#00FF7F"), "tint_alpha": 0.2, "sub_identity": "DNA Sequencing"},
	"cyber_matrix": {"accent_override": Color("#00FF00"), "tint_alpha": 0.25, "sub_identity": "Subliminal Architecture"},
	"color_theory": {"accent_override": Color("#FF00FF"), "tint_alpha": 0.2, "sub_identity": "Prismatic Harmonies"}
}

var active_universe_id: String = "science_lab"
var active_world_id: String = ""
var active_identity_payload: Dictionary = {}

func _ready():
	if BootTracer: BootTracer.log_init("VisualIdentityManager")
	print("[VISUAL IDENTITY] Online. Binding content graph to visual identity layer.")

func get_universe_identity(universe_id: String) -> Dictionary:
	var u_id = str(universe_id).to_lower()
	if universe_identities.has(u_id):
		return universe_identities[u_id].duplicate(true)
	var base = universe_identities["science_lab"].duplicate(true)
	base["display_name"] = u_id.capitalize().replace("_", " ")
	if FileAccess.file_exists("res://assets/textures/ui/v1/banner_" + u_id + ".png"):
		base["banner"] = "res://assets/textures/ui/v1/banner_" + u_id + ".png"
	if FileAccess.file_exists("res://assets/textures/env/bg_" + u_id + ".png"):
		base["background"] = "res://assets/textures/env/bg_" + u_id + ".png"
	return base

func get_world_identity(universe_id: String, world_id: String) -> Dictionary:
	var base_id = get_universe_identity(universe_id)
	var w_id = str(world_id).to_lower()
	if world_overrides.has(w_id):
		var over = world_overrides[w_id]
		if over.has("accent_override"):
			base_id["palette"]["accent"] = over["accent_override"]
		if over.has("sub_identity"):
			base_id["world_sub_identity"] = over["sub_identity"]
		base_id["world_tint_alpha"] = over.get("tint_alpha", 0.15)
	else:
		base_id["world_sub_identity"] = w_id.capitalize().replace("_", " ")
		base_id["world_tint_alpha"] = 0.15
	return base_id

func resolve_and_apply_identity(universe_id: String, world_id: String = "") -> Dictionary:
	active_universe_id = universe_id
	active_world_id = world_id
	active_identity_payload = get_world_identity(universe_id, world_id)
	
	print("[VISUAL IDENTITY] Resolved identity for [", universe_id, " -> ", world_id, "]: ", active_identity_payload["display_name"])
	visual_identity_applied.emit(universe_id, world_id, active_identity_payload)
	return active_identity_payload

func apply_screen_identity(screen_node: Node, universe_id: String, world_id: String = "", show_banner: bool = true) -> Dictionary:
	var identity = resolve_and_apply_identity(universe_id, world_id)
	var pal = identity["palette"]
	
	# 1. Background ColorRect modulation
	var bg = screen_node.get_node_or_null("ColorRect") if screen_node.has_node("ColorRect") else screen_node.get_node_or_null("VoidBG")
	if bg and bg is ColorRect:
		bg.color = pal["bg"]
		bg.color.a = identity.get("world_tint_alpha", 0.15)
		
	# 2. PanelContainer Glass Styling
	var panel = screen_node.get_node_or_null("PanelContainer") if screen_node.has_node("PanelContainer") else screen_node.get_node_or_null("Panel")
	if panel and panel is Container and panel.has_theme_stylebox_override("panel"):
		var sb = panel.get_theme_stylebox("panel").duplicate()
		if sb is StyleBoxFlat:
			sb.bg_color = pal["bg"]
			sb.bg_color.a = 0.95
			sb.border_color = pal["primary"]
			panel.add_theme_stylebox_override("panel", sb)
			
	# 3. Title font color
	var title = screen_node.find_child("Title", true, false)
	if title and title is Label:
		title.add_theme_color_override("font_color", pal["primary"])
		if world_id != "" and identity.has("world_sub_identity"):
			title.text = identity["display_name"].to_upper() + " — " + str(identity["world_sub_identity"]).to_upper()
			
	# 4. Hero Banner Insertion (Top Header of PanelContainer)
	if show_banner and identity.has("banner") and identity["banner"] != "":
		_inject_hero_banner(screen_node, panel, identity["banner"])
		
	return identity

func _inject_hero_banner(_screen_node: Node, panel_node: Node, banner_path: String):
	if not panel_node: return
	var vbox = panel_node.find_child("VBoxContainer", true, false)
	if not vbox: return
	
	var banner_rect = vbox.get_node_or_null("HeroBanner")
	if not banner_rect:
		banner_rect = TextureRect.new()
		banner_rect.name = "HeroBanner"
		banner_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		banner_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		banner_rect.custom_minimum_size = Vector2(0, 140)
		banner_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(banner_rect)
		vbox.move_child(banner_rect, 0) # Place at the very top of VBoxContainer
		
	if FileAccess.file_exists(banner_path):
		banner_rect.texture = load(banner_path)
		banner_rect.visible = true
		print("[VISUAL IDENTITY] Successfully injected hero banner: ", banner_path)
	else:
		banner_rect.visible = false
		print("[VISUAL IDENTITY WARNING] Banner asset not found: ", banner_path)
