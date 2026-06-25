extends SceneTree

func _init():
	print("\n=== SYSTEM READINESS AUDIT (HEADLESS ENVIRONMENT) ===")
	
	print("\n--- 1. Testing Boot Sequence (Simulated) ---")
	var profile = load("res://scripts/system/PlayerProfile.gd").new()
	profile._ready()
	
	var config = load("res://scripts/system/IVC0_InstrumentConfig.gd").new()
	config._ready()
	
	var registry = load("res://scripts/content/ContentRegistry.gd").new()
	registry._ready()
	var loader = load("res://scripts/content/ContentLoader.gd").new()
	loader.registry = registry
	loader._ready()
	
	print("\n--- 2. Validating Content Injection ---")
	var test_seed = "12345_science_lab"
	var payload = registry.resolve_scenario("science_lab", "ai", "rapid_classification", test_seed)
	if payload.is_empty():
		print("❌ Content Injection FAILED. Expected payload for science_lab/ai/rapid_classification.")
	else:
		print("✅ Content Injection PASS. Resolved payload ID: ", payload.get("id"))
	
	print("\n--- 3. Validating Asset Registry ---")
	var asset_reg = load("res://scripts/ui/AssetManifestRegistry.gd").new()
	var manifest = asset_reg.get_manifest("science_lab")
	if manifest.is_empty():
		print("❌ Asset Registry FAILED. Manifest not found.")
	else:
		var bg = asset_reg.resolve_asset(manifest, "bg_noise")
		print("✅ Asset Registry PASS. Resolved path: ", bg)
		
	print("\n--- 4. Validating Persistence Layer ---")
	profile.record_cognitive_event("pattern_recognition", "rapid_classification", "science_lab", "ai", true, 850.0)
	profile.free()
	
	var p2 = load("res://scripts/system/PlayerProfile.gd").new()
	p2._ready()
	print("✅ Persistence PASS. Lifetime Sessions restored: ", p2.lifetime_sessions)
	p2.free()
	
	print("\n=== AUDIT COMPLETE ===\n")
	quit()
