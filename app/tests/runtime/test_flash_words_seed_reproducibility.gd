extends SceneTree

const SAMPLE_COUNT: int = 100
const TIERS: Array[String] = ["beginner", "standard", "advanced", "expert"]

var failures: Array[String] = []
var passes: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if condition:
		passes += 1
		print("[FLASH-SEED PASS] %s" % message)
	else:
		failures.append(message)
		push_error("[FLASH-SEED FAIL] %s" % message)

func _run() -> void:
	var fixture_registry: Node = root.get_node("ChallengeRegistry")
	var registry: Node = root.get_node("ChallengeFamilyRegistry")
	var settings: Node = root.get_node("SettingsService")
	fixture_registry.call("initialize")
	settings.call("initialize")
	registry.call("initialize")
	var module: ChallengeFamilyModule = registry.call("get_module", "flash_words")
	var templates := module.get_templates()
	var family := module.get_family()
	var difficulty_policy := module.get_difficulty_policy()
	var exposure_policy := module.get_exposure_policy()
	var generator := module.get_generator()
	var validator := module.get_validator()
	var scoring := module.get_scoring_policy()
	var rng := RandomNumberGenerator.new()
	rng.seed = 20260711

	for sample: int in range(SAMPLE_COUNT):
		var template: ChallengeTemplate = templates[sample % templates.size()]
		var tier := TIERS[sample % TIERS.size()]
		var player_state := _state_for_tier(tier)
		var difficulty := difficulty_policy.resolve_difficulty(player_state, family, template)
		var exposure := exposure_policy.resolve_exposure(template, difficulty, player_state)
		var seed_value := rng.randi_range(1, 2000000000)
		var baseline := generator.generate(template, difficulty, exposure, seed_value)
		var baseline_validation := validator.validate(baseline)
		if not baseline_validation.is_valid:
			failures.append("Baseline rejected template=%s tier=%s seed=%d rule=%s" % [template.template_id, tier, seed_value, baseline_validation.rule_id])
			continue
		var baseline_json := JSON.stringify(baseline.to_dictionary())
		var correct_result := scoring.calculate_result(baseline, baseline.correct_answer, {"reaction_ms": 500})
		var correct_score := scoring.calculate_score(correct_result, template)
		var incorrect_response: Variant = _incorrect_option(baseline)
		var incorrect_result := scoring.calculate_result(baseline, incorrect_response, {"reaction_ms": 500})
		var incorrect_score := scoring.calculate_score(incorrect_result, template)
		for repetition: int in range(3):
			var repeated := generator.generate(template, difficulty, exposure, seed_value)
			if JSON.stringify(repeated.to_dictionary()) != baseline_json:
				failures.append("Serialized instance changed template=%s tier=%s seed=%d repetition=%d" % [template.template_id, tier, seed_value, repetition])
				break
			if repeated.correct_answer != baseline.correct_answer:
				failures.append("Correct answer changed template=%s tier=%s seed=%d" % [template.template_id, tier, seed_value])
				break
			var repeated_correct := scoring.calculate_result(repeated, repeated.correct_answer, {"reaction_ms": 500})
			var repeated_incorrect := scoring.calculate_result(repeated, incorrect_response, {"reaction_ms": 500})
			if scoring.calculate_score(repeated_correct, template) != correct_score or scoring.calculate_score(repeated_incorrect, template) != incorrect_score:
				failures.append("Scoring changed template=%s tier=%s seed=%d" % [template.template_id, tier, seed_value])
				break

	_check(failures.is_empty(), "100 sampled seeds reproduce identical instances, answers, and scores")
	print("[FLASH-SEED SUMMARY] %d samples, %d passed checks, %d failures" % [SAMPLE_COUNT, passes, failures.size()])
	for failure: String in failures:
		print("[FLASH-SEED FAILURE] %s" % failure)
	quit(0 if failures.is_empty() else 1)

func _incorrect_option(instance: ChallengeInstance) -> Variant:
	for option: Variant in instance.answer_options:
		if option != instance.correct_answer:
			return option
	return "__INCORRECT__"

func _state_for_tier(tier: String) -> Dictionary:
	var progress := {"plays": 0, "accuracy": 0.0, "mastery": 0.0, "incorrect_streak": 0}
	match tier:
		"standard": progress = {"plays": 5, "accuracy": 0.75, "mastery": 12.0, "incorrect_streak": 0}
		"advanced": progress = {"plays": 12, "accuracy": 0.76, "mastery": 45.0, "incorrect_streak": 0}
		"expert": progress = {"plays": 24, "accuracy": 0.86, "mastery": 82.0, "incorrect_streak": 0}
	return {"witness_progress": {"families": {"flash_words": progress}}}
