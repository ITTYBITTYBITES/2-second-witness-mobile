extends Node
class_name BootLoader

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness (Liquid Memory V2)
# THE BOOT CONTROLLER (1-TIME COLD LAUNCH MANAGER)
# ---------------------------------------------------------

signal boot_finished

static var _has_booted: bool = false
var state_machine: BootStateMachine
var boot_screen: CanvasLayer

func _ready():
	if _has_booted:
		print("[BOOT LOADER GUARD] Suppressed duplicate initialization. Boot sequence executes exactly once per cold launch.")
		queue_free()
		return
		
	_has_booted = true
	print("========================================")
	print("[BOOT LOADER] Witness System Boot Initiated.")
	print("========================================")
	
	state_machine = BootStateMachine.new()
	add_child(state_machine)
	
	var boot_scene = load("res://scenes/ui/screens/BootScreen.tscn")
	if boot_scene:
		boot_screen = boot_scene.instantiate()
		boot_screen.name = "BootScreen"
		var ui_layer = get_tree().root.get_node_or_null("MainShell/UILayer") if get_tree() and get_tree().root.has_node("MainShell/UILayer") else get_tree().root
		if ui_layer: ui_layer.add_child(boot_screen)
		
		if boot_screen.has_method("bind_state_machine"):
			boot_screen.bind_state_machine(state_machine)
			
	_execute_fast_boot()

func _execute_fast_boot():
	var start_ticks = Time.get_ticks_msec()
	
	state_machine.advance_state(BootStateMachine.BootState.BOOT_START)
	await get_tree().create_timer(0.15).timeout
	
	state_machine.advance_state(BootStateMachine.BootState.INITIALIZE_SINGLETONS)
	await get_tree().create_timer(0.15).timeout
	
	state_machine.advance_state(BootStateMachine.BootState.LOAD_PLAYER_PROFILE)
	var profile = get_node_or_null("/root/PlayerProfile")
	if profile and profile.has_method("_load_profile"): profile._load_profile()
	await get_tree().create_timer(0.15).timeout
	
	state_machine.advance_state(BootStateMachine.BootState.LOAD_SETTINGS)
	await get_tree().create_timer(0.15).timeout
	
	state_machine.advance_state(BootStateMachine.BootState.LOAD_UNIVERSE_REGISTRY)
	await get_tree().create_timer(0.15).timeout
	
	state_machine.advance_state(BootStateMachine.BootState.VERIFY_CONTENT)
	var loader = get_node_or_null("/root/ContentLoader")
	if loader and loader.has_method("_ready"): loader._ready()
	await get_tree().create_timer(0.15).timeout
	
	state_machine.advance_state(BootStateMachine.BootState.INITIALIZE_AUDIO)
	var audio = get_node_or_null("/root/AudioManager")
	if audio and audio.has_method("play_sfx"): audio.play_sfx("ui_click")
	await get_tree().create_timer(0.15).timeout
	
	state_machine.advance_state(BootStateMachine.BootState.READY)
	await get_tree().create_timer(0.15).timeout
	
	var total_time = (Time.get_ticks_msec() - start_ticks) / 1000.0
	print("[BOOT LOADER] Fast boot completed in: ", total_time, "s (Target: < 2.0s)")
	
	state_machine.advance_state(BootStateMachine.BootState.TRANSITION_TO_LANDING)
	
	var main_shell = get_tree().root.get_node_or_null("MainShell")
	if main_shell:
		var ui_layer = main_shell.get_node_or_null("UILayer")
		var world_layer = main_shell.get_node_or_null("WorldLayer")
		if ui_layer:
			ui_layer.process_mode = Node.PROCESS_MODE_INHERIT
			print("[BOOT LOADER] UILayer process mode restored to PROCESS_MODE_INHERIT. UI interaction enabled.")
		if world_layer:
			world_layer.process_mode = Node.PROCESS_MODE_INHERIT
			print("[BOOT LOADER] WorldLayer process mode restored to PROCESS_MODE_INHERIT. 3D simulation active.")
	
	var tween = get_tree().create_tween()
	if tween and is_instance_valid(boot_screen):
		tween.tween_property(boot_screen, "modulate:a", 0.0, 0.4)
		tween.tween_callback(func():
			if is_instance_valid(boot_screen): boot_screen.queue_free()
			boot_finished.emit()
			var router = get_node_or_null("/root/NavigationRouter")
			if router and router.has_method("show_landing_screen"):
				router.show_landing_screen()
			queue_free()
		)
	else:
		boot_finished.emit()
		var router = get_node_or_null("/root/NavigationRouter")
		if router and router.has_method("show_landing_screen"):
			router.show_landing_screen()
		queue_free()

func trigger_failure(reason: String):
	print("[BOOT LOADER FAILURE] Handling boot exception gracefully: ", reason)
	if is_instance_valid(boot_screen) and boot_screen.has_method("show_failure_dialog"):
		boot_screen.show_failure_dialog(reason)
