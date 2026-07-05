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

# (Previous _build_v2_payload and _build_legacy_v1_payload logic preserved below)
