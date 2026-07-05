extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# OBSERVATION BUILDER v4.0 (CONTRACT-DRIVEN PROJECTION)
# ---------------------------------------------------------
# Transforms semantic entity objects into gameplay payloads via a
# deterministic contract pipeline:
#
#   ENTITY → EDGE NORMALIZATION → COMPATIBILITY CHECK → PROJECTION
#
# Every mechanic declares a contract (required features). The
# normalization layer safely converts any v3 entity format into a
# single internal canonical representation. If an entity cannot
# satisfy a contract, it is projected via a safe fallback (never
# crashes, never returns empty).
# ---------------------------------------------------------

const SCHEMA_VERSION = 4

# =========================================================
# SECTION 1: MECHANIC CONTRACTS
# Each contract declares what a mechanic needs to produce a
# valid, high-quality payload. The compatibility resolver checks
# these against the NORMALIZED entity (not the raw input).
# =========================================================

const MECHANIC_CONTRACTS = {
	"rapid_classification": {
		"requires": ["category"],
		"prefers": ["confusions"],
		"output_schema": "single_label",
		"fallback": "derive_category_from_type"
	},
	"signal_vs_noise": {
		"requires": ["signature"],
		"prefers": ["confusions"],
		"output_schema": "disambiguation_task",
		"fallback": "derive_signature_from_label"
	},
	"odd_one_out": {
		"requires": ["confusions"],
		"prefers": ["category"],
		"output_schema": "set_exclusion",
		"fallback": "none"
	},
	"stroop_test": {
		"requires": ["material", "visual_color"],
		"prefers": [],
		"output_schema": "interference_pair",
		"fallback": "derive_material_from_dims"
	},
	"memory_cascade": {
		"requires": ["signature"],
		"prefers": [],
		"output_schema": "ordered_recall",
		"fallback": "derive_signature_from_label"
	}
}

# =========================================================
# SECTION 2: PUBLIC API
# =========================================================

func build_payload(cko: Dictionary, mechanic_id: String, context: Dictionary = {}) -> Dictionary:
	if cko.is_empty():
		return {}

	# Schema Version Detection
	if cko.has("entity") and cko.has("features"):
		return _build_v4_payload(cko, mechanic_id, context)
	elif cko.has("concept") and not cko.has("entity"):
		return _build_v2_payload(cko, mechanic_id, context)
	else:
		return _build_legacy_v1_payload(cko, mechanic_id, context)

## Returns the list of mechanics an entity can fully satisfy (contract-compatible).
## Enables mechanic coverage maps per universe (future Phase 10 feature).
func get_compatible_mechanics(cko: Dictionary) -> Array:
	if not (cko.has("entity") and cko.has("features")):
		return []
	var norm = _normalize_entity(cko)
	var result: Array = []
	for mechanic in MECHANIC_CONTRACTS.keys():
		if _is_compatible(norm, mechanic):
			result.append(mechanic)
	return result

# =========================================================
# SECTION 3: v4 CONTRACT-DRIVEN PROJECTION (entity path)
# Pipeline: normalize → check compatibility → project or fallback
# =========================================================

func _build_v4_payload(raw: Dictionary, mechanic_id: String, context: Dictionary) -> Dictionary:
	var mechanic = str(mechanic_id).to_lower()
	var norm = _normalize_entity(raw)

	var payload = _build_payload_shell(raw, mechanic, context)
	norm.mechanic = mechanic

	if _is_compatible(norm, mechanic):
		payload["rules"] = _project(norm, mechanic)
		payload["contract_status"] = "compatible"
	else:
		# Graceful fallback: always produces a valid payload, never crashes.
		# The compatibility info is available via get_compatible_mechanics()
		# for the selection engine to prefer compatible entities.
		payload["rules"] = _project_fallback(norm)
		payload["contract_status"] = "fallback"

	payload["rules"]["legacy_prompt"] = payload["rules"].get("prompt", "OBSERVE")
	return payload

# =========================================================
# SECTION 4: EDGE NORMALIZATION
# Converts ANY v3 entity (legacy Dict-visual, Array-visual, or
# missing fields) into a single canonical internal representation.
# This is the ONLY place format ambiguity is handled.
# Never crashes; missing data becomes empty strings/arrays.
# =========================================================

func _normalize_entity(raw: Dictionary) -> Dictionary:
	var dims_raw = raw.get("dimensions", {})
	var dims: Dictionary = dims_raw if dims_raw is Dictionary else {}

	var features_raw = raw.get("features", {})
	var features: Dictionary = features_raw if features_raw is Dictionary else {}

	# Safe visual extraction — handles Dict, Array, String, or missing.
	var visual_color := "#FFFFFF"
	var visual_raw = features.get("visual", null)
	if visual_raw is Dictionary:
		visual_color = str(visual_raw.get("color", visual_raw.get("pattern", "#FFFFFF")))
	elif visual_raw is Array and visual_raw.size() > 0:
		visual_color = str(visual_raw[0])
	elif visual_raw is String and visual_raw != "":
		visual_color = visual_raw

	# Safe confusions extraction
	var confusions_raw = raw.get("confusions", [])
	var confusions: Array = confusions_raw if confusions_raw is Array else []

	var label = str(raw.get("entity", raw.get("observation_id", "Unknown")))

	# Derive category with fallback chain
	var category = str(dims.get("Category", ""))
	if category == "":
		category = str(raw.get("entity_type", ""))

	# Derive signature with fallback chain
	var signature = str(dims.get("Signature", ""))
	if signature == "":
		# Try to derive from features description
		if features.has("visual") and features["visual"] is Dictionary:
			signature = str(features["visual"].get("pattern", ""))
		if signature == "":
			signature = label  # Last resort: use the label itself

	return {
		"label": label,
		"type": str(raw.get("entity_type", "")),
		"category": category,
		"signature": signature,
		"material": str(dims.get("Material", "")),
		"visual_color": visual_color,
		"confusions": confusions,
		"sequence": [label]
	}

# =========================================================
# SECTION 5: COMPATIBILITY RESOLVER
# Checks whether a normalized entity satisfies a mechanic's contract.
# Deterministic: same entity + mechanic = same result, every time.
# =========================================================

func _is_compatible(norm: Dictionary, mechanic: String) -> bool:
	var contract = MECHANIC_CONTRACTS.get(mechanic, null)
	if contract == null:
		return false
	var requires = contract.get("requires", [])
	for req in requires:
		var val = norm.get(req, null)
		if val == null:
			return false
		if val is String and val == "":
			return false
		if val is Array and val.is_empty():
			return false
	return true

# =========================================================
# SECTION 6: PROJECTION (contract-bound output generation)
# Each branch produces a structurally distinct rules dict.
# =========================================================

func _project(norm: Dictionary, mechanic: String) -> Dictionary:
	match mechanic:
		"rapid_classification":
			return {
				"prompt": norm.label,
				"correct_answer": norm.category,
				"wrong_answers": _take(norm.confusions, 3)
			}
		"signal_vs_noise":
			return {
				"prompt": "DETECT: " + norm.signature,
				"correct_answer": norm.label,
				"wrong_answers": norm.confusions
			}
		"odd_one_out":
			return {
				"prompt": "ANOMALY DETECTION",
				"correct_answer": norm.label,
				"wrong_answers": norm.confusions.slice(0, 3)
			}
		"stroop_test":
			return {
				"prompt": norm.label,
				"correct_answer": norm.material,
				"visual_interference": norm.visual_color
			}
		"memory_cascade":
			return {
				"prompt": "RECALL SIGNATURE",
				"correct_answer": norm.signature,
				"sequence": norm.sequence
			}
		_:
			return _project_fallback(norm)

# Safe fallback projection — always produces a valid payload,
# even for entities that satisfy no contract.
func _project_fallback(norm: Dictionary) -> Dictionary:
	var answer = norm.category
	if answer == "":
		answer = norm.signature
	if answer == "":
		answer = norm.type
	if answer == "":
		answer = "OBSERVE"
	return {
		"prompt": norm.label,
		"correct_answer": answer,
		"wrong_answers": _take(norm.confusions, 3)
	}

# =========================================================
# SECTION 7: UTILITIES
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
# SECTION 8: v2 PAYLOAD BUILDER (concept-based schema)
# Unchanged — separate path, not part of v4 projection.
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
			payload["rules"] = {
				"prompt": str(cko.get("concept", "OBSERVE")),
				"correct_answer": str(cko.get("recognized_answer", "YES")),
				"wrong_answers": [cko.get("distractor_family", ["NO"])[0]]
			}
		"signal_vs_noise":
			payload["rules"] = {
				"prompt": "FIND: " + str(cko.get("recognized_answer", "TARGET")),
				"correct_answer": str(cko.get("recognized_answer", "")),
				"wrong_answers": cko.get("distractor_family", [])
			}
		"odd_one_out":
			payload["rules"] = {
				"prompt": "ANOMALY DETECTION",
				"correct_answer": str(cko.get("recognized_answer", "")),
				"wrong_answers": cko.get("distractor_family", []).slice(0, 3)
			}
		"stroop_test":
			payload["rules"] = {
				"prompt": str(cko.get("concept", "")),
				"correct_answer": str(cko.get("recognized_answer", "")),
				"visual_interference": str((cko.get("visual_cues", {}) as Dictionary).get("color", "#FFFFFF"))
			}
		"memory_cascade", "sequence_reverse":
			payload["rules"] = {
				"prompt": "RECALL SEQUENCE",
				"correct_answer": str(cko.get("recognized_answer", "")),
				"sequence": [str(cko.get("concept", ""))]
			}
		"spatial_recall":
			payload["rules"] = {
				"prompt": "POSITIONAL AUDIT",
				"correct_answer": str(cko.get("recognized_answer", "")),
				"anchor": (cko.get("visual_cues", {}) as Dictionary).get("position", Vector2.ZERO)
			}
		_:
			payload["rules"] = {
				"prompt": str(cko.get("concept", "OBSERVE")),
				"correct_answer": str(cko.get("recognized_answer", "")),
				"wrong_answers": cko.get("distractor_family", [])
			}

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
# SECTION 9: LEGACY v1 PAYLOAD BUILDER
# Unchanged — separate path. v1 data carries pre-baked rules.
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
