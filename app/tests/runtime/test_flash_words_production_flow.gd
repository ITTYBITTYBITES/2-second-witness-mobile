extends SceneTree

var failures: Array[String] = []
var passes: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if condition:
		passes += 1
		print("[FLASH-FLOW PASS] %s" % message)
	else:
		failures.append(message)
		push_error("[FLASH-FLOW FAIL] %s" % message)

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
	var settings: Node = root.get_node("SettingsService")
	var audio: Node = root.get_node("AudioService")
	var family_registry: Node = root.get_node("ChallengeFamilyRegistry")
	var shell_scene: PackedScene = load("res://src/ui/shell/AppShell.tscn")
	var shell: Node = shell_scene.instantiate()
	shell.name = "AppShell"
	root.add_child(shell)
	await _wait_frames(5)

	var preferences: Dictionary = profile.get("profile").get("preferences", {})
	preferences["privacy_acknowledged"] = true
	preferences["onboarding_completed"] = true
	preferences["family_tutorial_versions"] = {"scene_investigation": "2"}
	profile.get("profile")["preferences"] = preferences
	profile.call("save")
	settings.call("set_value", "privacy_acknowledged", true)
	_screen(shell).call("_navigate_next")
	_check(await _wait_route(navigation, "home"), "Returning player reaches Home")

	navigation.call("navigate_to", "experiences")
	_check(await _wait_route(navigation, "experiences"), "Challenge Library opens")
	await _wait_frames(5)
	var library: Control = _screen(shell)
	_check(library.get_node("MainMargin/Scroll/Content/ChallengeList").get_child_count() == (family_registry.call("get_visible_family_ids") as Array).size(), "Challenge Library lists all production Challenge Types")
	var tutorial_buttons: Dictionary = library.get("_tutorial_buttons")
	_check(tutorial_buttons.has("scene_investigation") and tutorial_buttons.has("flash_words"), "Tutorial replay actions are generated for both families")

	_check(runtime.call("start_template_session", "single_word_v1", "challenge_library", 121212), "Flash Words launch request is accepted")
	_check(await _wait_route(navigation, "tutorial"), "First Flash Words visit routes to its family tutorial")
	await _wait_frames(5)
	var host: Control = _screen(shell)
	_check(str(host.get("_family_id")) == "flash_words", "Generic tutorial host selects Flash Words")
	var tutorial: Control = host.get("_tutorial_instance") as Control
	_check(tutorial != null and tutorial.name == "FlashWordsTutorial", "Flash Words tutorial scene is loaded")
	if tutorial:
		tutorial.call("_finish", false)
	_check(await _wait_route(navigation, "observation"), "Flash Words tutorial launches practice")
	await _wait_frames(5)
	var snapshot: Dictionary = runtime.call("get_active_session_snapshot")
	_check(snapshot.get("family_id", "") == "flash_words", "Flash Words family is active")
	_check(snapshot.get("template_id", "") == "single_word_v1", "Practice uses Single Word Recognition")
	var instance: Dictionary = snapshot.get("instance", {})
	var scene: Dictionary = instance.get("generated_scene", {})
	_check((scene.get("words", []) as Array).size() == 1, "Single Word instance resolves one presented word")
	_check(str(scene.get("renderer_script", "")).ends_with("FlashWordsSceneView.gd"), "Flash Words supplies its family renderer")

	var observation: Control = _screen(shell)
	observation.set("_duration", 0.05)
	_check(await _wait_route(navigation, "memory_question"), "Word flash advances to shared Recall")
	await _wait_frames(5)
	var recall: Control = _screen(shell)
	var challenge_data: Dictionary = recall.get("_challenge_data")
	var correct := str(challenge_data.get("correct_answer", ""))
	var correct_button: Button = null
	for child: Node in recall.get_node("MainMargin/Content/OptionsContainer").get_children():
		if child is Button and str((child as Button).text) == correct:
			correct_button = child as Button
	_check(correct_button != null, "Recall contains exactly one correct word option")
	if correct_button:
		recall.call("_on_option_selected", correct, correct_button)
	_check(await _wait_route(navigation, "result"), "Flash response reaches shared Result")
	await _wait_frames(5)
	var result_screen: Control = _screen(shell)
	_check((result_screen.get("_reveal_view") as Control) != null, "Result loads Flash Words comparison renderer")
	var result: ChallengeResult = runtime.call("get_active_result")
	_check(result.family_id == "flash_words" and result.outcome == "correct", "Family-owned scoring produces correct result")
	_check(result.explanation.contains("You selected") and result.explanation.contains("correct response"), "Result explains selected and correct words")
	var witness: Dictionary = profile.get("profile").get("witness_progress", {})
	var flash_progress: Dictionary = (witness.get("families", {}) as Dictionary).get("flash_words", {})
	_check(int(flash_progress.get("plays", 0)) == 1, "Flash Words Witness Progress is recorded")
	_check(float(flash_progress.get("mastery", 0.0)) > 0.0, "Flash Words Mastery increases")
	_check(result.recommendation.get("template_id", "") == "word_pair_order_v1", "Recommendation advances to Word Pair Order")

	result_screen.call("_on_continue")
	_check(await _wait_route(navigation, "observation"), "Continue launches next Flash Words template")
	await _wait_frames(5)
	_check(runtime.call("get_active_session_snapshot").get("template_id", "") == "word_pair_order_v1", "Pair Order launches without Engine changes")
	runtime.call("return_home")

	audio.call("stop_all")
	OS.delay_msec(400)
	shell.queue_free()
	await _wait_frames(30)
	print("[FLASH-FLOW SUMMARY] %d passed, %d failed" % [passes, failures.size()])
	for failure: String in failures:
		print("[FLASH-FLOW FAILURE] %s" % failure)
	quit(0 if failures.is_empty() else 1)
