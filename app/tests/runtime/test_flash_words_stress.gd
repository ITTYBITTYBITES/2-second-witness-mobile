extends SceneTree

const DEFAULT_SEEDS_PER_TIER: int = 2000
const TIERS: Array[String] = ["beginner", "standard", "advanced", "expert"]

var failures: Array[String] = []
var generated_count: int = 0
var seeds_per_tier: int = DEFAULT_SEEDS_PER_TIER

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_parse_args()
	var fixture_registry: Node = root.get_node("ChallengeRegistry")
	var registry: Node = root.get_node("ChallengeFamilyRegistry")
	var settings: Node = root.get_node("SettingsService")
	fixture_registry.call("initialize")
	settings.call("initialize")
	registry.call("initialize")
	var module: ChallengeFamilyModule = registry.call("get_module", "flash_words")
	if module == null:
		_fail("Flash Words family is unavailable")
		_finish()
		return
	var family := module.get_family()
	var generator := module.get_generator()
	var validator := module.get_validator()
	var difficulty_policy := module.get_difficulty_policy()
	var exposure_policy := module.get_exposure_policy()
	var durations: Dictionary = {}

	for template: ChallengeTemplate in module.get_templates():
		var started := Time.get_ticks_msec()
		var signatures: Dictionary = {}
		var duplicate_signatures: int = 0
		for tier: String in TIERS:
			var player_state := _state_for_tier(tier)
			var difficulty := difficulty_policy.resolve_difficulty(player_state, family, template)
			if str(difficulty.get("label", "")) != tier:
				_fail("%s failed to resolve tier %s" % [template.template_id, tier])
				continue
			var exposure := exposure_policy.resolve_exposure(template, difficulty, player_state)
			for offset: int in range(seeds_per_tier):
				var seed_value := _seed_for(template.template_id, tier, offset)
				var instance := generator.generate(template, difficulty, exposure, seed_value)
				generated_count += 1
				var validation := validator.validate(instance)
				if not validation.is_valid:
					_fail("Rejected seed template=%s tier=%s seed=%d rule=%s reason=%s" % [template.template_id, tier, seed_value, validation.rule_id, validation.reason])
					continue
				var signature := str(instance.metadata.get("scene_signature", ""))
				if signatures.has(signature):
					duplicate_signatures += 1
				else:
					signatures[signature] = seed_value
				if instance.answer_options.size() != (instance.answer_options as Array).duplicate().size():
					_fail("Option count mutation detected seed=%d" % seed_value)
				if instance.answer_options.count(instance.correct_answer) != 1:
					_fail("Correct answer ambiguity seed=%d" % seed_value)
				if offset < 3:
					var repeated := generator.generate(template, difficulty, exposure, seed_value)
					if instance.to_dictionary() != repeated.to_dictionary():
						_fail("Reproduction mismatch template=%s tier=%s seed=%d" % [template.template_id, tier, seed_value])
		durations[template.template_id] = Time.get_ticks_msec() - started
		print("[FLASH-STRESS DIVERSITY] %s unique=%d duplicates=%d" % [template.template_id, signatures.size(), duplicate_signatures])

	_check_performance(durations)
	_finish()

func _parse_args() -> void:
	for argument: String in OS.get_cmdline_user_args():
		var normalized := argument.trim_prefix("--")
		if normalized.begins_with("seeds="):
			seeds_per_tier = maxi(int(normalized.trim_prefix("seeds=")), 1)

func _state_for_tier(tier: String) -> Dictionary:
	var progress := {"plays": 0, "accuracy": 0.0, "mastery": 0.0, "incorrect_streak": 0}
	match tier:
		"standard": progress = {"plays": 5, "accuracy": 0.75, "mastery": 12.0, "incorrect_streak": 0}
		"advanced": progress = {"plays": 12, "accuracy": 0.76, "mastery": 45.0, "incorrect_streak": 0}
		"expert": progress = {"plays": 24, "accuracy": 0.86, "mastery": 82.0, "incorrect_streak": 0}
	return {"witness_progress": {"families": {"flash_words": progress}}}

func _seed_for(template_id: String, tier: String, offset: int) -> int:
	return absi((template_id + ":" + tier).hash()) % 100000000 + offset

func _check_performance(durations: Dictionary) -> void:
	if durations.size() != 4:
		_fail("Performance data is incomplete")
		return
	var minimum := INF
	var maximum := 0.0
	for value: Variant in durations.values():
		minimum = minf(minimum, float(value))
		maximum = maxf(maximum, float(value))
	if minimum > 0.0 and maximum / minimum > 3.0:
		_fail("Template performance differs by more than 3x: %s" % str(durations))
	print("[FLASH-STRESS PERFORMANCE] %s" % str(durations))

func _fail(message: String) -> void:
	if failures.size() < 100:
		failures.append(message)

func _finish() -> void:
	if failures.is_empty():
		print("[FLASH-STRESS SUMMARY] %d generated, 0 failed, %d seeds/template/tier" % [generated_count, seeds_per_tier])
		quit(0)
		return
	for failure: String in failures:
		print("[FLASH-STRESS FAILURE] %s" % failure)
	push_error("Flash Words stress failed: %d recorded failures" % failures.size())
	quit(1)
