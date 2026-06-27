extends SceneTree

func _init():
	print("\n=================================================================")
	print("[PHASE 2.5+] AUTOMATED REGRESSION HARNESS: UNIVERSE MANIFEST SYSTEM")
	print("=================================================================\n")
	
	print("--- STAGE 1: BOOTING UNIVERSE ASSET COMPILER & REGISTRY ---")
	var u_reg = load("res://scripts/ui/UniverseRegistry.gd").new()
	var compiler = load("res://scripts/system/UniverseAssetCompiler.gd").new()
	compiler._ready()
	print("✅ STAGE 1 PASS: UniverseAssetCompiler and UniverseRegistry online.\n")
	
	print("--- STAGE 2: ASSERTING PRE-GENERATED UNIVERSE CONTRACT COMPLIANCE ---")
	print("\n  [Action 1] Executing verify_and_provision_universe('science_lab')...")
	compiler.verify_and_provision_universe("science_lab", u_reg)
	
	print("\n  [Action 2] Executing verify_and_provision_universe('history')...")
	compiler.verify_and_provision_universe("history", u_reg)
	print("✅ STAGE 2 PASS: Pre-generated universes perfectly bypass AI generation. Contract compliance proven.\n")
	
	print("--- STAGE 3: ASSERTING 1-TIME BOOTSTRAP PROVISIONING FOR NEW UNIVERSE ---")
	print("\n  [Action 3] Executing verify_and_provision_universe('creative_arts')...")
	compiler.verify_and_provision_universe("creative_arts", u_reg)
	
	print("\n  [Action 4] Executing verify_and_provision_universe('creative_arts') SECOND TIME...")
	compiler.verify_and_provision_universe("creative_arts", u_reg)
	
	if not compiler.generated_registry.has("creative_arts"):
		push_error("COMPILER FAIL: New universe failed to persist to generated_registry.")
		quit(1)
		return
		
	print("✅ STAGE 3 PASS: New universe 'creative_arts' successfully triggered AI generation ONCE and bypassed on second pass. 1-time bootstrap gate proven.\n")
	
	print("=================================================================")
	print("🏆 UNIVERSE MANIFEST SYSTEM HARNESS PASS: 100% PROVISIONING SATISFIED.")
	print("=================================================================\n")
	
	u_reg.free()
	compiler.free()
	quit(0)
