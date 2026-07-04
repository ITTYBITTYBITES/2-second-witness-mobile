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

func normalize_id(value: Variant) -> String:
	return str(value)

func _scope_key(universe_id: Variant, world_id: Variant, subcategory_id: Variant = "", mechanic_id: Variant = "") -> String:
	return "%s::%s::%s::%s" % [normalize_id(universe_id), normalize_id(world_id), normalize_id(subcategory_id), normalize_id(mechanic_id)]

func clear_history(scope_key: String = ""):
	if scope_key == "":
		_recent_by_scope.clear()
		_recent_global.clear()
		_served_counts.clear()
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
	var items = []
	if subcategory_id != "" and registry.has_method("get_all_scenarios_in_subcategory"):
		items = registry.get_all_scenarios_in_subcategory(universe_id, world_id, subcategory_id)
	elif registry.has_method("get_all_scenarios_in_world"):
		items = registry.get_all_scenarios_in_world(universe_id, world_id)
	var result: Array = []
	for item in items:
		if not (item is Dictionary):
			continue
		if mechanic_id != "" and normalize_id(item.get("type", "")) != normalize_id(mechanic_id):
			continue
		var standardized = standardize(item)
		if _passes_filters(standardized, filters):
			result.append(standardized)
	return result

func get_available_mechanics(universe_id: Variant, world_id: Variant, subcategory_id: Variant = "") -> Array:
	var types = []
	for obs in get_collection(universe_id, world_id, subcategory_id):
		var t = normalize_id(obs.get("mechanic", ""))
		if t != "" and not types.has(t):
			types.append(t)
	types.sort()
	return types

func next_observation(universe_id: Variant, world_id: Variant, subcategory_id: Variant, mechanic_id: Variant, seed_value: Variant = "", filters: Dictionary = {}) -> Dictionary:
	var mechanic = normalize_id(mechanic_id)
	var scope = _scope_key(universe_id, world_id, subcategory_id, mechanic)
	var pool = get_collection(universe_id, world_id, subcategory_id, mechanic, filters)
	if pool.is_empty():
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
		seed_str = "%s:%s:%s:%s" % [universe_id, world_id, subcategory_id, Time.get_ticks_msec()]
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
	var rules = item.get("rules", {})
	var presentation = item.get("presentation", {})
	var metadata = item.get("metadata", {})
	var knowledge = metadata.get("knowledge", item.get("knowledge", {}))
	var observation_id = normalize_id(item.get("observation_id", item.get("id", "")))
	return {
		"id": normalize_id(item.get("id", observation_id)),
		"observation_id": observation_id,
		"universe": normalize_id(item.get("universe", "")),
		"world": normalize_id(item.get("world", "")),
		"subcategory": normalize_id(item.get("subcategory", presentation.get("subcategory", ""))),
		"mechanic": normalize_id(item.get("type", "rapid_classification")),
		"question": _clean_text(rules.get("prompt", rules.get("legacy_prompt", ""))),
		"correct_answer": _clean_text(rules.get("correct_answer", "")),
		"distractors": _clean_array(rules.get("wrong_answers", [])),
		"difficulty": presentation.get("difficulty_tier", metadata.get("difficulty_tier", 1)),
		"presentation": presentation,
		"metadata": metadata,
		"knowledge": knowledge,
		"raw": item
	}

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
