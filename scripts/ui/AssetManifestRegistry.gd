extends Node
class_name AssetManifestRegistry

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# VERSION-LOCKED ASSET MANIFESTS
# ---------------------------------------------------------

# The engine must only load assets that match a specific, version-pinned hash.
# Cross-version mixing of assets is strictly prohibited to prevent slow perceptual drift.

const CURRENT_ASSET_VERSION = "v1.0.0"

var manifests = {
	"v1.0.0": {
		"science_lab": {
			"button_frame": "res://assets/textures/ui/v1/btn_frame_scilab.png",
			"bg_noise": "res://assets/textures/env/v1/grid_noise_soft.png",
			"stimulus_node": "res://assets/textures/sprites/v1/neural_node_v3.png"
		},
		"tech_ops": {
			"button_frame": "res://assets/textures/ui/v1/btn_frame_tech.png",
			"bg_noise": "res://assets/textures/env/v1/plasma_static.png",
			"stimulus_node": "res://assets/textures/sprites/v1/hard_geo_hex.png"
		}
	}
	# Future revisions (v1.1.0) must be explicitly defined here.
}

func get_manifest(universe_id: String, version: String = CURRENT_ASSET_VERSION) -> Dictionary:
	if not manifests.has(version):
		push_error("[ASSET REGISTRY FATAL] Requested Asset Version Hash does not exist: " + version)
		return {}
		
	return manifests[version].get(universe_id, manifests[version]["science_lab"])
