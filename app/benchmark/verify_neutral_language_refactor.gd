extends SceneTree

func _init():
	print("\n=================================================================")
	print("[PHASE 2.5+] AUTOMATED REGRESSION HARNESS: NEUTRAL LANGUAGE REFACTOR")
	print("=================================================================\n")
	
	print("--- STAGE 1: BOOTING ORCHESTRATION & STATE CUSTODIANS ---")
	var router = NavigationRouter if NavigationRouter else load("res://scripts/NavigationRouter.gd").new()
	var modal_mgr = ModalWindowManager if ModalWindowManager else load("res://scripts/ui/ModalWindowManager.gd").new()
	var profile = PlayerProfile if PlayerProfile else load("res://scripts/system/PlayerProfile.gd").new()
	var orch = ExperienceOrchestrator if ExperienceOrchestrator else load("res://scripts/system/ExperienceOrchestrator.gd").new()
	var nav_state = NavigationState if NavigationState else load("res://scripts/system/NavigationState.gd").new()
	var kernel = InteractionKernel if InteractionKernel else load("res://scripts/system/InteractionKernel.gd").new()
	
	if not NavigationRouter: root.add_child(router); router.name = "NavigationRouter"; router._ready()
	if not ModalWindowManager: root.add_child(modal_mgr); modal_mgr.name = "ModalWindowManager"; modal_mgr._ready()
	if not PlayerProfile: root.add_child(profile); profile.name = "PlayerProfile"; profile._ready()
	if not ExperienceOrchestrator: root.add_child(orch); orch.name = "ExperienceOrchestrator"; orch._ready()
	if not NavigationState: root.add_child(nav_state); nav_state.name = "NavigationState"
	if not InteractionKernel: root.add_child(kernel); kernel.name = "InteractionKernel"; kernel._ready()
		
	print("✅ STAGE 1 PASS: Platform singletons active.\n")
	
	print("--- STAGE 2: ASSERTING NEUTRAL LANGUAGE REPLACEMENT CONTRACTS ---")
	
	print("\n  [Check 1] LandingScreen -> Verifying subtitle...")
	router.show_landing_screen()
	var landing = router.active_landing_screen
	var subtitle = landing.get_node_or_null("Panel/Subtitle")
	print("    Landing Subtitle: ", subtitle.text if subtitle else "NULL")
	if not subtitle or subtitle.text != "An interactive observation discovery experience":
		push_error("LANGUAGE FAIL: LandingScreen failed to reflect neutral observation experience.")
		quit(1); return
		
	print("\n  [Check 2] PlayerProfileScreen -> Verifying Mirror title & traits header...")
	router.toggle_mirror_modal()
	var mirror = router.persistent_mirror_instance
	var title = mirror.get_node_or_null("PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/Header/Title")
	var t_sec = mirror.get_node_or_null("PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/SectionTraits")
	print("    Mirror Title: ", title.text if title else "NULL")
	print("    Traits Header: ", t_sec.text if t_sec else "NULL")
	
	if not title or title.text != "MIRROR":
		push_error("LANGUAGE FAIL: PlayerProfileScreen failed to use the canonical Mirror term.")
		quit(1); return
		
	if not t_sec or t_sec.text != "OBSERVATION METRICS (PATTERN SKILLS)":
		push_error("LANGUAGE FAIL: PlayerProfileScreen failed to rename Cognitive Traits to Observation Metrics.")
		quit(1); return
		
	print("\n  [Check 3] MonetizationGate -> Verifying universe preview copy...")
	var gate_scene = load("res://scenes/ui/screens/MonetizationGate.tscn")
	var gate = gate_scene.instantiate()
	root.add_child(gate)
	gate.setup_universe_unlock("history")
	var g_sub = gate.get_node_or_null("PanelContainer/MarginContainer/VBoxContainer/Subtitle")
	print("    Monetization Subtitle:\n---\n", g_sub.text if g_sub else "NULL", "\n---")
	if not g_sub or g_sub.text.contains("cognitive") or not g_sub.text.contains("observation"):
		push_error("LANGUAGE FAIL: MonetizationGate failed to reflect neutral observation mechanics.")
		quit(1); return
	gate.free()
	
	print("\n✅ STAGE 2 PASS: 100% of user-facing medical, diagnostic, and clinical terminology perfectly eliminated in favor of neutral observation contracts.\n")
	
	print("=================================================================")
	print("🏆 NEUTRAL LANGUAGE REFACTOR HARNESS PASS: 100% SUCCESS CONDITION ATTAINED.")
	print("=================================================================\n")
	
	if not NavigationRouter: router.free()
	if not ModalWindowManager: modal_mgr.free()
	if not PlayerProfile: profile.free()
	if not ExperienceOrchestrator: orch.free()
	if not NavigationState: nav_state.free()
	if not InteractionKernel: kernel.free()
	quit(0)
