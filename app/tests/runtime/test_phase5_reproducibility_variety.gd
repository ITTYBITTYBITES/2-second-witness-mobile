extends SceneTree
var failures:Array[String]=[];var passes:=0
func _initialize()->void:call_deferred("run")
func check(ok:bool,msg:String)->void:
	if ok:passes+=1;print("[PHASE5-SEED PASS] ",msg)
	else:failures.append(msg);push_error("[PHASE5-SEED FAIL] "+msg)
func run()->void:
	var fixture=root.get_node("ChallengeRegistry");var interactions=root.get_node("InteractionAdapterRegistry");var registry=root.get_node("ChallengeFamilyRegistry");fixture.initialize();interactions.initialize();registry.initialize()
	for family_id:String in ["spot_the_difference","object_recall","pattern_recall"]:
		var module:ChallengeFamilyModule=registry.get_module(family_id);var reproducible:=true
		for template:ChallengeTemplate in module.get_templates():
			var difficulty:=module.get_difficulty_policy().resolve_difficulty({},module.get_family(),template);var exposure:=module.get_exposure_policy().resolve_exposure(template,difficulty,{})
			for index:int in range(100):
				var seed_value:=500000+index;var first:=module.get_generator().generate(template,difficulty,exposure,seed_value);var second:=module.get_generator().generate(template,difficulty,exposure,seed_value)
				if first==null or second==null or first.to_dictionary()!=second.to_dictionary():reproducible=false;break
		check(reproducible,"100-seed reproduction: "+family_id)
		var signatures:Dictionary={};var templates:Array[ChallengeTemplate]=module.get_templates()
		for round_index:int in range(20):
			var template:ChallengeTemplate=templates[round_index%templates.size()];var difficulty:=module.get_difficulty_policy().resolve_difficulty({},module.get_family(),template);var exposure:=module.get_exposure_policy().resolve_exposure(template,difficulty,{});var instance:=module.get_generator().generate(template,difficulty,exposure,700000+round_index);signatures[str(instance.metadata.get("scene_signature",""))]=true
		check(signatures.size()>=18,"20-round variety: "+family_id)
	print("[PHASE5-SEED SUMMARY] %d passed, %d failed"%[passes,failures.size()]);quit(0 if failures.is_empty() else 1)
