extends SceneTree
## Automated 50-round replay proxies for variety, fairness, evidence, and template identity.

const FAMILY_IDS: Array[String] = [
	"scene_investigation",
	"flash_words",
	"spot_the_difference",
	"object_recall",
	"pattern_recall"
]
const ROUNDS_PER_FAMILY := 50

var failures: Array[String] = []
var passes: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if condition:
		passes += 1
		print("[PHASE55-REPLAY PASS] %s" % message)
	else:
		failures.append(message)
		push_error("[PHASE55-REPLAY FAIL] %s" % message)

func _run() -> void:
	root.get_node("ChallengeRegistry").call("initialize")
	root.get_node("InteractionAdapterRegistry").call("initialize")
	var registry: Node = root.get_node("ChallengeFamilyRegistry")
	registry.call("initialize")
	for family_id: String in FAMILY_IDS:
		_audit_family(registry.call("get_module", family_id), family_id)
	print("[PHASE55-REPLAY SUMMARY] %d passed, %d failed, %d rounds audited" % [passes, failures.size(), FAMILY_IDS.size() * ROUNDS_PER_FAMILY])
	for failure: String in failures:
		print("[PHASE55-REPLAY FAILURE] %s" % failure)
	quit(0 if failures.is_empty() else 1)

func _audit_family(module: ChallengeFamilyModule, family_id: String) -> void:
	_check(module != null, "Family available for replay audit: %s" % family_id)
	if module == null:
		return
	var templates := module.get_templates()
	var template_ids: Dictionary = {}
	var signatures: Dictionary = {}
	var question_types: Dictionary = {}
	var content_identities: Dictionary = {}
	var evidence_complete: bool = true
	var reproduction_complete: bool = true
	var validation_complete: bool = true
	var no_consecutive_repeat: bool = true
	var previous_signature := ""
	for round_index: int in range(ROUNDS_PER_FAMILY):
		var template: ChallengeTemplate = templates[round_index % templates.size()]
		var tier_index: int = mini(floori(float(round_index) / 13.0), 3)
		var state := _state_for_tier(family_id, tier_index)
		var difficulty := module.get_difficulty_policy().resolve_difficulty(state, module.get_family(), template)
		var exposure := module.get_exposure_policy().resolve_exposure(template, difficulty, state)
		var seed_value := 5500000 + absi(family_id.hash()) % 100000 + round_index * 7919
		var instance := module.get_generator().generate(template, difficulty, exposure, seed_value)
		if instance == null:
			validation_complete = false
			continue
		var validation: ChallengeValidationResult = module.get_validator().validate(instance)
		if not validation.is_valid:
			validation_complete = false
		var repeated := module.get_generator().generate(template, difficulty, exposure, seed_value)
		if repeated == null or repeated.to_dictionary() != instance.to_dictionary():
			reproduction_complete = false
		template_ids[template.template_id] = true
		var signature := str(instance.metadata.get("scene_signature", ""))
		if signature == previous_signature:
			no_consecutive_repeat = false
		previous_signature = signature
		signatures[signature] = true
		question_types[str(instance.metadata.get("question_type", "unknown"))] = true
		_collect_identities(family_id, instance, content_identities)
		var scoring := module.get_scoring_policy()
		var wrong_response: Variant = _wrong_response(family_id)
		var resolved: Dictionary = scoring.calculate_result(instance, wrong_response, {})
		var evidence: Dictionary = scoring.explain_outcome(instance, wrong_response, resolved)
		var reveal_value: Variant = evidence.get("reveal_data", {})
		if (
			str(evidence.get("explanation", "")).is_empty()
			or str(evidence.get("where_to_look", "")).is_empty()
			or not (reveal_value is Dictionary)
			or not ((reveal_value as Dictionary).get("generated_scene", {}) is Dictionary)
		):
			evidence_complete = false
	_check(validation_complete, "%s validates every one of 50 rounds" % family_id)
	_check(reproduction_complete, "%s reproduces every audited seed" % family_id)
	_check(signatures.size() >= 48, "%s produces at least 48 distinct signatures in 50 rounds (actual %d)" % [family_id, signatures.size()])
	_check(no_consecutive_repeat, "%s never repeats the same signature consecutively" % family_id)
	_check(template_ids.size() == templates.size(), "%s exercises every template in 50 rounds" % family_id)
	_check(question_types.size() >= _minimum_question_types(family_id), "%s preserves meaningful mechanic/question variation" % family_id)
	_check(content_identities.size() >= _minimum_identities(family_id), "%s draws from a broad content pool" % family_id)
	_check(evidence_complete, "%s provides explanatory evidence after every audited round" % family_id)
	_check(_templates_are_distinct(module, family_id), "%s templates declare distinct identities" % family_id)

func _collect_identities(family_id: String, instance: ChallengeInstance, output: Dictionary) -> void:
	match family_id:
		"scene_investigation":
			for value: Variant in instance.generated_scene.get("objects", []):
				if value is Dictionary:
					output[str((value as Dictionary).get("archetype_id", ""))] = true
		"flash_words":
			for value: Variant in instance.generated_scene.get("words", []):
				output[str(value)] = true
		"spot_the_difference":
			output[str(instance.metadata.get("target_name", ""))] = true
		"object_recall":
			for value: Variant in instance.metadata.get("shown_objects", []):
				output[str(value)] = true
		"pattern_recall":
			for value: Variant in instance.correct_answer:
				output[str(value)] = true

func _templates_are_distinct(module: ChallengeFamilyModule, family_id: String) -> bool:
	var identities: Dictionary = {}
	for template: ChallengeTemplate in module.get_templates():
		var identity := ""
		match family_id:
			"scene_investigation":
				identity = str(template.metadata.get("content_path", ""))
			"flash_words", "spot_the_difference", "object_recall":
				identity = str(template.metadata.get("mode", ""))
			"pattern_recall":
				identity = str(template.metadata.get("presentation_style", ""))
		identities[identity] = true
	return not identities.has("") and identities.size() == module.get_templates().size()

func _state_for_tier(family_id: String, tier_index: int) -> Dictionary:
	var progress: Dictionary = {}
	match tier_index:
		1:
			progress = {"plays": 5, "accuracy": 0.74, "mastery": 15.0, "incorrect_streak": 0}
		2:
			progress = {"plays": 12, "accuracy": 0.75, "mastery": 45.0, "incorrect_streak": 0}
		3:
			progress = {"plays": 25, "accuracy": 0.86, "mastery": 82.0, "incorrect_streak": 0}
	return {"witness_progress": {"families": {family_id: progress}}, "preferences": {}}

func _wrong_response(family_id: String) -> Variant:
	match family_id:
		"spot_the_difference":
			return {"x": -1.0, "y": -1.0}
		"object_recall", "pattern_recall":
			return []
		_:
			return "__not_an_answer__"

func _minimum_question_types(family_id: String) -> int:
	return {
		"scene_investigation": 4,
		"flash_words": 4,
		"spot_the_difference": 5,
		"object_recall": 4,
		"pattern_recall": 3
	}.get(family_id, 1)

func _minimum_identities(family_id: String) -> int:
	return {
		"scene_investigation": 60,
		"flash_words": 70,
		"spot_the_difference": 20,
		"object_recall": 35,
		"pattern_recall": 12
	}.get(family_id, 10)
