extends Node
class_name AssetManifestRegistry

const CURRENT_ASSET_VERSION = "v1.0.0"

var manifests = {
	"v1.0.0": {
		"science_lab": {
			"bg_noise": "res://assets/textures/env/v1/grid_noise_soft.png",
			"rib_mesh": "res://assets/meshes/rib_science_lab.obj"
		},
		"tech_ops": {
			"bg_noise": "res://assets/textures/env/v1/bg_tech_ops.png",
			"rib_mesh": "res://assets/meshes/rib_tech_ops.obj"
		},
		"life_sciences": {
			"bg_noise": "res://assets/textures/env/v1/bg_life_sciences.png",
			"rib_mesh": "res://assets/meshes/rib_life_sciences.obj"
		},
		"society_mind": {
			"bg_noise": "res://assets/textures/env/v1/bg_society_mind.png",
			"rib_mesh": "res://assets/meshes/rib_society_mind.obj"
		},
		"creative_arts": {
			"bg_noise": "res://assets/textures/env/v1/bg_creative_arts.png",
			"rib_mesh": "res://assets/meshes/rib_creative_arts.obj"
		},
		"frontier": {
			"bg_noise": "res://assets/textures/env/v1/bg_frontier.png",
			"rib_mesh": "res://assets/meshes/rib_frontier.obj"
		}
	}
}

func get_manifest(universe_id: String, version: String = CURRENT_ASSET_VERSION) -> Dictionary:
	if not manifests.has(version):
		push_error("[ASSET REGISTRY FATAL] Requested Asset Version Hash does not exist: " + version)
		return {}
	return manifests[version].get(universe_id, manifests[version]["science_lab"])
