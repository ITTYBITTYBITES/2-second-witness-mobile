extends SceneTree

const OUTPUT_DIR: String = "res://../docs/product/artifacts/phase4_product_experience"
const PREVIEW_SIZE := Vector2i(768, 1050)

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	root.size = PREVIEW_SIZE
	root.get_node("SaveService").call("initialize")
	root.get_node("ProfileService").call("initialize")
	root.get_node("SettingsService").call("initialize")
	root.get_node("AccessibilityService").call("initialize")
	root.get_node("ThemeService").call("initialize")
	root.get_node("ChallengeRegistry").call("initialize")
	root.get_node("ChallengeFamilyRegistry").call("initialize")
	root.get_node("PlayerProgressService").call("initialize")
	root.get_node("RecommendationService").call("initialize")
	root.get_node("ProgramService").call("initialize")
	root.get_node("AchievementService").call("initialize")
	_seed_preview_profile()
	for screen_name: String in ["HomeScreen", "ProgramsScreen", "ExperiencesScreen", "ProfileScreen", "AchievementsScreen"]:
		await _capture(screen_name)
	quit(0)

func _seed_preview_profile() -> void:
	var profile_service: Node = root.get_node("ProfileService")
	var family_registry: Node = root.get_node("ChallengeFamilyRegistry")
	var ids: Array[String] = family_registry.call("get_visible_family_ids")
	var families: Dictionary = {}
	for index: int in range(ids.size()):
		families[ids[index]] = {
			"plays": 12 - index * 3,
			"correct": 9 - index * 2,
			"accuracy": 0.75,
			"mastery": 34.0 - index * 8.0,
			"current_streak": 3,
			"best_streak": 7,
			"progress_points": 124,
			"history": [{
				"template_id": family_registry.call("get_module", ids[index]).get_default_template_id(),
				"outcome": "correct",
				"timestamp": "2026-07-12T18:30:00"
			}]
		}
	profile_service.get("profile")["witness_progress"] = {
		"version": 1,
		"total_progress": 248,
		"witness_level": 3,
		"witness_rank": "Noticer",
		"last_played_family_id": ids[0],
		"last_played_template_id": family_registry.call("get_module", ids[0]).get_default_template_id(),
		"families": families
	}
	profile_service.get("profile")["stats"] = {
		"observations_made": 21,
		"correct_observations": 16,
		"fastest_reaction_ms": 842,
		"streak_current": 3,
		"streak_best": 7
	}
	profile_service.get("profile")["favorite_challenge_types"] = [ids[0]]
	profile_service.get("profile")["active_program_id"] = "daily_witness"
	profile_service.get("profile")["program_progress"] = {
		"daily_witness": {
			"rounds_completed": 7,
			"correct": 5,
			"accuracy": 0.714,
			"current_run_round": 1,
			"current_run_correct": 1,
			"completed_runs": 2,
			"best_run_accuracy": 1.0,
			"family_counts": {ids[0]: 4, ids[1]: 3}
		}
	}

func _capture(screen_name: String) -> void:
	var scene: PackedScene = load("res://src/ui/screens/%s.tscn" % screen_name)
	var screen: Control = scene.instantiate() as Control
	root.add_child(screen)
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
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
	print("[PHASE4 PREVIEW] %s" % path)
	screen.queue_free()
	await process_frame
