extends SceneTree

var failures: Array[String] = []
var passes: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if condition:
		passes += 1
		print("[TUTORIAL PASS] %s" % message)
	else:
		failures.append(message)
		push_error("[TUTORIAL FAIL] %s" % message)

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
	var audio_service: Node = root.get_node("AudioService")
	var shell_scene: PackedScene = load("res://src/ui/shell/AppShell.tscn")
	var shell: Node = shell_scene.instantiate()
	shell.name = "AppShell"
	root.add_child(shell)
	await _wait_frames(5)
	_screen(shell).call("_navigate_next")
	_check(await _wait_route(navigation, "title_splash"), "Fresh launch reaches Title")
	await _wait_frames(100)
	var title: Control = _screen(shell)
	var dialog: Control = title.get("_privacy_dialog") as Control
	if dialog:
		dialog.call("_on_accept")
	_check(await _wait_route(navigation, "tutorial"), "First visit opens Scene Investigation tutorial")
	await _wait_frames(5)
	var tutorial_host: Control = _screen(shell)
	var tutorial: Control = tutorial_host.get("_tutorial_instance") as Control
	_check(tutorial != null, "Generic host loads family tutorial scene")
	_check((tutorial.get("_steps") as Array).size() == 5, "Tutorial has five interactive stages")
	var demo: ChallengeInstance = tutorial.get("_demo_instance")
	_check(demo != null and demo.template_id == "office_v1", "Tutorial uses a generated Office demonstration")

	tutorial.call("_on_next_pressed")
	await _wait_frames(30)
	_check(int(tutorial.get("_current_step")) == 1, "Brief advances to untimed observation")
	_check((tutorial.get("_demo_host") as Control).visible, "Observation stage displays generated scene")

	tutorial.call("_on_next_pressed")
	await _wait_frames(30)
	_check(int(tutorial.get("_current_step")) == 2, "Observation advances to guided recall")
	_check((tutorial.get("_answer_container") as Control).visible, "Guided recall displays answer options")

	tutorial.call("_on_demo_answer", str(demo.correct_answer))
	await _wait_frames(3)
	_check(int(tutorial.get("_current_step")) == 3, "Answer advances to evidence reveal")
	_check((tutorial.get("_demo_host") as Control).visible, "Reveal restores generated scene")

	tutorial.call("_on_next_pressed")
	await _wait_frames(30)
	_check(int(tutorial.get("_current_step")) == 4, "Reveal advances to practice brief")
	tutorial.call("_on_next_pressed")
	_check(await _wait_route(navigation, "observation"), "Tutorial completion launches production practice")
	await _wait_frames(5)
	var snapshot: Dictionary = runtime.call("get_active_session_snapshot")
	_check(snapshot.get("template_id", "") == "office_v1", "Practice uses production Office template")
	var prefs: Dictionary = profile.get("profile").get("preferences", {})
	var versions: Dictionary = prefs.get("family_tutorial_versions", {})
	_check(versions.get("scene_investigation", "") == "2", "Tutorial completion persists family version")

	runtime.call("return_home")
	navigation.call("navigate_to", "experiences")
	_check(await _wait_route(navigation, "experiences"), "Challenge Library opens")
	await _wait_frames(5)
	var library: Control = _screen(shell)
	var tutorial_buttons: Dictionary = library.get("_tutorial_buttons")
	var replay_button := tutorial_buttons.get("scene_investigation") as Button
	_check(replay_button != null, "Challenge Library builds family tutorial replay action")
	if replay_button:
		replay_button.emit_signal("pressed")
	_check(await _wait_route(navigation, "tutorial"), "Replay button reopens tutorial")
	audio_service.call("stop_all")
	OS.delay_msec(400)
	shell.queue_free()
	await _wait_frames(30)

	print("[TUTORIAL SUMMARY] %d passed, %d failed" % [passes, failures.size()])
	for failure: String in failures:
		print("[TUTORIAL FAILURE] %s" % failure)
	quit(0 if failures.is_empty() else 1)
