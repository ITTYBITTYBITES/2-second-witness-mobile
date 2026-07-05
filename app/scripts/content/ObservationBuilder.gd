extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# OBSERVATION BUILDER v4.2 (FEATURE-CONTRACT SUBSTRATE)
# ---------------------------------------------------------
# A typed evaluation substrate over semantic objects.
#
# Pipeline:
#   RAW ENTITY
#     ↓ (canonical_cache)
#   NORMALIZED ENTITY (layered visual: semantic + asset)
#     ↓ (feature_cache)
#   RESOLVED FEATURE MAP (flat: feature_name → value)
#     ↓ (projection_cache)
#   COMPATIBILITY EVALUATION + PAYLOAD PROJECTION
#
# v4.2 refinements over v4.1:
#   - Mechanics depend on FEATURES, not layers. Contracts declare
#     "color" (what they need), not "visual.semantic.color" (where
#     to find it). A FEATURE_RESOLVERS map defines the resolution
#     chain per feature. Adding a new layer never touches contracts.
#   - Three-level caching: canonical (identity) → feature (resolution)
#     → projection (output). Feature resolution is never recomputed
#     for the same entity.
#   - Composable compatibility deltas: get_coverage_report(entities)
#     aggregates per-mechanic coverage across any entity set,
#     enabling precomputable coverage maps at universe/system scale.
# ---------------------------------------------------------

const SCHEMA_VERSION = 4

# =========================================================
# SECTION 1: FEATURE RESOLVERS
# Maps each feature NAME to a resolution chain (dotted paths into
# the normalized entity, tried in priority order). This is the ONLY
# place layer topology is encoded. Mechanics never reference layers.
# =========================================================

const FEATURE_RESOLVERS = {
	"label":      ["label"],
	"category":   ["category"],
	"signature":  ["signature"],
	"material":   ["material"],
	"color":      ["visual.semantic.color"],
	"pattern":    ["visual.semantic.pattern"],
	"confusions": ["confusions"],
	"sequence":   ["sequence"],
	"render_sprites":  ["visual.asset.sprites"],
	"render_available": ["visual.asset.available"]
}

# =========================================================
# SECTION 2: MECHANIC CONTRACTS
# Each mechanic declares required FEATURES (flat names, not layer
# paths). The resolver determines whether each feature is available
# and from which layer. Contracts are layer-agnostic.
# =========================================================

const MECHANIC_CONTRACTS = {
	"rapid_classification": {
		"requires": ["category"],
		"prefers": ["confusions"],
		"output_schema": "single_label"
	},
	"signal_vs_noise": {
		"requires": ["signature"],
		"prefers": ["confusions"],
		"output_schema": "disambiguation_task"
	},
	"odd_one_out": {
		"requires": ["confusions"],
		"prefers": ["category"],
		"output_schema": "set_exclusion"
	},
	"stroop_test": {
		"requires": ["material", "color"],
		"prefers": [],
		"output_schema": "interference_pair"
	},
	"memory_cascade": {
		"requires": ["signature"],
		"prefers": [],
		"output_schema": "ordered_recall"
	}
}

# =========================================================
# SECTION 3: THREE-LEVEL CACHING
# Level 1 (canonical): raw → normalized entity. Keyed by obs_id.
# Level 2 (feature):   normalized → resolved feature map. Keyed by obs_id.
# Level 3 (projection): resolved + mechanic → output. Keyed by "obs_id|mechanic".
# All deterministic. Feature resolution is never recomputed.
# =========================================================

var _norm_cache: Dictionary = {}     # [obs_id] → normalized entity
var _feature_cache: Dictionary = {}  # [obs_id] → resolved feature map
var _proj_cache: Dictionary = {}     # ["obs_id|mechanic"] → rules dict

# =========================================================
# SECTION 4: PUBLIC API
# =========================================================

func build_payload(cko: Dictionary, mechanic_id: String, context: Dictionary = {}) -> Dictionary:
	if cko.is_empty():
		return {}
	if cko.has("entity") and cko.has("features"):
		return _build_v4_payload(cko, mechanic_id, context)
	elif cko.has("concept") and not cko.has("entity"):
		return _build_v2_payload(cko, mechanic_id, context)
	else:
		return _build_legacy_v1_payload(cko, mechanic_id, context)

## Returns the list of mechanics an entity can fully satisfy.
func get_compatible_mechanics(cko: Dictionary) -> Array:
	if not (cko.has("entity") and cko.has("features")):
		return []
	var features = _resolve_all(cko)
	var result: Array = []
	for mechanic in MECHANIC_CONTRACTS.keys():
		if _check_compatibility(features, mechanic).compatible:
			result.append(mechanic)
	return result

## Returns a structured compatibility report for one entity across all mechanics.
## Structure: { mechanic: {compatible, reason, layer, severity, missing} }
func get_compatibility_report(cko: Dictionary) -> Dictionary:
	if not (cko.has("entity") and cko.has("features")):
		return {}
	var features = _resolve_all(cko)
	var report: Dictionary = {}
	for mechanic in MECHANIC_CONTRACTS.keys():
		report[mechanic] = _check_compatibility(features, mechanic)
	return report

## Aggregates compatibility across an entity set into a coverage map.
## This is the composable delta — mergeable at universe/system scale.
## Structure: { mechanic: {total, compatible, incompatible, coverage_pct, reasons: {reason: count}} }
func get_coverage_report(entities: Array) -> Dictionary:
	var report: Dictionary = {}
	for mechanic in MECHANIC_CONTRACTS.keys():
		report[mechanic] = {"total": 0, "compatible": 0, "incompatible": 0, "coverage_pct": 0.0, "reasons": {}}
	for entity in entities:
		if not (entity is Dictionary and entity.has("entity") and entity.has("features")):
			continue
		var compat = get_compatibility_report(entity)
		for mechanic in compat:
			report[mechanic]["total"] += 1
			if compat[mechanic].compatible:
				report[mechanic]["compatible"] += 1
			else:
				report[mechanic]["incompatible"] += 1
				var r = str(compat[mechanic].reason)
				var reasons: Dictionary = report[mechanic]["reasons"]
				reasons[r] = int(reasons.get(r, 0)) + 1
	# Compute coverage percentages
	for mechanic in report:
		var total = int(report[mechanic]["total"])
		if total > 0:
			var compat = int(report[mechanic]["compatible"])
			report[mechanic]["coverage_pct"] = float(compat) / float(total) * 100.0
	return report

# =========================================================
# SECTION 5: v4 PIPELINE (entity path)
# normalize → resolve features → check compatibility → project or fallback
# =========================================================

func _build_v4_payload(raw: Dictionary, mechanic_id: String, context: Dictionary) -> Dictionary:
	var mechanic = str(mechanic_id).to_lower()
	var obs_id = str(raw.get("observation_id", raw.get("id", "")))
	var features = _resolve_all(raw)

	var payload = _build_payload_shell(raw, mechanic, context)

	# Level-3 cache (projection): rules are deterministic from features + mechanic.
	var cache_key = obs_id + "|" + mechanic
	if _proj_cache.has(cache_key):
		payload["rules"] = (_proj_cache[cache_key] as Dictionary).duplicate(true)
		payload["contract_status"] = "cached"
		payload["rules"]["legacy_prompt"] = payload["rules"].get("prompt", "OBSERVE")
		return payload

	var compat = _check_compatibility(features, mechanic)
	if compat.compatible:
		payload["rules"] = _project(features, mechanic)
		payload["contract_status"] = "compatible"
	else:
		payload["rules"] = _project_fallback(features)
		payload["contract_status"] = "fallback"

	_proj_cache[cache_key] = (payload["rules"] as Dictionary).duplicate(true)
	payload["rules"]["legacy_prompt"] = payload["rules"].get("prompt", "OBSERVE")
	return payload

# =========================================================
# SECTION 6: NORMALIZATION (identity-level, cached)
# Converts any v3 entity format into canonical layered representation.
# visual.semantic = perceptual; visual.asset = renderable.
# =========================================================

func _normalize_entity(raw: Dictionary) -> Dictionary:
	var obs_id = str(raw.get("observation_id", raw.get("id", "")))
	if obs_id != "" and _norm_cache.has(obs_id):
		return _norm_cache[obs_id]

	var dims_raw = raw.get("dimensions", {})
	var dims: Dictionary = dims_raw if dims_raw is Dictionary else {}
	var features_raw = raw.get("features", {})
	var features: Dictionary = features_raw if features_raw is Dictionary else {}

	var visual_semantic := {"color": "#FFFFFF", "pattern": "", "label": ""}
	var visual_asset := {"sprites": [], "metadata": {}, "available": false}

	var visual_raw = features.get("visual", null)
	if visual_raw is Dictionary:
		if visual_raw.has("color"):
			visual_semantic["color"] = str(visual_raw["color"])
		if visual_raw.has("pattern"):
			visual_semantic["pattern"] = str(visual_raw["pattern"])
		if visual_raw.has("sprites"):
			var sp = visual_raw["sprites"]
			visual_asset["sprites"] = sp if sp is Array else []
			visual_asset["available"] = not (visual_asset["sprites"] as Array).is_empty()
		if visual_raw.has("metadata"):
			visual_asset["metadata"] = visual_raw["metadata"] if visual_raw["metadata"] is Dictionary else {}
		if visual_raw.has("annotation"):
			visual_semantic["label"] = str(visual_raw["annotation"])
	elif visual_raw is Array and visual_raw.size() > 0:
		visual_semantic["color"] = str(visual_raw[0])
	elif visual_raw is String and visual_raw != "":
		visual_semantic["color"] = visual_raw

	var confusions_raw = raw.get("confusions", [])
	var confusions: Array = confusions_raw if confusions_raw is Array else []
	var label = str(raw.get("entity", raw.get("observation_id", "Unknown")))
	var category = str(dims.get("Category", ""))
	if category == "":
		category = str(raw.get("entity_type", ""))
	var signature = str(dims.get("Signature", ""))
	if signature == "":
		if visual_semantic["pattern"] != "":
			signature = str(visual_semantic["pattern"])
		if signature == "":
			signature = label

	var norm = {
		"label": label,
		"type": str(raw.get("entity_type", "")),
		"category": category,
		"signature": signature,
		"material": str(dims.get("Material", "")),
		"visual": {"semantic": visual_semantic, "asset": visual_asset},
		"confusions": confusions,
		"sequence": [label]
	}
	if obs_id != "":
		_norm_cache[obs_id] = norm
	return norm

# =========================================================
# SECTION 7: FEATURE RESOLUTION (level-2 cache)
# Flattens the layered normalized entity into a single feature map
# using FEATURE_RESOLVERS chains. This is the only place layer
# topology → flat features. Cached per entity.
# =========================================================

func _resolve_all(raw: Dictionary) -> Dictionary:
	var obs_id = str(raw.get("observation_id", raw.get("id", "")))
	if obs_id != "" and _feature_cache.has(obs_id):
		return _feature_cache[obs_id]

	var norm = _normalize_entity(raw)
	var resolved: Dictionary = {}
	for feature_name in FEATURE_RESOLVERS:
		var chain = FEATURE_RESOLVERS[feature_name]
		var value = _resolve_chain(norm, chain)
		if value != null:
			resolved[feature_name] = value
	if obs_id != "":
		_feature_cache[obs_id] = resolved
	return resolved

func _resolve_chain(norm: Dictionary, chain: Array) -> Variant:
	for path in chain:
		var val = _get_nested(norm, str(path))
		if val != null:
			if val is String and val != "":
				return val
			elif val is Array and not val.is_empty():
				return val
			elif val is Dictionary and not val.is_empty():
				return val
			elif not (val is String or val is Array or val is Dictionary):
				return val  # bool, int, float
	return null

func _get_nested(dict: Variant, dotted_path: String) -> Variant:
	var parts = dotted_path.split(".", false)
	var current: Variant = dict
	for part in parts:
		if current is Dictionary and current.has(part):
			current = current[part]
		else:
			return null
	return current

# =========================================================
# SECTION 8: COMPATIBILITY EVALUATION (structured, composable)
# Checks resolved features against contract requirements.
# Returns structured delta with reason/layer/severity for analytics.
# =========================================================

func _check_compatibility(features: Dictionary, mechanic: String) -> Dictionary:
	var contract = MECHANIC_CONTRACTS.get(mechanic, null)
	if contract == null:
		return {"compatible": false, "reason": "unsupported_contract", "layer": "structural", "severity": "hard", "missing": []}

	var requires = contract.get("requires", [])
	var missing: Array = []
	for req in requires:
		var req_name = str(req)
		if not features.has(req_name):
			missing.append(req_name)
		else:
			var val = features[req_name]
			if val is String and val == "":
				missing.append(req_name)
			elif val is Array and val.is_empty():
				missing.append(req_name)

	if missing.is_empty():
		return {"compatible": true, "reason": "", "layer": "", "severity": "none", "missing": []}

	# Classify based on what's missing (layer-agnostic classification)
	var reason: String = "missing_dimension"
	var layer: String = "semantic"
	var severity: String = "soft"
	for m in missing:
		# Determine which resolution layer this feature comes from
		var resolver = FEATURE_RESOLVERS.get(m, [])
		if resolver.size() > 0:
			var source_path = str(resolver[0])
			if source_path.begins_with("visual.asset"):
				layer = "asset"
				reason = "no_render_layer"
			elif source_path.begins_with("visual.semantic"):
				layer = "semantic"
				reason = "missing_dimension"
			else:
				layer = "structural"
		if m == "confusions":
			severity = "hard"
			layer = "structural"

	return {"compatible": false, "reason": reason, "layer": layer, "severity": severity, "missing": missing}

func _is_compatible(features: Dictionary, mechanic: String) -> bool:
	return _check_compatibility(features, mechanic).compatible

# =========================================================
# SECTION 9: PROJECTION (contract-bound output generation)
# Reads from the RESOLVED FEATURE MAP (flat). Output shape is
# IDENTICAL to all prior v4 versions.
# =========================================================

func _project(f: Dictionary, mechanic: String) -> Dictionary:
	match mechanic:
		"rapid_classification":
			return {
				"prompt": f.get("label", "?"),
				"correct_answer": f.get("category", "?"),
				"wrong_answers": _take(f.get("confusions", []), 3)
			}
		"signal_vs_noise":
			return {
				"prompt": "DETECT: " + str(f.get("signature", "")),
				"correct_answer": f.get("label", "?"),
				"wrong_answers": f.get("confusions", [])
			}
		"odd_one_out":
			return {
				"prompt": "ANOMALY DETECTION",
				"correct_answer": f.get("label", "?"),
				"wrong_answers": (f.get("confusions", []) as Array).slice(0, 3)
			}
		"stroop_test":
			return {
				"prompt": f.get("label", "?"),
				"correct_answer": f.get("material", "?"),
				"visual_interference": f.get("color", "#FFFFFF")
			}
		"memory_cascade":
			return {
				"prompt": "RECALL SIGNATURE",
				"correct_answer": f.get("signature", "?"),
				"sequence": f.get("sequence", [])
			}
		_:
			return _project_fallback(f)

func _project_fallback(f: Dictionary) -> Dictionary:
	var answer = str(f.get("category", ""))
	if answer == "":
		answer = str(f.get("signature", ""))
	if answer == "":
		answer = "OBSERVE"
	return {
		"prompt": f.get("label", "?"),
		"correct_answer": answer,
		"wrong_answers": _take(f.get("confusions", []), 3)
	}

# =========================================================
# SECTION 10: UTILITIES
# =========================================================

func _take(arr: Array, n: int) -> Array:
	if arr.size() <= n:
		return arr.duplicate()
	return arr.slice(0, n)

func _build_payload_shell(raw: Dictionary, mechanic: String, context: Dictionary) -> Dictionary:
	var entity = str(raw.get("entity", "Unknown Entity"))
	return {
		"id": str(raw.get("observation_id", "unknown")) + "_" + mechanic,
		"observation_id": str(raw.get("observation_id", "unknown")),
		"universe": str(raw.get("universe", context.get("universe", ""))),
		"world": str(raw.get("world", context.get("world", ""))),
		"subcategory": str(raw.get("subcategory", context.get("subcategory", ""))),
		"type": mechanic,
		"difficulty": int(raw.get("difficulty", 1)),
		"rules": {},
		"presentation": {
			"title": entity.to_upper(),
			"subcategory": str(raw.get("subcategory", "")),
			"difficulty_tier": int(raw.get("difficulty", 1))
		},
		"metadata": (raw.get("metadata", {}) as Dictionary).duplicate(true)
	}

# =========================================================
# SECTION 11: v2 PAYLOAD BUILDER (concept-based schema, unchanged)
# =========================================================

func _build_v2_payload(cko: Dictionary, mechanic_id: String, context: Dictionary) -> Dictionary:
	var mechanic = str(mechanic_id).to_lower()
	var payload = {
		"id": str(cko.get("observation_id", "unknown")) + "_" + mechanic,
		"observation_id": str(cko.get("observation_id", "unknown")),
		"universe": str(cko.get("universe", context.get("universe", ""))),
		"world": str(cko.get("world", context.get("world", ""))),
		"subcategory": str(cko.get("subcategory", context.get("subcategory", ""))),
		"type": mechanic,
		"difficulty": int(cko.get("difficulty", 1)),
		"rules": {},
		"presentation": {
			"title": _generate_title(cko),
			"subcategory": str(cko.get("subcategory", "")),
			"difficulty_tier": int(cko.get("difficulty", 1))
		},
		"metadata": (cko.get("metadata", {}) as Dictionary).duplicate(true)
	}
	match mechanic:
		"rapid_classification":
			payload["rules"] = {"prompt": str(cko.get("concept", "OBSERVE")), "correct_answer": str(cko.get("recognized_answer", "YES")), "wrong_answers": [cko.get("distractor_family", ["NO"])[0]]}
		"signal_vs_noise":
			payload["rules"] = {"prompt": "FIND: " + str(cko.get("recognized_answer", "TARGET")), "correct_answer": str(cko.get("recognized_answer", "")), "wrong_answers": cko.get("distractor_family", [])}
		"odd_one_out":
			payload["rules"] = {"prompt": "ANOMALY DETECTION", "correct_answer": str(cko.get("recognized_answer", "")), "wrong_answers": cko.get("distractor_family", []).slice(0, 3)}
		"stroop_test":
			payload["rules"] = {"prompt": str(cko.get("concept", "")), "correct_answer": str(cko.get("recognized_answer", "")), "visual_interference": str((cko.get("visual_cues", {}) as Dictionary).get("color", "#FFFFFF"))}
		"memory_cascade", "sequence_reverse":
			payload["rules"] = {"prompt": "RECALL SEQUENCE", "correct_answer": str(cko.get("recognized_answer", "")), "sequence": [str(cko.get("concept", ""))]}
		"spatial_recall":
			payload["rules"] = {"prompt": "POSITIONAL AUDIT", "correct_answer": str(cko.get("recognized_answer", "")), "anchor": (cko.get("visual_cues", {}) as Dictionary).get("position", Vector2.ZERO)}
		_:
			payload["rules"] = {"prompt": str(cko.get("concept", "OBSERVE")), "correct_answer": str(cko.get("recognized_answer", "")), "wrong_answers": cko.get("distractor_family", [])}
	payload["rules"]["legacy_prompt"] = payload["rules"].get("prompt", "OBSERVE")
	return payload

func _generate_title(cko: Dictionary) -> String:
	var world = str(cko.get("world", "")).capitalize()
	var sub = str(cko.get("subcategory", "")).capitalize().replace("_", " ")
	if world != "" and sub != "":
		return world + " — " + sub
	elif world != "":
		return world
	elif sub != "":
		return sub
	return "OBSERVATION"

# =========================================================
# SECTION 12: LEGACY v1 PAYLOAD BUILDER (unchanged)
# =========================================================

func _build_legacy_v1_payload(v1_data: Dictionary, mechanic_id: String, context: Dictionary) -> Dictionary:
	var mechanic = str(mechanic_id)
	var rules = v1_data.get("rules", {})
	var payload = {
		"id": str(v1_data.get("id", v1_data.get("observation_id", mechanic))),
		"observation_id": str(v1_data.get("observation_id", v1_data.get("id", ""))),
		"universe": str(v1_data.get("universe", context.get("universe", ""))),
		"world": str(v1_data.get("world", context.get("world", ""))),
		"subcategory": str(v1_data.get("subcategory", context.get("subcategory", ""))),
		"type": mechanic,
		"rules": (rules as Dictionary).duplicate(true) if rules is Dictionary else {},
		"presentation": (v1_data.get("presentation", {}) as Dictionary).duplicate(true),
		"metadata": (v1_data.get("metadata", {}) as Dictionary).duplicate(true)
	}
	if not payload["rules"].has("legacy_prompt"):
		payload["rules"]["legacy_prompt"] = str((rules as Dictionary).get("prompt", "OBSERVE")) if rules is Dictionary else "OBSERVE"
	return payload
