extends SceneTree

const OUTPUT_DIR: String = "res://../docs/product/artifacts/flash_words"
const PREVIEW_SIZE := Vector2i(768, 1050)
const RENDERER_SCRIPT: String = "res://src/gameplay/families/flash_words/FlashWordsSceneView.gd"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	var fixture_registry: Node = root.get_node("ChallengeRegistry")
	var registry: Node = root.get_node("ChallengeFamilyRegistry")
	fixture_registry.call("initialize")
	registry.call("initialize")
	var module: ChallengeFamilyModule = registry.call("get_module", "flash_words")
	root.size = PREVIEW_SIZE
	for template: ChallengeTemplate in module.get_templates():
		var difficulty := module.get_difficulty_policy().resolve_difficulty({}, module.get_family(), template)
		var exposure := module.get_exposure_policy().resolve_exposure(template, difficulty, {})
		var instance := module.get_generator().generate(template, difficulty, exposure, 8080 + template.template_id.hash())
		var view := Control.new()
		view.set_script(load(RENDERER_SCRIPT))
		view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		root.add_child(view)
		view.call("set_scene_data", instance.generated_scene, [])
		await _save_frame("%s/%s_observation.png" % [OUTPUT_DIR, template.template_id])
		var reveal := instance.generated_scene.duplicate(true)
		reveal["reveal_mode"] = true
		reveal["player_display"] = str(instance.answer_options[1])
		reveal["correct_display"] = str(instance.correct_answer)
		reveal["difference"] = "Letter or order comparison"
		reveal["outcome"] = "incorrect"
		view.set_scene_data(reveal, [])
		await _save_frame("%s/%s_reveal.png" % [OUTPUT_DIR, template.template_id])
		view.queue_free()
		await process_frame
	quit(0)

func _save_frame(path: String) -> void:
	RenderingServer.force_draw()
	await process_frame
	var image := root.get_texture().get_image()
	var error := image.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		push_error("Failed to save %s: %s" % [path, error])
		quit(1)
		return
	print("[FLASH PREVIEW] %s" % path)
