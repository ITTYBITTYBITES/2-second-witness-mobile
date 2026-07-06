extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# OBSERVATION COLLECTION (AUTHORITATIVE RUNTIME OBSERVATION LAYER)
# ---------------------------------------------------------
# Owns observation retrieval, standardization, recency history,
# deterministic rotation, and future-ready difficulty filtering.
# Gameplay mechanics consume observations through ObservationBuilder.
# ---------------------------------------------------------

signal observation_served(observation_id: String, scope_key: String)

const RECENT_SCOPE_LIMIT := 48
const RECENT_GLOBAL_LIMIT := 256

var _recent_by_scope: Dictionary = {}
var _recent_global: Array[String] = []
var _served_counts: Dictionary = {}
var _standardization_cache: Dictionary = {} # [observation_id] = standardized_dictionary

func normalize_id(value: Variant) -> String:
	return str(value)

func _scope_key(universe_id: Variant, world_id: Variant, subcategory_id: Variant = "", mechanic_id: Variant = "") -> String:
	return "%s::%s::%s::%s" % [normalize_id(universe_id), normalize_id(world_id), normalize_id(subcategory_id), normalize_id(mechanic_id)]

func clear_history(scope_key: String = ""):
	if scope_key == "":
		_recent_by_scope.clear()
		_recent_global.clear()
		_served_counts.clear()
		_standardization_cache.clear()
	else:
		_recent_by_scope.erase(scope_key)

func get_recent_history(scope_key: String = "") -> Array:
	if scope_key == "":
		return _recent_global.duplicate()
	return _recent_by_scope.get(scope_key, []).duplicate()

func mark_observation_used(observation: Dictionary, scope_key: String):
	var obs_id = normalize_id(observation.get("observation_id", observation.get("id", "")))
	if obs_id == "":
		return
	if not _recent_by_scope.has(scope_key):
		_recent_by_scope[scope_key] = []
	var scoped: Array = _recent_by_scope[scope_key]
	if scoped.has(obs_id): scoped.erase(obs_id)
	scoped.push_front(obs_id)
	while scoped.size() > RECENT_SCOPE_LIMIT:
		scoped.pop_back()
	_recent_by_scope[scope_key] = scoped
	if _recent_global.has(obs_id): _recent_global.erase(obs_id)
	_recent_global.push_front(obs_id)
	while _recent_global.size() > RECENT_GLOBAL_LIMIT:
		_recent_global.pop_back()
	_served_counts[obs_id] = int(_served_counts.get(obs_id, 0)) + 1
	observation_served.emit(obs_id, scope_key)

func get_collection(universe_id: Variant, world_id: Variant, subcategory_id: Variant = "", mechanic_id: Variant = "", filters: Dictionary = {}) -> Array:
	var registry = ContentRegistry if ContentRegistry else get_tree().root.get_node_or_null("ContentRegistry")
	if not registry:
		return []
		
	# FORCE LOAD: Ensure the world content is loaded before querying
	var u_id = normalize_id(universe_id)
	var w_id = normalize_id(world_id)
	if registry.has_method("_ensure_content_loaded_for"):
		registry._ensure_content_loaded_for(u_id, w_id)
		
	var items = []
	if subcategory_id != "" and registry.has_method("get_all_scenarios_in_subcategory"):
		items = registry.get_all_scenarios_in_subcategory(universe_id, world_id, subcategory_id)
	elif registry.has_method("get_all_scenarios_in_world"):
		items = registry.get_all_scenarios_in_world(universe_id, world_id)
		
	var result: Array = []
	for item in items:
		if not (item is Dictionary):
			continue
		
		# Optimized filtering: Check mechanic before expensive standardization.
		# "dynamic" items are mechanic-agnostic (CKO v3) and eligible for any mechanic.
		if mechanic_id != "":
			var item_type = normalize_id(item.get("type", ""))
			var want = normalize_id(mechanic_id)
			if item_type != want and item_type != "dynamic":
				continue
			
		var standardized = standardize(item)
		if _passes_filters(standardized, filters):
			result.append(standardized)
	return result

func get_available_mechanics(universe_id: Variant, world_id: Variant, subcategory_id: Variant = "") -> Array:
	var types = []
	# Use a lightweight query to get types if possible
	var u_id = normalize_id(universe_id)
	var w_id = normalize_id(world_id)
	var sub_id = normalize_id(subcategory_id)
	
	var collection = get_collection(u_id, w_id, sub_id)
	for obs in collection:
		var t = normalize_id(obs.get("type", obs.get("mechanic", "")))
		if t != "" and not types.has(t):
			types.append(t)
	types.sort()
	return types

func next_observation(universe_id: Variant, world_id: Variant, subcategory_id: Variant, mechanic_id: Variant, seed_value: Variant = "", filters: Dictionary = {}) -> Dictionary:
	var mechanic = normalize_id(mechanic_id)
	var u_id = normalize_id(universe_id)
	var w_id = normalize_id(world_id)
	var sub_id = normalize_id(subcategory_id)
	var scope = _scope_key(u_id, w_id, sub_id, mechanic)
	
	var pool = get_collection(u_id, w_id, sub_id, mechanic, filters)
	if pool.is_empty():
		# FALLBACK: If subcategory is too restrictive, try world-wide
		if sub_id != "":
			pool = get_collection(u_id, w_id, "", mechanic, filters)
		
		if pool.is_empty():
			print("[OBSERVATION ERROR] No eligible observations found for: ", scope)
			return {}
			
	var recent: Array = _recent_by_scope.get(scope, [])
	var eligible: Array = []
	for obs in pool:
		var obs_id = normalize_id(obs.get("observation_id", obs.get("id", "")))
		if not recent.has(obs_id):
			eligible.append(obs)
			
	if eligible.is_empty():
		eligible = pool.duplicate()
		
	var seed_str = normalize_id(seed_value)
	if seed_str == "":
		seed_str = "%s:%s:%s:%s" % [u_id, w_id, sub_id, Time.get_ticks_msec()]
		
	# Optimized sort for deterministic but varied selection
	eligible.sort_custom(func(a, b):
		var a_id = normalize_id(a.get("observation_id", a.get("id", "")))
		var b_id = normalize_id(b.get("observation_id", b.get("id", "")))
		var a_count = int(_served_counts.get(a_id, 0))
		var b_count = int(_served_counts.get(b_id, 0))
		if a_count != b_count:
			return a_count < b_count
		return (seed_str + a_id).hash() < (seed_str + b_id).hash()
	)
	
	var selected = eligible[0]
	mark_observation_used(selected, scope)
	return selected

func standardize(item: Dictionary) -> Dictionary:
	var obs_id = normalize_id(item.get("observation_id", item.get("id", "")))
	if obs_id == "":
		obs_id = "obs_" + str(item.hash())
	if _standardization_cache.has(obs_id):
		return _standardization_cache[obs_id]

	var u_id = normalize_id(item.get("universe", ""))
	var w_id = normalize_id(item.get("world", ""))
	var sub_id = normalize_id(item.get("subcategory", item.get("presentation", {}).get("subcategory", "")))
	var t_id = normalize_id(item.get("type", "dynamic"))

	# Difficulty resolution: handles int, float, or {"label","tier"} dict
	var diff = item.get("difficulty", item.get("presentation", {}).get("difficulty_tier", 1))
	if diff is Dictionary:
		diff = int(diff.get("tier", 1))
	else:
		diff = int(diff)

	var standardized = {
		"id": normalize_id(item.get("id", obs_id)),
		"observation_id": obs_id,
		"universe": u_id,
		"world": w_id,
		"subcategory": sub_id,
		"type": t_id,
		"difficulty": diff,
		"raw": item
	}

	# Preserve builder-relevant payload for the consumer (ObservationBuilder).
	if item.has("entity") and item.has("features"):
		standardized["entity"] = item.get("entity", "")
		standardized["entity_type"] = item.get("entity_type", "")
		standardized["features"] = item.get("features", {})
		standardized["dimensions"] = item.get("dimensions", {})
		standardized["confusions"] = item.get("confusions", [])
	else:
		# Rules-based (v2_compiled or v1_legacy): ensure a usable rules block exists.
		var rules = item.get("rules", {})
		if rules is Dictionary and rules.size() > 0:
			standardized["rules"] = rules
		elif item.has("prompt"):
			standardized["rules"] = {
				"prompt": str(item.get("prompt", "")),
				"correct_answer": str(item.get("correct_answer", "")),
				"wrong_answers": item.get("distractors", []),
				"legacy_prompt": str(item.get("prompt", ""))
			}

	if obs_id != "":
		_standardization_cache[obs_id] = standardized
	return standardized

func _passes_filters(observation: Dictionary, filters: Dictionary) -> bool:
	if filters.has("difficulty_tier") and int(filters["difficulty_tier"]) != int(observation.get("difficulty", 1)):
		return false
	if filters.has("min_difficulty") and int(observation.get("difficulty", 1)) < int(filters["min_difficulty"]):
		return false
	if filters.has("max_difficulty") and int(observation.get("difficulty", 1)) > int(filters["max_difficulty"]):
		return false
	return true

func _clean_text(value: Variant) -> String:
	var text = str(value).strip_edges()
	var trace_idx = text.find(" // TRACE")
	if trace_idx >= 0:
		text = text.substr(0, trace_idx).strip_edges()
	return text

func _clean_array(values: Variant) -> Array:
	var result: Array = []
	if values is Array:
		for v in values:
			var clean = _clean_text(v)
			if clean != "" and not result.has(clean):
				result.append(clean)
	return result
