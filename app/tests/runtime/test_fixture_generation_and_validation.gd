extends SceneTree

var failures: Array[String] = []
var passes: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if condition:
		passes += 1
		print("[GENERATION PASS] %s" % message)
	else:
		failures.append(message)
		push_error("[GENERATION FAIL] %s" % message)

func _run() -> void:
	var legacy_registry: Node = root.get_node("ChallengeRegistry")
	var family_registry: Node = root.get_node("ChallengeFamilyRegistry")
	legacy_registry.call("initialize")
	family_registry.call("initialize")
	var module: ChallengeFamilyModule = family_registry.call("get_module", "scene_investigation_fixtures")
	_check(module != null, "Reference family module loads")
	if module == null:
		_finish()
		return

	var family := module.get_family()
	var generator := module.get_generator()
	var validator := module.get_validator()
	var difficulty_policy := module.get_difficulty_policy()
	var exposure_policy := module.get_exposure_policy()
	var templates := module.get_templates()
	_check(templates.size() == 5, "All five deterministic templates are available")

	for template: ChallengeTemplate in templates:
		var template_difficulty := difficulty_policy.resolve_difficulty({}, family, template)
		var template_exposure := exposure_policy.resolve_exposure(template, template_difficulty, {})
		var first := generator.generate(template, template_difficulty, template_exposure, 12345)
		var second := generator.generate(template, template_difficulty, template_exposure, 12345)
		_check(first != null, "%s generates an instance" % template.template_id)
		_check(first.to_dictionary() == second.to_dictionary(), "%s is deterministic for the same seed" % template.template_id)
		_check(validator.validate(first).is_valid, "%s passes fairness validation" % template.template_id)
		_check(first.answer_options.count(first.correct_answer) == 1, "%s has exactly one correct option" % template.template_id)
		_check(first.exposure_duration_sec == 2.0, "%s resolves fixture exposure" % template.template_id)

	var template: ChallengeTemplate = templates[0]
	var difficulty := difficulty_policy.resolve_difficulty({}, family, template)
	var exposure := exposure_policy.resolve_exposure(template, difficulty, {})
	var invalid_answers := generator.generate(template, difficulty, exposure, 1)
	invalid_answers.answer_options.append(invalid_answers.correct_answer)
	var answer_rejection := validator.validate(invalid_answers)
	_check(not answer_rejection.is_valid and answer_rejection.rule_id == "answer.unique", "Validator rejects ambiguous answer sets")

	var invalid_asset := generator.generate(template, difficulty, exposure, 2)
	invalid_asset.generated_scene["image_path"] = "res://missing_fixture_asset.png"
	var asset_rejection := validator.validate(invalid_asset)
	_check(not asset_rejection.is_valid and asset_rejection.rule_id == "presentation.asset", "Validator rejects missing required presentation assets")

	var invalid_exposure := generator.generate(template, difficulty, 0.0, 3)
	var exposure_rejection := validator.validate(invalid_exposure)
	_check(not exposure_rejection.is_valid and exposure_rejection.rule_id == "exposure.duration", "Validator rejects impossible exposure duration")

	_finish()

func _finish() -> void:
	print("[GENERATION SUMMARY] %d passed, %d failed" % [passes, failures.size()])
	for failure: String in failures:
		print("[GENERATION FAILURE] %s" % failure)
	quit(0 if failures.is_empty() else 1)
