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

func _ready():
	if BootTracer: BootTracer.log_init("ContentRegistry")
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
	if not runtime_index.has(universe_id): return {}
	
	var pool = []
	
	if world_id == "" or world_id == "all":
		for w_key in runtime_index[universe_id].keys():
			if runtime_index[universe_id][w_key].has(type_id):
				pool.append_array(runtime_index[universe_id][w_key][type_id])
	else:
		if runtime_index[universe_id].has(world_id) and runtime_index[universe_id][world_id].has(type_id):
			pool = runtime_index[universe_id][world_id][type_id]
			
	if pool.size() == 0:
		return {}
		
	var hash_val = seed_string.hash()
	var selected_index = hash_val % pool.size()
	
	return pool[selected_index]
	
func get_all_worlds_in_universe(universe_id: String) -> Array:
	if runtime_index.has(universe_id):
		return runtime_index[universe_id].keys()
	return []
