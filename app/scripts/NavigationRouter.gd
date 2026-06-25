extends Node

signal routed_to(destination: Dictionary)

var active_landing_screen = null
var active_secondary_screen = null

func _ready():
	BootTracer.log_init("NavigationRouter")
	print("NavigationRouter initialized. Awaiting structured events.")

func _input(_event):
	if InteractionKernel and InteractionKernel.is_ui_blocking():
		return

func show_landing_screen():
	if active_secondary_screen and is_instance_valid(active_secondary_screen):
		if ModalWindowManager: ModalWindowManager.pop_modal(active_secondary_screen)
		else: active_secondary_screen.queue_free()
		active_secondary_screen = null
		
	if active_landing_screen and is_instance_valid(active_landing_screen):
		active_landing_screen.show_screen()
		if ModalWindowManager: ModalWindowManager.push_modal(active_landing_screen, false)
		return
		
	var landing_scene = load("res://scenes/ui/screens/LandingScreen.tscn")
	if not landing_scene:
		push_error("[ROUTER FATAL] LandingScreen.tscn failed to load.")
		return
		
	active_landing_screen = landing_scene.instantiate()
	
	if ModalWindowManager:
		ModalWindowManager.push_modal(active_landing_screen, false)
	else:
		var ui_layer = get_tree().root.get_node_or_null("MainShell/UILayer/NavigationUI")
		if not ui_layer: ui_layer = get_tree().root.get_node_or_null("MainShell/UILayer")
		if ui_layer: ui_layer.add_child(active_landing_screen)
		
	active_landing_screen.play_requested.connect(_on_play_requested)
	active_landing_screen.profile_requested.connect(_on_profile_requested)
	active_landing_screen.discover_requested.connect(_on_discover_requested)
	active_landing_screen.show_screen()
	print("[ROUTER] Landing Screen instantiated and active.")

func _on_play_requested():
	print("STEP 1: PLAY REQUEST RECEIVED")
	print("UNIVERSE BOOT START")
	if active_landing_screen:
		active_landing_screen.hide_screen()
		if ModalWindowManager: ModalWindowManager.pop_modal(active_landing_screen)
		
	var portal_mgr = get_tree().root.get_node_or_null("MainShell/WorldLayer/TunnelLayer/Tier3_PortalLayer")
	print("STEP 2: PORTAL LOOKUP = ", portal_mgr)
	
	if portal_mgr == null:
		push_error("PORTAL MANAGER NULL")
		return
		
	print("STEP 3: CALLING SPAWN")
	portal_mgr.spawn_lens_portal("0")
	print("STEP 4: SPAWN CALL COMPLETED")

func _on_profile_requested():
	print("[ROUTER] Profile requested. Opening Cognitive Mirror.")
	if active_landing_screen:
		active_landing_screen.hide_screen()
		
	var profile_scene = load("res://scenes/ui/screens/PlayerProfileScreen.tscn")
	if profile_scene:
		active_secondary_screen = profile_scene.instantiate()
		if ModalWindowManager:
			ModalWindowManager.push_modal(active_secondary_screen, true)
		else:
			var ui_layer = get_tree().root.get_node_or_null("MainShell/UILayer/NavigationUI")
			if not ui_layer: ui_layer = get_tree().root.get_node_or_null("MainShell/UILayer")
			if ui_layer: ui_layer.add_child(active_secondary_screen)
		
		if active_secondary_screen.has_signal("return_requested"):
			active_secondary_screen.return_requested.connect(show_landing_screen)

func _on_discover_requested():
	print("[ROUTER] Discovery requested. Opening Weekly Featured Screen.")
	if active_landing_screen:
		active_landing_screen.hide_screen()
		
	var discover_scene = load("res://scenes/ui/screens/WeeklyFeaturedScreen.tscn")
	if discover_scene:
		active_secondary_screen = discover_scene.instantiate()
		if ModalWindowManager:
			ModalWindowManager.push_modal(active_secondary_screen, true)
		else:
			var ui_layer = get_tree().root.get_node_or_null("MainShell/UILayer/NavigationUI")
			if not ui_layer: ui_layer = get_tree().root.get_node_or_null("MainShell/UILayer")
			if ui_layer: ui_layer.add_child(active_secondary_screen)
		
		active_secondary_screen.return_requested.connect(show_landing_screen)
		active_secondary_screen.play_universe_requested.connect(_on_play_universe_requested)

func _on_play_universe_requested(universe_id: String):
	print("STEP 1: PLAY REQUEST RECEIVED")
	print("[ROUTER] Play Universe requested: ", universe_id)
	print("UNIVERSE BOOT START")
	if active_secondary_screen:
		if ModalWindowManager: ModalWindowManager.pop_modal(active_secondary_screen)
		else: active_secondary_screen.queue_free()
		active_secondary_screen = null
		
	ThemeManager.apply_theme(universe_id)
	var portal_mgr = get_tree().root.get_node_or_null("MainShell/WorldLayer/TunnelLayer/Tier3_PortalLayer")
	print("STEP 2: PORTAL LOOKUP = ", portal_mgr)
	
	if portal_mgr == null:
		push_error("PORTAL MANAGER NULL")
		return
		
	print("STEP 3: CALLING SPAWN")
	portal_mgr.spawn_lens_portal("0")
	print("STEP 4: SPAWN CALL COMPLETED")

func handle_navigation_event(event: Dictionary):
	if event.get("type") == "portal_selected":
		var dest = event.get("destination", {})
		print("STEP 8: LOADING SCENARIO")
		print("[ROUTER] Executing continuous scene shift to Destination: ", dest)
		
		var cascade_scene_name = SamplingController.get_next_scenario()
		var seed_string = str(PlayerProfile.lifetime_sessions) + dest.get("chunk_id", "0")
		var world_id = dest.get("world", "")
		var scenario_payload = ContentRegistry.resolve_scenario(dest.get("universe", "science_lab"), world_id, cascade_scene_name, seed_string)
		
		var cascade_scene = load("res://scenes/scenarios/" + _snake_to_pascal(cascade_scene_name) + ".tscn")
		if cascade_scene == null:
			cascade_scene = preload("res://scenes/scenarios/MemoryCascade.tscn")
			
		var cascade = cascade_scene.instantiate()
		
		if cascade.has_method("inject_payload"):
			cascade.inject_payload(scenario_payload, seed_string.hash())
		
		var world_layer = get_tree().root.get_node("MainShell/WorldLayer")
		if world_layer:
			world_layer.add_child(cascade)
			print("SCENARIO SPAWNED")
			cascade.completed.connect(_on_cascade_completed)
		emit_signal("routed_to", dest)
	else:
		print("[ROUTER] Unknown routing event: ", event)

func _snake_to_pascal(snake: String) -> String:
	var parts = snake.split("_")
	var result = ""
	for part in parts:
		result += part.capitalize()
	return result

func _on_cascade_completed():
	print("[ROUTER] Cognitive Spike resolved. Checking Ad Gate before Slingshot.")
	
	if AdManager.check_and_show_ad():
		await AdManager.ad_finished
	
	SystemHealthMonitor.pop_context(SystemHealthMonitor.ExecContext.SCENARIO_ACTIVE)
	SystemHealthMonitor.queue_telemetry_dump("Post-Scenario Return")
	var tunnel = get_tree().root.get_node_or_null("MainShell/WorldLayer/TunnelLayer")
	if tunnel and tunnel.has_method("trigger_slingshot"):
		tunnel.trigger_slingshot()
		
	var portal_mgr = get_tree().root.get_node_or_null("MainShell/WorldLayer/TunnelLayer/Tier3_PortalLayer")
	if portal_mgr and portal_mgr.has_method("spawn_lens_portal"):
		portal_mgr.spawn_lens_portal("0")
