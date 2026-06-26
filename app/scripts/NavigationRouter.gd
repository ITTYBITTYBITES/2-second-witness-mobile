extends Node

signal routed_to(destination: Dictionary)

var active_landing_screen = null
var active_secondary_screen = null
var active_gameplay_hud = null
var persistent_mirror_instance = null

func _ready():
	BootTracer.log_init("NavigationRouter")
	print("NavigationRouter initialized. Awaiting structured events.")

func _input(_event):
	if InteractionKernel and InteractionKernel.is_ui_blocking():
		return

func show_landing_screen():
	if ModalWindowManager: ModalWindowManager.pop_all_modals(active_landing_screen if is_instance_valid(active_landing_screen) else null)
	if active_secondary_screen and is_instance_valid(active_secondary_screen):
		active_secondary_screen.queue_free()
		active_secondary_screen = null
		
	if active_gameplay_hud and is_instance_valid(active_gameplay_hud):
		active_gameplay_hud.visible = false
		
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

func _show_gameplay_hud():
	if active_gameplay_hud and is_instance_valid(active_gameplay_hud):
		active_gameplay_hud.visible = true
		return
		
	var hud_root = get_tree().root.get_node_or_null("MainShell/UILayer/HUDRoot")
	if not hud_root: return
	
	active_gameplay_hud = Control.new()
	active_gameplay_hud.name = "GameplayHUD"
	active_gameplay_hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	active_gameplay_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var btn_leave = Button.new()
	btn_leave.custom_minimum_size = Vector2(180, 60)
	btn_leave.position = Vector2(40, 40)
	btn_leave.text = "< LEAVE STREAM"
	btn_leave.add_theme_font_size_override("font_size", 20)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.12, 0.85)
	style.border_width_bottom = 4
	style.border_color = Color(0.968, 0.145, 0.521)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	
	btn_leave.add_theme_stylebox_override("normal", style)
	btn_leave.add_theme_stylebox_override("hover", style.duplicate())
	btn_leave.add_theme_stylebox_override("pressed", style.duplicate())
	btn_leave.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	
	btn_leave.pressed.connect(func():
		AudioManager.play_sfx("ui_click")
		if InteractionKernel: InteractionKernel.commit_intent({"type": "scene_shift", "target": "LandingScreen"})
		else: show_landing_screen()
	)
	
	var btn_mirror = Button.new()
	btn_mirror.custom_minimum_size = Vector2(180, 60)
	btn_mirror.position = Vector2(240, 40)
	btn_mirror.text = "★ THE MIRROR"
	btn_mirror.add_theme_font_size_override("font_size", 20)
	btn_mirror.add_theme_stylebox_override("normal", style)
	btn_mirror.add_theme_stylebox_override("hover", style.duplicate())
	btn_mirror.add_theme_stylebox_override("pressed", style.duplicate())
	btn_mirror.add_theme_color_override("font_color", Color(0.298, 0.788, 0.941))
	
	btn_mirror.pressed.connect(func():
		AudioManager.play_sfx("ui_click")
		if InteractionKernel: InteractionKernel.commit_intent({"type": "toggle_utility", "utility_id": ModalWindowManager.UtilityID.MIRROR})
		elif ModalWindowManager: ModalWindowManager.toggle_utility(ModalWindowManager.UtilityID.MIRROR)
	)
	
	active_gameplay_hud.add_child(btn_leave)
	active_gameplay_hud.add_child(btn_mirror)
	hud_root.add_child(active_gameplay_hud)
	print("[ROUTER] Gameplay HUD attached. Persistent 3-Layer UI separation active.")

func toggle_mirror_modal():
	print("[HUD UTILITY] Toggling Cognitive Mirror modal instance under HUDRoot.")
	if persistent_mirror_instance and is_instance_valid(persistent_mirror_instance):
		if persistent_mirror_instance.visible:
			persistent_mirror_instance.visible = false
			if ModalWindowManager: ModalWindowManager.pop_modal(persistent_mirror_instance)
		else:
			persistent_mirror_instance.visible = true
			if ModalWindowManager: ModalWindowManager.push_modal(persistent_mirror_instance, true)
		return
		
	var profile_scene = load("res://scenes/ui/screens/PlayerProfileScreen.tscn")
	if profile_scene:
		persistent_mirror_instance = profile_scene.instantiate()
		var hud_root = get_tree().root.get_node_or_null("MainShell/UILayer/HUDRoot")
		if not hud_root: hud_root = get_tree().root.get_node_or_null("MainShell/UILayer")
		if hud_root: hud_root.add_child(persistent_mirror_instance)
		
		if ModalWindowManager: ModalWindowManager.push_modal(persistent_mirror_instance, true)
		if persistent_mirror_instance.has_signal("return_requested"):
			persistent_mirror_instance.return_requested.connect(func():
				persistent_mirror_instance.visible = false
				if ModalWindowManager: ModalWindowManager.pop_modal(persistent_mirror_instance)
			)

func _on_play_requested():
	print("STEP 1: PLAY REQUEST RECEIVED")
	print("UNIVERSE BOOT START")
	if active_landing_screen: active_landing_screen.hide_screen()
	if ModalWindowManager: ModalWindowManager.pop_all_modals()
		
	_show_gameplay_hud()
	
	var vector = ExperienceOrchestrator.determine_next_experience(PlayerProfile) if Engine.get_main_loop().root.has_node("ExperienceOrchestrator") else {}
	var u_id = vector.get("universe", "history")
	var w_id = vector.get("world", "ancient_egypt")
	
	ThemeManager.apply_theme(u_id)
	var portal_mgr = get_tree().root.get_node_or_null("MainShell/WorldLayer/TunnelLayer/Tier3_PortalLayer")
	print("STEP 2: PORTAL LOOKUP = ", portal_mgr)
	
	if portal_mgr == null:
		push_error("PORTAL MANAGER NULL")
		return
		
	if portal_mgr.has_method("apply_theme"):
		portal_mgr.apply_theme(ThemeManager.get_active_theme(), u_id, w_id)
		
	print("STEP 3: CALLING SPAWN")
	portal_mgr.spawn_lens_portal("0")
	print("STEP 4: SPAWN CALL COMPLETED")

func _on_profile_requested():
	print("[ROUTER] Profile requested from menu. Invoking HUD utility modal.")
	if active_landing_screen:
		active_landing_screen.hide_screen()
	if ModalWindowManager: ModalWindowManager.pop_all_modals()
	toggle_mirror_modal()

func _on_discover_requested():
	print("[ROUTER] Discovery requested. Opening Weekly Featured Screen.")
	if active_landing_screen:
		active_landing_screen.hide_screen()
	if ModalWindowManager: ModalWindowManager.pop_all_modals()
		
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
	print("→ WORLD LIST RESOLVED: ", universe_id)
	
	if ModalWindowManager: ModalWindowManager.pop_all_modals()
	if active_secondary_screen:
		active_secondary_screen.queue_free()
		active_secondary_screen = null
		
	var world_scene = load("res://scenes/ui/screens/WorldSelectScreen.tscn")
	if world_scene:
		active_secondary_screen = world_scene.instantiate()
		active_secondary_screen.setup(universe_id)
		
		if ModalWindowManager:
			ModalWindowManager.push_modal(active_secondary_screen, true)
		else:
			var ui_layer = get_tree().root.get_node_or_null("MainShell/UILayer/NavigationUI")
			if not ui_layer: ui_layer = get_tree().root.get_node_or_null("MainShell/UILayer")
			if ui_layer: ui_layer.add_child(active_secondary_screen)
			
		print("→ WORLD SELECT SCREEN PUSHED")
		active_secondary_screen.return_requested.connect(_on_discover_requested)
		active_secondary_screen.world_selected.connect(_on_world_selected)

func _on_world_selected(universe_id: String, world_id: String):
	print("[ROUTER] World Selected: ", universe_id, " -> ", world_id)
	print("→ world_selected event emitted: ", world_id)
	if ModalWindowManager: ModalWindowManager.pop_all_modals()
	if active_secondary_screen:
		active_secondary_screen.queue_free()
		active_secondary_screen = null
		
	_show_gameplay_hud()
	
	ThemeManager.apply_theme(universe_id)
	var portal_mgr = get_tree().root.get_node_or_null("MainShell/WorldLayer/TunnelLayer/Tier3_PortalLayer")
	print("STEP 2: PORTAL LOOKUP = ", portal_mgr)
	
	if portal_mgr == null:
		push_error("PORTAL MANAGER NULL")
		return
		
	if portal_mgr.has_method("apply_theme"):
		portal_mgr.apply_theme(ThemeManager.get_active_theme(), universe_id, world_id)
		
	print("STEP 3: CALLING SPAWN")
	portal_mgr.spawn_lens_portal("0")
	print("STEP 4: SPAWN CALL COMPLETED")

func handle_navigation_event(event: Dictionary):
	if event.get("type") == "portal_selected":
		var dest = event.get("destination", {})
		print("STEP 8: LOADING SCENARIO")
		print("[ROUTER] Executing continuous scene shift to Destination: ", dest)
		
		var vector = ExperienceOrchestrator.determine_next_experience(PlayerProfile) if Engine.get_main_loop().root.has_node("ExperienceOrchestrator") else {}
		var cascade_scene_name = vector.get("spike", "memory_cascade")
		var scenario_payload = vector.get("knowledge_item", {})
		var seed_string = str(PlayerProfile.lifetime_sessions) + dest.get("chunk_id", "0")
		
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
