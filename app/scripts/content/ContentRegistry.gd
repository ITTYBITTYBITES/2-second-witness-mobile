extends Node

var runtime_index = {} # Active working set

func _ready():
	print("ContentRegistry initialized. Awaiting content ingestion...")

func register_scenario(data: Dictionary):
	var u_id = data.get("universe", "unknown")
	var w_id = data.get("world", "unknown")
	var t_id = data.get("type", "unknown")
	
	if not runtime_index.has(u_id):
		runtime_index[u_id] = {}
	if not runtime_index[u_id].has(t_id):
		runtime_index[u_id][t_id] = []
		
	runtime_index[u_id][t_id].append(data)

func resolve_scenario(universe_id: String, type_id: String, seed_string: String) -> Dictionary:
	if not runtime_index.has(universe_id) or not runtime_index[universe_id].has(type_id):
		return {}
		
	var pool = runtime_index[universe_id][type_id]
	if pool.size() == 0:
		return {}
		
	# Deterministic Selection Rule: No randomness chaos.
	var hash_val = seed_string.hash()
	var selected_index = hash_val % pool.size()
	
	return pool[selected_index]
