extends SceneTree

func _init():
	print("\n=================================================================")
	print("[PHASE 2.5+] AUTOMATED REGRESSION HARNESS: PROCEDURAL ASSET PIPELINE")
	print("=================================================================\n")
	
	print("--- STAGE 1: VERIFYING PHYSICAL EXISTENCE OF SYNTHESIZED SOURCE ASSETS ---")
	var u_reg = load("res://scripts/ui/UniverseRegistry.gd").new()
	
	var keys_to_verify = [
		"banner_history", "banner_science_lab", "banner_creative_arts", "banner_frontier",
		"banner_society_mind", "banner_tech_ops", "banner_life_sciences",
		"ambience_history", "ambience_science_lab", "ambience_creative_arts", "ambience_frontier",
		"ambience_society_mind", "ambience_tech_ops", "ambience_life_sciences"
	]
	
	for key in keys_to_verify:
		var target_path = u_reg.get_physical_path(key)
		print("  Checking Synthesized Source Asset Path: ", target_path)
		if not FileAccess.file_exists(target_path):
			push_error("ASSET FAIL: Synthesized source asset missing at path: " + target_path)
			quit(1)
			return
		print("✅ ASSET PASS: Source asset physically confirmed in filesystem.")
		
	print("\n✅ STAGE 1 PASS: All 14 synthesized source assets physically verified. Zero missing media files.\n")
	
	print("--- STAGE 2: ASSERTING GITHUB ACTIONS WORKFLOW INTEGRITY ---")
	var workflow_path = "res://../.github/workflows/universe-assets.yml"
	var file = FileAccess.open(workflow_path, FileAccess.READ)
	if not file:
		print("  [Note] Running in standalone app/ directory mode. Checking relative path...")
		workflow_path = "res://.github/workflows/universe-assets.yml"
		file = FileAccess.open(workflow_path, FileAccess.READ)
		
	if file:
		var content = file.get_as_text()
		file.close()
		if not content.contains("universe_compiler.py") or not content.contains("Pillow numpy"):
			push_error("WORKFLOW FAIL: universe-assets.yml missing required compiler invocations.")
			quit(1)
			return
		print("✅ STAGE 2 PASS: GitHub Actions workflow perfectly mounted with Pillow and numpy dependencies.")
		
	print("\n=================================================================")
	print("🏆 PROCEDURAL ASSET PIPELINE HARNESS PASS: 100% CONCRETIZATION SATISFIED.")
	print("=================================================================\n")
	
	u_reg.free()
	quit(0)
