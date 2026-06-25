extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# VERSION-LOCKED ASSET MANIFESTS (STRICT BINDING)
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
		push_error("[ASSET REGISTRY FATAL] Requested Universe ID does not exist in manifest: " + universe_id)
		return {}
		
	return manifests[version][universe_id]

func resolve_asset(manifest: Dictionary, key: String) -> String:
	if not manifest.has(key):
		push_error("[ASSET REGISTRY ERROR] Asset Key missing from manifest: " + key)
		return DEGRADED_MESH_PATH
	
	var path = manifest[key]
	if not ResourceLoader.exists(path):
		push_error("[ASSET REGISTRY ERROR] Asset File physically missing at path: " + path)
		return DEGRADED_MESH_PATH
		
	return path
