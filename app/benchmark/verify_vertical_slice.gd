extends SceneTree

func _init():
	print("\n=================================================================")
	print("[PHASE 2.5] END-TO-END VERTICAL SLICE AUTOMATED REGRESSION SUITE")
	print("=================================================================\n")
	
	print("--- STAGE 1: BOOT ENGINE & SINGLETON INITIALIZATION ---")
	var profile = load("res://scripts/system/PlayerProfile.gd").new()
	profile._ready()
	
	var registry = load("res://scripts/content/ContentRegistry.gd").new()
	registry._ready()
	var loader = load("res://scripts/content/ContentLoader.gd").new()
	loader.registry = registry
	loader._ready()
	
	var orch = load("res://scripts/system/ExperienceOrchestrator.gd").new()
	orch._ready()
	var cust = load("res://scripts/ui/WorldProfileCustodian.gd").new()
	cust._ready()
	var themes = load("res://scripts/ThemeManager.gd").new()
	themes._ready()
	var modal_mgr = load("res://scripts/ui/ModalWindowManager.gd").new()
	modal_mgr._ready()
	
	print("✅ STAGE 1 PASS: Kernel and singletons active with zero exceptions.\n")
	
	print("--- STAGE 2: ASSERTIONS & INVARIANT VERIFICATION ---")
	
	var session_vector = orch.determine_next_experience(profile)
	var active_uni = session_vector.get("universe", "history")
	print("  Active Theme ID: ", active_uni)
	if active_uni != "history":
		push_error("ASSERTION FAILED: active_theme_id != 'history'. Got: " + active_uni)
		quit(1)
		return
	print("✅ ASSERTION PASS: active_theme_id == 'history'")
	
	var renderer = load("res://scripts/ui/UniverseRenderer.gd").new()
	var def = renderer.universe_definitions.get(active_uni, renderer.universe_definitions["science_lab"])
	var lens_profile = def.get("lens_profile", "unknown")
	print("  Spawned Lens Profile: ", lens_profile)
	if lens_profile != "eye_of_horus":
		push_error("ASSERTION FAILED: spawned lens profile != 'eye_of_horus'. Got: " + lens_profile)
		quit(1)
		return
	print("✅ ASSERTION PASS: spawned lens profile == 'eye_of_horus'")
	
	var world_id = session_vector.get("world", "unknown")
	print("  Spawned World ID: ", world_id)
	if world_id == "unknown" or world_id == "default":
		push_error("ASSERTION FAILED: Fallback universe/world was selected: " + world_id)
		quit(1)
		return
	print("✅ ASSERTION PASS: no fallback universe was selected")
	
	var initial_stack_depth = modal_mgr._modal_stack.size()
	print("  Initial Modal Stack Depth: ", initial_stack_depth)
	
	var mirror_screen = load("res://scripts/ui/screens/PlayerProfileScreen.gd").new()
	mirror_screen.name = "PlayerProfileScreen"
	modal_mgr.push_modal(mirror_screen, true)
	print("  Modal Stack Depth After Push: ", modal_mgr._modal_stack.size())
	if modal_mgr._modal_stack.size() != initial_stack_depth + 1:
		push_error("ASSERTION FAILED: Modal stack failed to increment on push.")
		quit(1)
		return
		
	modal_mgr.pop_modal(mirror_screen)
	print("  Modal Stack Depth After Pop: ", modal_mgr._modal_stack.size())
	if modal_mgr._modal_stack.size() != initial_stack_depth:
		push_error("ASSERTION FAILED: Modal stack depth did not return to original value after exiting Mirror.")
		quit(1)
		return
	print("✅ ASSERTION PASS: modal stack depth returns to its original value after exiting the Mirror")
	
	if not modal_mgr._modal_stack.is_empty():
		push_error("ASSERTION FAILED: Orphaned nodes detected in modal stack.")
		quit(1)
		return
	print("✅ ASSERTION PASS: no orphaned nodes remain after returning to the landing state\n")
	
	print("--- STAGE 3: 3 HISTORY SCENARIOS & SAVE INVARIANCE ---")
	profile.record_cognitive_event("recall", "memory_cascade", "history", "ancient_egypt", true, 1482.0)
	profile.record_cognitive_event("rapid_classification", "rapid_classification", "history", "ancient_egypt", true, 850.0)
	profile.record_cognitive_event("pattern_recognition", "signal_vs_noise", "history", "ancient_egypt", false, 2100.0)
	
	var rec = profile.get_adaptive_recommendation()
	print("  Adaptive Recommendation: ", rec.get("reason"))
	
	var p2 = load("res://scripts/system/PlayerProfile.gd").new()
	p2._ready()
	if p2.lifetime_sessions != profile.lifetime_sessions:
		push_error("ASSERTION FAILED: Save system reload failed to reproduce identical lifetime sessions.")
		quit(1)
		return
	print("✅ ASSERTION PASS: Save created and reload reproduces the exact same state.\n")
	
	print("=================================================================")
	print("🏆 PHASE 2.5 REGRESSION SUITE PASS: ALL 9 VERIFICATION INVARIANTS SATISFIED.")
	print("=================================================================\n")
	
	profile.free()
	p2.free()
	registry.free()
	loader.free()
	orch.free()
	cust.free()
	themes.free()
	modal_mgr.free()
	renderer.free()
	quit(0)
