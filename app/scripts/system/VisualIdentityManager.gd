extends Node
class_name VisualIdentityManagerNode

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# VISUAL IDENTITY MANAGER (REGISTRY-DRIVEN VISUAL BINDING)
# Bridge: ContentGraph -> Visual Assets -> UI Rendering
# All universe/world identity data is sourced from ContentRegistry.
# ---------------------------------------------------------

signal visual_identity_applied(universe_id: String, world_id: String, identity_data: Dictionary)

var active_universe_id: String = ""
var active_world_id: String = ""
var active_identity_payload: Dictionary = {}

func _ready():
	if BootTracer: BootTracer.log_init("VisualIdentityManager")
	print("[VISUAL IDENTITY] Online. Binding content graph to visual identity layer via registry.")

func _coerce_color(value: Variant, fallback: Color) -> Color:
	if value is Color:
		return value
	if typeof(value) == TYPE_STRING:
		var text = str(value).strip_edges()
		if text != "":
			return Color(text)
	return fallback

func _normalize_palette(identity: Dictionary) -> Dictionary:
	if not identity.has("palette") or not (identity["palette"] is Dictionary):
		identity["palette"] = {}
	var palette: Dictionary = identity["palette"]
	palette["bg"] = _coerce_color(palette.get("bg", Color("#0B1320")), Color("#0B1320"))
	palette["primary"] = _coerce_color(palette.get("primary", Color("#00D4FF")), Color("#00D4FF"))
	palette["accent"] = _coerce_color(palette.get("accent", Color("#80E5FF")), Color("#80E5FF"))
	identity["palette"] = palette
	return identity

func _registry() -> Node:
	return ContentRegistry if ContentRegistry else get_tree().root.get_node_or_null("ContentRegistry")

func get_universe_identity(universe_id: String) -> Dictionary:
	var reg = _registry()
	if reg and reg.has_method("get_universe_identity"):
		var identity = reg.get_universe_identity(universe_id).duplicate(true)
		return _normalize_palette(identity)
	# Minimal fallback only if registry unavailable (should never happen in production)
	return _normalize_palette({
		"display_name": str(universe_id).capitalize().replace("_", " "),
		"banner": "",
		"background": "",
		"palette": {"bg": Color("#0B1320"), "primary": Color("#00D4FF"), "accent": Color("#80E5FF")},
		"typography": "TECHNICAL",
		"emotion": "CLINICAL",
		"motion_scale": 1.0,
		"lens_profile": "particle_accelerator"
	})

func get_world_identity(universe_id: String, world_id: String) -> Dictionary:
	var base_id = get_universe_identity(universe_id)
	var w_id = str(world_id).to_lower()
	var reg = _registry()
	if reg and reg.has_method("get_world_identity"):
		base_id = reg.get_world_identity(universe_id, world_id).duplicate(true)
		return _normalize_palette(base_id)
	
	var custodian = Engine.get_main_loop().root.get_node_or_null("WorldProfileCustodian") if Engine.get_main_loop() else null
	var cust_profile = custodian.get_profile(w_id) if (custodian and custodian.has_method("get_profile")) else {}
	
	if not cust_profile.is_empty() and cust_profile.get("world", "") == w_id:
		if cust_profile.has("ui") and cust_profile["ui"].has("border_color"):
			base_id["palette"]["primary"] = _coerce_color(cust_profile["ui"]["border_color"], base_id["palette"].get("primary", Color("#00D4FF")))
		if cust_profile.has("lens") and cust_profile["lens"].has("colors"):
			var c = cust_profile["lens"]["colors"]
			if c.has("primary"): base_id["palette"]["accent"] = _coerce_color(c["primary"], base_id["palette"].get("accent", Color("#80E5FF")))
			if c.has("bg"): base_id["palette"]["bg"] = _coerce_color(c["bg"], base_id["palette"].get("bg", Color("#0B1320")))
		base_id["world_sub_identity"] = w_id.capitalize().replace("_", " ")
		base_id["world_tint_alpha"] = cust_profile.get("ui", {}).get("glass_opacity", 0.18)
	else:
		base_id["world_sub_identity"] = w_id.capitalize().replace("_", " ")
		base_id["world_tint_alpha"] = 0.15
	return _normalize_palette(base_id)

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
		vbox.move_child(banner_rect, 0)
		
	if FileAccess.file_exists(banner_path):
		banner_rect.texture = load(banner_path)
		banner_rect.visible = true
		print("[VISUAL IDENTITY] Successfully injected hero banner: ", banner_path)
	else:
		banner_rect.visible = false
		print("[VISUAL IDENTITY WARNING] Banner asset not found: ", banner_path)
