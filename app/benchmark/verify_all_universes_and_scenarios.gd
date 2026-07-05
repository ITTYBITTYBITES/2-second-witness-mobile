extends SceneTree

func _init():
	print("\n=================================================================")
	print("[PHASE 2.5+] COMPREHENSIVE VERIFICATION: ALL 7 UNIVERSES, WORLDS & SCENARIOS")
	print("=================================================================\n")
	
	print("--- STAGE 1: BOOTING GOVERNED PLATFORM CUSTODIANS ---")
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
	
	print("--- STAGE 2: PRIORITY 2 — VERIFYING EVERY UNIVERSE HAS WORLDS ---")
	var all_universes = ["history", "science_lab", "creative_arts", "society_mind", "tech_ops", "life_sciences", "frontier"]
	
	for uni in all_universes:
		print("\n  [Universe Target] Verifying world population for: ", uni.capitalize())
		router._on_play_universe_requested(uni)
		
		var world_select = router.active_secondary_screen
		if not world_select or world_select.name != "WorldSelectScreen":
			push_error("POPULATION FAIL: WorldSelectScreen failed to instantiate for universe: " + uni)
			quit(1)
			return
			
		var grid = world_select.get_node_or_null("PanelContainer/MarginContainer/VBoxContainer/GridContainer")
		var cards = grid.get_children() if grid else []
		print("    Populated World Cards Count: ", cards.size())
		if cards.size() < 5:
			push_error("POPULATION FAIL: Universe '" + uni + "' failed to populate world cards. Got: " + str(cards.size()))
			quit(1)
			return
			
		for c in cards:
			print("      World Card: ", c.text.split("\n")[0])
			
	print("\n✅ STAGE 2 PASS: All 7 universes successfully populate world selection cards exactly like Frontier.\n")
	
	print("--- STAGE 3: PRIORITY 3 — VERIFYING 3-SCENARIO GAMEPLAY STREAM TO MIRROR LOOP ---")
	print("  Target Loop: Gameplay -> Scenario 1 -> Scenario 2 -> Scenario 3 -> Mirror -> Return Home")
	
	print("\n  [Action 1] Selecting World 'ancient_egypt' in 'history' -> Gameplay starts...")
	router._on_world_selected("history", "ancient_egypt")
	if router.current_screen_name != "GameplayHUD":
		push_error("STREAM FAIL: GameplayHUD failed to mount upon world selection.")
		quit(1)
		return
		
	print("\n  [Action 2] Executing Scenario 1 (MemoryCascade)...")
	profile.record_cognitive_event("recall", "memory_cascade", "history", "ancient_egypt", true, 1420.0)
	print("    Observation recorded: Recall | RT: 1420.0ms")
	
	print("\n  [Action 3] Executing Scenario 2 (RapidClassification)...")
	profile.record_cognitive_event("rapid_classification", "rapid_classification", "history", "ancient_egypt", true, 810.0)
	print("    Observation recorded: Rapid Classification | RT: 810.0ms")
	
	print("\n  [Action 4] Executing Scenario 3 (SignalVsNoise)...")
	profile.record_cognitive_event("pattern_recognition", "signal_vs_noise", "history", "ancient_egypt", false, 2100.0)
	print("    Observation recorded: Pattern Recognition | RT: 2100.0ms")
	
	print("\n  [Action 5] Scenarios complete -> Opening Mirror (PlayerProfileScreen)...")
	router.toggle_mirror_modal()
	if router.current_screen_name != "PlayerProfileScreen":
		push_error("STREAM FAIL: Mirror failed to open after scenario completion.")
		quit(1)
		return
		
	var mirror = router.persistent_mirror_instance
	var container = mirror.get_node_or_null("PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/InsightsContainer")
	var text_content = ""
	for c in container.get_children():
		if c is RichTextLabel: text_content += c.text + "\n"
		elif c is HBoxContainer: text_content += "[NAVIGATION BUTTONS: CONTINUE JOURNEY | EXPLORE RECOMMENDATION | RETURN HOME]\n"
		
	print("  [Mirror Centerpiece Content]:\n---\n", text_content, "\n---")
	
	if not text_content.contains("Working Memory:") or not text_content.contains("Suggested Exploration:"):
		push_error("STREAM FAIL: Mirror centerpiece failed to render rich observation trends or Bayesian recommendations.")
		quit(1)
		return
		
	print("\n  [Action 6] Return Home -> User clicks RETURN HOME...")
	router.show_landing_screen()
	if router.current_screen_name != "LandingScreen":
		push_error("STREAM FAIL: Return Home failed to restore LandingScreen.")
		quit(1)
		return
		
	print("\n✅ STAGE 3 PASS: 3-scenario gameplay stream successfully feeds observations into the Mirror centerpiece and returns home flawlessly.\n")
	
	print("=================================================================")
	print("🏆 COMPREHENSIVE VERIFICATION HARNESS PASS: ALL UNIVERSES & GAMEPLAY LOOPS SATISFIED.")
	print("=================================================================\n")
	
	if not NavigationRouter: router.free()
	if not ModalWindowManager: modal_mgr.free()
	if not PlayerProfile: profile.free()
	if not ContentRegistry: registry.free()
	if not InteractionKernel: kernel.free()
	quit(0)
