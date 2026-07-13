extends SceneTree
const OUT:="res://../docs/product/artifacts/phase5_challenge_types"
func _initialize()->void:call_deferred("run")
func run()->void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT));root.size=Vector2i(768,1050);var fixture=root.get_node("ChallengeRegistry");var interactions=root.get_node("InteractionAdapterRegistry");var registry=root.get_node("ChallengeFamilyRegistry");fixture.initialize();interactions.initialize();registry.initialize()
	for family_id:String in ["spot_the_difference","object_recall","pattern_recall"]:
		var module:ChallengeFamilyModule=registry.get_module(family_id);var template:ChallengeTemplate=module.get_templates()[0];var difficulty:=module.get_difficulty_policy().resolve_difficulty({},module.get_family(),template);var exposure:=module.get_exposure_policy().resolve_exposure(template,difficulty,{});var instance:=module.get_generator().generate(template,difficulty,exposure,424242);var view:=Control.new();view.set_script(load(str(instance.generated_scene.get("renderer_script",""))));view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);root.add_child(view);view.call("set_scene_data",instance.generated_scene,[]);await save("%s/%s_presentation.png"%[OUT,family_id]);view.call("set_scene_data",instance.generated_scene,[instance.metadata.get("target_id","")]);await save("%s/%s_reveal.png"%[OUT,family_id]);view.queue_free();await process_frame
	quit()
func save(path:String)->void:
	await process_frame;await process_frame;RenderingServer.force_draw();await process_frame;var image:=root.get_texture().get_image();var error:=image.save_png(ProjectSettings.globalize_path(path));if error!=OK:push_error("preview failed")
