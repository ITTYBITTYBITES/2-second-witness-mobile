extends SceneTree

var failures: Array[String] = []
var passes: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if condition:
		passes += 1
		print("[DIFFICULTY PASS] %s" % message)
	else:
		failures.append(message)
		push_error("[DIFFICULTY FAIL] %s" % message)

func _run() -> void:
	var fixture_registry: Node = root.get_node("ChallengeRegistry")
	var family_registry: Node = root.get_node("ChallengeFamilyRegistry")
	fixture_registry.call("initialize")
	family_registry.call("initialize")
	var module: ChallengeFamilyModule = family_registry.call("get_module", "scene_investigation")
	var family := module.get_family()
	var template := module.get_template("office_v1")
	var difficulty := module.get_difficulty_policy()
	var exposure := module.get_exposure_policy()

	var beginner := difficulty.resolve_difficulty(_state(0, 0.0, 0.0, 0), family, template)
	var standard := difficulty.resolve_difficulty(_state(5, 0.8, 12.0, 0), family, template)
	var advanced := difficulty.resolve_difficulty(_state(12, 0.75, 45.0, 0), family, template)
	var expert := difficulty.resolve_difficulty(_state(24, 0.88, 82.0, 0), family, template)
	_check(beginner.get("label") == "beginner", "New player receives Beginner axes")
	_check(standard.get("label") == "standard", "Familiar player receives Standard axes")
	_check(advanced.get("label") == "advanced", "Established player receives Advanced axes")
	_check(expert.get("label") == "expert", "High mastery receives Expert axes")
	_check((expert.get("axes", {}) as Dictionary).size() >= 7, "Difficulty resolves independent axes rather than one number")

	var struggling := difficulty.resolve_difficulty(_state(24, 0.88, 82.0, 2), family, template)
	_check(struggling.get("label") == "standard", "Two consecutive misses reduce challenge pressure")

	var beginner_time := exposure.resolve_exposure(template, beginner, _state(0, 0.0, 0.0, 0))
	var standard_time := exposure.resolve_exposure(template, standard, _state(5, 0.8, 12.0, 0))
	var advanced_time := exposure.resolve_exposure(template, advanced, _state(12, 0.75, 45.0, 0))
	var expert_time := exposure.resolve_exposure(template, expert, _state(24, 0.88, 82.0, 0))
	_check(beginner_time >= 5.0 and beginner_time <= 6.0, "Beginner exposure stays within 5–6 seconds")
	_check(standard_time >= 3.5 and standard_time <= 5.0, "Standard exposure stays within 3.5–5 seconds")
	_check(advanced_time >= 2.0 and advanced_time <= 3.5, "Advanced exposure stays within 2–3.5 seconds")
	_check(expert_time >= 1.5 and expert_time <= 2.0, "Expert exposure stays within 1.5–2 seconds")

	var comfortable_state := _state(5, 0.8, 12.0, 0)
	comfortable_state["preferences"] = {"comfortable_timing": true}
	var comfortable := exposure.resolve_exposure(template, standard, comfortable_state)
	_check(comfortable > standard_time, "Comfortable Timing extends exposure")
	_check((standard.get("axes", {}) as Dictionary).get("scene_complexity", 0.0) > (beginner.get("axes", {}) as Dictionary).get("scene_complexity", 1.0), "Scene complexity changes independently from exposure")

	print("[DIFFICULTY SUMMARY] %d passed, %d failed" % [passes, failures.size()])
	for failure: String in failures:
		print("[DIFFICULTY FAILURE] %s" % failure)
	quit(0 if failures.is_empty() else 1)

func _state(plays: int, accuracy: float, mastery: float, incorrect_streak: int) -> Dictionary:
	return {
		"witness_progress": {
			"families": {
				"scene_investigation": {
					"plays": plays,
					"accuracy": accuracy,
					"mastery": mastery,
					"incorrect_streak": incorrect_streak
				}
			}
		}
	}
