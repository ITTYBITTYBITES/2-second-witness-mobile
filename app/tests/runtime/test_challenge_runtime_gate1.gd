extends SceneTree

var failures: Array[String] = []
var passes: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if condition:
		passes += 1
		print("[GATE1 PASS] %s" % message)
	else:
		failures.append(message)
		push_error("[GATE1 FAIL] %s" % message)

func _wait_frames(count: int) -> void:
	for _i: int in range(count):
		await process_frame

func _wait_route(navigation: Node, expected: String, max_frames: int = 360) -> bool:
	for _i: int in range(max_frames):
		if str(navigation.get("current_route")) == expected:
			return true
		await process_frame
	return false

func _screen(shell: Node) -> Control:
	return shell.get("_current_screen") as Control

func _run() -> void:
	var navigation: Node = root.get_node("NavigationService")
	var profile: Node = root.get_node("ProfileService")
	var settings: Node = root.get_node("SettingsService")
	var runtime: Node = root.get_node("ChallengeSessionService")
	var audio_service: Node = root.get_node("AudioService")
	var family_registry: Node = root.get_node("ChallengeFamilyRegistry")
	var shell_scene: PackedScene = load("res://src/ui/shell/AppShell.tscn")
	var shell: Node = shell_scene.instantiate()
	shell.name = "AppShell"
	root.add_child(shell)
	await _wait_frames(5)

	# Configure a returning-player state so the real title flow reaches Home.
	var prefs: Dictionary = profile.get("profile").get("preferences", {})
	prefs["privacy_acknowledged"] = true
	prefs["tutorial_seen"] = true
	prefs["onboarding_completed"] = true
	prefs["family_tutorial_versions"] = {"scene_investigation": "2"}
	profile.get("profile")["preferences"] = prefs
	profile.call("save")
	settings.call("set_value", "privacy_acknowledged", true)
	settings.call("set_value", "show_tutorials", false)

	_screen(shell).call("_navigate_next")
	_check(await _wait_route(navigation, "title_splash"), "Publisher reaches Title")
	_check(await _wait_route(navigation, "home", 360), "Returning-player Title reaches Home")
	await _wait_frames(5)

	_check(family_registry.call("get_family_ids") == ["scene_investigation", "flash_words", "spot_the_difference", "object_recall", "pattern_recall", "scene_investigation_fixtures"], "Family registry loads five production families and regression fixtures")
	var module: RefCounted = family_registry.call("get_module", "scene_investigation")
	_check(module != null and module.call("get_templates").size() >= 3, "Production family preserves Office, Kitchen, and Workshop")
	var fixture_module: RefCounted = family_registry.call("get_module", "scene_investigation_fixtures")
	_check(fixture_module != null and fixture_module.call("get_templates").size() == 5, "Regression family preserves five deterministic fixtures")

	# Exercise the actual Home Play Now action.
	_screen(shell).call("_on_quick_play")
	_check(await _wait_route(navigation, "observation"), "Home Play Now launches the shared Challenge Runtime")
	await _wait_frames(5)
	_check(runtime.call("has_active_session"), "Challenge session is active")
	var snapshot: Dictionary = runtime.call("get_active_session_snapshot")
	_check(snapshot.get("family_id", "") == "scene_investigation", "Runtime resolves ChallengeFamily")
	_check(snapshot.get("template_id", "") == "office_v1", "Runtime resolves Office production template")
	var instance: Dictionary = snapshot.get("instance", {})
	_check(instance.get("seed", null) != null, "Runtime records a reproduction seed")
	_check(float(instance.get("exposure_duration_sec", 0.0)) >= 5.0 and float(instance.get("exposure_duration_sec", 0.0)) <= 6.0, "Exposure Policy resolves approved Beginner timing")
	_check((instance.get("validation_metadata", {}) as Dictionary).get("is_valid", false), "Validator accepts the complete ChallengeInstance")

	var observation: Control = _screen(shell)
	observation.set("_duration", 0.05)
	_check(await _wait_route(navigation, "memory_question"), "Presentation advances through runtime response route")
	await _wait_frames(5)
	var recall: Control = _screen(shell)
	var challenge_data: Dictionary = recall.get("_challenge_data")
	var correct: String = str(challenge_data.get("correct_answer", ""))
	var correct_button: Button = null
	var options: Node = recall.get_node("MainMargin/Content/OptionsContainer")
	for child: Node in options.get_children():
		if child is Button and str((child as Button).text) == correct:
			correct_button = child as Button
	_check(correct_button != null, "Resolved answer options reach presentation")
	if correct_button:
		recall.call("_on_option_selected", correct, correct_button)

	_check(await _wait_route(navigation, "result"), "Player response produces and presents Result Contract")
	await _wait_frames(5)
	var result_screen: Control = _screen(shell)
	_check(str(result_screen.get_node("MainMargin/Content/ResultCard/Margin/VBox/Title").text) == "CORRECT!", "Result presentation consumes canonical result data")
	var progress: Dictionary = profile.call("get_experience_progress", "scene_investigation")
	_check(int(progress.get("played", 0)) == 1, "PlayerProgressService records the result exactly once")
	var active_result: RefCounted = runtime.call("get_active_result")
	var result_data: Dictionary = active_result.call("to_dictionary") if active_result else {}
	_check((result_data.get("recommendation", {}) as Dictionary).get("template_id", "") == "kitchen_v1", "RecommendationService selects the next template")

	result_screen.call("_on_menu")
	_check(await _wait_route(navigation, "home"), "Runtime returns the completed session to Home")
	var expected_trace: Array[String] = [
		"play_now",
		"challenge_session",
		"challenge_family",
		"challenge_template",
		"difficulty_policy",
		"exposure_policy",
		"generator",
		"validator",
		"challenge_instance",
		"presentation",
		"player_response",
		"result_contract",
		"player_progress",
		"recommendation",
		"home"
	]
	_check(runtime.call("get_pipeline_trace") == expected_trace, "Runtime executes the complete gated pipeline without shortcuts")

	# Prove fixture reproducibility through the runtime API.
	_check(runtime.call("start_template_session", "office_v1", "determinism_check", 4242), "Runtime accepts an explicit seed")
	var first: Dictionary = runtime.call("get_active_session_snapshot").get("instance", {})
	runtime.call("return_home")
	_check(runtime.call("start_template_session", "office_v1", "determinism_check", 4242), "Runtime can replay the same fixture seed")
	var second: Dictionary = runtime.call("get_active_session_snapshot").get("instance", {})
	_check(first == second, "Same versions and seed reproduce the same ChallengeInstance")
	runtime.call("return_home")
	audio_service.call("stop_all")
	OS.delay_msec(400)
	shell.queue_free()
	# Let short SFX playback resources finish before the headless process exits.
	await _wait_frames(60)

	print("[GATE1 SUMMARY] %d passed, %d failed" % [passes, failures.size()])
	for failure: String in failures:
		print("[GATE1 FAILURE] %s" % failure)
	quit(0 if failures.is_empty() else 1)
