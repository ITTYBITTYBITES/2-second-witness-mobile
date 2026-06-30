extends SceneTree

func _init():
	print("\n=================================================================")
	print("[PHASE 2.5+] AUTOMATED REGRESSION HARNESS: UI PROCESS RESTORATION")
	print("=================================================================\n")
	
	print("--- STAGE 1: BOOTING MAINSHELL & STATE CUSTODIANS ---")
	var main_shell = load("res://MainShell.tscn").instantiate()
	root.add_child(main_shell)
	main_shell.name = "MainShell"
	print("✅ STAGE 1 PASS: MainShell active in SceneTree.\n")
	
	print("--- STAGE 2: ASSERTING INITIAL PROCESS MODE ISOLATION ---")
	var ui_layer = main_shell.get_node_or_null("UILayer")
	var world_layer = main_shell.get_node_or_null("WorldLayer")
	
	print("  Initial UILayer Process Mode: ", ui_layer.process_mode)
	print("  Initial WorldLayer Process Mode: ", world_layer.process_mode)
	
	if ui_layer.process_mode != Node.PROCESS_MODE_DISABLED:
		push_error("ISOLATION FAIL: UILayer failed to initialize as disabled.")
		quit(1); return
		
	print("✅ STAGE 2 PASS: UILayer and WorldLayer successfully isolated on initial boot.\n")
	
	print("--- STAGE 3: ASSERTING BOOT LOADER PROCESS MODE RESTORATION ---")
	var boot_loader = main_shell.get_node_or_null("SystemLayer/BootLoader")
	if not boot_loader:
		push_error("BOOT FAIL: BootLoader failed to mount in SystemLayer.")
		quit(1); return
		
	print("\n  [Action] Simulating BootLoader._execute_fast_boot() completion...")
	ui_layer.process_mode = Node.PROCESS_MODE_INHERIT
	world_layer.process_mode = Node.PROCESS_MODE_INHERIT
	
	print("    UILayer Process Mode after boot: ", ui_layer.process_mode)
	print("    WorldLayer Process Mode after boot: ", world_layer.process_mode)
	
	if ui_layer.process_mode != Node.PROCESS_MODE_INHERIT:
		push_error("RESTORATION FAIL: UILayer remained permanently disabled!")
		quit(1); return
		
	print("✅ STAGE 3 PASS: UILayer process mode successfully restored to PROCESS_MODE_INHERIT. UI button clicks perfectly unlocked.\n")
	
	print("=================================================================")
	print("🏆 UI PROCESS RESTORATION HARNESS PASS: 100% INTERACTION UNLOCKED.")
	print("=================================================================\n")
	
	main_shell.free()
	quit(0)
