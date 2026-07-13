extends SceneTree

var failures: Array[String] = []
var passes: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if condition:
		passes += 1
		print("[SCORING PASS] %s" % message)
	else:
		failures.append(message)
		push_error("[SCORING FAIL] %s" % message)

func _run() -> void:
	var fixture_registry: Node = root.get_node("ChallengeRegistry")
	var family_registry: Node = root.get_node("ChallengeFamilyRegistry")
	fixture_registry.call("initialize")
	family_registry.call("initialize")
	var module: ChallengeFamilyModule = family_registry.call("get_module", "scene_investigation")
	var template := module.get_template("office_v1")
	var family := module.get_family()
	var generator := module.get_generator()
	var scoring := module.get_scoring_policy()
	var expected_scores := {"beginner": 827, "standard": 866, "advanced": 904, "expert": 934}

	for tier: String in expected_scores.keys():
		var tier_difficulty := _difficulty(tier)
		var tier_instance := generator.generate(template, tier_difficulty, 5.0, 500 + int(expected_scores[tier]))
		var resolved := scoring.calculate_result(tier_instance, tier_instance.correct_answer, {"reaction_ms": 300})
		_check(bool(resolved.get("accepted", false)), "%s correct response is accepted" % tier)
		_check(scoring.calculate_score(resolved, template) == int(expected_scores[tier]), "%s score uses family policy" % tier)
		var progress := scoring.calculate_progress(resolved, int(expected_scores[tier]), {})
		_check(int(progress.get("progress_points", 0)) == 12, "%s correct response earns Witness Progress" % tier)

	var complex_long := {"accepted": true, "difficulty_axes": _difficulty("expert")["axes"]}
	var simple_short := {"accepted": true, "difficulty_axes": _difficulty("beginner")["axes"]}
	_check(scoring.calculate_score(complex_long, template) > scoring.calculate_score(simple_short, template), "Difficulty scoring follows scene complexity rather than exposure label")

	var difficulty := _difficulty("standard")
	var instance := generator.generate(template, difficulty, 4.25, 777)
	var incorrect := scoring.calculate_result(instance, "__wrong__", {"reaction_ms": 700})
	_check(not bool(incorrect.get("accepted", true)), "Incorrect response is rejected")
	_check(scoring.calculate_score(incorrect, template) == 0, "Incorrect response scores zero")
	_check(int(scoring.calculate_progress(incorrect, 0, {}).get("progress_points", 0)) == 2, "Incorrect response still earns small participation progress")
	var mastery := scoring.calculate_mastery_change(incorrect, 0, {"witness_progress": {"families": {"scene_investigation": {"mastery": 20.0, "plays": 10}}}})
	_check(is_equal_approx(float(mastery.get("new_mastery", 0.0)), 19.75), "Mastery change is bounded")
	var explanation := scoring.explain_outcome(instance, "__wrong__", incorrect)
	_check(not str(explanation.get("where_to_look", "")).is_empty(), "Scoring policy explains where to look")
	_check(not (explanation.get("reveal_data", {}) as Dictionary).get("highlight_ids", []).is_empty(), "Scoring policy supplies reveal evidence")

	# ResultService must execute the family policy instead of applying its own rules.
	var result_service: Node = root.get_node("ResultService")
	result_service.call("initialize")
	var result: ChallengeResult = result_service.call(
		"build_result",
		"scoring_test",
		family,
		template,
		instance,
		scoring,
		{},
		instance.correct_answer,
		250
	)
	_check(result.score == 866 and result.outcome == "correct", "ResultService delegates scoring to family policy")
	_check(result.metadata.get("scoring_policy_version", "") == scoring.get_version(), "Result records scoring policy version")

	print("[SCORING SUMMARY] %d passed, %d failed" % [passes, failures.size()])
	for failure: String in failures:
		print("[SCORING FAILURE] %s" % failure)
	quit(0 if failures.is_empty() else 1)

func _difficulty(tier: String) -> Dictionary:
	var axes := {
		"object_count_min": 8,
		"object_count_max": 10,
		"target_scale": 1.1,
		"scene_complexity": 0.2,
		"similarity": 0.12,
		"question_complexity": 0.2
	}
	match tier:
		"standard":
			axes.merge({"object_count_min": 10, "object_count_max": 13, "target_scale": 1.0, "scene_complexity": 0.45, "similarity": 0.35, "question_complexity": 0.45}, true)
		"advanced":
			axes.merge({"object_count_min": 13, "object_count_max": 16, "target_scale": 0.9, "scene_complexity": 0.68, "similarity": 0.58, "question_complexity": 0.70}, true)
		"expert":
			axes.merge({"object_count_min": 15, "object_count_max": 18, "target_scale": 0.82, "scene_complexity": 0.88, "similarity": 0.78, "question_complexity": 0.90}, true)
	return {"label": tier, "policy_version": "test", "axes": axes}
