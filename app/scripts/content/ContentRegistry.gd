extends Node

const MASTER_REGISTRY_PATH = "res://MASTER_UNIVERSE_REGISTRY.json"
var master_universe_registry: Dictionary = {}

var runtime_index = {} # Structure: [universe_id][world_id][type_id] = Array[Dictionary]
var _registered_ids: Dictionary = {}
var _world_metadata: Dictionary = {}
var _subcategory_index: Dictionary = {} # [universe_id][world_id][subcategory_id] = metadata

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


func _load_master_registry():
	if not FileAccess.file_exists(MASTER_REGISTRY_PATH):
		push_error("[CONTENT REGISTRY] Master universe registry missing: " + MASTER_REGISTRY_PATH)
		return
	var file = FileAccess.open(MASTER_REGISTRY_PATH, FileAccess.READ)
	if not file:
		push_error("[CONTENT REGISTRY] Failed to open master universe registry")
		return
	var json = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		push_error("[CONTENT REGISTRY] Failed to parse master universe registry")
		file.close()
		return
	file.close()
	var data = json.get_data()
	if typeof(data) != TYPE_DICTIONARY:
		push_error("[CONTENT REGISTRY] Master registry root is not a dictionary")
		return
	master_universe_registry = data
	print("[CONTENT REGISTRY] Master universe registry loaded: ", master_universe_registry.get("universes", {}).size(), " universes")

func get_master_registry() -> Dictionary:
	return master_universe_registry
func _ready():
	if BootTracer: BootTracer.log_init("ContentRegistry")
	print("ContentRegistry initialized. Awaiting content ingestion...")
	_load_master_registry()

func register_world(universe_id: Variant, world_id: Variant, metadata: Dictionary = {}):
	var u_id = normalize_id(universe_id)
	var w_id = normalize_id(world_id)
	if not runtime_index.has(u_id):
		runtime_index[u_id] = {}
	if not runtime_index[u_id].has(w_id):
		runtime_index[u_id][w_id] = {}
	if not metadata.is_empty():
		if not _world_metadata.has(u_id): _world_metadata[u_id] = {}
		_world_metadata[u_id][w_id] = metadata

func register_subcategory(universe_id: Variant, world_id: Variant, subcategory_id: Variant, metadata: Dictionary = {}):
	var u_id = normalize_id(universe_id)
	var w_id = normalize_id(world_id)
	var s_id = normalize_id(subcategory_id)
	register_world(u_id, w_id)
	if not _subcategory_index.has(u_id): _subcategory_index[u_id] = {}
	if not _subcategory_index[u_id].has(w_id): _subcategory_index[u_id][w_id] = {}
	var sub_meta = metadata.duplicate(true)
	sub_meta["id"] = s_id
	_subcategory_index[u_id][w_id][s_id] = sub_meta

func register_scenario(data: Dictionary):
	var u_id = normalize_id(data.get("universe", "unknown"))
	var w_id = normalize_id(data.get("world", "unknown"))
	var t_id = normalize_id(data.get("type", "unknown"))
	var s_id = normalize_id(data.get("id", "unknown"))

	if _registered_ids.has(s_id):
		return
	_registered_ids[s_id] = true

	data["universe"] = u_id
	data["world"] = w_id
	data["type"] = t_id
	data["id"] = s_id

	register_world(u_id, w_id)
	if not runtime_index[u_id][w_id].has(t_id):
		runtime_index[u_id][w_id][t_id] = []

	runtime_index[u_id][w_id][t_id].append(data)

func resolve_scenario(universe_id: Variant, world_id: Variant, type_id: Variant, seed_string: Variant, subcategory_id: Variant = "") -> Dictionary:
	var u_id = normalize_id(universe_id)
	var w_id = normalize_id(world_id)
	var t_id = normalize_id(type_id)
	var s_str = normalize_id(seed_string)
	var sub_id = normalize_id(subcategory_id)

	var pool = _collect_pool(u_id, w_id, t_id, sub_id)
	if pool.size() == 0:
		_ensure_content_loaded_for(u_id, w_id)
		pool = _collect_pool(u_id, w_id, t_id, sub_id)

	if pool.size() == 0:
		return {}

	var hash_val = abs(s_str.hash())
	var selected_index = hash_val % pool.size()

	return pool[selected_index]

func _collect_pool(u_id: String, w_id: String, t_id: String, sub_id: String = "") -> Array:
	var pool = []
	if not runtime_index.has(u_id):
		return pool

	if w_id == "" or w_id == "all":
		for w_key in runtime_index[u_id].keys():
			if runtime_index[u_id][w_key].has(t_id):
				pool.append_array(runtime_index[u_id][w_key][t_id])
	else:
		if runtime_index[u_id].has(w_id) and runtime_index[u_id][w_id].has(t_id):
			pool = runtime_index[u_id][w_id][t_id]
	if sub_id != "":
		var filtered = []
		for item in pool:
			if item is Dictionary and normalize_id(item.get("subcategory", item.get("presentation", {}).get("subcategory", ""))) == sub_id:
				filtered.append(item)
		pool = filtered
	return pool

func _ensure_content_loaded_for(u_id: String, w_id: String):
	var loader = get_node_or_null("/root/ContentLoader")
	if not loader:
		return
	if w_id == "" or w_id == "all":
		if loader.has_method("load_universe_content"):
			loader.load_universe_content(u_id)
	elif loader.has_method("load_world_content"):
		loader.load_world_content(u_id, w_id)

func get_all_worlds_in_universe(universe_id: Variant) -> Array:
	var u_id = normalize_id(universe_id)
	if runtime_index.has(u_id):
		return runtime_index[u_id].keys()
	return []

func get_all_universes() -> Array:
	return runtime_index.keys()

func get_all_scenarios_in_world(universe_id: Variant, world_id: Variant) -> Array:
	var u_id = normalize_id(universe_id)
	var w_id = normalize_id(world_id)
	_ensure_content_loaded_for(u_id, w_id)
	var result = []
	if runtime_index.has(u_id) and runtime_index[u_id].has(w_id):
		for t_key in runtime_index[u_id][w_id].keys():
			result.append_array(runtime_index[u_id][w_id][t_key])
	return result

func get_subcategories_in_world(universe_id: Variant, world_id: Variant) -> Array:
	var u_id = normalize_id(universe_id)
	var w_id = normalize_id(world_id)
	var result = []
	if _subcategory_index.has(u_id) and _subcategory_index[u_id].has(w_id):
		for key in _subcategory_index[u_id][w_id].keys():
			result.append(_subcategory_index[u_id][w_id][key])
	result.sort_custom(func(a, b): return str(a.get("display_name", a.get("id", ""))) < str(b.get("display_name", b.get("id", ""))))
	return result

func get_subcategory_metadata(universe_id: Variant, world_id: Variant, subcategory_id: Variant) -> Dictionary:
	var u_id = normalize_id(universe_id)
	var w_id = normalize_id(world_id)
	var s_id = normalize_id(subcategory_id)
	if _subcategory_index.has(u_id) and _subcategory_index[u_id].has(w_id) and _subcategory_index[u_id][w_id].has(s_id):
		return _subcategory_index[u_id][w_id][s_id]
	return {}

func get_all_scenarios_in_subcategory(universe_id: Variant, world_id: Variant, subcategory_id: Variant) -> Array:
	var sub_id = normalize_id(subcategory_id)
	var result = []
	for item in get_all_scenarios_in_world(universe_id, world_id):
		if item is Dictionary and normalize_id(item.get("subcategory", item.get("presentation", {}).get("subcategory", ""))) == sub_id:
			result.append(item)
	return result

func get_available_types_in_subcategory(universe_id: Variant, world_id: Variant, subcategory_id: Variant) -> Array:
	var types = []
	for item in get_all_scenarios_in_subcategory(universe_id, world_id, subcategory_id):
		var t = normalize_id(item.get("type", ""))
		if t != "" and not types.has(t):
			types.append(t)
	types.sort()
	return types

func get_available_types_in_world(universe_id: Variant, world_id: Variant) -> Array:
	var u_id = normalize_id(universe_id)
	var w_id = normalize_id(world_id)
	_ensure_content_loaded_for(u_id, w_id)
	if runtime_index.has(u_id) and runtime_index[u_id].has(w_id):
		return runtime_index[u_id][w_id].keys()
	return []

func get_scenario_count(universe_id: Variant = "all") -> int:
	var count = 0
	for u_key in runtime_index.keys():
		if universe_id != "all" and normalize_id(universe_id) != u_key:
			continue
		for w_key in runtime_index[u_key].keys():
			for t_key in runtime_index[u_key][w_key].keys():
				count += runtime_index[u_key][w_key][t_key].size()
	return count

func get_all_scenario_ids() -> Array:
	var ids = []
	for u in runtime_index.keys():
		for w in runtime_index[u].keys():
			for t in runtime_index[u][w].keys():
				for item in runtime_index[u][w][t]:
					var sid = item.get("id", "")
					if sid != "" and not ids.has(sid): ids.append(sid)
	return ids
