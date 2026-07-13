extends SceneTree

const ROUNDS: int = 20

var failures: Array[String] = []
var passes: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if condition:
		passes += 1
		print("[FLASH-VARIETY PASS] %s" % message)
	else:
		failures.append(message)
		push_error("[FLASH-VARIETY FAIL] %s" % message)

func _run() -> void:
	var save_service: Node = root.get_node("SaveService")
	var profile: Node = root.get_node("ProfileService")
	var settings: Node = root.get_node("SettingsService")
	var fixture_registry: Node = root.get_node("ChallengeRegistry")
	var family_registry: Node = root.get_node("ChallengeFamilyRegistry")
	var progress_service: Node = root.get_node("PlayerProgressService")
	var recommendation_service: Node = root.get_node("RecommendationService")
	var result_service: Node = root.get_node("ResultService")
	var runtime: Node = root.get_node("ChallengeSessionService")
	var navigation: Node = root.get_node("NavigationService")
	save_service.call("initialize")
	profile.call("initialize")
	settings.call("initialize")
	fixture_registry.call("initialize")
	family_registry.call("initialize")
	progress_service.call("initialize")
	recommendation_service.call("initialize")
	result_service.call("initialize")
	runtime.call("initialize")
	navigation.call("initialize")
	await process_frame

	var signatures: Dictionary = {}
	var templates: Dictionary = {}
	var recent_words: Array[String] = []
	var next_template := "single_word_v1"
	for round_index: int in range(ROUNDS):
		var started: bool = runtime.call("start_family_session", "flash_words", next_template, "flash_variety", 700000 + round_index)
		if not started:
			failures.append("Round %d failed to start" % round_index)
			continue
		var instance: ChallengeInstance = runtime.call("get_active_instance")
		var signature := str(instance.metadata.get("scene_signature", ""))
		if signatures.has(signature):
			failures.append("Round %d repeated a recent signature" % round_index)
		signatures[signature] = true
		templates[instance.template_id] = true
		var words_value: Variant = instance.metadata.get("presented_words", [])
		if words_value is Array:
			for word_value: Variant in words_value:
				var word := str(word_value)
				if recent_words.has(word):
					failures.append("Round %d repeated recent word %s" % [round_index, word])
				recent_words.append(word)
		while recent_words.size() > 24:
			recent_words.pop_front()
		var response: Variant = instance.correct_answer if round_index % 5 != 4 else "__WRONG__"
		var result_data: Dictionary = runtime.call("submit_response", response, 300 + round_index)
		next_template = str((result_data.get("recommendation", {}) as Dictionary).get("template_id", "single_word_v1"))
		runtime.call("return_home")

	_check(signatures.size() == ROUNDS, "Twenty-round Flash Words session has no exact repeated instance")
	_check(templates.size() == 4, "Recommendations rotate all four Flash Words templates")
	var witness: Dictionary = profile.get("profile").get("witness_progress", {})
	var progress: Dictionary = (witness.get("families", {}) as Dictionary).get("flash_words", {})
	_check(int(progress.get("plays", 0)) == ROUNDS, "Flash Words progress records all rounds")
	_check(is_equal_approx(float(progress.get("accuracy", 0.0)), 0.8), "Flash Words accuracy reflects mixed outcomes")
	_check(float(progress.get("mastery", 0.0)) > 0.0, "Flash Words Mastery advances")
	_check((progress.get("history", []) as Array).size() == ROUNDS, "Flash Words challenge history is retained")
	_check(not runtime.call("has_active_session"), "Session leaves no active runtime state")

	print("[FLASH-VARIETY SUMMARY] %d passed, %d failed" % [passes, failures.size()])
	for failure: String in failures:
		print("[FLASH-VARIETY FAILURE] %s" % failure)
	quit(0 if failures.is_empty() else 1)
