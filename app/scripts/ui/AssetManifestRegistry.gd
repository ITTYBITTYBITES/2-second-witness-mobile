extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# VERSION-LOCKED ASSET MANIFESTS & WORLD COMPILER PROXY
# ---------------------------------------------------------

const CURRENT_ASSET_VERSION = "v1.0.0"

# Missing assets must fail loudly. We define a specific DEGRADED asset, not a silent primitive.
const DEGRADED_MESH_PATH = "res://assets/meshes/degraded_fallback.obj"

var manifests = {
	"v1.0.0": {
		"science_lab": {
			"bg_noise": "res://assets/textures/env/v1/grid_noise_soft.png",
			"rib_mesh": "res://assets/meshes/rib_science_lab.obj",
			"particle_accelerator_tier_0": "res://assets/meshes/iris_crystalline.obj",
			"particle_accelerator_tier_1": "res://assets/meshes/iris_crystalline.obj",
			"particle_accelerator_tier_2": "res://assets/meshes/iris_crystalline.obj",
			"particle_accelerator_tier_3": "res://assets/meshes/iris_crystalline.obj"
		},
		"history": {
			"bg_noise": "res://assets/textures/env/v1/bg_society_mind.png",
			"rib_mesh": "res://assets/meshes/rib_society_mind.obj",
			"eye_of_horus_tier_0": "res://assets/meshes/iris_crystalline.obj",
			"eye_of_horus_tier_1": "res://assets/meshes/iris_crystalline.obj",
			"eye_of_horus_tier_2": "res://assets/meshes/iris_crystalline.obj",
			"eye_of_horus_tier_3": "res://assets/meshes/iris_crystalline.obj"
		},
		"tech_ops": {
			"bg_noise": "res://assets/textures/env/v1/plasma_static.png",
			"rib_mesh": "res://assets/meshes/rib_tech_ops.obj",
			"cyber_matrix_tier_0": "res://assets/meshes/iris_crystalline.obj",
			"cyber_matrix_tier_1": "res://assets/meshes/iris_crystalline.obj",
			"cyber_matrix_tier_2": "res://assets/meshes/iris_crystalline.obj",
			"cyber_matrix_tier_3": "res://assets/meshes/iris_crystalline.obj"
		},
		"life_sciences": {
			"bg_noise": "res://assets/textures/env/v1/bg_life_sciences.png",
			"rib_mesh": "res://assets/meshes/rib_life_sciences.obj",
			"cellular_membrane_tier_0": "res://assets/meshes/iris_crystalline.obj",
			"cellular_membrane_tier_1": "res://assets/meshes/iris_crystalline.obj",
			"cellular_membrane_tier_2": "res://assets/meshes/iris_crystalline.obj",
			"cellular_membrane_tier_3": "res://assets/meshes/iris_crystalline.obj"
		},
		"society_mind": {
			"bg_noise": "res://assets/textures/env/v1/bg_society_mind.png",
			"rib_mesh": "res://assets/meshes/rib_society_mind.obj",
			"historical_astrolabe_tier_0": "res://assets/meshes/iris_crystalline.obj",
			"historical_astrolabe_tier_1": "res://assets/meshes/iris_crystalline.obj",
			"historical_astrolabe_tier_2": "res://assets/meshes/iris_crystalline.obj",
			"historical_astrolabe_tier_3": "res://assets/meshes/iris_crystalline.obj"
		},
		"creative_arts": {
			"bg_noise": "res://assets/textures/env/v1/bg_creative_arts.png",
			"rib_mesh": "res://assets/meshes/rib_creative_arts.obj",
			"prismatic_lens_tier_0": "res://assets/meshes/iris_crystalline.obj",
			"prismatic_lens_tier_1": "res://assets/meshes/iris_crystalline.obj",
			"prismatic_lens_tier_2": "res://assets/meshes/iris_crystalline.obj",
			"prismatic_lens_tier_3": "res://assets/meshes/iris_crystalline.obj"
		},
		"frontier": {
			"bg_noise": "res://assets/textures/env/v1/bg_frontier.png",
			"rib_mesh": "res://assets/meshes/rib_frontier.obj",
			"wormhole_singularity_tier_0": "res://assets/meshes/iris_crystalline.obj",
			"wormhole_singularity_tier_1": "res://assets/meshes/iris_crystalline.obj",
			"wormhole_singularity_tier_2": "res://assets/meshes/iris_crystalline.obj",
			"wormhole_singularity_tier_3": "res://assets/meshes/iris_crystalline.obj"
		}
	}
}

func get_manifest(universe_id: String, version: String = CURRENT_ASSET_VERSION) -> Dictionary:
	if not manifests.has(version):
		push_error("[ASSET REGISTRY FATAL] Requested Asset Version Hash does not exist: " + version)
		return {}
	
	if not manifests[version].has(universe_id):
		var clean_name = universe_id.capitalize().replace("_", " ")
		var fallback_bg = "res://assets/textures/env/v1/grid_noise_soft.png"
		var u_manifest = {
			"id": universe_id,
			"display_name": clean_name,
			"version": version,
			"textures": {"bg_noise": fallback_bg},
			"meshes": {"iris_accent": "res://assets/models/v1/iris_ring_base.obj"},
			"audio": {"ambience_loop": "res://assets/audio/ambience/v1/ambient_stream_01.ogg"}
		}
		manifests[version][universe_id] = u_manifest
		return u_manifest
		
	return manifests[version][universe_id]

func get_world_bundle(universe_id: String, world_id: String, modifiers: Dictionary = {}) -> Dictionary:
	return WorldAssetCompiler.get_or_compile_world(universe_id, world_id, modifiers)

func get_bundle_by_hash(world_hash: int) -> Dictionary:
	return WorldAssetCompiler.get_bundle(world_hash)

func resolve_asset(manifest: Dictionary, key: String) -> String:
	if manifest.has("hash"):
		if key == "bg_noise" and manifest.has("textures") and manifest["textures"].has("bg_noise_path"):
			return manifest["textures"]["bg_noise_path"]
		if key.begins_with("iris_") or key.contains("tier_") or key.contains("lens"):
			if manifest.has("meshes") and manifest["meshes"].has("iris_accent_path"):
				return manifest["meshes"]["iris_accent_path"]
		if key == "audio_overlay" and manifest.has("audio") and manifest["audio"].has("audio_overlay_path"):
			return manifest["audio"]["audio_overlay_path"]

	if not manifest.has(key):
		push_error("[ASSET REGISTRY ERROR] Asset Key missing from manifest: " + key)
		return DEGRADED_MESH_PATH
	
	var path = manifest[key]
	if not ResourceLoader.exists(path) and not FileAccess.file_exists(path):
		push_error("[ASSET REGISTRY ERROR] Asset File physically missing at path: " + path)
		return DEGRADED_MESH_PATH
		
	return path
