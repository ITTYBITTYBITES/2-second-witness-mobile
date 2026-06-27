extends Node
class_name UniverseRegistry

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness (Liquid Memory V2)
# ASSET REGISTRY LAYER (STABLE LOGICAL KEY TO PHYSICAL PATH MAP)
# ---------------------------------------------------------

var asset_identity_map = {
	"banner_science_lab": "res://assets/textures/ui/v1/banner_science_lab.png",
	"banner_history": "res://assets/textures/ui/v1/banner_history.png",
	"banner_creative_arts": "res://assets/textures/ui/v1/banner_creative_arts.png",
	"banner_frontier": "res://assets/textures/ui/v1/banner_frontier.png",
	"banner_society_mind": "res://assets/textures/ui/v1/banner_society_mind.png",
	"banner_tech_ops": "res://assets/textures/ui/v1/banner_tech_ops.png",
	"banner_life_sciences": "res://assets/textures/ui/v1/banner_life_sciences.png",
	
	"ambience_science_lab": "res://assets/audio/ambience_science_lab.wav",
	"ambience_history": "res://assets/audio/ambience_history.wav",
	"ambience_creative_arts": "res://assets/audio/ambience_creative_arts.wav",
	"ambience_frontier": "res://assets/audio/ambience_frontier.wav",
	"ambience_society_mind": "res://assets/audio/ambience_society_mind.wav",
	"ambience_tech_ops": "res://assets/audio/ambience_tech_ops.wav",
	"ambience_life_sciences": "res://assets/audio/ambience_life_sciences.wav",
	
	"ui_click": "res://assets/audio/ui_click.wav",
	"ui_error": "res://assets/audio/ui_error.wav",
	
	"iris_crystalline": "res://assets/meshes/iris_crystalline.obj",
	"eye_of_horus": "res://assets/meshes/iris_crystalline.obj",
	"prismatic_lens": "res://assets/meshes/iris_crystalline.obj",
	"wormhole_singularity": "res://assets/meshes/iris_crystalline.obj",
	"historical_astrolabe": "res://assets/meshes/iris_crystalline.obj",
	"cyber_matrix": "res://assets/meshes/iris_crystalline.obj",
	"cellular_membrane": "res://assets/meshes/iris_crystalline.obj",
	"data_node": "res://assets/meshes/data_node.obj"
}

func get_physical_path(logical_key: String) -> String:
	if not asset_identity_map.has(logical_key):
		push_error("[UNIVERSE REGISTRY ERROR] Logical asset key not found in identity map: " + logical_key)
		return "res://assets/textures/env/v1/grid_noise_soft.png"
	return asset_identity_map[logical_key]
