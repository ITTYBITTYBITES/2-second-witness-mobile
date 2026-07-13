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
	var legacy_registry: Node = root.get_node("ChallengeRegistry")
	var family_registry: Node = root.get_node("ChallengeFamilyRegistry")
	legacy_registry.call("initialize")
	family_registry.call("initialize")
	var module: ChallengeFamilyModule = family_registry.call("get_module", "scene_investigation")
	if module == null:
		_fail("Production Scene Investigation family is unavailable")
		_finish()
		return
	var family := module.get_family()
	var generator := module.get_generator()
	var validator := module.get_validator()
	var difficulty_policy := module.get_difficulty_policy()
	var exposure_policy := module.get_exposure_policy()
	var template_durations: Dictionary = {}

	for template: ChallengeTemplate in module.get_templates():
		var template_start := Time.get_ticks_msec()
		var signatures: Dictionary = {}
		var question_types: Dictionary = {}
		for tier: String in TIERS:
			var player_state := _player_state_for_tier(tier)
			var difficulty := difficulty_policy.resolve_difficulty(player_state, family, template)
			if str(difficulty.get("label", "")) != tier:
				_fail("%s did not resolve requested tier %s" % [template.template_id, tier])
				continue
			var exposure := exposure_policy.resolve_exposure(template, difficulty, player_state)
			if not _exposure_in_range(tier, exposure):
				_fail("%s %s exposure %.3f is outside approved range" % [template.template_id, tier, exposure])
			for seed_offset: int in range(seeds_per_tier):
				var seed_value := _seed_for(template.template_id, tier, seed_offset)
				var instance := generator.generate(template, difficulty, exposure, seed_value)
				generated_count += 1
				var validation := validator.validate(instance)
				if not validation.is_valid:
					_fail("Rejected production seed template=%s tier=%s seed=%d rule=%s reason=%s" % [template.template_id, tier, seed_value, validation.rule_id, validation.reason])
					continue
				var signature := str(instance.metadata.get("scene_signature", ""))
				if signatures.has(signature):
					_fail("Duplicate scene signature template=%s tier=%s seeds=%d/%d" % [template.template_id, tier, int(signatures[signature]), seed_value])
				else:
					signatures[signature] = seed_value
				question_types[str(instance.metadata.get("question_type", "unknown"))] = true
				if seed_offset < 3:
					var repeated := generator.generate(template, difficulty, exposure, seed_value)
					if instance.to_dictionary() != repeated.to_dictionary():
						_fail("Reproduction mismatch template=%s tier=%s seed=%d" % [template.template_id, tier, seed_value])
		var required_questions: Array = template.question_types
		for question_type: Variant in required_questions:
			if not question_types.has(str(question_type)):
				_fail("%s did not generate question type %s" % [template.template_id, question_type])
		template_durations[template.template_id] = Time.get_ticks_msec() - template_start

	_check_performance_balance(template_durations)
	_finish()

func _parse_args() -> void:
	for argument: String in OS.get_cmdline_user_args():
		var normalized := argument.trim_prefix("--")
		if normalized.begins_with("seeds="):
			seeds_per_tier = maxi(int(normalized.trim_prefix("seeds=")), 1)

func _player_state_for_tier(tier: String) -> Dictionary:
	var progress := {"plays": 0, "correct": 0, "accuracy": 0.0, "mastery": 0.0}
	match tier:
		"standard": progress = {"plays": 4, "correct": 3, "accuracy": 0.75, "mastery": 12.0}
		"advanced": progress = {"plays": 12, "correct": 9, "accuracy": 0.75, "mastery": 45.0}
		"expert": progress = {"plays": 24, "correct": 21, "accuracy": 0.875, "mastery": 82.0}
	return {"witness_progress": {"families": {"scene_investigation": progress}}}

func _seed_for(template_id: String, tier: String, offset: int) -> int:
	var base: int = absi((template_id + ":" + tier).hash()) % 100000000
	return base + offset

func _exposure_in_range(tier: String, duration: float) -> bool:
	var ranges := {
		"beginner": Vector2(5.0, 6.0),
		"standard": Vector2(3.5, 5.0),
		"advanced": Vector2(2.0, 3.5),
		"expert": Vector2(1.5, 2.0)
	}
	var bounds: Vector2 = ranges[tier]
	return duration >= bounds.x and duration <= bounds.y

func _check_performance_balance(durations: Dictionary) -> void:
	if durations.size() < 3:
		_fail("Performance data is incomplete")
		return
	var minimum := INF
	var maximum := 0.0
	for value: Variant in durations.values():
		minimum = minf(minimum, float(value))
		maximum = maxf(maximum, float(value))
	if minimum > 0.0 and maximum / minimum > 3.0:
		_fail("Template generation performance differs by more than 3x: %s" % str(durations))
	print("[STRESS PERFORMANCE] %s" % str(durations))

func _fail(message: String) -> void:
	if failures.size() < 100:
		failures.append(message)

func _finish() -> void:
	if failures.is_empty():
		print("[STRESS SUMMARY] %d generated, 0 failed, %d seeds/template/tier" % [generated_count, seeds_per_tier])
		quit(0)
		return
	for failure: String in failures:
		print("[STRESS FAILURE] %s" % failure)
	push_error("Scene Investigation stress test failed: %d recorded failures" % failures.size())
	quit(1)
