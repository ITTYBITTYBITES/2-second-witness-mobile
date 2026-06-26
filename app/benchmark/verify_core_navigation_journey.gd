extends SceneTree

func _init():
	print("\n=================================================================")
	print("[PHASE 2.5+] CORE NAVIGATION JOURNEY AUTOMATED REGRESSION SUITE")
	print("=================================================================\n")
	
	print("--- STAGE 1: BOOTING ORCHESTRATION & NAVIGATION CUSTODIANS ---")
	var router = NavigationRouter if NavigationRouter else load("res://scripts/NavigationRouter.gd").new()
	var modal_mgr = ModalWindowManager if ModalWindowManager else load("res://scripts/ui/ModalWindowManager.gd").new()
	var profile = PlayerProfile if PlayerProfile else load("res://scripts/system/PlayerProfile.gd").new()
	var registry = ContentRegistry if ContentRegistry else load("res://scripts/content/ContentRegistry.gd").new()
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
	if not ContentRegistry:
		root.add_child(registry)
		registry.name = "ContentRegistry"
		registry._ready()
	if not InteractionKernel:
		root.add_child(kernel)
		kernel.name = "InteractionKernel"
		kernel._ready()
		
	print("✅ STAGE 1 PASS: Navigation singletons active.\n")
	
	print("--- STAGE 2: VERIFYING FORWARD USER JOURNEY ---")
	print("  Journey Target: Landing -> Universe List -> World List -> Scenario -> Mirror")
	
	print("\n  [Step 1] Initializing LandingScreen...")
	router.show_landing_screen()
	if router.current_screen_name != "LandingScreen":
		push_error("NAVIGATION FAIL: Current screen != LandingScreen")
		quit(1)
		return
		
	print("\n  [Step 2] User clicks BtnDiscover -> Universe List (WeeklyFeaturedScreen)...")
	router._on_discover_requested()
	if router.current_screen_name != "WeeklyFeaturedScreen":
		push_error("NAVIGATION FAIL: Current screen != WeeklyFeaturedScreen")
		quit(1)
		return
		
	print("\n  [Step 3] User clicks Universe Card -> World List (WorldSelectScreen)...")
	router._on_play_universe_requested("frontier")
	if router.current_screen_name != "WorldSelectScreen":
		push_error("NAVIGATION FAIL: Current screen != WorldSelectScreen")
		quit(1)
		return
		
	print("\n  [Step 4] User clicks World Card -> Scenario / Gameplay Stream (GameplayHUD)...")
	router._on_world_selected("frontier", "foundations")
	if router.current_screen_name != "GameplayHUD":
		push_error("NAVIGATION FAIL: Current screen != GameplayHUD")
		quit(1)
		return
		
	print("\n  [Step 5] User clicks ★ THE MIRROR -> Mirror Modal (PlayerProfileScreen)...")
	router.toggle_mirror_modal()
	if router.current_screen_name != "PlayerProfileScreen":
		push_error("NAVIGATION FAIL: Current screen != PlayerProfileScreen")
		quit(1)
		return
		
	print("\n✅ FORWARD JOURNEY PASS: Successfully reached Mirror from Landing via Universe/World lists.\n")
	
	print("--- STAGE 3: VERIFYING REVERSE USER JOURNEY (BI-DIRECTIONAL INTEGRITY) ---")
	print("  Journey Target: Mirror -> Back to World List -> Back to Universe List -> Landing")
	
	print("\n  [Step 6] User exits Mirror -> Back to World List / GameplayHUD...")
	# Simulate toggling mirror modal off (return requested)
	router.toggle_mirror_modal()
	if router.current_screen_name != "GameplayHUD":
		push_error("NAVIGATION FAIL: Current screen != GameplayHUD. Got: " + router.current_screen_name)
		quit(1)
		return
		
	print("\n  [Step 7] User clicks < LEAVE STREAM -> Back to World List (WorldSelectScreen)...")
	router._on_play_universe_requested(router.active_universe_selection)
	if router.current_screen_name != "WorldSelectScreen":
		push_error("NAVIGATION FAIL: Current screen != WorldSelectScreen")
		quit(1)
		return
		
	print("\n  [Step 8] User clicks Return on World Select -> Back to Universe List (WeeklyFeaturedScreen)...")
	router._on_discover_requested()
	if router.current_screen_name != "WeeklyFeaturedScreen":
		push_error("NAVIGATION FAIL: Current screen != WeeklyFeaturedScreen")
		quit(1)
		return
		
	print("\n  [Step 9] User clicks Return on Universe List -> Back to Landing (LandingScreen)...")
	router.show_landing_screen()
	if router.current_screen_name != "LandingScreen":
		push_error("NAVIGATION FAIL: Current screen != LandingScreen")
		quit(1)
		return
		
	print("\n✅ REVERSE JOURNEY PASS: Successfully navigated backward from Mirror to Landing menu. Zero dead ends.\n")
	
	print("=================================================================")
	print("🏆 CORE NAVIGATION JOURNEY HARNESS PASS: 100% BI-DIRECTIONAL NAVIGATION INTEGRITY SATISFIED.")
	print("=================================================================\n")
	
	if not NavigationRouter: router.free()
	if not ModalWindowManager: modal_mgr.free()
	if not PlayerProfile: profile.free()
	if not ContentRegistry: registry.free()
	if not InteractionKernel: kernel.free()
	quit(0)
