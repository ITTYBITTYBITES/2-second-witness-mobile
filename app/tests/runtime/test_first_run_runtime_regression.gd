extends SceneTree

var failures: Array[String] = []
var passes: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if condition:
		passes += 1
		print("[FIRST-RUN PASS] %s" % message)
	else:
		failures.append(message)
		push_error("[FIRST-RUN FAIL] %s" % message)

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
	var runtime: Node = root.get_node("ChallengeSessionService")
	var profile: Node = root.get_node("ProfileService")
	var audio_service: Node = root.get_node("AudioService")
	var shell_scene: PackedScene = load("res://src/ui/shell/AppShell.tscn")
	var shell: Node = shell_scene.instantiate()
	shell.name = "AppShell"
	root.add_child(shell)
	await _wait_frames(5)

	_check(str(navigation.get("current_route")) == "publisher_splash", "Fresh launch starts at Publisher")
	_screen(shell).call("_navigate_next")
	_check(await _wait_route(navigation, "title_splash"), "Publisher reaches Title")
	await _wait_frames(100)
	var title: Control = _screen(shell)
	var dialog: Control = title.get("_privacy_dialog") as Control
	_check(dialog != null and dialog.visible, "First launch presents privacy acknowledgment")
	if dialog:
		dialog.call("_on_accept")
	_check(await _wait_route(navigation, "tutorial"), "Privacy acceptance reaches Tutorial")
	await _wait_frames(5)
	var tutorial_host: Control = _screen(shell)
	var family_tutorial: Control = tutorial_host.get("_tutorial_instance") as Control
	_check(family_tutorial != null, "Generic host loads the recommended family tutorial")
	if family_tutorial:
		family_tutorial.call("_finish_tutorial", false)
	_check(await _wait_route(navigation, "observation"), "Family tutorial launches through shared runtime")
	await _wait_frames(5)
	_check(runtime.call("has_active_session"), "First-run challenge has an active runtime session")
	var snapshot: Dictionary = runtime.call("get_active_session_snapshot")
	_check(snapshot.get("source", "") == "tutorial", "Runtime records Tutorial launch source")
	_check(snapshot.get("template_id", "") == "office_v1", "Tutorial launches the Office production template")

	var observation: Control = _screen(shell)
	observation.set("_duration", 0.05)
	_check(await _wait_route(navigation, "memory_question"), "Observation reaches Recall through runtime")
	await _wait_frames(5)
	var recall: Control = _screen(shell)
	var data: Dictionary = recall.get("_challenge_data")
	var correct := str(data.get("correct_answer", ""))
	var correct_button: Button = null
	for child: Node in recall.get_node("MainMargin/Content/OptionsContainer").get_children():
		if child is Button and str((child as Button).text) == correct:
			correct_button = child as Button
	_check(correct_button != null, "Recall receives the resolved answer")
	if correct_button:
		recall.call("_on_option_selected", correct, correct_button)
	_check(await _wait_route(navigation, "result"), "Runtime produces Result")
	await _wait_frames(5)
	_screen(shell).call("_on_menu")
	_check(await _wait_route(navigation, "home"), "First result returns Home")
	var progress: Dictionary = profile.call("get_experience_progress", "scene_investigation")
	_check(int(progress.get("played", 0)) == 1, "First result persists exactly once")

	var trace: Array[String] = runtime.call("get_pipeline_trace")
	_check(trace.has("challenge_family") and trace.has("generator") and trace.has("validator"), "First-run path does not bypass runtime contracts")
	_check(trace[-1] == "home", "First-run runtime pipeline completes at Home")
	audio_service.call("stop_all")
	OS.delay_msec(400)
	shell.queue_free()
	await _wait_frames(30)

	print("[FIRST-RUN SUMMARY] %d passed, %d failed" % [passes, failures.size()])
	for failure: String in failures:
		print("[FIRST-RUN FAILURE] %s" % failure)
	quit(0 if failures.is_empty() else 1)
