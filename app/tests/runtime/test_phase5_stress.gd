extends SceneTree
var failures:=0;var generated:=0
func _initialize()->void:call_deferred("run")
func run()->void:
	var count:=1000;for arg:String in OS.get_cmdline_user_args():
		if arg.begins_with("--seeds="):count=int(arg.get_slice("=",1))
	var fixture=root.get_node("ChallengeRegistry");var interactions=root.get_node("InteractionAdapterRegistry");var registry=root.get_node("ChallengeFamilyRegistry");fixture.initialize();interactions.initialize();registry.initialize()
	for family_id:String in ["spot_the_difference","object_recall","pattern_recall"]:
		var module:ChallengeFamilyModule=registry.get_module(family_id)
		for tier_state:Dictionary in [{},state(family_id,5,20),state(family_id,12,45),state(family_id,25,75)]:
			for template:ChallengeTemplate in module.get_templates():
				var difficulty:=module.get_difficulty_policy().resolve_difficulty(tier_state,module.get_family(),template);var exposure:=module.get_exposure_policy().resolve_exposure(template,difficulty,tier_state)
				for seed_index:int in range(count):
					var instance:=module.get_generator().generate(template,difficulty,exposure,1000000+seed_index);var validation:=module.get_validator().validate(instance);generated+=1
					if not validation.is_valid:failures+=1;if failures<10:print("[PHASE5-STRESS FAILURE] ",family_id,"/",template.template_id,"/",difficulty.label," seed=",seed_index," ",validation.reason)
	print("[PHASE5-STRESS SUMMARY] %d generated, %d failed, %d seeds/template/tier"%[generated,failures,count]);quit(0 if failures==0 else 1)
func state(family_id:String,plays:int,mastery:float)->Dictionary:return {"witness_progress":{"families":{family_id:{"plays":plays,"mastery":mastery,"accuracy":.8}}},"preferences":{}}
