extends SceneTree

func _init():
	print("\n=================================================================")
	print("[PHASE 2.5+] AUTOMATED REGRESSION HARNESS: CURATED COGNITIVE MISSIONS")
	print("=================================================================\n")
	
	print("--- STAGE 1: BOOTING ORCHESTRATION & CONTENT CUSTODIANS ---")
	var profile = PlayerProfile if PlayerProfile else load("res://scripts/system/PlayerProfile.gd").new()
	var registry = ContentRegistry if ContentRegistry else load("res://scripts/content/ContentRegistry.gd").new()
	var orch = ExperienceOrchestrator if ExperienceOrchestrator else load("res://scripts/system/ExperienceOrchestrator.gd").new()
	
	if not PlayerProfile:
		root.add_child(profile)
		profile.name = "PlayerProfile"
		profile._ready()
	if not ContentRegistry:
		root.add_child(registry)
		registry.name = "ContentRegistry"
		registry._ready()
	if not ExperienceOrchestrator:
		root.add_child(orch)
		orch.name = "ExperienceOrchestrator"
		orch._ready()
		
	print("✅ STAGE 1 PASS: Content Registry, Player Profile, and Experience Orchestrator active.\n")
	
	print("--- STAGE 2: ASSERTING CURATED MISSION CHAINS IN ANCIENT EGYPT ---")
	
	# Verify Mission 1: Life Along the Nile (Sessions 0..3)
	print("\n  [Target Mission 1] Verifying 'Life Along the Nile' mechanics chain...")
	var expected_m1 = ["memory_cascade", "stroop_test", "signal_vs_noise", "spatial_recall"]
	for i in range(4):
		profile.lifetime_sessions = i
		var vector = orch.determine_next_experience(profile)
		var active_mission = vector.get("mission", {})
		var spike = vector.get("spike", "")
		
		print("    Session ", i, " -> Mission: ", active_mission.get("title", ""), " | Exposure: ", i + 1, " | Mechanic: ", spike)
		if active_mission.get("mission_id") != "life_along_nile":
			push_error("MISSION FAIL: Expected mission_id 'life_along_nile', got: " + active_mission.get("mission_id", "NULL"))
			quit(1)
			return
		if spike != expected_m1[i]:
			push_error("MISSION FAIL: Expected mechanic '" + expected_m1[i] + "', got: " + spike)
			quit(1)
			return
			
	print("✅ MISSION 1 PASS: 'Life Along the Nile' perfectly steps through Memory Cascade, Stroop, Signal vs Noise, and Spatial Recall.\n")
	
	# Verify Mission 2: Pharaoh's Court (Sessions 4..7)
	print("\n  [Target Mission 2] Verifying 'Pharaoh's Court' mechanics chain...")
	var expected_m2 = ["rapid_classification", "pattern_continuation", "memory_cascade", "reflex_tap"]
	for i in range(4, 8):
		profile.lifetime_sessions = i
		var vector = orch.determine_next_experience(profile)
		var active_mission = vector.get("mission", {})
		var spike = vector.get("spike", "")
		
		print("    Session ", i, " -> Mission: ", active_mission.get("title", ""), " | Exposure: ", (i % 4) + 1, " | Mechanic: ", spike)
		if active_mission.get("mission_id") != "pharaohs_court":
			push_error("MISSION FAIL: Expected mission_id 'pharaohs_court', got: " + active_mission.get("mission_id", "NULL"))
			quit(1)
			return
		if spike != expected_m2[i - 4]:
			push_error("MISSION FAIL: Expected mechanic '" + expected_m2[i - 4] + "', got: " + spike)
			quit(1)
			return
			
	print("✅ MISSION 2 PASS: 'Pharaoh's Court' perfectly steps through Rapid Classification, Pattern Continuation, Memory Cascade, and Reflex Tap.\n")
	
	# Verify Mission 3: Building the Pyramids (Sessions 8..11)
	print("\n  [Target Mission 3] Verifying 'Building the Pyramids' mechanics chain...")
	var expected_m3 = ["sequence_reverse", "speed_sort", "signal_vs_noise", "stroop_test"]
	for i in range(8, 12):
		profile.lifetime_sessions = i
		var vector = orch.determine_next_experience(profile)
		var active_mission = vector.get("mission", {})
		var spike = vector.get("spike", "")
		
		print("    Session ", i, " -> Mission: ", active_mission.get("title", ""), " | Exposure: ", (i % 4) + 1, " | Mechanic: ", spike)
		if active_mission.get("mission_id") != "building_pyramids":
			push_error("MISSION FAIL: Expected mission_id 'building_pyramids', got: " + active_mission.get("mission_id", "NULL"))
			quit(1)
			return
		if spike != expected_m3[i - 8]:
			push_error("MISSION FAIL: Expected mechanic '" + expected_m3[i - 8] + "', got: " + spike)
			quit(1)
			return
			
	print("✅ MISSION 3 PASS: 'Building the Pyramids' perfectly steps through Sequence Reverse, Speed Sort, Signal vs Noise, and Stroop.\n")
	
	print("=================================================================")
	print("🏆 CURATED COGNITIVE MISSIONS HARNESS PASS: 100% NARRATIVE SEQUENCING SATISFIED.")
	print("=================================================================\n")
	
	if not PlayerProfile: profile.free()
	if not ContentRegistry: registry.free()
	if not ExperienceOrchestrator: orch.free()
	quit(0)
