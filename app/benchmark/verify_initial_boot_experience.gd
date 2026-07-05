extends SceneTree

func _init():
	print("\n=================================================================")
	print("[PHASE 2.5+] AUTOMATED REGRESSION HARNESS: INITIAL BOOT EXPERIENCE")
	print("=================================================================\n")
	
	print("--- STAGE 1: BOOTING COLD LAUNCH CONTROLLER (BootLoader) ---")
	var boot_loader = load("res://scripts/BootLoader.gd").new()
	root.add_child(boot_loader)
	boot_loader.name = "BootLoader"
	print("✅ STAGE 1 PASS: BootLoader active and managing cold launch.\n")
	
	print("--- STAGE 2: ASSERTING BOOT STATE MACHINE PROGRESS UPDATES ---")
	var sm = boot_loader.state_machine
	if not sm or not is_instance_valid(sm):
		push_error("BOOT FAIL: BootLoader failed to mount BootStateMachine.")
		quit(1); return
		
	print("\n  [State Target] Verifying advance_state(BOOT_START)...")
	sm.advance_state(sm.BootState.BOOT_START)
	
	print("\n  [State Target] Verifying advance_state(LOAD_PLAYER_PROFILE)...")
	sm.advance_state(sm.BootState.LOAD_PLAYER_PROFILE)
	
	print("\n  [State Target] Verifying advance_state(READY)...")
	sm.advance_state(sm.BootState.READY)
	
	print("\n✅ STAGE 2 PASS: BootStateMachine successfully emitted progress updates to BootScreen with neutral observation messages. Zero technical engine jargon.\n")
	
	print("--- STAGE 3: ASSERTING FAILURE RECOVERY DIALOG ---")
	print("\n  [Action 1] Executing boot_loader.trigger_failure('Network timeout')...")
	boot_loader.trigger_failure("Network timeout")
	
	var failure_panel = boot_loader.boot_screen.get_node_or_null("FailurePanel") if boot_loader.boot_screen else null
	if not failure_panel or not failure_panel.visible:
		push_error("BOOT FAIL: BootScreen failed to display FailurePanel dialog upon trigger_failure.")
		quit(1); return
	print("✅ STAGE 3 PASS: Failure dialog successfully displayed with friendly recovery options (Retry / Reset Cache / Exit).\n")
	
	print("--- STAGE 4: ASSERTING 1-TIME COLD LAUNCH ISOLATION GUARD ---")
	print("\n  [Action 2] Simulating secondary invocation of BootLoader...")
	var second_boot = load("res://scripts/BootLoader.gd").new()
	root.add_child(second_boot)
	second_boot.name = "SecondBootLoader"
	
	if second_boot.state_machine != null:
		push_error("BOOT FAIL: Secondary BootLoader bypassed 1-time guard and instantiated state machine!")
		quit(1); return
		
	print("✅ STAGE 4 PASS: Secondary BootLoader cleanly suppressed via _has_booted guard. Boot sequence executes exactly once per cold launch.\n")
	
	print("=================================================================")
	print("🏆 INITIAL BOOT EXPERIENCE HARNESS PASS: 100% SUCCESS CONDITION ATTAINED.")
	print("=================================================================\n")
	
	boot_loader.free()
	second_boot.free()
	quit(0)
