extends SceneTree

var failures: Array[String] = []
var passes: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if condition:
		passes += 1
		print("[PRODUCTION PASS] %s" % message)
	else:
		failures.append(message)
		push_error("[PRODUCTION FAIL] %s" % message)

func _wait_frames(count: int) -> void:
	for _index: int in range(count):
		await process_frame

func _wait_route(navigation: Node, expected: String, max_frames: int = 360) -> bool:
	for _index: int in range(max_frames):
		if str(navigation.get("current_route")) == expected:
			return true
		await process_frame
	return false

func _screen(shell: Node) -> Control:
	return shell.get("_current_screen") as Control

func _run() -> void:
	var navigation: Node = root.get_node("NavigationService")
	var runtime: Node = root.get_node("ChallengeSessionService")
	var profile: Node = root.get_node("ProfileService")
	var save_service: Node = root.get_node("SaveService")
	var audio_service: Node = root.get_node("AudioService")
	var settings: Node = root.get_node("SettingsService")
	var family_registry: Node = root.get_node("ChallengeFamilyRegistry")
	var shell_scene: PackedScene = load("res://src/ui/shell/AppShell.tscn")
	var shell: Node = shell_scene.instantiate()
	shell.name = "AppShell"
	root.add_child(shell)
	await _wait_frames(5)

	var prefs: Dictionary = profile.get("profile").get("preferences", {})
	prefs["privacy_acknowledged"] = true
	prefs["onboarding_completed"] = true
	prefs["tutorial_seen"] = true
	prefs["family_tutorial_versions"] = {"scene_investigation": "2"}
	profile.get("profile")["preferences"] = prefs
	profile.call("save")
	settings.call("set_value", "privacy_acknowledged", true)

	_screen(shell).call("_navigate_next")
	_check(await _wait_route(navigation, "home"), "Returning player reaches Home")
	await _wait_frames(5)
	_screen(shell).call("_on_quick_play")
	_check(await _wait_route(navigation, "observation"), "Play Now launches production Scene Investigation")
	await _wait_frames(5)
	var snapshot: Dictionary = runtime.call("get_active_session_snapshot")
	_check(snapshot.get("family_id", "") == "scene_investigation", "Production family is active")
	_check(snapshot.get("template_id", "") == "office_v1", "Office is the onboarding production template")
	var instance: Dictionary = snapshot.get("instance", {})
	var scene: Dictionary = instance.get("generated_scene", {})
	_check(str(scene.get("renderer_script", "")).ends_with("SceneInvestigationSceneView.gd"), "Generated scene selects family renderer")
	_check((scene.get("objects", []) as Array).size() >= 8, "Generated Office scene contains resolved object layout")
	_check((_screen(shell).get("_scene_view") as Control) != null, "Observation presents generated vector scene")

	var observation: Control = _screen(shell)
	observation.set("_duration", 0.05)
	_check(await _wait_route(navigation, "memory_question"), "Generated scene advances to Recall")
	await _wait_frames(5)
	var recall: Control = _screen(shell)
	var data: Dictionary = recall.get("_challenge_data")
	var correct := str(data.get("correct_answer", ""))
	var correct_button: Button = null
	for child: Node in recall.get_node("MainMargin/Content/OptionsContainer").get_children():
		if child is Button and str((child as Button).text) == correct:
			correct_button = child as Button
	_check(correct_button != null, "Generated question exposes one correct response")
	if correct_button:
		recall.call("_on_option_selected", correct, correct_button)
	_check(await _wait_route(navigation, "result"), "Production response reaches Result")
	await _wait_frames(5)
	var result_screen: Control = _screen(shell)
	_check((result_screen.get("_reveal_view") as Control) != null, "Result restores generated scene with reveal renderer")
	var result: RefCounted = runtime.call("get_active_result")
	var result_data: Dictionary = result.call("to_dictionary") if result else {}
	_check(int((result_data.get("progress_earned", {}) as Dictionary).get("progress_points", 0)) > 0, "Result awards Witness Progress")
	var witness: Dictionary = profile.get("profile").get("witness_progress", {})
	var family_progress: Dictionary = (witness.get("families", {}) as Dictionary).get("scene_investigation", {})
	_check(int(family_progress.get("plays", 0)) == 1, "Production play is recorded once")
	_check(float(family_progress.get("mastery", 0.0)) > 0.0, "Scene Investigation Mastery increases")
	var persisted_profile: Dictionary = save_service.call("load_profile")
	_check((persisted_profile.get("witness_progress", {}) as Dictionary).has("families"), "Witness Progress persists through SaveService")
	_check((result_data.get("recommendation", {}) as Dictionary).get("template_id", "") == "kitchen_v1", "Recommendation rotates Office to Kitchen")

	result_screen.call("_on_continue")
	_check(await _wait_route(navigation, "observation"), "Next Challenge starts through same runtime")
	await _wait_frames(5)
	var next_snapshot: Dictionary = runtime.call("get_active_session_snapshot")
	_check(next_snapshot.get("template_id", "") == "kitchen_v1", "Continue launches Kitchen template")
	runtime.call("return_home")
	_check(await _wait_route(navigation, "home"), "Production session returns Home")

	navigation.call("navigate_to", "experiences")
	_check(await _wait_route(navigation, "experiences"), "Challenge Library opens")
	await _wait_frames(5)
	var library: Control = _screen(shell)
	var visible_count: int = (family_registry.call("get_visible_family_ids") as Array).size()
	_check(library.get_node("MainMargin/Scroll/Content/ChallengeList").get_child_count() == visible_count, "Challenge Library shows all production types and hides regression fixtures")

	navigation.call("navigate_to", "profile")
	_check(await _wait_route(navigation, "profile"), "Profile opens")
	await _wait_frames(5)
	var profile_screen: Control = _screen(shell)
	_check(profile_screen.get_node("Margin/Scroll/VBox/ExperienceProgress").get_child_count() == visible_count, "Profile shows all player-facing Challenge Types")
	audio_service.call("stop_all")
	OS.delay_msec(400)
	shell.queue_free()
	await _wait_frames(30)

	print("[PRODUCTION SUMMARY] %d passed, %d failed" % [passes, failures.size()])
	for failure: String in failures:
		print("[PRODUCTION FAILURE] %s" % failure)
	quit(0 if failures.is_empty() else 1)
