extends SceneTree

var failures: Array[String] = []
var passes: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if condition:
		passes += 1
		print("[FLASH-POLICY PASS] %s" % message)
	else:
		failures.append(message)
		push_error("[FLASH-POLICY FAIL] %s" % message)

func _run() -> void:
	var fixture_registry: Node = root.get_node("ChallengeRegistry")
	var registry: Node = root.get_node("ChallengeFamilyRegistry")
	var settings: Node = root.get_node("SettingsService")
	fixture_registry.call("initialize")
	settings.call("initialize")
	registry.call("initialize")
	var module: ChallengeFamilyModule = registry.call("get_module", "flash_words")
	var family := module.get_family()
	var difficulty := module.get_difficulty_policy()
	var exposure := module.get_exposure_policy()
	var scoring := module.get_scoring_policy()

	var single := module.get_template("single_word_v1")
	var pair := module.get_template("word_pair_order_v1")
	var stream := module.get_template("word_stream_presence_v1")
	var beginner := difficulty.resolve_difficulty(_state(0, 0.0, 0.0, 0), family, single)
	var standard := difficulty.resolve_difficulty(_state(5, 0.75, 12.0, 0), family, single)
	var advanced := difficulty.resolve_difficulty(_state(12, 0.76, 45.0, 0), family, single)
	var expert := difficulty.resolve_difficulty(_state(24, 0.86, 82.0, 0), family, single)
	_check(beginner.get("label") == "beginner" and expert.get("label") == "expert", "Difficulty tiers resolve from Flash Words progress")
	_check(int((beginner.get("axes", {}) as Dictionary).get("word_length_max", 0)) < int((expert.get("axes", {}) as Dictionary).get("word_length_max", 0)), "Word length scales independently")
	_check(float((beginner.get("axes", {}) as Dictionary).get("similarity", 0.0)) < float((expert.get("axes", {}) as Dictionary).get("similarity", 0.0)), "Distractor similarity scales independently")

	var single_times := [exposure.resolve_exposure(single, beginner, {}), exposure.resolve_exposure(single, standard, {}), exposure.resolve_exposure(single, advanced, {}), exposure.resolve_exposure(single, expert, {})]
	_check(single_times[0] >= 4.5 and single_times[0] <= 5.5, "Single Word Beginner timing is 4.5–5.5 seconds")
	_check(single_times[1] >= 3.0 and single_times[1] <= 4.0, "Single Word Standard timing is 3–4 seconds")
	_check(single_times[2] >= 2.0 and single_times[2] <= 2.8, "Single Word Advanced timing is 2–2.8 seconds")
	_check(single_times[3] >= 1.4 and single_times[3] <= 1.8, "Single Word Expert timing is 1.4–1.8 seconds")

	var pair_beginner := difficulty.resolve_difficulty(_state(0, 0.0, 0.0, 0), family, pair)
	var pair_total := exposure.resolve_exposure(pair, pair_beginner, {})
	_check(float((pair_beginner.get("axes", {}) as Dictionary).get("display_duration", 0.0)) >= 2.5, "Pair Beginner per-word timing is relaxed")
	_check(pair_total > 5.0, "Pair total includes display and interval timing")

	var stream_advanced := difficulty.resolve_difficulty(_state(12, 0.76, 45.0, 0), family, stream)
	var stream_total := exposure.resolve_exposure(stream, stream_advanced, {})
	_check(int((stream_advanced.get("axes", {}) as Dictionary).get("sequence_length", 0)) == 4, "Word Stream resolves sequence length independently")
	_check(stream_total > float((stream_advanced.get("axes", {}) as Dictionary).get("display_duration", 0.0)) * 4.0, "Word Stream total includes inter-word intervals")

	settings.call("set_value", "reading_comfort_mode", true)
	var comfort := difficulty.resolve_difficulty(_state(5, 0.75, 12.0, 0), family, single)
	var comfort_time := exposure.resolve_exposure(single, comfort, {})
	_check(bool((comfort.get("axes", {}) as Dictionary).get("reading_comfort_mode", false)), "Reading Comfort Mode reaches family policy")
	_check(comfort_time > single_times[1], "Reading Comfort Mode extends exposure")

	var generator := module.get_generator()
	var instance := generator.generate(single, standard, single_times[1], 4545)
	var resolved := scoring.calculate_result(instance, "__WRONG__", {})
	var explanation := scoring.explain_outcome(instance, "__WRONG__", resolved)
	_check(str(explanation.get("explanation", "")).contains("You selected"), "Result explanation includes player response")
	_check(str(explanation.get("explanation", "")).contains("correct response"), "Result explanation includes correct response")
	_check(not str((explanation.get("reveal_data", {}) as Dictionary).get("generated_scene", {}).get("difference", "")).is_empty(), "Result contains exact difference data")

	print("[FLASH-POLICY SUMMARY] %d passed, %d failed" % [passes, failures.size()])
	for failure: String in failures:
		print("[FLASH-POLICY FAILURE] %s" % failure)
	quit(0 if failures.is_empty() else 1)

func _state(plays: int, accuracy: float, mastery: float, incorrect_streak: int) -> Dictionary:
	return {"witness_progress": {"families": {"flash_words": {"plays": plays, "accuracy": accuracy, "mastery": mastery, "incorrect_streak": incorrect_streak}}}}
