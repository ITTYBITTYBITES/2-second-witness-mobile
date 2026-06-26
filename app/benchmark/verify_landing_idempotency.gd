extends SceneTree

func _init():
	print("\n=================================================================")
	print("[PHASE 2.5+] TARGETED REPRODUCTION: LANDING SCREEN IDEMPOTENCY & GUARD")
	print("=================================================================\n")
	
	print("--- STAGE 1: BOOTING ORCHESTRATION CUSTODIANS ---")
	var router = NavigationRouter if NavigationRouter else load("res://scripts/NavigationRouter.gd").new()
	var modal_mgr = ModalWindowManager if ModalWindowManager else load("res://scripts/ui/ModalWindowManager.gd").new()
	var kernel = InteractionKernel if InteractionKernel else load("res://scripts/system/InteractionKernel.gd").new()
	
	if not NavigationRouter:
		root.add_child(router)
		router.name = "NavigationRouter"
		router._ready()
	if not ModalWindowManager:
		root.add_child(modal_mgr)
		modal_mgr.name = "ModalWindowManager"
		modal_mgr._ready()
	if not InteractionKernel:
		root.add_child(kernel)
		kernel.name = "InteractionKernel"
		kernel._ready()
		
	print("✅ STAGE 1 PASS: NavigationRouter, ModalWindowManager, and InteractionKernel active.\n")
	
	print("--- STAGE 2: TEST A — LANDING SCREEN IDEMPOTENCY (10 RAPID CYCLES) ---")
	print("  Executing 10 rapid 'BtnPlay → return → BtnPlay' cycles...")
	
	var initial_stack_depth = modal_mgr.get_modal_stack().size()
	print("  Baseline Modal Stack Depth: ", initial_stack_depth)
	
	for i in range(1, 11):
		print("\n  [CYCLE ", i, "] Initiating show_landing_screen -> BtnPlay sequence...")
		# 1. Simulate returning to landing screen (e.g. initial boot or return)
		router.show_landing_screen()
		var depth_after_landing = modal_mgr.get_modal_stack().size()
		print("    Modal Stack Depth after show_landing_screen: ", depth_after_landing)
		if depth_after_landing != initial_stack_depth + 1:
			push_error("IDEMPOTENCY FAIL: Modal stack depth did not correctly register single LandingScreen instance. Got: " + str(depth_after_landing))
			quit(1)
			return
			
		# 2. Simulate BtnPlay pressed (enter_stream)
		router._on_play_requested()
		var depth_after_play = modal_mgr.get_modal_stack().size()
		print("    Modal Stack Depth after BtnPlay (enter_stream): ", depth_after_play)
		if depth_after_play != initial_stack_depth:
			push_error("IDEMPOTENCY FAIL: Modal stack depth did not return to baseline after BtnPlay. Got: " + str(depth_after_play))
			quit(1)
			return
			
	print("\n✅ TEST A PASS: LandingScreen appeared exactly once per cycle. Modal stack depth returned to baseline perfectly each time.\n")
	
	print("--- STAGE 3: TEST B — ROUTER RE-ENTRY GUARD ---")
	print("  Injecting manual call to NavigationRouter.goto_landing() during active transition resolution phase...")
	
	# Simulate transition resolution phase active in NavigationRouter
	router._is_transitioning_to_landing = true
	var depth_before_inject = modal_mgr.get_modal_stack().size()
	
	print("  Calling NavigationRouter.goto_landing() while _is_transitioning_to_landing == true...")
	router.goto_landing()
	
	var depth_after_inject = modal_mgr.get_modal_stack().size()
	print("  Modal Stack Depth after injected call: ", depth_after_inject)
	
	if depth_after_inject != depth_before_inject:
		push_error("RE-ENTRY GUARD FAIL: Second call was appended instead of ignored/merged.")
		quit(1)
		return
		
	# Restore transition guard
	router._is_transitioning_to_landing = false
	
	print("✅ TEST B PASS: Second call to goto_landing() was perfectly ignored/merged. Zero redundant modal pushes.\n")
	
	print("--- STAGE 4: TEST C — SIGNAL DOUBLE-FIRE TRACING (DEBUG COUNTERS) ---")
	print("  Evaluating debug counters to trace duplication root cause...")
	print("  landing_screen_instantiation_count: ", router.landing_screen_instantiation_count)
	print("  router_scene_shift_count: ", router.router_scene_shift_count)
	
	if router.landing_screen_instantiation_count != 1:
		push_error("ORCHESTRATION FAIL: landing_screen_instantiation_count != 1. Got: " + str(router.landing_screen_instantiation_count))
		quit(1)
		return
		
	if router.router_scene_shift_count <= router.landing_screen_instantiation_count:
		push_error("ORCHESTRATION FAIL: router_scene_shift_count did not diverge from instantiation count.")
		quit(1)
		return
		
	print("✅ TEST C PASS: Debug counters diverged successfully (Instantiation: 1 vs Scene Shifts: " + str(router.router_scene_shift_count) + "). Persistent singleton cache proven.\n")
	
	print("=================================================================")
	print("🏆 TARGETED REPRODUCTION HARNESS PASS: ALL IDEMPOTENCY & GUARD INVARIANTS SATISFIED.")
	print("=================================================================\n")
	
	if not NavigationRouter: router.free()
	if not ModalWindowManager: modal_mgr.free()
	if not InteractionKernel: kernel.free()
	quit(0)
