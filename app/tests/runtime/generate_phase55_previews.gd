extends SceneTree
## Local visual-review captures for the Phase 5.5 family expansions.

const OUT := "res://../docs/product/artifacts/phase55_content_quality"
const CAPTURES: Array[Dictionary] = [
	{"family_id": "scene_investigation", "template_id": "travel_desk_v1", "seed": 551001},
	{"family_id": "scene_investigation", "template_id": "garden_bench_v1", "seed": 551002},
	{"family_id": "flash_words", "template_id": "position_catch_v1", "seed": 551003},
	{"family_id": "spot_the_difference", "template_id": "sequential_switch_v1", "seed": 551004},
	{"family_id": "object_recall", "template_id": "missing_set_v1", "seed": 551005},
	{"family_id": "pattern_recall", "template_id": "pattern_build_v1", "seed": 551006}
]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	root.size = Vector2i(768, 1050)
	root.get_node("ChallengeRegistry").call("initialize")
	root.get_node("InteractionAdapterRegistry").call("initialize")
	var registry: Node = root.get_node("ChallengeFamilyRegistry")
	registry.call("initialize")
	for capture: Dictionary in CAPTURES:
		var family_id := str(capture.get("family_id", ""))
		var template_id := str(capture.get("template_id", ""))
		var module: ChallengeFamilyModule = registry.call("get_module", family_id)
		var template: ChallengeTemplate = module.get_template(template_id)
		var state := _advanced_state(family_id)
		var difficulty := module.get_difficulty_policy().resolve_difficulty(state, module.get_family(), template)
		var exposure := module.get_exposure_policy().resolve_exposure(template, difficulty, state)
		var instance := module.get_generator().generate(template, difficulty, exposure, int(capture.get("seed", 0)))
		var view := Control.new()
		view.set_script(load(str(instance.generated_scene.get("renderer_script", ""))))
		view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		root.add_child(view)
		view.call("set_scene_data", instance.generated_scene, [])
		await _save("%s/%s_%s_presentation.png" % [OUT, family_id, template_id])
		var resolved: Dictionary = module.get_scoring_policy().calculate_result(instance, _wrong_response(family_id), {})
		var explanation: Dictionary = module.get_scoring_policy().explain_outcome(instance, _wrong_response(family_id), resolved)
		var reveal: Dictionary = explanation.get("reveal_data", {})
		view.call("set_scene_data", reveal.get("generated_scene", instance.generated_scene), reveal.get("highlight_ids", []))
		await _save("%s/%s_%s_reveal.png" % [OUT, family_id, template_id])
		view.queue_free()
		await process_frame
	quit()

func _advanced_state(family_id: String) -> Dictionary:
	return {
		"witness_progress": {
			"families": {
				family_id: {"plays": 12, "accuracy": 0.76, "mastery": 45.0, "incorrect_streak": 0}
			}
		},
		"preferences": {}
	}

func _wrong_response(family_id: String) -> Variant:
	if family_id == "spot_the_difference":
		return {"x": -1.0, "y": -1.0}
	if family_id in ["object_recall", "pattern_recall"]:
		return []
	return "NOT SHOWN"

func _save(path: String) -> void:
	await process_frame
	await process_frame
	RenderingServer.force_draw()
	await process_frame
	var texture := root.get_texture()
	if texture == null:
		print("[PHASE55 PREVIEW] Capture skipped because no graphical renderer is available: %s" % path)
		return
	var image := texture.get_image()
	var error := image.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		push_error("Phase 5.5 preview failed: %s" % path)
