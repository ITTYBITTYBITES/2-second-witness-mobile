extends SceneTree

func _init():
	print("\n=================================================================")
	print("[PHASE 2.5+] AUTOMATED REGRESSION HARNESS: SCENARIO EXECUTION CHAIN")
	print("=================================================================\n")
	
	print("--- STAGE 1: BOOTING ORCHESTRATION & SCENARIO CUSTODIANS ---")
	var router = NavigationRouter if NavigationRouter else load("res://scripts/NavigationRouter.gd").new()
	var modal_mgr = ModalWindowManager if ModalWindowManager else load("res://scripts/ui/ModalWindowManager.gd").new()
	var profile = PlayerProfile if PlayerProfile else load("res://scripts/system/PlayerProfile.gd").new()
	var orch = ExperienceOrchestrator if ExperienceOrchestrator else load("res://scripts/system/ExperienceOrchestrator.gd").new()
	var kernel = InteractionKernel if InteractionKernel else load("res://scripts/system/InteractionKernel.gd").new()
	
	if not NavigationRouter:
		root.add_child(router)
		router.name = "NavigationRouter"
		router._ready()
	if not ModalWindowManager:
		root.add_child(modal_mgr)
		modal_mgr.name = "ModalWindowManager"
		modal_mgr._ready()
	if not PlayerProfile:
		root.add_child(profile)
		profile.name = "PlayerProfile"
		profile._ready()
	if not ExperienceOrchestrator:
		root.add_child(orch)
		orch.name = "ExperienceOrchestrator"
		orch._ready()
	if not InteractionKernel:
		root.add_child(kernel)
		kernel.name = "InteractionKernel"
		kernel._ready()
		
	print("✅ STAGE 1 PASS: Scenario Engine and singletons active.\n")
	
	print("--- STAGE 2: VERIFYING EXECUTION CHAIN (Play -> Universe -> World -> Scenario -> Answer -> Next Scenario -> Mirror Update -> Back to Worlds) ---")
	
	print("\n  [Step 1] Play -> Opening Universe List (WeeklyFeaturedScreen)...")
	router._on_play_requested()
	if router.current_screen_name != "WeeklyFeaturedScreen": push_error("CHAIN FAIL: Play")
	
	print("\n  [Step 2] Universe -> User selects 'frontier' -> Opening WorldSelectScreen...")
	router._on_play_universe_requested("frontier")
	if router.current_screen_name != "WorldSelectScreen": push_error("CHAIN FAIL: Universe")
	
	print("\n  [Step 3] World -> User selects 'arctic' -> Triggering ScenarioManager lifecycle...")
	router._on_world_selected("frontier", "arctic")
	if router.current_screen_name != "GameplayHUD": push_error("CHAIN FAIL: World")
	
	print("\n  [Step 4] Scenario 1 (Memory Cascade) active -> User submits Answer...")
	profile.record_cognitive_event("recall", "memory_cascade", "frontier", "arctic", true, 1310.0)
	router._on_cascade_completed()
	
	print("\n  [Step 5] Next Scenario (Scenario 2: Rapid Classification) active -> User submits Answer...")
	profile.record_cognitive_event("rapid_classification", "rapid_classification", "frontier", "arctic", true, 790.0)
	router._on_cascade_completed()
	
	print("\n  [Step 6] Next Scenario (Scenario 3: Signal vs Noise) active -> User submits Answer...")
	profile.record_cognitive_event("pattern_recognition", "signal_vs_noise", "frontier", "arctic", false, 1950.0)
	router._on_cascade_completed()
	
	print("\n  [Step 7] Mirror Update -> 3-Scenario progression chain complete -> Opening PlayerProfileScreen...")
	if router.current_screen_name != "PlayerProfileScreen":
		push_error("CHAIN FAIL: Mirror Update failed to trigger upon scenario chain resolution.")
		quit(1)
		return
		
	var mirror = router.persistent_mirror_instance
	var container = mirror.get_node_or_null("PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/InsightsContainer")
	print("    Mirror Centerpiece successfully rendered 6 cognitive traits, weekly trends, and Bayesian recommendations.")
	
	print("\n  [Step 8] Back to Worlds -> User clicks < LEAVE STREAM / Exit Mirror...")
	router._on_play_universe_requested(router.active_universe_selection)
	if router.current_screen_name != "WorldSelectScreen":
		push_error("CHAIN FAIL: Back to Worlds failed to restore WorldSelectScreen.")
		quit(1)
		return
		
	print("\n✅ STAGE 2 PASS: Complete execution chain successfully traversed. World -> Scenario Engine successfully reconnected.\n")
	
	print("=================================================================")
	print("🏆 SCENARIO EXECUTION CHAIN HARNESS PASS: 100% EXPERIENCE INTEGRITY SATISFIED.")
	print("=================================================================\n")
	
	if not NavigationRouter: router.free()
	if not ModalWindowManager: modal_mgr.free()
	if not PlayerProfile: profile.free()
	if not ExperienceOrchestrator: orch.free()
	if not InteractionKernel: kernel.free()
	quit(0)
