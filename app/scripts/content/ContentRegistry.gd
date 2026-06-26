extends Node

var runtime_index = {} # Structure: [universe_id][world_id][type_id] = Array[Dictionary]

var curated_missions = {
	"history_ancient_egypt": [
		{
			"mission_id": "life_along_nile",
			"title": "Life Along the Nile",
			"description": "Examine the ecological and agricultural cycles of the Nile river basin.",
			"mechanics_chain": ["memory_cascade", "stroop_test", "signal_vs_noise", "spatial_recall"]
		},
		{
			"mission_id": "pharaohs_court",
			"title": "Pharaoh's Court",
			"description": "Process political hierarchies, royal decrees, and dynastic lineage under time pressure.",
			"mechanics_chain": ["rapid_classification", "pattern_continuation", "memory_cascade", "reflex_tap"]
		},
		{
			"mission_id": "building_pyramids",
			"title": "Building the Pyramids",
			"description": "Analyze monumental architectural trade-offs, labor logistics, and geometry.",
			"mechanics_chain": ["sequence_reverse", "speed_sort", "signal_vs_noise", "stroop_test"]
		},
		{
			"mission_id": "the_tomb_builder",
			"title": "The Tomb Builder",
			"description": "Navigate funerary texts, sacred geometry, and subterranean traps.",
			"mechanics_chain": ["spatial_recall", "rapid_classification", "memory_cascade", "speed_sort"]
		}
	]
}

func normalize_id(id: Variant) -> String:
	return str(id)

func _ready():
	if BootTracer: BootTracer.log_init("ContentRegistry")
	print("ContentRegistry initialized. Awaiting content ingestion...")

func register_scenario(data: Dictionary):
	var u_id = normalize_id(data.get("universe", "unknown"))
	var w_id = normalize_id(data.get("world", "unknown"))
	var t_id = normalize_id(data.get("type", "unknown"))
	var s_id = normalize_id(data.get("id", "unknown"))
	
	data["universe"] = u_id
	data["world"] = w_id
	data["type"] = t_id
	data["id"] = s_id
	
	if not runtime_index.has(u_id):
		runtime_index[u_id] = {}
	if not runtime_index[u_id].has(w_id):
		runtime_index[u_id][w_id] = {}
	if not runtime_index[u_id][w_id].has(t_id):
		runtime_index[u_id][w_id][t_id] = []
		
	runtime_index[u_id][w_id][t_id].append(data)

func resolve_scenario(universe_id: Variant, world_id: Variant, type_id: Variant, seed_string: Variant) -> Dictionary:
	var u_id = normalize_id(universe_id)
	var w_id = normalize_id(world_id)
	var t_id = normalize_id(type_id)
	var s_str = normalize_id(seed_string)
	
	if not runtime_index.has(u_id): return {}
	
	var pool = []
	
	if w_id == "" or w_id == "all":
		for w_key in runtime_index[u_id].keys():
			if runtime_index[u_id][w_key].has(t_id):
				pool.append_array(runtime_index[u_id][w_key][t_id])
	else:
		if runtime_index[u_id].has(w_id) and runtime_index[u_id][w_id].has(t_id):
			pool = runtime_index[u_id][w_id][t_id]
			
	if pool.size() == 0:
		return {}
		
	var hash_val = s_str.hash()
	var selected_index = hash_val % pool.size()
	
	return pool[selected_index]
	
func get_all_worlds_in_universe(universe_id: Variant) -> Array:
	var u_id = normalize_id(universe_id)
	if runtime_index.has(u_id):
		return runtime_index[u_id].keys()
	return []
