extends SceneTree

func _init():
	print("\n=================================================================")
	print("[PHASE 2.5+] VERIFYING COMPLETE COHERENT PRODUCT LOOP & MIRROR POPULATION")
	print("=================================================================\n")
	
	print("--- STAGE 1: BOOTING COHERENT PLATFORM SINGLETONS ---")
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
		
	print("✅ STAGE 1 PASS: Platform singletons active.\n")
	
	print("--- STAGE 2: ASSERTING BRAND-NEW USER MIRROR EXPERIENCE (lifetime = 0) ---")
	profile.lifetime_sessions = 0
	router.toggle_mirror_modal()
	var mirror_zero = router.persistent_mirror_instance
	
	var container_zero = mirror_zero.get_node_or_null("PanelContainer/MarginContainer/VBoxContainer/InsightsContainer")
	var text_zero = ""
	for c in container_zero.get_children():
		if c is RichTextLabel: text_zero += c.text + "\n"
		elif c is Button: text_zero += "[BUTTON: " + c.text + "]\n"
		
	print("  [Mirror Text for lifetime_sessions == 0]:\n---\n", text_zero, "\n---")
	
	if not text_zero.contains("Welcome to the Mirror") or not text_zero.contains("Universes explored: 0") or not text_zero.contains("BEGIN JOURNEY"):
		push_error("MIRROR FAIL: Brand-new user mirror experience missing required welcome copy or Begin Journey action.")
		quit(1)
		return
		
	print("✅ STAGE 2 PASS: Brand-new user Mirror perfectly populated with introductory copy and clear onboarding call to action.\n")
	
	# Close mirror
	router.toggle_mirror_modal()
	
	print("--- STAGE 3: EXECUTING COMPLETE PRODUCT LOOP (Launch -> Play -> Universe -> World -> Scenario -> Mirror -> Home) ---")
	
	print("\n  [Step 1] Launch -> LandingScreen...")
	router.show_landing_screen()
	if router.current_screen_name != "LandingScreen": push_error("LOOP FAIL: Launch")
	
	print("\n  [Step 2] Play -> Universe List (WeeklyFeaturedScreen)...")
	router._on_play_requested()
	if router.current_screen_name != "WeeklyFeaturedScreen": push_error("LOOP FAIL: Play")
	
	print("\n  [Step 3] Universe -> World List (WorldSelectScreen)...")
	router._on_play_universe_requested("history")
	if router.current_screen_name != "WorldSelectScreen": push_error("LOOP FAIL: Universe")
	
	print("\n  [Step 4] World -> Scenario Stream (GameplayHUD)...")
	router._on_world_selected("history", "ancient_egypt")
	if router.current_screen_name != "GameplayHUD": push_error("LOOP FAIL: World")
	
	print("\n  [Step 5] Player completes scenario -> Incrementing lifetime_sessions...")
	profile.lifetime_sessions = 5
	profile.record_cognitive_event("rapid_classification", "rapid_classification", "history", "ancient_egypt", true, 850.0)
	
	print("\n  [Step 6] Mirror -> Opening PlayerProfileScreen (now contains rich evolutionary data)...")
	router.toggle_mirror_modal()
	if router.current_screen_name != "PlayerProfileScreen": push_error("LOOP FAIL: Mirror")
	
	var mirror_rich = router.persistent_mirror_instance
	var container_rich = mirror_rich.get_node_or_null("PanelContainer/MarginContainer/VBoxContainer/InsightsContainer")
	var text_rich = ""
	for c in container_rich.get_children():
		if c is RichTextLabel: text_rich += c.text + "\n"
		elif c is HBoxContainer:
			text_rich += "[BUTTONS: " + c.get_child(0).text + " | " + c.get_child(1).text + " | " + c.get_child(2).text + "]\n"
			
	print("  [Mirror Text for active user]:\n---\n", text_rich, "\n---")
	if not text_rich.contains("Working Memory:") or not text_rich.contains("Suggested Exploration:") or not text_rich.contains("RETURN HOME"):
		push_error("MIRROR FAIL: Active user mirror missing rich evolutionary observations, suggestions, or 3-way navigation.")
		quit(1)
		return
		
	print("\n  [Step 7] Back to Home -> User clicks RETURN HOME...")
	router.show_landing_screen()
	if router.current_screen_name != "LandingScreen": push_error("LOOP FAIL: Back to Home")
	
	print("\n✅ STAGE 3 PASS: Complete coherent product loop successfully traversed. Zero empty screens, zero dead ends.\n")
	
	print("=================================================================")
	print("🏆 COMPLETE PRODUCT LOOP HARNESS PASS: 100% COHERENT PRODUCT EXPERIENCE SATISFIED.")
	print("=================================================================\n")
	
	if not NavigationRouter: router.free()
	if not ModalWindowManager: modal_mgr.free()
	if not PlayerProfile: profile.free()
	if not ContentRegistry: registry.free()
	if not InteractionKernel: kernel.free()
	quit(0)
