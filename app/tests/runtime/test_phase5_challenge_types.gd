extends SceneTree

var failures:Array[String]=[]
var passes:=0
func _initialize()->void:call_deferred("run")
func check(ok:bool,msg:String)->void:
	if ok:passes+=1;print("[PHASE5 PASS] ",msg)
	else:failures.append(msg);push_error("[PHASE5 FAIL] "+msg)
func run()->void:
	var save=root.get_node("SaveService");var profile=root.get_node("ProfileService");var settings=root.get_node("SettingsService");var fixture=root.get_node("ChallengeRegistry");var interactions=root.get_node("InteractionAdapterRegistry");var registry=root.get_node("ChallengeFamilyRegistry");var progress=root.get_node("PlayerProgressService");var recommendations=root.get_node("RecommendationService");var programs=root.get_node("ProgramService");var results=root.get_node("ResultService");var runtime=root.get_node("ChallengeSessionService");var navigation=root.get_node("NavigationService")
	save.initialize();profile.initialize();settings.initialize();fixture.initialize();interactions.initialize();registry.initialize();progress.initialize();recommendations.initialize();programs.initialize();results.initialize();runtime.initialize();navigation.initialize();await process_frame
	var visible:Array[String]=registry.get_visible_family_ids();check(visible==["scene_investigation","flash_words","spot_the_difference","object_recall","pattern_recall"],"Portfolio exposes five ordered production Challenge Types")
	var expectations:={"spot_the_difference":4,"object_recall":4,"pattern_recall":3};var adapter_expectations:={"spot_the_difference":"spatial_tap","object_recall":"multiple_choice","pattern_recall":"sequence_input"}
	for family_id:String in expectations:
		var module:ChallengeFamilyModule=registry.get_module(family_id);check(module!=null,"Family registers: "+family_id);check(module.get_templates().size()==expectations[family_id],"Family owns expected templates: "+family_id);check(module.get_interaction_profile().adapter_id==adapter_expectations[family_id],"Family declares distinct InteractionProfile: "+family_id);check(ResourceLoader.exists(module.get_tutorial_profile().scene_path),"Family tutorial resolves: "+family_id)
		verify_generation(module,family_id)
	# Enable all current production families for direct runtime proof.
	var witness:Dictionary=profile.profile.get("witness_progress",{});witness["witness_level"]=3;witness["total_progress"]=300;profile.profile["witness_progress"]=witness;var prefs:Dictionary=profile.profile.get("preferences",{});var versions:Dictionary={}
	for id:String in visible:versions[id]=registry.get_family(id).tutorial_version
	prefs["family_tutorial_versions"]=versions;profile.profile["preferences"]=prefs
	for family_id:String in expectations:
		check(runtime.start_family_session(family_id,"","phase5_proof",424200+family_id.hash()),"Runtime starts "+family_id);var snapshot:Dictionary=runtime.get_active_session_snapshot();check((snapshot.get("interaction_profile",{}) as Dictionary).get("adapter_id","")==adapter_expectations[family_id],"Runtime carries generic interaction profile")
		var instance:ChallengeInstance=runtime.get_active_instance();var response:Variant=instance.correct_answer
		if family_id=="spot_the_difference":
			var region:Dictionary=(instance.metadata.get("target_regions",[]) as Array)[0];response={"x":float(region.x)+float(region.w)*.5,"y":float(region.y)+float(region.h)*.5}
		var result:Dictionary=runtime.submit_response(response,700);check(result.get("outcome","")=="correct","Family scoring accepts correct generic payload");check(runtime.present_result(),"Family result uses shared Result route");runtime.return_home()
		check(int(progress.get_family_progress(family_id).get("plays",0))==1,"Family writes Witness Progress exactly once")
	var catalog:Array[Dictionary]=recommendations.get_available_challenge_types(progress.get_player_state());check(catalog.size()==5,"Home and Library catalog include all five production types")
	print("[PHASE5 SUMMARY] %d passed, %d failed"%[passes,failures.size()]);quit(0 if failures.is_empty() else 1)
func verify_generation(module:ChallengeFamilyModule,family_id:String)->void:
	var states:Array[Dictionary]=[{},_state(family_id,5,20),_state(family_id,12,45),_state(family_id,25,75)]
	var signatures:Dictionary={}
	for state:Dictionary in states:
		for template:ChallengeTemplate in module.get_templates():
			var difficulty:Dictionary=module.get_difficulty_policy().resolve_difficulty(state,module.get_family(),template);var exposure:float=module.get_exposure_policy().resolve_exposure(template,difficulty,state);var seed_value:int=81000+template.template_id.hash()+states.find(state);var first:ChallengeInstance=module.get_generator().generate(template,difficulty,exposure,seed_value);var second:ChallengeInstance=module.get_generator().generate(template,difficulty,exposure,seed_value);check(first!=null and module.get_validator().validate(first).is_valid,"Generated instance validates: %s/%s/%s"%[family_id,template.template_id,difficulty.label]);check(first.to_dictionary()==second.to_dictionary(),"Same seed reproduces: %s/%s"%[family_id,template.template_id]);signatures[str(first.metadata.get("scene_signature",""))]=true
	check(signatures.size()>=module.get_templates().size()*3,"Family produces broad deterministic variation: "+family_id)
func _state(family_id:String,plays:int,mastery:float)->Dictionary:return {"witness_progress":{"families":{family_id:{"plays":plays,"mastery":mastery,"accuracy":.8}}},"preferences":{}}
