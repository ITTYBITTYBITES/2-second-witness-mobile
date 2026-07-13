extends SceneTree

const OUTPUT_DIR: String = "res://../docs/product/artifacts/scene_investigation"
const PREVIEW_SIZE := Vector2i(768, 1050)

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	var fixture_registry: Node = root.get_node("ChallengeRegistry")
	var family_registry: Node = root.get_node("ChallengeFamilyRegistry")
	fixture_registry.call("initialize")
	family_registry.call("initialize")
	var module: ChallengeFamilyModule = family_registry.call("get_module", "scene_investigation")
	root.size = PREVIEW_SIZE
	for template: ChallengeTemplate in module.get_templates():
		var difficulty := module.get_difficulty_policy().resolve_difficulty({}, module.get_family(), template)
		var exposure := module.get_exposure_policy().resolve_exposure(template, difficulty, {})
		var instance := module.get_generator().generate(template, difficulty, exposure, 424242 + template.template_id.hash())
		var view := SceneInvestigationSceneView.new()
		view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		root.add_child(view)

		view.set_scene_data(instance.generated_scene, [])
		await _save_frame("%s/%s_observation.png" % [OUTPUT_DIR, template.template_id])

		view.set_scene_data(instance.generated_scene, instance.metadata.get("highlight_ids", []))
		await _save_frame("%s/%s_reveal.png" % [OUTPUT_DIR, template.template_id])

		view.queue_free()
		await process_frame
	quit(0)

func _save_frame(path: String) -> void:
	await process_frame
	await process_frame
	RenderingServer.force_draw()
	await process_frame
	var image := root.get_texture().get_image()
	var error := image.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		push_error("Failed to save preview %s: %s" % [path, error])
		quit(1)
		return
	print("[PREVIEW] %s" % path)
