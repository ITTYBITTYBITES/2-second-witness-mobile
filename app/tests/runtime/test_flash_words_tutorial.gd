extends SceneTree

var failures: Array[String] = []
var passes: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if condition:
		passes += 1
		print("[FLASH-TUTORIAL PASS] %s" % message)
	else:
		failures.append(message)
		push_error("[FLASH-TUTORIAL FAIL] %s" % message)

func _wait_frames(count: int) -> void:
	for _index: int in range(count):
		await process_frame

func _wait_route(navigation: Node, expected: String, max_frames: int = 180) -> bool:
	for _index: int in range(max_frames):
		if str(navigation.get("current_route")) == expected:
			return true
		await process_frame
	return false

func _run() -> void:
	var navigation: Node = root.get_node("NavigationService")
	var runtime: Node = root.get_node("ChallengeSessionService")
	var profile: Node = root.get_node("ProfileService")
	var settings: Node = root.get_node("SettingsService")
	var audio: Node = root.get_node("AudioService")
	var shell_scene: PackedScene = load("res://src/ui/shell/AppShell.tscn")
	var shell: Node = shell_scene.instantiate()
	shell.name = "AppShell"
	root.add_child(shell)
	await _wait_frames(5)

	navigation.call("navigate_to", "tutorial", {"family_id": "flash_words", "replay": true})
	_check(await _wait_route(navigation, "tutorial"), "Generic host opens Flash Words tutorial")
	await _wait_frames(5)
	var host: Control = shell.get("_current_screen") as Control
	var tutorial: Control = host.get("_tutorial_instance") as Control
	_check(tutorial != null, "Family tutorial scene is active")
	_check(int(tutorial.get("_step")) == 0, "Tutorial starts with Flash Words brief")

	tutorial.call("_on_next")
	_check(int(tutorial.get("_step")) == 1 and str((tutorial.get("_word") as Label).text) == "GARDEN", "Tutorial shows untimed demonstration")
	tutorial.call("_on_next")
	_check(int(tutorial.get("_step")) == 2 and (tutorial.get("_answers") as VBoxContainer).get_child_count() == 2, "Tutorial presents guided recognition")
	tutorial.call("_on_demo_answer", "HARDEN")
	_check(int(tutorial.get("_step")) == 3, "Guided response advances to comparison reveal")
	_check(str((tutorial.get("_description") as Label).text).contains("Position 1"), "Reveal identifies exact letter difference")
	tutorial.call("_on_next")
	_check(int(tutorial.get("_step")) == 4 and str((tutorial.get("_word") as Label).text).contains("LIGHT"), "Tutorial demonstrates pair order")
	tutorial.call("_on_next")
	_check(int(tutorial.get("_step")) == 5 and (tutorial.get("_comfort") as CheckButton).visible, "Tutorial explains Reading Comfort Mode")
	(tutorial.get("_comfort") as CheckButton).button_pressed = true
	_check(bool(settings.call("get_value", "reading_comfort_mode", false)), "Reading Comfort Mode persists through SettingsService")
	tutorial.call("_on_next")
	_check(await _wait_route(navigation, "observation"), "Tutorial launches Single Word practice")
	var snapshot: Dictionary = runtime.call("get_active_session_snapshot")
	_check(snapshot.get("template_id", "") == "single_word_v1", "Practice request uses Flash Words template")
	var versions: Dictionary = (profile.get("profile").get("preferences", {}) as Dictionary).get("family_tutorial_versions", {})
	_check(versions.get("flash_words", "") == "1", "Generic host persists Flash Words tutorial version")

	runtime.call("return_home")
	audio.call("stop_all")
	OS.delay_msec(300)
	shell.queue_free()
	await _wait_frames(20)
	print("[FLASH-TUTORIAL SUMMARY] %d passed, %d failed" % [passes, failures.size()])
	for failure: String in failures:
		print("[FLASH-TUTORIAL FAILURE] %s" % failure)
	quit(0 if failures.is_empty() else 1)
