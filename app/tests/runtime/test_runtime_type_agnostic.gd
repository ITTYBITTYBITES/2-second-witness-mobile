extends SceneTree

const SyntheticFamilyScript := preload("res://tests/runtime/fixtures/SyntheticChallengeFamily.gd")

var failures: Array[String] = []
var passes: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if condition:
		passes += 1
		print("[TYPE-AGNOSTIC PASS] %s" % message)
	else:
		failures.append(message)
		push_error("[TYPE-AGNOSTIC FAIL] %s" % message)

func _run() -> void:
	var save_service: Node = root.get_node("SaveService")
	var profile_service: Node = root.get_node("ProfileService")
	var settings_service: Node = root.get_node("SettingsService")
	var fixture_registry: Node = root.get_node("ChallengeRegistry")
	var family_registry: Node = root.get_node("ChallengeFamilyRegistry")
	var progress_service: Node = root.get_node("PlayerProgressService")
	var recommendation_service: Node = root.get_node("RecommendationService")
	var result_service: Node = root.get_node("ResultService")
	var runtime: Node = root.get_node("ChallengeSessionService")
	var navigation: Node = root.get_node("NavigationService")
	var app_state: Node = root.get_node("AppState")

	save_service.call("initialize")
	profile_service.call("initialize")
	settings_service.call("initialize")
	fixture_registry.call("initialize")
	family_registry.call("initialize")
	progress_service.call("initialize")
	recommendation_service.call("initialize")
	result_service.call("initialize")
	runtime.call("initialize")
	navigation.call("initialize")
	await process_frame

	_verify_synthetic_success(family_registry, runtime, navigation, profile_service)
	_verify_retry_then_accept(family_registry, runtime)
	_verify_fallback(family_registry, runtime)
	_verify_failure_has_no_side_effects(family_registry, runtime, navigation, profile_service, app_state)
	_verify_duplicate_registration_is_rejected(family_registry)
	_verify_invalid_contract_is_rejected(family_registry)

	for family_id: String in ["synthetic_accept", "synthetic_retry", "synthetic_fallback", "synthetic_failure"]:
		family_registry.call("unregister_family", family_id)

	print("[TYPE-AGNOSTIC SUMMARY] %d passed, %d failed" % [passes, failures.size()])
	for failure: String in failures:
		print("[TYPE-AGNOSTIC FAILURE] %s" % failure)
	quit(0 if failures.is_empty() else 1)

func _verify_synthetic_success(
	family_registry: Node,
	runtime: Node,
	navigation: Node,
	profile_service: Node
) -> void:
	var module: ChallengeFamilyModule = SyntheticFamilyScript.new("synthetic_accept", "accept", 1, true)
	_check(family_registry.call("register_module", module, "test.synthetic_accept"), "Synthetic non-visual family registers through public API")
	_check(runtime.call("start_family_session", "synthetic_accept", "", "gate2_synthetic", 100), "Synthetic family starts without runtime changes")
	var snapshot: Dictionary = runtime.call("get_active_session_snapshot")
	var instance: Dictionary = snapshot.get("instance", {})
	_check((instance.get("generated_scene", {}) as Dictionary).get("mode", "") == "synthetic_non_visual", "Runtime accepts a non-visual presentation mode")
	_check(navigation.get("current_route") == "observation", "Runtime follows the family PresentationProfile")
	_check(runtime.call("advance_to_response"), "Synthetic session advances through profile response route")
	_check(navigation.get("current_route") == "memory_question", "Response route is selected without a family branch")
	var result_data: Dictionary = runtime.call("submit_response", "B", 25)
	_check(result_data.get("outcome", "") == "correct", "Standard ResultService scores synthetic response")
	_check((result_data.get("recommendation", {}) as Dictionary).get("family_id", "") == "synthetic_accept", "Recommendation remains type-agnostic")
	var repeated_result: Dictionary = runtime.call("submit_response", "A", 99)
	_check(repeated_result == result_data, "Repeated response returns the existing immutable result")
	var repeated_progress: Dictionary = profile_service.call("get_experience_progress", "synthetic_accept")
	_check(int(repeated_progress.get("played", 0)) == 1, "Repeated response does not write progress twice")
	_check(runtime.call("present_result"), "Synthetic result uses profile result route")
	_check(navigation.get("current_route") == "result", "Result route is selected from PresentationProfile")
	var progress: Dictionary = profile_service.call("get_experience_progress", "synthetic_accept")
	_check(int(progress.get("played", 0)) == 1, "Synthetic result persists through PlayerProgressService")
	_check(runtime.call("return_home"), "Synthetic session returns Home")

func _verify_retry_then_accept(family_registry: Node, runtime: Node) -> void:
	var module: ChallengeFamilyModule = SyntheticFamilyScript.new("synthetic_retry", "retry", 3, true)
	_check(family_registry.call("register_module", module, "test.synthetic_retry"), "Retry family registers")
	_check(runtime.call("start_family_session", "synthetic_retry", "", "gate2_retry", 200), "Runtime accepts a valid third candidate")
	_check(int(module.call("get_generator_call_count")) == 3, "Runtime performs bounded retries before acceptance")
	var instance: ChallengeInstance = runtime.call("get_active_instance")
	_check(instance.seed == 202, "Each retry advances the deterministic seed")
	runtime.call("return_home")

func _verify_fallback(family_registry: Node, runtime: Node) -> void:
	var module: ChallengeFamilyModule = SyntheticFamilyScript.new("synthetic_fallback", "always_invalid", 1, true)
	_check(family_registry.call("register_module", module, "test.synthetic_fallback"), "Fallback family registers")
	_check(runtime.call("start_family_session", "synthetic_fallback", "", "gate2_fallback", 300), "Known-valid fallback starts after rejected candidates")
	_check(int(module.call("get_generator_call_count")) == 3, "Runtime stops generation at configured attempt limit")
	var instance: ChallengeInstance = runtime.call("get_active_instance")
	_check(bool(instance.metadata.get("synthetic_valid", false)), "Fallback instance is validated before presentation")
	runtime.call("return_home")

func _verify_failure_has_no_side_effects(
	family_registry: Node,
	runtime: Node,
	navigation: Node,
	profile_service: Node,
	app_state: Node
) -> void:
	var module: ChallengeFamilyModule = SyntheticFamilyScript.new("synthetic_failure", "always_invalid", 1, false)
	_check(family_registry.call("register_module", module, "test.synthetic_failure"), "Failure family registers")
	navigation.call("navigate_to", "home")
	var route_before: String = str(navigation.get("current_route"))
	var stats_before: Dictionary = profile_service.call("get_stats").duplicate(true)
	var started: bool = runtime.call("start_family_session", "synthetic_failure", "", "gate2_failure", 400)
	_check(not started, "Runtime reports failure when candidates and fallback are invalid")
	_check(not runtime.call("has_active_session"), "Failed generation leaves no active session")
	_check(str(navigation.get("current_route")) == route_before, "Failed generation does not navigate")
	_check(profile_service.call("get_stats") == stats_before, "Failed generation does not update player progress")
	_check(not bool(app_state.call("get_transient", "challenge_runtime_active", false)), "Failed generation leaves no runtime transient state")

func _verify_duplicate_registration_is_rejected(family_registry: Node) -> void:
	var duplicate: ChallengeFamilyModule = SyntheticFamilyScript.new("synthetic_accept", "accept", 1, true)
	_check(not family_registry.call("register_module", duplicate, "test.duplicate"), "Registry rejects duplicate family IDs without replacement")

func _verify_invalid_contract_is_rejected(family_registry: Node) -> void:
	var invalid: ChallengeFamilyModule = SyntheticFamilyScript.new("synthetic_invalid", "accept", 1, true)
	invalid.get_family().presentation_profile_id = "mismatched.presentation"
	_check(not family_registry.call("register_module", invalid, "test.invalid_contract"), "Registry rejects inconsistent family contracts")
	_check(not family_registry.call("has_family", "synthetic_invalid"), "Rejected family is not partially registered")
