extends SceneTree

func _init():
	print("\n=================================================================")
	print("[PHASE 2.5+] AUTOMATED REGRESSION HARNESS: IMMUTABLE TRANSITION CONTEXT")
	print("=================================================================\n")
	
	print("--- STAGE 1: BOOTING ORCHESTRATION & STATE CUSTODIANS ---")
	var router = NavigationRouter if NavigationRouter else load("res://scripts/NavigationRouter.gd").new()
	var modal_mgr = ModalWindowManager if ModalWindowManager else load("res://scripts/ui/ModalWindowManager.gd").new()
	var profile = PlayerProfile if PlayerProfile else load("res://scripts/system/PlayerProfile.gd").new()
	var orch = ExperienceOrchestrator if ExperienceOrchestrator else load("res://scripts/system/ExperienceOrchestrator.gd").new()
	var nav_state = NavigationState if NavigationState else load("res://scripts/system/NavigationState.gd").new()
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
	if not NavigationState:
		root.add_child(nav_state)
		nav_state.name = "NavigationState"
	if not InteractionKernel:
		root.add_child(kernel)
		kernel.name = "InteractionKernel"
		kernel._ready()
		
	print("✅ STAGE 1 PASS: NavigationState and singletons active.\n")
	
	print("--- STAGE 2: VERIFYING IMMUTABLE TRANSITION CONTEXT CONTINUITY ---")
	
	print("\n  [Action 1] Tapping Play -> Opening Universe List...")
	router._on_play_requested()
	
	print("\n  [Action 2] User selects 'history' -> Opening WorldSelectScreen...")
	router._on_play_universe_requested("history")
	
	print("\n  [Action 3] User selects 'ancient_egypt' -> Triggering Scenario 1 (Memory Cascade)...")
	router._on_world_selected("history", "ancient_egypt")
	
	var ctx1 = nav_state.get_transition_context()
	print("    Locked Transition Context 1: ", ctx1)
	if ctx1.get("universe_id") != "history" or ctx1.get("world_id") != "ancient_egypt":
		push_error("CONTEXT FAIL: Initial transition context missing target universe or world.")
		quit(1)
		return
		
	print("\n  [Action 4] Completing Scenario 1 -> Triggering _on_cascade_completed() -> Advancing to Scenario 2...")
	router._on_cascade_completed()
	
	var ctx2 = nav_state.get_transition_context()
	print("    Locked Transition Context 2: ", ctx2)
	if ctx2.get("universe_id") != "history" or ctx2.get("world_id") != "ancient_egypt":
		push_error("CONTEXT FAIL: Stale state detected! World context jumped to: " + str(ctx2.get("world_id")))
		quit(1)
		return
		
	print("\n  [Action 5] Completing Scenario 2 -> Triggering _on_cascade_completed() -> Advancing to Scenario 3...")
	router._on_cascade_completed()
	
	var ctx3 = nav_state.get_transition_context()
	print("    Locked Transition Context 3: ", ctx3)
	if ctx3.get("universe_id") != "history" or ctx3.get("world_id") != "ancient_egypt":
		push_error("CONTEXT FAIL: Stale state detected! World context jumped to: " + str(ctx3.get("world_id")))
		quit(1)
		return
		
	print("\n✅ STAGE 2 PASS: 100% world context preservation achieved across multi-scenario progression chain. Zero hardcoded jumps to firstaid.\n")
	
	print("=================================================================")
	print("🏆 IMMUTABLE TRANSITION CONTEXT HARNESS PASS: 100% STATE CONTINUITY.")
	print("=================================================================\n")
	
	if not NavigationRouter: router.free()
	if not ModalWindowManager: modal_mgr.free()
	if not PlayerProfile: profile.free()
	if not ExperienceOrchestrator: orch.free()
	if not NavigationState: nav_state.free()
	if not InteractionKernel: kernel.free()
	quit(0)
