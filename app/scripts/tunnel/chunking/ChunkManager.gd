extends Node3D
class_name ChunkManager

@onready var chunk_spawner = $ChunkSpawner
@onready var chunk_pool = $ChunkPool
@onready var instance_registry = $InstanceRegistry
@onready var stream_controller = $StreamController

# Android Constraints
const MAX_VISIBLE_CHUNKS = 5
const MAX_INSTANCES_PER_CHUNK = 250
const CHUNK_LENGTH = 50.0

var active_speed_multiplier: float = 1.0
var device_performance_factor: float = 1.0 # 0.5 for low-end, 1.0 for high-end

func _ready():
	_detect_device_performance()
	if stream_controller:
		stream_controller.chunk_pool = chunk_pool

func apply_theme(theme_data: Dictionary, universe_id: String = "", world_id: String = ""):
	var u_id = universe_id if universe_id != "" else theme_data.get("id", "")
	if u_id == "":
		var registry = get_tree().root.get_node_or_null("ContentRegistry")
		if registry and registry.has_method("get_first_universe"):
			u_id = registry.get_first_universe()
	var tunnel = theme_data.get("tunnel", {})
	var world_prof = WorldProfileCustodian.get_profile(world_id) if world_id != "" and Engine.get_main_loop().root.has_node("WorldProfileCustodian") else {}
	active_speed_multiplier = world_prof.get("tunnel", {}).get("speed_multiplier", tunnel.get("speed_multiplier", 1.0))
	var theme_density = world_prof.get("tunnel", {}).get("density", tunnel.get("density", 1.0))
	
	# Density calculation
	var final_density = theme_density * device_performance_factor
	
	print("[CHUNK MANAGER] Re-initializing stream buffer. Scaled Density: ", final_density)
	
	# Instruct subsystems to purge and recreate for the new Theme
	instance_registry.assign_mesh_profiles(theme_data)
	chunk_pool.reset_pool(MAX_VISIBLE_CHUNKS, universe_id)
	stream_controller.chunk_pool = chunk_pool
	stream_controller.set_flow_speed(active_speed_multiplier)
	chunk_spawner.seed_initial_buffer(final_density)

func _detect_device_performance():
	# Future: Interrogate OS memory/CPU limits
	device_performance_factor = 1.0
