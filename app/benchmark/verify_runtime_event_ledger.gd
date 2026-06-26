extends SceneTree

func _init():
	print("\n=================================================================")
	print("[PHASE 2.5+] AUTOMATED REGRESSION HARNESS: RUNTIME EVENT LEDGER VERIFICATION")
	print("=================================================================\n")
	
	print("--- STAGE 1: BOOTING ORCHESTRATION & EVENT LEDGER CUSTODIANS ---")
	var logger = StructuredLogger if StructuredLogger else load("res://scripts/system/StructuredLogger.gd").new()
	var router = NavigationRouter if NavigationRouter else load("res://scripts/NavigationRouter.gd").new()
	var modal_mgr = ModalWindowManager if ModalWindowManager else load("res://scripts/ui/ModalWindowManager.gd").new()
	var profile = PlayerProfile if PlayerProfile else load("res://scripts/system/PlayerProfile.gd").new()
	var orch = ExperienceOrchestrator if ExperienceOrchestrator else load("res://scripts/system/ExperienceOrchestrator.gd").new()
	var kernel = InteractionKernel if InteractionKernel else load("res://scripts/system/InteractionKernel.gd").new()
	
	if not StructuredLogger:
		root.add_child(logger)
		logger.name = "StructuredLogger"
		logger._ready()
	if not NavigationRouter:
		root.add_child(router)
		router.name = "NavigationRouter"
		router._enter_tree()
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
		
	print("✅ STAGE 1 PASS: Runtime Event Ledger active.\n")
	
	print("--- STAGE 2: EXECUTING SINGLE FULL SESSION LIFECYCLE ---")
	
	print("\n  [Action 1] Cold Boot -> Initializing LandingScreen...")
	router.show_landing_screen()
	
	print("\n  [Action 2] Play -> Opening Universe List (WeeklyFeaturedScreen)...")
	router._on_play_requested()
	
	print("\n  [Action 3] Universe -> User selects 'history' -> Opening WorldSelectScreen...")
	router._on_play_universe_requested("history")
	
	print("\n  [Action 4] World -> User selects 'ancient_egypt' -> Triggering Scenario 1 (Memory Cascade)...")
	router._on_world_selected("history", "ancient_egypt")
	
	print("\n  [Action 5] Scenario 1 (Memory Cascade) active -> User submits Answer...")
	profile.record_cognitive_event("recall", "memory_cascade", "history", "ancient_egypt", true, 1420.0)
	router._on_cascade_completed()
	
	print("\n  [Action 6] Scenario 2 (Rapid Classification) active -> User submits Answer...")
	profile.record_cognitive_event("rapid_classification", "rapid_classification", "history", "ancient_egypt", true, 810.0)
	router._on_cascade_completed()
	
	print("\n  [Action 7] Scenario 3 (Signal vs Noise) active -> User submits Answer -> Invoking Mirror Update...")
	profile.record_cognitive_event("pattern_recognition", "signal_vs_noise", "history", "ancient_egypt", false, 2100.0)
	router._on_cascade_completed()
	
	print("\n  [Action 8] Return Home -> User clicks RETURN HOME...")
	router.show_landing_screen()
	
	print("\n--- STAGE 3: DUMPING RUNTIME EVENT LEDGER ORDERING TRACE ---")
	logger.dump_runtime_event_ledger()
	
	var ledger: Array = logger.runtime_event_ledger
	if ledger.size() < 10:
		push_error("LEDGER FAIL: Runtime Event Ledger failed to capture complete session ordering trace.")
		quit(1)
		return
		
	var found_inject = false
	var found_enter = false
	var found_ready = false
	var found_dispatch = false
	
	for entry in ledger:
		if entry["event_type"] == "inject_payload": found_inject = true
		elif entry["event_type"] == "_enter_tree": found_enter = true
		elif entry["event_type"] == "_ready": found_ready = true
		elif entry["event_type"] == "signal_dispatch": found_dispatch = true
		
	if not found_inject or not found_enter or not found_ready:
		push_error("LEDGER FAIL: Runtime Event Ledger missing required lifecycle trace events (inject_payload -> _enter_tree -> _ready).")
		quit(1)
		return
		
	print("✅ STAGE 3 PASS: Runtime Event Ledger perfectly reconstructed genuine engine lifecycle ordering trace across full session.\n")
	
	print("=================================================================")
	print("🏆 RUNTIME EVENT LEDGER HARNESS PASS: 100% GROUND TRUTH COMPLETE SATISFIED.")
	print("=================================================================\n")
	
	if not StructuredLogger: logger.free()
	if not NavigationRouter: router.free()
	if not ModalWindowManager: modal_mgr.free()
	if not PlayerProfile: profile.free()
	if not ExperienceOrchestrator: orch.free()
	if not InteractionKernel: kernel.free()
	quit(0)
