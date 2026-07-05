extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# OBSERVATION BUILDER v3.0 (ENTITY-CENTRIC FOUNDATION)
# ---------------------------------------------------------
# Authoritatively transforms CKO v3.0 Entity Objects into 
# multiple high-fidelity gameplay experiences.
# ---------------------------------------------------------

const SCHEMA_VERSION = 3

func build_payload(cko: Dictionary, mechanic_id: String, context: Dictionary = {}) -> Dictionary:
	if cko.is_empty():
		return {}
		
	# 1. Schema Version Detection
	if cko.has("entity") and cko.has("features"):
		return _build_v3_payload(cko, mechanic_id, context)
	elif cko.has("concept") and not cko.has("entity"):
		return _build_v2_payload(cko, mechanic_id, context)
	else:
		return _build_legacy_v1_payload(cko, mechanic_id, context)

func _build_v3_payload(cko: Dictionary, mechanic_id: String, context: Dictionary) -> Dictionary:
	var mechanic = str(mechanic_id).to_lower()
	var entity = str(cko.get("entity", "Unknown Entity"))
	var dims = cko.get("dimensions", {})
	var features = cko.get("features", {})
	
	var payload = {
		"id": cko.get("observation_id", "unknown") + "_" + mechanic,
		"observation_id": cko.get("observation_id", "unknown"),
		"universe": cko.get("universe", context.get("universe", "")),
		"world": cko.get("world", context.get("world", "")),
		"subcategory": cko.get("subcategory", context.get("subcategory", "")),
		"type": mechanic,
		"difficulty": int(cko.get("difficulty", 1)),
		"rules": {},
		"presentation": {
			"title": entity.to_upper(),
			"subcategory": cko.get("subcategory", ""),
			"difficulty_tier": int(cko.get("difficulty", 1))
		},
		"metadata": cko.get("metadata", {}).duplicate(true)
	}

	# 2. Entity-Centric Transformation Logic
	match mechanic:
		"rapid_classification":
			# Focus: Group Membership (Is X a Material?)
			payload["rules"] = {
				"prompt": entity,
				"correct_answer": dims.get("Category", cko.get("entity_type", "Concept")),
				"wrong_answers": [cko.get("confusions", ["Generic"])[0]]
			}
		"signal_vs_noise":
			# Focus: Feature Detection (Find the Signature)
			var sig = dims.get("Signature", features.get("visual", ["Observation"])[0])
			payload["rules"] = {
				"prompt": "DETECT: " + sig,
				"correct_answer": entity,
				"wrong_answers": cko.get("confusions", [])
			}
		"odd_one_out":
			# Focus: Anomaly Detection (1 Entity vs 3 Confusions)
			payload["rules"] = {
				"prompt": "ANOMALY DETECTION",
				"correct_answer": entity,
				"wrong_answers": cko.get("confusions", []).slice(0, 3)
			}
		"stroop_test":
			# Focus: Semantic vs Visual Conflict
			var visual = features.get("visual", {})
			payload["rules"] = {
				"prompt": entity,
				"correct_answer": dims.get("Material", "STONE"),
				"visual_interference": visual.get("color", "#FFFFFF") if visual is Dictionary else "#FFFFFF"
			}
		"memory_cascade":
			# Focus: Relationship Chains
			payload["rules"] = {
				"prompt": "RECALL SIGNATURE",
				"correct_answer": dims.get("Signature", "Pattern"),
				"sequence": [entity]
			}
		_:
			# Default: Identification
			payload["rules"] = {
				"prompt": entity,
				"correct_answer": dims.get("Signature", "Identify"),
				"wrong_answers": cko.get("confusions", [])
			}

	payload["rules"]["legacy_prompt"] = payload["rules"].get("prompt", "OBSERVE")
	return payload

# ---------------------------------------------------------
# CKO v2.0 BUILDER (concept / recognized_answer / distractor_family schema)
# Restored for backward compatibility. Uses context-provided
# universe/world IDs only (no hardcoded IDs), per the ID refactor.
# ---------------------------------------------------------
func _build_v2_payload(cko: Dictionary, mechanic_id: String, context: Dictionary) -> Dictionary:
	var mechanic = str(mechanic_id).to_lower()
	var payload = {
		"id": cko.get("observation_id", "unknown") + "_" + mechanic,
		"observation_id": cko.get("observation_id", "unknown"),
		"universe": cko.get("universe", context.get("universe", "")),
		"world": cko.get("world", context.get("world", "")),
		"subcategory": cko.get("subcategory", context.get("subcategory", "")),
		"type": mechanic,
		"difficulty": int(cko.get("difficulty", 1)),
		"rules": {},
		"presentation": {
			"title": _generate_title(cko),
			"subcategory": cko.get("subcategory", ""),
			"difficulty_tier": int(cko.get("difficulty", 1))
		},
		"metadata": cko.get("metadata", {}).duplicate(true)
	}

	match mechanic:
		"rapid_classification":
			payload["rules"] = {
				"prompt": cko.get("concept", "OBSERVE"),
				"correct_answer": cko.get("recognized_answer", "YES"),
				"wrong_answers": [cko.get("distractor_family", ["NO"])[0]]
			}
		"signal_vs_noise":
			payload["rules"] = {
				"prompt": "FIND: " + cko.get("recognized_answer", "TARGET"),
				"correct_answer": cko.get("recognized_answer", ""),
				"wrong_answers": cko.get("distractor_family", [])
			}
		"odd_one_out":
			payload["rules"] = {
				"prompt": "ANOMALY DETECTION",
				"correct_answer": cko.get("recognized_answer", ""),
				"wrong_answers": cko.get("distractor_family", []).slice(0, 3)
			}
		"stroop_test":
			payload["rules"] = {
				"prompt": cko.get("concept", ""),
				"correct_answer": cko.get("recognized_answer", ""),
				"visual_interference": cko.get("visual_cues", {}).get("color", "#FFFFFF")
			}
		"memory_cascade", "sequence_reverse":
			payload["rules"] = {
				"prompt": "RECALL SEQUENCE",
				"correct_answer": cko.get("recognized_answer", ""),
				"sequence": [cko.get("concept", "")] # Scenarios will append further items
			}
		"spatial_recall":
			payload["rules"] = {
				"prompt": "POSITIONAL AUDIT",
				"correct_answer": cko.get("recognized_answer", ""),
				"anchor": cko.get("visual_cues", {}).get("position", Vector2.ZERO)
			}
		_:
			# Fallback to simple classification
			payload["rules"] = {
				"prompt": cko.get("concept", "OBSERVE"),
				"correct_answer": cko.get("recognized_answer", ""),
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

# ---------------------------------------------------------
# LEGACY v1.0 BUILDER (data already carries a pre-baked "rules" block)
# Preserved verbatim for backward compatibility with v1 content packs.
# ---------------------------------------------------------
func _build_legacy_v1_payload(v1_data: Dictionary, mechanic_id: String, context: Dictionary) -> Dictionary:
	# Preserve original v1 logic for backward compatibility
	var mechanic = str(mechanic_id)
	var rules = v1_data.get("rules", {})
	var payload = {
		"id": v1_data.get("id", v1_data.get("observation_id", mechanic)),
		"observation_id": v1_data.get("observation_id", v1_data.get("id", "")),
		"universe": v1_data.get("universe", context.get("universe", "")),
		"world": v1_data.get("world", context.get("world", "")),
		"subcategory": v1_data.get("subcategory", context.get("subcategory", "")),
		"type": mechanic,
		"rules": rules.duplicate(true),
		"presentation": v1_data.get("presentation", {}).duplicate(true),
		"metadata": v1_data.get("metadata", {}).duplicate(true)
	}
	if not payload["rules"].has("legacy_prompt"):
		payload["rules"]["legacy_prompt"] = rules.get("prompt", "OBSERVE")
	return payload
