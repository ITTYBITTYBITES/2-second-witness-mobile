extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# GAMEPLAY DIRECTOR (METADATA-DRIVEN MECHANIC SELECTION)
# ---------------------------------------------------------
# Chooses gameplay mechanics from observation metadata while avoiding
# repetitive mechanics and preserving automatic default UX.
# ---------------------------------------------------------

signal mechanic_selected(mechanic_id: String, scope_key: String)

const RECENT_MECHANIC_LIMIT := 8

var _recent_mechanics_by_scope: Dictionary = {}

func normalize_id(value: Variant) -> String:
	return str(value)

func _scope_key(universe_id: Variant, world_id: Variant, subcategory_id: Variant = "") -> String:
	return "%s::%s::%s" % [normalize_id(universe_id), normalize_id(world_id), normalize_id(subcategory_id)]

func choose_mechanic(universe_id: Variant, world_id: Variant, subcategory_id: Variant = "", manual_override: Variant = "", context: Dictionary = {}) -> String:
	var scope = _scope_key(universe_id, world_id, subcategory_id)
	var available = ObservationCollection.get_available_mechanics(universe_id, world_id, subcategory_id) if ObservationCollection else []
	if available.is_empty():
		return ""
	# Expand polymorphic types (e.g. "dynamic") to real playable mechanics.
	# All type→mechanic translation goes through MechanicResolver.
	available = MechanicResolver.expand_all(available)
	var override = normalize_id(manual_override)
	if override != "" and available.has(override):
		record_mechanic_used(scope, override)
		return override
	var registry = ContentRegistry if ContentRegistry else get_tree().root.get_node_or_null("ContentRegistry")
	var sub_meta = registry.get_subcategory_metadata(universe_id, world_id, subcategory_id) if (registry and registry.has_method("get_subcategory_metadata")) else {}
	var prefs = sub_meta.get("scenario_preferences", {})
	var recent: Array = _recent_mechanics_by_scope.get(scope, [])
	var scored: Array = []
	for mechanic in available:
		var score = _base_score(mechanic, prefs)
		var recent_idx = recent.find(mechanic)
		if recent_idx == 0:
			score -= 80
		elif recent_idx > 0:
			score -= max(0, 35 - recent_idx * 6)
		if context.has("fatigue") and float(context["fatigue"]) > 0.7 and mechanic in ["memory_cascade", "sequence_reverse", "spatial_recall"]:
			score -= 15
		scored.append({"mechanic": mechanic, "score": score})
	scored.sort_custom(func(a, b):
		if int(a["score"]) == int(b["score"]):
			return str(a["mechanic"]) < str(b["mechanic"])
		return int(a["score"]) > int(b["score"])
	)
	var selected = scored[0]["mechanic"]
	record_mechanic_used(scope, selected)
	mechanic_selected.emit(selected, scope)
	return selected

func record_mechanic_used(scope_key: String, mechanic_id: String):
	if not _recent_mechanics_by_scope.has(scope_key):
		_recent_mechanics_by_scope[scope_key] = []
	var recent: Array = _recent_mechanics_by_scope[scope_key]
	if recent.has(mechanic_id): recent.erase(mechanic_id)
	recent.push_front(mechanic_id)
	while recent.size() > RECENT_MECHANIC_LIMIT:
		recent.pop_back()
	_recent_mechanics_by_scope[scope_key] = recent

func get_recent_mechanics(scope_key: String) -> Array:
	return _recent_mechanics_by_scope.get(scope_key, []).duplicate()

func _base_score(mechanic: String, prefs: Dictionary) -> int:
	if prefs.get("disabled", []).has(mechanic): return -9999
	if prefs.get("preferred", []).has(mechanic): return 100
	if prefs.get("secondary", []).has(mechanic): return 55
	if prefs.get("rare", []).has(mechanic): return 18
	return 35
