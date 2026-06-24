extends Node

var runtime_index = {} # Structure: [universe_id][world_id][type_id] = Array[Dictionary]

func _ready():
	print("ContentRegistry initialized. Awaiting content ingestion...")

func register_scenario(data: Dictionary):
	var u_id = data.get("universe", "unknown")
	var w_id = data.get("world", "unknown")
	var t_id = data.get("type", "unknown")
	
	if not runtime_index.has(u_id):
		runtime_index[u_id] = {}
	if not runtime_index[u_id].has(w_id):
		runtime_index[u_id][w_id] = {}
	if not runtime_index[u_id][w_id].has(t_id):
		runtime_index[u_id][w_id][t_id] = []
		
	runtime_index[u_id][w_id][t_id].append(data)

func resolve_scenario(universe_id: String, world_id: String, type_id: String, seed_string: String) -> Dictionary:
	# Fallback if the universe or type doesn't exist at all
	if not runtime_index.has(universe_id): return {}
	
	var pool = []
	
	if world_id == "" or world_id == "all":
		# UNIVERSE EXPLORATION MODE: Aggregate all worlds inside the universe for this type
		for w_key in runtime_index[universe_id].keys():
			if runtime_index[universe_id][w_key].has(type_id):
				pool.append_array(runtime_index[universe_id][w_key][type_id])
	else:
		# WORLD FOCUS MODE: Pull strictly from the targeted world
		if runtime_index[universe_id].has(world_id) and runtime_index[universe_id][world_id].has(type_id):
			pool = runtime_index[universe_id][world_id][type_id]
			
	if pool.size() == 0:
		return {}
		
	# Deterministic Selection Rule
	var hash_val = seed_string.hash()
	var selected_index = hash_val % pool.size()
	
	return pool[selected_index]
	
func get_all_worlds_in_universe(universe_id: String) -> Array:
	if runtime_index.has(universe_id):
		return runtime_index[universe_id].keys()
	return []
