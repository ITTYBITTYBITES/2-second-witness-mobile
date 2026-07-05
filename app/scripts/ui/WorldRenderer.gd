extends Node
class_name WorldRenderer

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# WORLD PRESENTATION MANIFOLD (REGISTRY-DRIVEN)
# World overrides are sourced from ContentRegistry.
# ---------------------------------------------------------

func _registry() -> Node:
	return ContentRegistry if ContentRegistry else get_tree().root.get_node_or_null("ContentRegistry")

func _to_color(value: Variant, fallback: Color) -> Color:
	if value is Color: return value
	if typeof(value) == TYPE_STRING and str(value).strip_edges() != "": return Color(str(value))
	return fallback

func get_world_modifiers(world_id: String, base_universe_def: Dictionary) -> Dictionary:
	var reg = _registry()
	var w = {}
	if reg and reg.has_method("get_world"):
		w = reg.get_world(base_universe_def.get("universe_id", ""), world_id)
	
	if w.is_empty():
		return base_universe_def.duplicate(true)
		
	var modified_def = base_universe_def.duplicate(true)
	
	if w.has("palette_override"):
		var po = w["palette_override"]
		if po.has("accent"):
			modified_def["palette"]["primary"] = _to_color(po["accent"], modified_def["palette"].get("primary", Color("#00D4FF")))
		if po.has("shadow"):
			modified_def["palette"]["bg"] = _to_color(po["shadow"], modified_def["palette"].get("bg", Color("#0B1320")))
			
	if w.has("tunnel_modifier"):
		modified_def["tunnel_modifier"] = w["tunnel_modifier"]
		
	if w.has("lens_accent"):
		modified_def["lens_accent"] = w["lens_accent"]
		
	if w.has("cognitive_presentation"):
		modified_def["cognitive_presentation"] = w["cognitive_presentation"]
		
	return modified_def
