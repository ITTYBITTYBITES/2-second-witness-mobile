extends SceneTree

var failures: Array[String] = []
var passes: int = 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if ok:
		passes += 1
		print("[PHASE5-TUTORIAL PASS] ", message)
	else:
		failures.append(message)
		push_error("[PHASE5-TUTORIAL FAIL] " + message)

func run() -> void:
	var fixture: Node = root.get_node("ChallengeRegistry")
	var interactions: Node = root.get_node("InteractionAdapterRegistry")
	var registry: Node = root.get_node("ChallengeFamilyRegistry")
	fixture.call("initialize")
	interactions.call("initialize")
	registry.call("initialize")
	for family_id: String in ["spot_the_difference", "object_recall", "pattern_recall"]:
		var module: ChallengeFamilyModule = registry.call("get_module", family_id)
		var profile: TutorialProfile = module.get_tutorial_profile()
		var scene: PackedScene = load(profile.scene_path) as PackedScene
		var tutorial: Control = scene.instantiate() as Control
		root.add_child(tutorial)
		await process_frame
		check(tutorial.has_signal("completed") and tutorial.has_signal("practice_requested"), "Tutorial exposes generic signals: " + family_id)
		var captured: Array[String] = ["", ""]
		tutorial.completed.connect(func(id: String, version: String): captured[0] = id + ":" + version)
		tutorial.practice_requested.connect(func(id: String, template: String): captured[1] = id + ":" + template)
		for _index: int in range(4):
			tutorial.call("_advance")
		check(captured[0].begins_with(family_id + ":"), "Tutorial persists family identity: " + family_id)
		check(captured[1].begins_with(family_id + ":"), "Tutorial requests family practice: " + family_id)
		tutorial.queue_free()
		await process_frame
	print("[PHASE5-TUTORIAL SUMMARY] %d passed, %d failed" % [passes, failures.size()])
	quit(0 if failures.is_empty() else 1)
