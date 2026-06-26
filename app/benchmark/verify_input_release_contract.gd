extends SceneTree

func _init():
	print("\n=================================================================")
	print("[PHASE 2.5+] AUTOMATED REGRESSION HARNESS: INPUT RELEASE CONTRACT")
	print("=================================================================\n")
	
	print("--- STAGE 1: BOOTING ORCHESTRATION & INPUT CUSTODIANS ---")
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
		
	print("✅ STAGE 1 PASS: Platform singletons active.\n")
	
	print("--- STAGE 2: ASSERTING SINGLE AUTHORITATIVE INPUT RELEASE CONTRACT ---")
	
	print("\n  [Action 1] Tapping World Card -> Triggering scenario injection...")
	router._on_world_selected("history", "ancient_egypt")
	
	print("    Simulating active transition locks during scenario stream...")
	kernel._active_transitions_count = 1
	kernel._transitional_suppression_lock = true
	print("    is_ui_blocking() before release: ", kernel.is_ui_blocking())
	if not kernel.is_ui_blocking():
		push_error("CONTRACT FAIL: UI failed to establish transition lock.")
		quit(1)
		return
		
	print("\n  [Action 2] Scenario mounting resolves -> Triggering orch.finalize_scenario_mounting()...")
	orch.finalize_scenario_mounting("memory_cascade")
	
	print("    is_ui_blocking() after release: ", kernel.is_ui_blocking())
	if kernel.is_ui_blocking():
		push_error("CONTRACT FAIL: Authoritative Input Release Contract failed to unblock UI.")
		quit(1)
		return
	print("✅ STAGE 2 PASS: Input Release Contract perfectly cleared all transition locks and restored global interaction determinism.\n")
	
	print("--- STAGE 3: ASSERTING MODAL WINDOW MANAGER STACK EMPTY CLEANUP ---")
	print("\n  [Action 3] Pushing modal to stack to enable Input Blocker...")
	var dummy_screen = CanvasLayer.new()
	dummy_screen.name = "DummyScreen"
	modal_mgr.push_modal(dummy_screen, true, "ModalWindowManager")
	print("    Input Blocker Mouse Filter: ", modal_mgr._input_blocker.mouse_filter)
	
	print("\n  [Action 4] Popping modal -> Stack becomes empty...")
	modal_mgr._last_write_frame = -1
	modal_mgr.pop_modal(dummy_screen, "ModalWindowManager")
	print("    Input Blocker Mouse Filter after empty stack: ", modal_mgr._input_blocker.mouse_filter)
	
	if modal_mgr._input_blocker.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		push_error("CONTRACT FAIL: ModalWindowManager failed to set Input Blocker to IGNORE on empty stack.")
		quit(1)
		return
		
	print("✅ STAGE 3 PASS: ModalWindowManager perfectly resets Input Blocker to IGNORE when modal stack empties.\n")
	
	print("=================================================================")
	print("🏆 INPUT RELEASE CONTRACT HARNESS PASS: 100% LIFECYCLE GOVERNANCE SATISFIED.")
	print("=================================================================\n")
	
	if not NavigationRouter: router.free()
	if not ModalWindowManager: modal_mgr.free()
	if not PlayerProfile: profile.free()
	if not ExperienceOrchestrator: orch.free()
	if not InteractionKernel: kernel.free()
	dummy_screen.free()
	quit(0)
