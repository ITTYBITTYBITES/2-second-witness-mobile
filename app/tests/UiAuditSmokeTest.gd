extends Node
## Runtime smoke test for every production UI scene at the 360 x 640 reference size.

const CASES := [
	{"name": "publisher", "path": "res://src/ui/screens/PublisherSplashScreen.tscn"},
	{"name": "title", "path": "res://src/ui/screens/TitleSplashScreen.tscn"},
	{"name": "privacy", "path": "res://src/ui/dialogs/PrivacyTermsDialog.tscn"},
	{"name": "home", "path": "res://src/ui/screens/HomeScreen.tscn"},
	{"name": "experiences", "path": "res://src/ui/screens/ExperiencesScreen.tscn"},
	{"name": "profile", "path": "res://src/ui/screens/ProfileScreen.tscn"},
	{"name": "settings", "path": "res://src/ui/screens/SettingsScreen.tscn"},
	{"name": "about", "path": "res://src/ui/screens/AboutScreen.tscn"},
	{"name": "tutorial", "path": "res://src/ui/screens/TutorialScreen.tscn"},
	{"name": "observation", "path": "res://src/ui/screens/ObservationChallengeScreen.tscn"},
	{"name": "question", "path": "res://src/ui/screens/MemoryQuestionScreen.tscn"},
	{"name": "result", "path": "res://src/ui/screens/ResultScreen.tscn"}
]

var _failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	_initialize_services()
	await get_tree().process_frame
	for test_case in CASES:
		await _test_scene(test_case)
	_test_project_configuration()
	if _failures.is_empty():
		print("UI_AUDIT_SMOKE_OK: %d scenes" % CASES.size())
		get_tree().quit(0)
	else:
		for failure in _failures:
			push_error("UI_AUDIT_SMOKE: %s" % failure)
		get_tree().quit(1)

func _initialize_services() -> void:
	SaveService.initialize()
	ProfileService.initialize()
	SettingsService.initialize()
	ThemeService.initialize()
	AccessibilityService.initialize()
	ContentService.initialize()
	ChallengeRegistry.initialize()

func _test_scene(test_case: Dictionary) -> void:
	var path := str(test_case["path"])
	var case_name := str(test_case["name"])
	if not ResourceLoader.exists(path):
		_failures.append("%s scene missing: %s" % [case_name, path])
		return
	var packed := load(path) as PackedScene
	if not packed:
		_failures.append("%s scene failed to load" % case_name)
		return
	var instance := packed.instantiate() as Control
	if not instance:
		_failures.append("%s root is not a Control" % case_name)
		return
	add_child(instance)
	await get_tree().process_frame
	_apply_navigation_data(case_name, instance)
	await get_tree().process_frame
	_check_bounds(case_name, instance)
	_check_touch_targets(case_name, instance)
	_check_text_clipping(case_name, instance)
	instance.queue_free()
	await get_tree().process_frame

func _apply_navigation_data(case_name: String, instance: Control) -> void:
	if not instance.has_method("on_navigated_to"):
		return
	var challenge := ChallengeRegistry.get_challenge("challenge_01")
	match case_name:
		"observation", "question":
			instance.call("on_navigated_to", {
				"challenge_id": "challenge_01", "challenge_data": challenge
			})
		"result":
			instance.call("on_navigated_to", {
				"challenge_id": "challenge_01",
				"title": "Study Desk",
				"selected": "4",
				"correct": "5",
				"is_correct": false,
				"detail": "There were 5 writing tools in the green mug."
			})
		_:
			instance.call("on_navigated_to", {})

func _check_bounds(case_name: String, instance: Control) -> void:
	var viewport_size := get_viewport_rect().size
	if viewport_size.x < 320.0 or viewport_size.y < 480.0:
		_failures.append("reference viewport unexpectedly small: %s" % viewport_size)
	var minimum := instance.get_combined_minimum_size()
	if minimum.x > viewport_size.x + 1.0:
		_failures.append("%s minimum width %.1f exceeds viewport %.1f" % [
			case_name, minimum.x, viewport_size.x
		])

func _check_touch_targets(case_name: String, root: Node) -> void:
	for node in _walk(root):
		if node is BaseButton and node.visible:
			var button := node as BaseButton
			var minimum := button.get_combined_minimum_size()
			if minimum.y < 47.5:
				_failures.append("%s/%s touch target is %.1f (<48)" % [
					case_name, str(root.get_path_to(button)), minimum.y
				])

func _check_text_clipping(case_name: String, root: Node) -> void:
	for node in _walk(root):
		if node is Label and node.visible:
			var label := node as Label
			if label.clip_text and label.get_combined_minimum_size().x > label.size.x + 1.0:
				_failures.append("%s/%s clips text" % [case_name, str(root.get_path_to(label))])

func _walk(root: Node) -> Array[Node]:
	var output: Array[Node] = [root]
	var cursor := 0
	while cursor < output.size():
		var current := output[cursor]
		for child in current.get_children():
			output.append(child)
		cursor += 1
	return output

func _test_project_configuration() -> void:
	var width := int(ProjectSettings.get_setting("display/window/size/viewport_width", 0))
	var height := int(ProjectSettings.get_setting("display/window/size/viewport_height", 0))
	if width != 360 or height != 640:
		_failures.append("logical viewport is %dx%d, expected 360x640" % [width, height])
	var foreground := load("res://assets/brand/android/icon_foreground.png") as Texture2D
	if not foreground:
		_failures.append("adaptive foreground failed to import")
