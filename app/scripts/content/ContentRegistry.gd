extends Node

var runtime_index = {} # Active working set

func _ready():
	print("ContentRegistry initialized. Awaiting content ingestion...")

func register_scenario(data: Dictionary):
	var u_id = data.get("universe", "unknown")
	var w_id = data.get("world", "unknown")
	var s_id = data.get("id", "unknown")
	
	if not runtime_index.has(u_id):
		runtime_index[u_id] = {}
	if not runtime_index[u_id].has(w_id):
		runtime_index[u_id][w_id] = {}
		
	runtime_index[u_id][w_id][s_id] = data

func resolve_scenario(universe_id: String, world_id: String, chunk_id: String, player_id: String = "local_user") -> Dictionary:
	if not runtime_index.has(universe_id) or not runtime_index[universe_id].has(world_id):
		return {}
		
	var pool = runtime_index[universe_id][world_id].values()
	if pool.size() == 0:
		return {}
		
	# Deterministic Selection Rule: No randomness chaos.
	var seed_string = player_id + world_id + chunk_id
	var hash_val = seed_string.hash()
	var selected_index = hash_val % pool.size()
	
	return pool[selected_index]
