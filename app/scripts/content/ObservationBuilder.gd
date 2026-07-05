extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# OBSERVATION BUILDER v4.1 (LAYERED CONTRACT PROJECTION)
# ---------------------------------------------------------
# Transforms semantic entity objects into gameplay payloads via a
# deterministic contract pipeline:
#
#   ENTITY → EDGE NORMALIZATION → COMPATIBILITY CHECK → PROJECTION
#
# v4.1 refinements over v4.0:
#   - Visual is a LAYERED representation system:
#       visual.semantic  = descriptive perceptual features (color, pattern)
#       visual.asset     = renderable asset abstraction (sprites, metadata)
#     Legacy Dict-visual maps to semantic; v4 visual maps to asset.
#     Mechanics declare which layer they depend on. No silent overloading.
#   - Structured incompatibility reasoning (reason, layer, severity, missing)
#     so coverage analytics are analytically valid, not visually plausible.
#   - Two-level caching: identity-level normalization cache + projection cache.
# ---------------------------------------------------------

const SCHEMA_VERSION = 4

# =========================================================
# SECTION 1: MECHANIC CONTRACTS
# Each contract declares required features (dotted paths into the
# normalized entity), the visual layer it depends on, and a fallback.
# =========================================================

const MECHANIC_CONTRACTS = {
	"rapid_classification": {
		"requires": ["category"],
		"prefers": ["confusions"],
		"layer": "semantic",
		"output_schema": "single_label",
		"fallback": "derive_category_from_type"
	},
	"signal_vs_noise": {
		"requires": ["signature"],
		"prefers": ["confusions"],
		"layer": "semantic",
		"output_schema": "disambiguation_task",
		"fallback": "derive_signature_from_label"
	},
	"odd_one_out": {
		"requires": ["confusions"],
		"prefers": ["category"],
		"layer": "structural",
		"output_schema": "set_exclusion",
		"fallback": "none"
	},
	"stroop_test": {
		"requires": ["material", "visual.semantic.color"],
		"prefers": [],
		"layer": "semantic",
		"output_schema": "interference_pair",
		"fallback": "derive_material_from_dims"
	},
	"memory_cascade": {
		"requires": ["signature"],
		"prefers": [],
		"layer": "semantic",
		"output_schema": "ordered_recall",
		"fallback": "derive_signature_from_label"
	}
}

# =========================================================
# SECTION 1b: CACHING (two-level)
# _norm_cache: identity-level, keyed by observation_id (stable)
# _proj_cache: projection-level, keyed by "obs_id|mechanic" (volatile)
# Both are deterministic: same input always yields same output.
# =========================================================

var _norm_cache: Dictionary = {}
var _proj_cache: Dictionary = {}

# =========================================================
# SECTION 2: PUBLIC API
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

## Returns the list of mechanics an entity can fully satisfy (contract-compatible).
func get_compatible_mechanics(cko: Dictionary) -> Array:
	if not (cko.has("entity") and cko.has("features")):
		return []
	var norm = _normalize_entity(cko)
	var result: Array = []
	for mechanic in MECHANIC_CONTRACTS.keys():
		if _is_compatible(norm, mechanic):
			result.append(mechanic)
	return result

## Returns a structured compatibility report for an entity across all mechanics.
## This is what enables analytically-valid mechanic coverage maps.
## Structure: { mechanic: {compatible, reason, layer, severity, missing} }
func get_compatibility_report(cko: Dictionary) -> Dictionary:
	if not (cko.has("entity") and cko.has("features")):
		return {}
	var norm = _normalize_entity(cko)
	var report: Dictionary = {}
	for mechanic in MECHANIC_CONTRACTS.keys():
		report[mechanic] = _check_compatibility(norm, mechanic)
	return report

# =========================================================
# SECTION 3: v4 CONTRACT-DRIVEN PROJECTION (entity path)
# Pipeline: normalize → check compatibility → project or fallback
# =========================================================

func _build_v4_payload(raw: Dictionary, mechanic_id: String, context: Dictionary) -> Dictionary:
	var mechanic = str(mechanic_id).to_lower()
	var norm = _normalize_entity(raw)

	var payload = _build_payload_shell(raw, mechanic, context)

	# Projection cache (level 2): rules are deterministic from norm + mechanic.
	var cache_key = str(norm.label) + "|" + mechanic
	if _proj_cache.has(cache_key):
		payload["rules"] = (_proj_cache[cache_key] as Dictionary).duplicate(true)
		payload["contract_status"] = "cached"
		payload["rules"]["legacy_prompt"] = payload["rules"].get("prompt", "OBSERVE")
		return payload

	var compat = _check_compatibility(norm, mechanic)
	if compat.compatible:
		payload["rules"] = _project(norm, mechanic)
		payload["contract_status"] = "compatible"
	else:
		payload["rules"] = _project_fallback(norm)
		payload["contract_status"] = "fallback"

	_proj_cache[cache_key] = (payload["rules"] as Dictionary).duplicate(true)
	payload["rules"]["legacy_prompt"] = payload["rules"].get("prompt", "OBSERVE")
	return payload

# =========================================================
# SECTION 4: EDGE NORMALIZATION (layered visual)
# Converts ANY v3 entity into a canonical internal representation.
# Visual is split into two layers:
#   semantic = descriptive perceptual features (what it looks like)
#   asset    = renderable abstraction (what it can render as)
# This is the ONLY place format ambiguity is resolved.
# =========================================================

func _normalize_entity(raw: Dictionary) -> Dictionary:
	# Level-1 cache (identity-level): same entity always normalizes identically.
	var obs_id = str(raw.get("observation_id", raw.get("id", "")))
	if obs_id != "" and _norm_cache.has(obs_id):
		return _norm_cache[obs_id]

	var dims_raw = raw.get("dimensions", {})
	var dims: Dictionary = dims_raw if dims_raw is Dictionary else {}

	var features_raw = raw.get("features", {})
	var features: Dictionary = features_raw if features_raw is Dictionary else {}

	# --- Layered visual extraction ---
	var visual_semantic := {"color": "#FFFFFF", "pattern": "", "label": ""}
	var visual_asset := {"sprites": [], "metadata": {}, "available": false}

	var visual_raw = features.get("visual", null)
	if visual_raw is Dictionary:
		# Legacy v3: color/pattern are descriptive perceptual features.
		if visual_raw.has("color"):
			visual_semantic["color"] = str(visual_raw["color"])
		if visual_raw.has("pattern"):
			visual_semantic["pattern"] = str(visual_raw["pattern"])
		# v4: sprites/metadata are renderable asset abstraction.
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
		"visual": {
			"semantic": visual_semantic,
			"asset": visual_asset
		},
		"confusions": confusions,
		"sequence": [label]
	}

	if obs_id != "":
		_norm_cache[obs_id] = norm
	return norm

# =========================================================
# SECTION 5: COMPATIBILITY RESOLVER (structured)
# Returns a structured result, not just bool. This is what makes
# coverage analytics analytically valid.
# =========================================================

func _check_compatibility(norm: Dictionary, mechanic: String) -> Dictionary:
	var contract = MECHANIC_CONTRACTS.get(mechanic, null)
	if contract == null:
		return {"compatible": false, "reason": "unsupported_contract", "layer": "structural", "severity": "hard", "missing": []}

	var requires = contract.get("requires", [])
	var missing: Array = []
	for req in requires:
		if not _has_feature(norm, req):
			missing.append(req)

	var contract_layer = str(contract.get("layer", "structural"))

	if missing.is_empty():
		return {"compatible": true, "reason": "", "layer": contract_layer, "severity": "none", "missing": []}

	# Classify the incompatibility.
	var reason: String = "missing_dimension"
	var layer: String = contract_layer
	var severity: String = "soft"
	for m in missing:
		if m.find("visual.asset") >= 0:
			reason = "no_render_layer"
			layer = "asset"
			severity = "soft"
		elif m.find("visual.semantic") >= 0:
			reason = "missing_dimension"
			layer = "semantic"
			severity = "soft"
		elif m == "confusions":
			reason = "missing_dimension"
			layer = "structural"
			severity = "hard"
		else:
			reason = "missing_dimension"
			layer = "semantic"
			severity = "soft"

	return {"compatible": false, "reason": reason, "layer": layer, "severity": severity, "missing": missing}

func _is_compatible(norm: Dictionary, mechanic: String) -> bool:
	return _check_compatibility(norm, mechanic).compatible

# Resolves a dotted path (e.g. "visual.semantic.color") into the normalized dict.
func _has_feature(norm: Dictionary, dotted_path: String) -> bool:
	var val = _get_nested(norm, dotted_path)
	if val == null:
		return false
	if val is String:
		return val != ""
	if val is Array:
		return not val.is_empty()
	return true

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
# SECTION 6: PROJECTION (contract-bound output generation)
# Output shape is IDENTICAL to v4.0 — only the source of visual
# color changed (now from the layered semantic sub-dict).
# =========================================================

func _project(norm: Dictionary, mechanic: String) -> Dictionary:
	var vis_semantic = (norm.get("visual", {}).get("semantic", {})) if norm.get("visual", {}) is Dictionary else {}
	var visual_color = str(vis_semantic.get("color", "#FFFFFF")) if vis_semantic is Dictionary else "#FFFFFF"

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
				"visual_interference": visual_color
			}
		"memory_cascade":
			return {
				"prompt": "RECALL SIGNATURE",
				"correct_answer": norm.signature,
				"sequence": norm.sequence
			}
		_:
			return _project_fallback(norm)

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
