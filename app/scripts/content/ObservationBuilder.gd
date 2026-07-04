extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# OBSERVATION BUILDER (KNOWLEDGE -> GAMEPLAY PAYLOAD)
# ---------------------------------------------------------
# Converts standardized observations into legacy-compatible gameplay
# payloads. Scenario scripts consume payloads; they do not own content.
# ---------------------------------------------------------

func build_payload(observation: Dictionary, mechanic_id: String, context: Dictionary = {}) -> Dictionary:
	if observation.is_empty():
		return {}
	var mechanic = str(mechanic_id)
	var prompt = _prompt_for_mechanic(observation, mechanic)
	var correct = str(observation.get("correct_answer", ""))
	var distractors = observation.get("distractors", [])
	if not (distractors is Array): distractors = []
	var payload = {
		"id": observation.get("id", observation.get("observation_id", mechanic)),
		"observation_id": observation.get("observation_id", observation.get("id", "")),
		"universe": observation.get("universe", context.get("universe", "")),
		"world": observation.get("world", context.get("world", "")),
		"subcategory": observation.get("subcategory", context.get("subcategory", "")),
		"type": mechanic,
		"rules": {
			"prompt": prompt,
			"legacy_prompt": prompt,
			"correct_answer": correct,
			"wrong_answers": _build_distractors(correct, distractors, mechanic)
		},
		"presentation": observation.get("presentation", {}).duplicate(true),
		"metadata": observation.get("metadata", {}).duplicate(true),
		"knowledge": observation.get("knowledge", {}).duplicate(true)
	}
	payload["presentation"]["subcategory"] = payload["subcategory"]
	payload["presentation"]["difficulty_tier"] = int(observation.get("difficulty", payload["presentation"].get("difficulty_tier", 1)))
	payload["metadata"]["built_by"] = "ObservationBuilder"
	payload["metadata"]["source_observation_id"] = payload["observation_id"]
	return payload

func _prompt_for_mechanic(observation: Dictionary, mechanic: String) -> String:
	var prompt = str(observation.get("question", "")).strip_edges()
	var knowledge = observation.get("knowledge", {})
	match mechanic:
		"stroop_test":
			var term = str(knowledge.get("term", knowledge.get("title", knowledge.get("concept", observation.get("correct_answer", prompt))))).strip_edges()
			return term.to_upper() if term != "" else prompt.to_upper()
		"signal_vs_noise":
			return "Find: " + str(observation.get("correct_answer", "TARGET"))
		"memory_cascade", "sequence_reverse":
			return str(knowledge.get("sequence_prompt", prompt))
		_:
			return prompt

func _build_distractors(correct: String, distractors: Array, mechanic: String) -> Array:
	var result: Array = []
	for d in distractors:
		var text = str(d).strip_edges()
		if text != "" and text != correct and not result.has(text):
			result.append(text)
	match mechanic:
		"stroop_test":
			return []
		_:
			while result.size() < 3:
				result.append("Not " + correct if correct != "" else "Distractor")
			return result.slice(0, 3)
