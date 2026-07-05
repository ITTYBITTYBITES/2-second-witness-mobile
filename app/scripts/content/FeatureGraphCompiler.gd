extends Node
class_name FeatureGraphCompiler

# ---------------------------------------------------------
# FEATURE GRAPH COMPILER — Immutable IR / Audit Artifact
# ---------------------------------------------------------
# Produces a FeatureGraphSnapshot: a complete, immutable record of how
# an entity's features were derived for contract evaluation.
#
# This is NOT a cache. Caches (norm_cache, feature_cache, proj_cache)
# exist for performance and are mutable. The snapshot exists for
# correctness, replay, and audit. It is evidence.
#
# Relationship to ObservationBuilder:
#   The compiler consumes the SAME resolver + contract definitions.
#   ObservationBuilder uses them at runtime (mutable, optimized).
#   The compiler traces them for audit (immutable, inspectable).
#
# Snapshot lifecycle:
#   - In gameplay: in-memory only (optional debug build)
#   - In validation/CI/regression: serialize to JSON, archive, diff
#
# Compiler fingerprint prevents cross-version snapshot comparison:
#   schema_version + resolver_hash + contract_hash = unique identity.
#   If any differ, snapshots are not directly comparable.
# ---------------------------------------------------------

const SCHEMA_VERSION = "feature-graph-v1"
const RESOLVER_VERSION = "v4.2"

# Mirrors ObservationBuilder's definitions (single source of truth).
# These are duplicated intentionally — the compiler must be a frozen
# artifact of the definitions at compile time, not a live reference
# that could drift if the builder's constants change.
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

const MECHANIC_CONTRACTS = {
	"rapid_classification": {"requires": ["category"], "prefers": ["confusions"], "output_schema": "single_label"},
	"signal_vs_noise":      {"requires": ["signature"], "prefers": ["confusions"], "output_schema": "disambiguation_task"},
	"odd_one_out":          {"requires": ["confusions"], "prefers": ["category"], "output_schema": "set_exclusion"},
	"stroop_test":          {"requires": ["material", "color"], "prefers": [], "output_schema": "interference_pair"},
	"memory_cascade":       {"requires": ["signature"], "prefers": [], "output_schema": "ordered_recall"}
}

# =========================================================
# SECTION 1: COMPILER FINGERPRINT
# Prevents comparing snapshots generated under different definitions.
# =========================================================

func get_fingerprint() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"resolver_version": RESOLVER_VERSION,
		"feature_set_hash": _hash_dict(FEATURE_RESOLVERS),
		"contract_hash": _hash_dict(MECHANIC_CONTRACTS)
	}

# =========================================================
# SECTION 2: ENTITY NORMALIZATION
# Identical logic to ObservationBuilder._normalize_entity.
# Duplicated to keep the compiler self-contained for replay.
# =========================================================

func _normalize_entity(raw: Dictionary) -> Dictionary:
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

	return {
		"label": label, "type": str(raw.get("entity_type", "")),
		"category": category, "signature": signature,
		"material": str(dims.get("Material", "")),
		"visual": {"semantic": visual_semantic, "asset": visual_asset},
		"confusions": confusions, "sequence": [label]
	}

# =========================================================
# SECTION 3: FEATURE RESOLUTION WITH TRACE
# Resolves each feature and records the FULL trace: attempted paths,
# winning path, final value, and failure reason if unresolved.
# =========================================================

func _resolve_with_trace(norm: Dictionary, feature_name: String) -> Dictionary:
	var chain = FEATURE_RESOLVERS.get(feature_name, [])
	var trace = {
		"requested": true,
		"attempts": [],
		"selected": null,
		"status": "unresolved",
		"reason": ""
	}
	for path in chain:
		var path_str = str(path)
		trace.attempts.append(path_str)
		var val = _get_nested(norm, path_str)
		if val != null:
			var valid = false
			if val is String and val != "":
				valid = true
			elif val is Array and not val.is_empty():
				valid = true
			elif val is Dictionary and not val.is_empty():
				valid = true
			elif not (val is String or val is Array or val is Dictionary):
				valid = true
			if valid:
				trace.selected = {"path": path_str, "value": val}
				trace.status = "resolved"
				trace.reason = ""
				return trace
	# All attempts failed
	if chain.is_empty():
		trace.reason = "no_resolver_defined"
	else:
		trace.reason = "all_paths_empty_or_missing"
	return trace

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
# SECTION 4: COMPATIBILITY EVALUATION
# Deterministic: same features + contract → same result.
# =========================================================

func _check_compatibility(features: Dictionary, mechanic: String) -> Dictionary:
	var contract = MECHANIC_CONTRACTS.get(mechanic, null)
	if contract == null:
		return {"compatible": false, "reason": "unsupported_contract", "severity": "hard", "missing": []}
	var requires = contract.get("requires", [])
	var missing: Array = []
	for req in requires:
		var req_name = str(req)
		if not features.has(req_name):
			missing.append(req_name)
		else:
			var val = features[req_name]
			if val is String and val == "": missing.append(req_name)
			elif val is Array and val.is_empty(): missing.append(req_name)
	if missing.is_empty():
		return {"compatible": true, "reason": "", "severity": "none", "missing": []}
	var severity = "soft"
	if "confusions" in missing: severity = "hard"
	return {"compatible": false, "reason": "missing_dimension", "severity": severity, "missing": missing}

# =========================================================
# SECTION 5: PER-ENTITY SNAPSHOT
# The core audit artifact. Immutable once produced.
# =========================================================

func compile_snapshot(raw: Dictionary) -> Dictionary:
	var obs_id = str(raw.get("observation_id", raw.get("id", "unknown")))
	var norm = _normalize_entity(raw)

	# Resolve all features with traces
	var feature_map: Dictionary = {}
	var feature_traces: Dictionary = {}
	var unresolved: Array = []
	for feature_name in FEATURE_RESOLVERS:
		var trace = _resolve_with_trace(norm, feature_name)
		feature_traces[feature_name] = trace
		if trace.status == "resolved" and trace.selected != null:
			feature_map[feature_name] = trace.selected.value
		else:
			unresolved.append({"feature": feature_name, "reason": trace.reason})

	# Evaluate compatibility for each mechanic
	var compatible: Array = []
	var incompatible: Array = []
	for mechanic in MECHANIC_CONTRACTS:
		var result = _check_compatibility(feature_map, mechanic)
		if result.compatible:
			compatible.append(mechanic)
		else:
			incompatible.append({"mechanic": mechanic, "reason": result.reason, "missing": result.missing})

	return {
		"entity_id": obs_id,
		"compiler": get_fingerprint(),
		"source": {
			"raw_hash": _hash_dict(raw),
			"normalized_hash": _hash_dict(norm)
		},
		"features": feature_traces,
		"projection": {
			"compatible": compatible,
			"incompatible": incompatible
		},
		"diagnostics": {
			"unresolved": unresolved,
			"warnings": []
		}
	}

# =========================================================
# SECTION 6: BATCH SNAPSHOT
# Aggregates entity snapshots + system-wide statistics + coverage map.
# This is the artifact to archive during validation/CI.
# =========================================================

func compile_batch(raw_entities: Array) -> Dictionary:
	var entity_snapshots: Array = []
	var resolved_count = 0
	var unresolved_count = 0
	var resolver_usage: Dictionary = {}
	var coverage: Dictionary = {}

	for mechanic in MECHANIC_CONTRACTS:
		coverage[mechanic] = {"total": 0, "compatible": 0}

	for raw in raw_entities:
		if not (raw is Dictionary and raw.has("entity") and raw.has("features")):
			continue
		var snap = compile_snapshot(raw)
		entity_snapshots.append(snap["entity_id"])

		# Tally feature resolution stats
		for fname in snap["features"]:
			var ft = snap["features"][fname]
			if ft.status == "resolved":
				resolved_count += 1
				if ft.selected != null:
					var rp = str(ft.selected.path)
					resolver_usage[rp] = int(resolver_usage.get(rp, 0)) + 1
			else:
				unresolved_count += 1

		# Tally coverage
		for mech in snap["projection"]["compatible"]:
			coverage[mech]["total"] += 1
			coverage[mech]["compatible"] += 1
		for inc in snap["projection"]["incompatible"]:
			var m = str(inc.mechanic)
			coverage[m]["total"] += 1

	# Compute coverage percentages
	var coverage_pct: Dictionary = {}
	for mech in coverage:
		var t = int(coverage[mech]["total"])
		var c = int(coverage[mech]["compatible"])
		coverage_pct[mech] = (float(c) / float(t) * 100.0) if t > 0 else 0.0

	return {
		"compiler": get_fingerprint(),
		"entity_count": entity_snapshots.size(),
		"entities": entity_snapshots,
		"statistics": {
			"resolved_features": resolved_count,
			"unresolved_features": unresolved_count,
			"resolver_usage": resolver_usage,
			"coverage_pct": coverage_pct
		}
	}

# =========================================================
# SECTION 7: SERIALIZATION
# JSON serialize/deserialize for CI/regression archival + diffing.
# =========================================================

func serialize_snapshot(snap: Dictionary) -> String:
	return JSON.stringify(snap, "  ")

func serialize_batch(batch: Dictionary) -> String:
	return JSON.stringify(batch, "  ")

func deserialize(json_str: String) -> Dictionary:
	var json = JSON.new()
	if json.parse(json_str) == OK:
		return json.data
	return {}

# =========================================================
# SECTION 8: SNAPSHOT DIFF (regression tool)
# Compares two snapshots. Returns the delta — what changed.
# If compiler fingerprints differ, flags as non-comparable.
# =========================================================

func diff_snapshots(snap_a: Dictionary, snap_b: Dictionary) -> Dictionary:
	var fp_a = snap_a.get("compiler", {})
	var fp_b = snap_b.get("compiler", {})
	var fp_match = _hash_dict(fp_a) == _hash_dict(fp_b)

	if not fp_match:
		return {"comparable": false, "reason": "compiler_fingerprint_mismatch",
			"fingerprint_a": fp_a, "fingerprint_b": fp_b}

	var delta: Dictionary = {"comparable": true, "feature_changes": [], "projection_changes": []}

	# Feature changes
	var features_a = snap_a.get("features", {})
	var features_b = snap_b.get("features", {})
	for fname in features_a:
		var fa = features_a[fname]
		var fb = features_b.get(fname, {})
		var val_a = str(fa.selected.value) if fa.selected != null else "UNRESOLVED"
		var val_b = str(fb.selected.value) if fb.get("selected") != null else "UNRESOLVED"
		if val_a != val_b:
			delta.feature_changes.append({"feature": fname, "before": val_a, "after": val_b})

	# Projection changes
	var proj_a = snap_a.get("projection", {})
	var proj_b = snap_b.get("projection", {})
	var comp_a: Array = proj_a.get("compatible", [])
	var comp_b: Array = proj_b.get("compatible", [])
	for mech in comp_a:
		if mech not in comp_b:
			delta.projection_changes.append({"mechanic": mech, "change": "lost_compatibility"})
	for mech in comp_b:
		if mech not in comp_a:
			delta.projection_changes.append({"mechanic": mech, "change": "gained_compatibility"})

	return delta

# =========================================================
# SECTION 9: HASH UTILITY
# Deterministic string hash of a Dictionary for fingerprinting.
# =========================================================

func _hash_dict(d: Variant) -> String:
	return str(JSON.stringify(d)).sha256_text().substr(0, 16)
