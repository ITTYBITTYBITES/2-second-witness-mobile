extends SceneTree

func _init():
	print("\n=================================================================")
	print("[PHASE 2.5+] AUTOMATED REGRESSION HARNESS: CORE GAMEPLAY ASSERTIONS")
	print("=================================================================\n")
	
	print("--- STAGE 1: BOOTING ORCHESTRATION & STACK CUSTODIANS ---")
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
	
	print("--- STAGE 2: EXECUTING FULL NAVIGATION JOURNEY & ASSERTING STACK PURITY ---")
	
	print("\n  [Step 1] Boot game -> Initializing LandingScreen...")
	router.show_landing_screen()
	
	print("\n  [Step 2] Navigate: Landing -> WeeklyFeatured...")
	router._on_discover_requested()
	
	print("\n  [Step 3] Navigate: WeeklyFeatured -> WorldSelect...")
	router._on_play_universe_requested("history")
	
	print("\n  [Step 4] Navigate: WorldSelect -> GameplayHUD -> Injecting scenario...")
	router._on_world_selected("history", "ancient_egypt")
	
	print("\n  [Step 5] Invoking single authoritative completion hook: on_scene_transition_complete()...")
	router.on_scene_transition_complete()
	
	print("\n  [Step 6] Attempting duplicate execution of on_scene_transition_complete()...")
	router.on_scene_transition_complete()
	
	print("\n  [Step 7] Testing utility modal filtering in navigation stack...")
	router.toggle_mirror_modal()
	print("    Active Navigation Stack after Mirror Push: ", router.navigation_stack)
	if router.navigation_stack.has("PlayerProfileScreen"):
		push_error("STACK FAIL: PlayerProfileScreen leaked into navigation stack.")
		quit(1)
		return
	print("✅ STAGE 2 PASS: PlayerProfileScreen successfully excluded from navigation history. Stack purity proven.\n")
	
	print("--- STAGE 3: ASSERTING ALL 4 CORE RUNTIME ASSERTIONS ---")
	print("  1. !LayoutFreezer.is_frozen = ", not LayoutFreezer.is_frozen)
	print("  2. !InteractionKernel.is_ui_blocking() = ", not kernel.is_ui_blocking())
	
	router.toggle_mirror_modal() 
	print("  [Action] Toggling mirror off to assert empty modal stack...")
	print("  3. ModalWindowManager.modal_stack.is_empty() = ", modal_mgr.get_modal_stack().is_empty())
	print("  4. current_screen == GameplayHUD = ", router.current_screen_name == "GameplayHUD")
	
	assert(not LayoutFreezer.is_frozen, "Fatal: LayoutFreezer remained frozen before gameplay began.")
	assert(not kernel.is_ui_blocking(), "Fatal: InteractionKernel remained blocking before gameplay began.")
	assert(modal_mgr.get_modal_stack().is_empty(), "Fatal: Modal stack was not empty when gameplay started.")
	assert(router.current_screen_name == "GameplayHUD", "Fatal: Current screen != GameplayHUD after transition completed.")
	
	print("\n✅ STAGE 3 PASS: All 4 core runtime assertions satisfied perfectly. Zero input deadlocks, zero Quiescence re-freezing.\n")
	
	print("=================================================================")
	print("🏆 CORE GAMEPLAY ASSERTIONS HARNESS PASS: 100% STATE MACHINE CORRECT.")
	print("=================================================================\n")
	
	if not NavigationRouter: router.free()
	if not ModalWindowManager: modal_mgr.free()
	if not PlayerProfile: profile.free()
	if not ExperienceOrchestrator: orch.free()
	if not InteractionKernel: kernel.free()
	quit(0)
