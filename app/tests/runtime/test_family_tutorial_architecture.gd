extends SceneTree

const SyntheticFamilyScript := preload("res://tests/runtime/fixtures/SyntheticChallengeFamily.gd")

var failures: Array[String] = []
var passes: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if condition:
		passes += 1
		print("[FAMILY-TUTORIAL PASS] %s" % message)
	else:
		failures.append(message)
		push_error("[FAMILY-TUTORIAL FAIL] %s" % message)

func _wait_frames(count: int) -> void:
	for _index: int in range(count):
		await process_frame

func _wait_route(navigation: Node, expected: String, max_frames: int = 180) -> bool:
	for _index: int in range(max_frames):
		if str(navigation.get("current_route")) == expected:
			return true
		await process_frame
	return false

func _screen(shell: Node) -> Control:
	return shell.get("_current_screen") as Control

func _run() -> void:
	var navigation: Node = root.get_node("NavigationService")
	var registry: Node = root.get_node("ChallengeFamilyRegistry")
	var runtime: Node = root.get_node("ChallengeSessionService")
	var profile: Node = root.get_node("ProfileService")
	var audio: Node = root.get_node("AudioService")
	var shell_scene: PackedScene = load("res://src/ui/shell/AppShell.tscn")
	var shell: Node = shell_scene.instantiate()
	shell.name = "AppShell"
	root.add_child(shell)
	await _wait_frames(5)

	var first_family: ChallengeFamilyModule = SyntheticFamilyScript.new("synthetic_tutorial_one", "accept", 1, true)
	_check(registry.call("register_module", first_family, "test.tutorial.one"), "Synthetic family with TutorialProfile registers")
	_check(runtime.call("start_template_session", "synthetic_tutorial_one_template", "challenge_library"), "Runtime accepts first family launch request")
	_check(await _wait_route(navigation, "tutorial"), "Missing family tutorial routes through generic host")
	await _wait_frames(5)
	var host: Control = _screen(shell)
	_check(str(host.get("_family_id")) == "synthetic_tutorial_one", "Host resolves requested family")
	var tutorial: Control = host.get("_tutorial_instance") as Control
	_check(tutorial != null and tutorial.has_method("complete_for_test"), "Host instantiates family tutorial scene")
	if tutorial:
		tutorial.call("complete_for_test")
	_check(await _wait_route(navigation, "observation"), "Family tutorial launches its practice template")
	var snapshot: Dictionary = runtime.call("get_active_session_snapshot")
	_check(snapshot.get("family_id", "") == "synthetic_tutorial_one", "Practice launch remains family-driven")
	var preferences: Dictionary = profile.get("profile").get("preferences", {})
	var versions: Dictionary = preferences.get("family_tutorial_versions", {})
	_check(versions.get("synthetic_tutorial_one", "") == "1", "Generic host persists family tutorial version")
	runtime.call("return_home")

	var second_family: ChallengeFamilyModule = SyntheticFamilyScript.new("synthetic_tutorial_two", "accept", 1, true)
	_check(registry.call("register_module", second_family, "test.tutorial.two"), "Second synthetic family registers without host changes")
	navigation.call("navigate_to", "tutorial", {"family_id": "synthetic_tutorial_two", "replay": true})
	_check(await _wait_route(navigation, "tutorial"), "Cached host accepts a second family")
	await _wait_frames(5)
	host = _screen(shell)
	_check(str(host.get("_family_id")) == "synthetic_tutorial_two", "Host replaces tutorial by profile")
	tutorial = host.get("_tutorial_instance") as Control
	_check(tutorial != null and tutorial.has_method("skip_for_test"), "Second family tutorial scene is active")

	registry.call("unregister_family", "synthetic_tutorial_one")
	registry.call("unregister_family", "synthetic_tutorial_two")
	audio.call("stop_all")
	OS.delay_msec(300)
	shell.queue_free()
	await _wait_frames(20)

	print("[FAMILY-TUTORIAL SUMMARY] %d passed, %d failed" % [passes, failures.size()])
	for failure: String in failures:
		print("[FAMILY-TUTORIAL FAILURE] %s" % failure)
	quit(0 if failures.is_empty() else 1)
