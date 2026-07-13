extends SceneTree

const OUTPUT_DIR: String = "res://../docs/product/artifacts/home_experience"
const PREVIEW_SIZE := Vector2i(768, 1050)

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	root.size = PREVIEW_SIZE
	root.get_node("SaveService").call("initialize")
	root.get_node("ProfileService").call("initialize")
	root.get_node("SettingsService").call("initialize")
	root.get_node("ThemeService").call("initialize")
	root.get_node("ChallengeRegistry").call("initialize")
	root.get_node("ChallengeFamilyRegistry").call("initialize")
	root.get_node("PlayerProgressService").call("initialize")
	root.get_node("RecommendationService").call("initialize")
	root.get_node("AchievementService").call("initialize")
	for screen_name: String in ["HomeScreen", "ExperiencesScreen", "ProfileScreen", "AchievementsScreen", "SettingsScreen"]:
		var scene: PackedScene = load("res://src/ui/screens/%s.tscn" % screen_name)
		var screen: Control = scene.instantiate() as Control
		screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		root.add_child(screen)
		await process_frame
		await process_frame
		RenderingServer.force_draw()
		await process_frame
		var image: Image = root.get_texture().get_image()
		var path: String = "%s/%s.png" % [OUTPUT_DIR, screen_name.to_snake_case()]
		var error: Error = image.save_png(ProjectSettings.globalize_path(path))
		if error != OK:
			push_error("Failed to save %s: %s" % [path, error_string(error)])
			quit(1)
			return
		print("[PHASE3 PREVIEW] %s" % path)
		screen.queue_free()
		await process_frame
	quit(0)
