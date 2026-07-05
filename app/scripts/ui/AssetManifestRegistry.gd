extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# VERSION-LOCKED ASSET MANIFESTS (REGISTRY-DRIVEN)
# Universe-specific asset data is sourced from ContentRegistry.
# ---------------------------------------------------------

const CURRENT_ASSET_VERSION = "v1.0.0"

# Missing assets must fail loudly. We define a specific DEGRADED asset, not a silent primitive.
const DEGRADED_MESH_PATH = "res://assets/meshes/degraded_fallback.obj"

func _registry() -> Node:
	return ContentRegistry if ContentRegistry else get_tree().root.get_node_or_null("ContentRegistry")

func get_manifest(universe_id: String, version: String = CURRENT_ASSET_VERSION) -> Dictionary:
	if version != CURRENT_ASSET_VERSION:
		push_error("[ASSET REGISTRY FATAL] Requested Asset Version Hash does not exist: " + version)
		return {}
	
	var reg = _registry()
	if reg and reg.has_method("get_universe"):
		var spec = reg.get_universe(universe_id)
		var manifest = spec.get("assets", {})
		if not manifest.is_empty():
			return manifest.duplicate(true)
	
	push_warning("[ASSET REGISTRY] No manifest for universe: " + universe_id + "; returning degraded fallback.")
	return {
		"bg_noise": "res://assets/textures/env/v1/grid_noise_soft.png",
		"rib_mesh": DEGRADED_MESH_PATH,
		"particle_accelerator_tier_0": DEGRADED_MESH_PATH,
		"particle_accelerator_tier_1": DEGRADED_MESH_PATH,
		"particle_accelerator_tier_2": DEGRADED_MESH_PATH,
		"particle_accelerator_tier_3": DEGRADED_MESH_PATH
	}
