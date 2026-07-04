extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# OBSERVATION BUILDER v2.0 (FOUNDATION LAYER)
# ---------------------------------------------------------
# Converts a single Canonical Knowledge Object into any requested
# gameplay mechanic payload at runtime. 
# ---------------------------------------------------------

const SCHEMA_VERSION = 2

## The Canonical Knowledge Object (CKO) structure:
## {
##    "observation_id": String,
##    "universe": String,
##    "world": String,
##    "subcategory": String,
##    "concept": String,           # The primary subject (e.g. "Mona Lisa")
##    "recognized_answer": String,  # The target attribute (e.g. "Leonardo da Vinci")
##    "distractor_family": Array,   # Like-kind items for choices (e.g. ["Vermeer", "Gogh"])
##    "difficulty": int,            # 1-5
##    "visual_cues": Dictionary,    # Optional: { "color": "#FF0000", "shape": "circle" }
##    "metadata": Dictionary,       # Optional: { "tags": [], "scenario_compatibility": [] }
## }

func build_payload(cko: Dictionary, mechanic_id: String, context: Dictionary = {}) -> Dictionary:
	if cko.is_empty():
		return {}
		
	# 1. Detect and Handle Legacy v1.0 payloads
	if not cko.has("concept") and cko.has("rules"):
		return _build_legacy_v1_payload(cko, mechanic_id, context)

	var mechanic = str(mechanic_id).to_lower()
	var payload = {
		"id": cko.get("observation_id", "unknown") + "_" + mechanic,
		"observation_id": cko.get("observation_id", "unknown"),
		"universe": cko.get("universe", context.get("universe", "history")),
		"world": cko.get("world", context.get("world", "ancient_egypt")),
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

	# 2. Dynamic Transformation Logic
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

	# Ensure consistency tags
	payload["rules"]["legacy_prompt"] = payload["rules"].get("prompt", "OBSERVE")
	return payload

func _generate_title(cko: Dictionary) -> String:
	var world = str(cko.get("world", "")).capitalize()
	var sub = str(cko.get("subcategory", "")).capitalize().replace("_", " ")
	return world + " — " + sub

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
