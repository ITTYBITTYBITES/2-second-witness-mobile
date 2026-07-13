extends SceneTree

const ROUNDS: int = 20

var failures: Array[String] = []
var passes: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if condition:
		passes += 1
		print("[VARIETY PASS] %s" % message)
	else:
		failures.append(message)
		push_error("[VARIETY FAIL] %s" % message)

func _run() -> void:
	var save_service: Node = root.get_node("SaveService")
	var profile: Node = root.get_node("ProfileService")
	var fixture_registry: Node = root.get_node("ChallengeRegistry")
	var family_registry: Node = root.get_node("ChallengeFamilyRegistry")
	var progress_service: Node = root.get_node("PlayerProgressService")
	var recommendation_service: Node = root.get_node("RecommendationService")
	var result_service: Node = root.get_node("ResultService")
	var runtime: Node = root.get_node("ChallengeSessionService")
	var navigation: Node = root.get_node("NavigationService")

	save_service.call("initialize")
	profile.call("initialize")
	fixture_registry.call("initialize")
	family_registry.call("initialize")
	progress_service.call("initialize")
	recommendation_service.call("initialize")
	result_service.call("initialize")
	runtime.call("initialize")
	navigation.call("initialize")
	await process_frame

	var signatures: Dictionary = {}
	var template_counts: Dictionary = {}
	var next_template := "office_v1"
	for round_index: int in range(ROUNDS):
		var seed_value := 900000 + round_index
		var started: bool = runtime.call("start_family_session", "scene_investigation", next_template, "variety_test", seed_value)
		if not started:
			failures.append("Round %d failed to start" % round_index)
			continue
		var instance: ChallengeInstance = runtime.call("get_active_instance")
		var signature := str(instance.metadata.get("scene_signature", ""))
		if signatures.has(signature):
			failures.append("Round %d repeated a scene signature" % round_index)
		signatures[signature] = true
		template_counts[instance.template_id] = int(template_counts.get(instance.template_id, 0)) + 1
		var response: Variant = instance.correct_answer if round_index % 5 != 4 else "__incorrect__"
		var result_data: Dictionary = runtime.call("submit_response", response, 250 + round_index)
		var recommendation: Dictionary = result_data.get("recommendation", {})
		next_template = str(recommendation.get("template_id", "office_v1"))
		runtime.call("return_home")

	_check(signatures.size() == ROUNDS, "Twenty-round session contains no exact repeated scene")
	_check(template_counts.size() == 5, "Recommendation rotates all five production templates")
	var witness: Dictionary = profile.get("profile").get("witness_progress", {})
	var family_progress: Dictionary = (witness.get("families", {}) as Dictionary).get("scene_investigation", {})
	_check(int(family_progress.get("plays", 0)) == ROUNDS, "Witness Progress records all rounds")
	_check((family_progress.get("history", []) as Array).size() == ROUNDS, "Challenge history records all rounds")
	_check(is_equal_approx(float(family_progress.get("accuracy", 0.0)), 0.8), "Accuracy reflects mixed session outcomes")
	_check(int(family_progress.get("progress_points", 0)) > 0, "Session earns Witness Progress")
	_check(float(family_progress.get("mastery", 0.0)) > 0.0, "Session advances Scene Investigation Mastery")
	_check(not runtime.call("has_active_session"), "Session leaves no active runtime state")

	var module: ChallengeFamilyModule = family_registry.call("get_module", "scene_investigation")
	var duplicate_template := module.get_template("office_v1")
	var current_state: Dictionary = progress_service.call("get_player_state")
	var duplicate_difficulty := module.get_difficulty_policy().resolve_difficulty(current_state, module.get_family(), duplicate_template)
	var duplicate_exposure := module.get_exposure_policy().resolve_exposure(duplicate_template, duplicate_difficulty, current_state)
	var duplicate_candidate := module.get_generator().generate(duplicate_template, duplicate_difficulty, duplicate_exposure, 990000)
	var recent_signatures: Array = family_progress.get("recent_signatures", [])
	recent_signatures.append(str(duplicate_candidate.metadata.get("scene_signature", "")))
	family_progress["recent_signatures"] = recent_signatures
	(witness.get("families", {}) as Dictionary)["scene_investigation"] = family_progress
	profile.get("profile")["witness_progress"] = witness
	profile.call("save")
	var duplicate_started: bool = runtime.call("start_family_session", "scene_investigation", "office_v1", "duplicate_check", 990000)
	_check(duplicate_started, "Runtime can recover from a recently used requested scene")
	var duplicate_instance: ChallengeInstance = runtime.call("get_active_instance")
	_check(duplicate_instance.seed != 990000, "Recent scene signature is rejected and regenerated")
	runtime.call("return_home")

	print("[VARIETY SUMMARY] %d passed, %d failed" % [passes, failures.size()])
	for failure: String in failures:
		print("[VARIETY FAILURE] %s" % failure)
	quit(0 if failures.is_empty() else 1)
