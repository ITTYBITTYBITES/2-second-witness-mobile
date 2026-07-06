extends Node

signal routed_to(destination: Dictionary)

var active_landing_screen = null
var active_secondary_screen = null
var active_gameplay_hud = null
var persistent_mirror_instance = null

var landing_screen_instantiation_count: int = 0
var router_scene_shift_count: int = 0
var _is_transitioning_to_landing: bool = false
var _is_transition_completed: bool = false

var navigation_stack: Array[String] = []
var current_screen_name: String = ""
var previous_screen_name: String = ""
var active_universe_selection: String = ""
var active_world_selection: String = ""
var active_subcategory_selection: String = ""
var active_scenario_selection: String = ""
var current_scenario_chain_index: int = 1

func normalize_id(id: Variant) -> String:
	return str(id)

func _enter_tree():
	if StructuredLogger and StructuredLogger.has_method("log_event_trace"):
		StructuredLogger.log_event_trace(self, "_enter_tree", "NavigationRouter singleton mounting.")

func _ready():
	if StructuredLogger and StructuredLogger.has_method("log_event_trace"):
		StructuredLogger.log_event_trace(self, "_ready", "NavigationRouter online.")
	if BootTracer: BootTracer.log_init("NavigationRouter")
	print("NavigationRouter initialized. Awaiting structured events.")

func _input(_event):
	var kernel = InteractionKernel if InteractionKernel else get_tree().root.get_node_or_null("InteractionKernel")
	if kernel and kernel.is_ui_blocking():
		return

func _update_nav_log(new_screen: String, is_pop: bool = false):
	if new_screen == "PlayerProfileScreen" or new_screen == "SettingsScreen":
		print("\n[ROUTER] Utility modal active: ", new_screen, ". Retaining clean navigation stack history.")
		var m_mgr = ModalWindowManager if ModalWindowManager else get_tree().root.get_node_or_null("ModalWindowManager")
		var m_stk = []
		if m_mgr:
			for m in m_mgr.get_modal_stack():
				if is_instance_valid(m): m_stk.append(m.name)
		print("Current Screen: ", current_screen_name)
		print("Previous Screen: ", previous_screen_name)
		print("Navigation Stack:\n[\n    ", ", \n    ".join(navigation_stack), "\n]")
		print("Modal Stack:\n[\n    ", ", \n    ".join(m_stk), "\n]\n")
		return

	previous_screen_name = current_screen_name
	current_screen_name = new_screen
	
	if not is_pop:
		if not navigation_stack.has(new_screen):
			navigation_stack.append(new_screen)
	else:
		if navigation_stack.size() > 0 and navigation_stack[-1] != new_screen:
			navigation_stack.pop_back()
			
	print("\nCurrent Screen: ", current_screen_name)
	print("Previous Screen: ", previous_screen_name)
	print("Navigation Stack:\n[\n    ", ", \n    ".join(navigation_stack), "\n]")
	
	var modal_mgr = ModalWindowManager if ModalWindowManager else get_tree().root.get_node_or_null("ModalWindowManager")
	var m_stack = []
	if modal_mgr:
		for m in modal_mgr.get_modal_stack():
			if is_instance_valid(m): m_stack.append(m.name)
	print("Modal Stack:\n[\n    ", ", \n    ".join(m_stack), "\n]\n")

func on_scene_transition_complete():
	if _is_transition_completed:
		print("[ROUTER GUARD] Suppressed duplicate execution of on_scene_transition_complete(). Terminal completion callback executed exactly once.")
		return
		
	_is_transition_completed = true
	print("[ROUTER] Executing single authoritative completion hook: on_scene_transition_complete()...")
	var modal_mgr = ModalWindowManager if ModalWindowManager else get_tree().root.get_node_or_null("ModalWindowManager")
	var kernel = InteractionKernel if InteractionKernel else get_tree().root.get_node_or_null("InteractionKernel")
	
	LayoutFreezer.unfreeze()
	if kernel and kernel.has_method("release_all_locks"):
		kernel.release_all_locks()
		
	if modal_mgr and modal_mgr.has_method("set_input_blocker"):
		modal_mgr.set_input_blocker(false)
		
	print("[ROUTER] Terminal Lifecycle State Reached. GameplayHUD active. Input restored. Zero deadlocks.")

func goto_landing():
	show_landing_screen()

func _show_daily_expedition():
	print("[ROUTER] Opening DailyExpeditionScreen.")
	var modal_mgr = ModalWindowManager if ModalWindowManager else get_tree().root.get_node_or_null("ModalWindowManager")
	if active_secondary_screen:
		active_secondary_screen.queue_free()
		active_secondary_screen = null
	var exp_scene = load("res://scenes/ui/screens/DailyExpeditionScreen.tscn")
	if exp_scene:
		active_secondary_screen = exp_scene.instantiate()
		active_secondary_screen.name = "DailyExpeditionScreen"
		if modal_mgr:
			modal_mgr.push_modal(active_secondary_screen, true, "NavigationRouter")
		else:
			var ui_layer = get_tree().root.get_node_or_null("MainShell/UILayer/NavigationUI")
			if not ui_layer: ui_layer = get_tree().root.get_node_or_null("MainShell/UILayer")
			if ui_layer: ui_layer.add_child(active_secondary_screen)
		active_secondary_screen.return_requested.connect(func(): show_landing_screen())
		active_secondary_screen.expedition_world_selected.connect(func(u_id, w_id): _on_play_universe_requested(u_id))
		_update_nav_log("DailyExpeditionScreen", false)


func show_landing_screen():
	if StructuredLogger and StructuredLogger.has_method("log_event_trace"):
		StructuredLogger.log_event_trace(self, "external_call", "show_landing_screen()")
	router_scene_shift_count += 1
	var modal_mgr = ModalWindowManager if ModalWindowManager else get_tree().root.get_node_or_null("ModalWindowManager")
	
	if _is_transitioning_to_landing:
		print("[ROUTER GUARD] Suppressed re-entrant call to show_landing_screen during active transition resolution. Call merged.")
		return
		
	if active_landing_screen and is_instance_valid(active_landing_screen) and modal_mgr and modal_mgr.has_modal(active_landing_screen):
		print("[ROUTER GUARD] Suppressed redundant call to show_landing_screen. LandingScreen is already active in modal stack. Call merged.")
		return
		
	_is_transitioning_to_landing = true
	
	if modal_mgr: modal_mgr.pop_all_modals(active_landing_screen if is_instance_valid(active_landing_screen) else null, "NavigationRouter")
	if active_secondary_screen and is_instance_valid(active_secondary_screen):
		active_secondary_screen.queue_free()
		active_secondary_screen = null
		
	if active_gameplay_hud and is_instance_valid(active_gameplay_hud):
		active_gameplay_hud.visible = false
		
	if active_landing_screen and is_instance_valid(active_landing_screen):
		active_landing_screen.show_screen()
		if modal_mgr: modal_mgr.push_modal(active_landing_screen, false, "NavigationRouter")
		_is_transitioning_to_landing = false
		_update_nav_log("LandingScreen", navigation_stack.size() > 1)
		print("[ROUTER] Landing Screen restored from persistent singleton cache. (Instantiation count: ", landing_screen_instantiation_count, ", Scene shift count: ", router_scene_shift_count, ")")
		return
		
	var landing_scene = load("res://scenes/ui/screens/LandingScreen.tscn")
	if not landing_scene:
		push_error("[ROUTER FATAL] LandingScreen.tscn failed to load.")
		_is_transitioning_to_landing = false
		return
		
	active_landing_screen = landing_scene.instantiate()
	active_landing_screen.name = "LandingScreen"
	landing_screen_instantiation_count += 1
	
	if modal_mgr:
		modal_mgr.push_modal(active_landing_screen, false, "NavigationRouter")
	else:
		var ui_layer = get_tree().root.get_node_or_null("MainShell/UILayer/NavigationUI")
		if not ui_layer: ui_layer = get_tree().root.get_node_or_null("MainShell/UILayer")
		if ui_layer: ui_layer.add_child(active_landing_screen)
		
	active_landing_screen.play_requested.connect(_on_play_requested)
	active_landing_screen.profile_requested.connect(_on_profile_requested)
	active_landing_screen.discover_requested.connect(_on_discover_requested)
	active_landing_screen.show_screen()
	_update_nav_log("LandingScreen", false)
	print("[ROUTER] Landing Screen instantiated and active. (Instantiation count: ", landing_screen_instantiation_count, ", Scene shift count: ", router_scene_shift_count, ")")
	_is_transitioning_to_landing = false

func _show_gameplay_hud():
	if StructuredLogger and StructuredLogger.has_method("log_event_trace"):
		StructuredLogger.log_event_trace(self, "external_call", "_show_gameplay_hud()")
	_update_nav_log("GameplayHUD", false)
	if active_gameplay_hud and is_instance_valid(active_gameplay_hud):
		active_gameplay_hud.visible = true
		return
		
	var hud_root = get_tree().root.get_node_or_null("MainShell/UILayer/HUDRoot")
	if not hud_root: return
	
	active_gameplay_hud = Control.new()
	active_gameplay_hud.name = "GameplayHUD"
	active_gameplay_hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	active_gameplay_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	active_gameplay_hud.z_index = 900
	
	var btn_leave = Button.new()
	btn_leave.custom_minimum_size = Vector2(154, 44)
	btn_leave.anchor_left = 1.0
	btn_leave.anchor_right = 1.0
	btn_leave.offset_left = -342.0
	btn_leave.offset_top = 64.0
	btn_leave.offset_right = -188.0
	btn_leave.offset_bottom = 108.0
	btn_leave.z_index = 1000
	btn_leave.text = "< LEAVE"
	btn_leave.add_theme_font_size_override("font_size", 15)
	
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
		print("[ROUTER] Back button pressed (< LEAVE STREAM)")
		if AudioManager: AudioManager.play_sfx("ui_click")
		if navigation_stack.has("WorldSelectScreen"):
			_on_play_universe_requested(active_universe_selection)
		else:
			var kernel = InteractionKernel if InteractionKernel else get_tree().root.get_node_or_null("InteractionKernel")
			if kernel: kernel.commit_intent({"type": "scene_shift", "target": "LandingScreen"})
			else: show_landing_screen()
	)
	
	var btn_mirror = Button.new()
	btn_mirror.custom_minimum_size = Vector2(154, 44)
	btn_mirror.anchor_left = 1.0
	btn_mirror.anchor_right = 1.0
	btn_mirror.offset_left = -176.0
	btn_mirror.offset_top = 64.0
	btn_mirror.offset_right = -22.0
	btn_mirror.offset_bottom = 108.0
	btn_mirror.z_index = 1000
	btn_mirror.text = "★ MIRROR"
	btn_mirror.add_theme_font_size_override("font_size", 15)
	btn_mirror.add_theme_stylebox_override("normal", style)
	btn_mirror.add_theme_stylebox_override("hover", style.duplicate())
	btn_mirror.add_theme_stylebox_override("pressed", style.duplicate())
	btn_mirror.add_theme_color_override("font_color", Color(0.298, 0.788, 0.941))
	
	btn_mirror.pressed.connect(func():
		if AudioManager: AudioManager.play_sfx("ui_click")
		var kernel = InteractionKernel if InteractionKernel else get_tree().root.get_node_or_null("InteractionKernel")
		var modal_mgr = ModalWindowManager if ModalWindowManager else get_tree().root.get_node_or_null("ModalWindowManager")
		if kernel: kernel.commit_intent({"type": "toggle_utility", "utility_id": modal_mgr.UtilityID.MIRROR if modal_mgr else 0})
		elif modal_mgr: modal_mgr.toggle_utility(modal_mgr.UtilityID.MIRROR)
	)
	
	active_gameplay_hud.add_child(btn_leave)
	active_gameplay_hud.add_child(btn_mirror)
	hud_root.add_child(active_gameplay_hud)
	print("[ROUTER] Gameplay HUD attached. Persistent 3-Layer UI separation active.")

func _close_mirror_modal(restore_landing: bool = true):
	var should_restore_landing = restore_landing and current_screen_name == "LandingScreen" and active_landing_screen and is_instance_valid(active_landing_screen)
	var modal_mgr = ModalWindowManager if ModalWindowManager else get_tree().root.get_node_or_null("ModalWindowManager")
	if persistent_mirror_instance and is_instance_valid(persistent_mirror_instance):
		persistent_mirror_instance.visible = false
		if modal_mgr and modal_mgr.has_modal(persistent_mirror_instance):
			modal_mgr.pop_modal(persistent_mirror_instance, "NavigationRouter")
	if should_restore_landing:
		call_deferred("show_landing_screen")
	else:
		_update_nav_log(previous_screen_name, true)

func _validate_recommended_world(universe_id: String, world_id: String) -> Dictionary:
	var u_id = normalize_id(universe_id)
	var w_id = normalize_id(world_id)
	var registry = ContentRegistry if ContentRegistry else get_tree().root.get_node_or_null("ContentRegistry")
	if registry and registry.has_method("ensure_valid_selection"):
		var validated = registry.ensure_valid_selection({"universe_id": u_id, "world_id": w_id})
		return {"universe": validated["universe_id"], "world": validated["world_id"]}
	return {"universe": u_id, "world": w_id}

func _on_mirror_recommendation_requested(universe_id: String, world_id: String):
	print("[ROUTER] Mirror recommendation selected: ", universe_id, " / ", world_id)
	var clean = _validate_recommended_world(universe_id, world_id)
	_close_mirror_modal(false)
	call_deferred("_start_recommended_world", clean["universe"], clean["world"])

func _start_recommended_world(universe_id: String, world_id: String):
	_on_world_selected(universe_id, world_id)

func toggle_mirror_modal():
	if StructuredLogger and StructuredLogger.has_method("log_event_trace"):
		StructuredLogger.log_event_trace(self, "external_call", "toggle_mirror_modal()")
	print("[HUD UTILITY] Toggling Mirror modal instance under HUDRoot.")
	var modal_mgr = ModalWindowManager if ModalWindowManager else get_tree().root.get_node_or_null("ModalWindowManager")
	if persistent_mirror_instance and is_instance_valid(persistent_mirror_instance):
		if persistent_mirror_instance.visible:
			_close_mirror_modal()
		else:
			persistent_mirror_instance.visible = true
			if modal_mgr: modal_mgr.push_modal(persistent_mirror_instance, true, "NavigationRouter")
			_update_nav_log("PlayerProfileScreen", false)
		return
		
	var profile_scene = load("res://scenes/ui/screens/PlayerProfileScreen.tscn")
	if profile_scene:
		persistent_mirror_instance = profile_scene.instantiate()
		persistent_mirror_instance.name = "PlayerProfileScreen"
		var hud_root = get_tree().root.get_node_or_null("MainShell/UILayer/HUDRoot")
		if not hud_root: hud_root = get_tree().root.get_node_or_null("MainShell/UILayer")
		if hud_root: hud_root.add_child(persistent_mirror_instance)
		
		if modal_mgr: modal_mgr.push_modal(persistent_mirror_instance, true, "NavigationRouter")
		_update_nav_log("PlayerProfileScreen", false)
		if persistent_mirror_instance.has_signal("return_requested"):
			persistent_mirror_instance.return_requested.connect(_close_mirror_modal)
		if persistent_mirror_instance.has_signal("recommendation_requested"):
			persistent_mirror_instance.recommendation_requested.connect(_on_mirror_recommendation_requested)

func _on_play_requested():
	print("STEP 1: PLAY REQUEST RECEIVED")
	print("[ROUTER] Tapping Play -> Opening Daily Expedition")
	_on_discover_requested()

func _on_profile_requested():
	print("[ROUTER] Profile requested from menu. Invoking HUD utility modal.")
	_is_transitioning_to_landing = false
	if active_landing_screen:
		active_landing_screen.hide_screen()
	var modal_mgr = ModalWindowManager if ModalWindowManager else get_tree().root.get_node_or_null("ModalWindowManager")
	if modal_mgr: modal_mgr.pop_all_modals(null, "NavigationRouter")
	toggle_mirror_modal()

func _on_discover_requested():
	if StructuredLogger and StructuredLogger.has_method("log_event_trace"):
		StructuredLogger.log_event_trace(self, "external_call", "_on_discover_requested()")
	print("[ROUTER] Discovery requested. Opening Weekly Featured Screen.")
	_is_transitioning_to_landing = false
	if active_landing_screen:
		active_landing_screen.hide_screen()
	var modal_mgr = ModalWindowManager if ModalWindowManager else get_tree().root.get_node_or_null("ModalWindowManager")
	if modal_mgr: modal_mgr.pop_all_modals(null, "NavigationRouter")
		
	var discover_scene = load("res://scenes/ui/screens/DailyExpeditionScreen.tscn")
	if discover_scene:
		active_secondary_screen = discover_scene.instantiate()
		active_secondary_screen.name = "DailyExpeditionScreen"
		if modal_mgr:
			modal_mgr.push_modal(active_secondary_screen, true, "NavigationRouter")
		else:
			var ui_layer = get_tree().root.get_node_or_null("MainShell/UILayer/NavigationUI")
			if not ui_layer: ui_layer = get_tree().root.get_node_or_null("MainShell/UILayer")
			if ui_layer: ui_layer.add_child(active_secondary_screen)
		
		_update_nav_log("DailyExpeditionScreen", false)
		active_secondary_screen.return_requested.connect(show_landing_screen)
		active_secondary_screen.play_universe_requested.connect(_on_play_universe_requested)

func _on_play_universe_requested(universe_id: Variant):
	var u_id = normalize_id(universe_id)
	if StructuredLogger and StructuredLogger.has_method("log_event_trace"):
		StructuredLogger.log_event_trace(self, "external_call", "_on_play_universe_requested(" + u_id + ")")
	print("STEP 1: PLAY REQUEST RECEIVED")
	print("[ROUTER] Play Universe requested: ", u_id)
	print("UNIVERSE BOOT START")
	print("→ WORLD LIST RESOLVED: ", u_id)
	_is_transitioning_to_landing = false
	active_universe_selection = u_id
	
	var modal_mgr = ModalWindowManager if ModalWindowManager else get_tree().root.get_node_or_null("ModalWindowManager")
	if modal_mgr: modal_mgr.pop_all_modals(null, "NavigationRouter")
	if active_secondary_screen:
		active_secondary_screen.queue_free()
		active_secondary_screen = null
		
	print("[ROUTER] Opening WorldSelectScreen")
	var world_scene = load("res://scenes/ui/screens/WorldSelectScreen.tscn")
	if world_scene:
		active_secondary_screen = world_scene.instantiate()
		active_secondary_screen.name = "WorldSelectScreen"
		
		if modal_mgr:
			modal_mgr.push_modal(active_secondary_screen, true, "NavigationRouter")
		else:
			var ui_layer = get_tree().root.get_node_or_null("MainShell/UILayer/NavigationUI")
			if not ui_layer: ui_layer = get_tree().root.get_node_or_null("MainShell/UILayer")
			if ui_layer: ui_layer.add_child(active_secondary_screen)
			
		active_secondary_screen.setup(u_id)
		print("→ WORLD SELECT SCREEN PUSHED")
		
		_update_nav_log("WorldSelectScreen", false)
		active_secondary_screen.return_requested.connect(_on_discover_requested)
		active_secondary_screen.world_selected.connect(_on_world_selected)

func _on_world_selected(universe_id: Variant, world_id: Variant):
	var u_id = normalize_id(universe_id)
	var w_id = normalize_id(world_id)
	if StructuredLogger and StructuredLogger.has_method("log_event_trace"):
		StructuredLogger.log_event_trace(self, "external_call", "_on_world_selected(" + u_id + ", " + w_id + ")")
	print("[ROUTER] World Selected: ", u_id, " -> ", w_id, ". Opening SubcategorySelectScreen.")
	_is_transitioning_to_landing = false
	active_universe_selection = u_id
	active_world_selection = w_id
	active_subcategory_selection = ""
	active_scenario_selection = ""
	var modal_mgr = ModalWindowManager if ModalWindowManager else get_tree().root.get_node_or_null("ModalWindowManager")
	if modal_mgr: modal_mgr.pop_all_modals(null, "NavigationRouter")
	if active_secondary_screen:
		active_secondary_screen.queue_free()
		active_secondary_screen = null

	var scenario_scene = load("res://scenes/ui/screens/SubcategorySelectScreen.tscn")
	if scenario_scene:
		active_secondary_screen = scenario_scene.instantiate()
		active_secondary_screen.name = "SubcategorySelectScreen"
		if modal_mgr:
			modal_mgr.push_modal(active_secondary_screen, true, "NavigationRouter")
		else:
			var ui_layer = get_tree().root.get_node_or_null("MainShell/UILayer/NavigationUI")
			if not ui_layer: ui_layer = get_tree().root.get_node_or_null("MainShell/UILayer")
			if ui_layer: ui_layer.add_child(active_secondary_screen)
		active_secondary_screen.setup(u_id, w_id)
		_update_nav_log("SubcategorySelectScreen", false)
		active_secondary_screen.return_requested.connect(func(): _on_play_universe_requested(u_id))
		active_secondary_screen.subcategory_selected.connect(_on_subcategory_selected)

func _on_subcategory_selected(universe_id: Variant, world_id: Variant, subcategory_id: Variant, manual_activity: bool = false):
	var u_id = normalize_id(universe_id)
	var w_id = normalize_id(world_id)
	var sub_id = normalize_id(subcategory_id)
	if manual_activity:
		_open_scenario_select(u_id, w_id, sub_id)
		return
	var selected_type = GameplayDirector.choose_mechanic(u_id, w_id, sub_id) if GameplayDirector else ""
	if selected_type == "":
		print("[ROUTER] No installed observation bank for subcategory: ", sub_id)
		return
	_on_scenario_selected(u_id, w_id, sub_id, selected_type, false)

func _open_scenario_select(universe_id: String, world_id: String, subcategory_id: String):
	var modal_mgr = ModalWindowManager if ModalWindowManager else get_tree().root.get_node_or_null("ModalWindowManager")
	if modal_mgr: modal_mgr.pop_all_modals(null, "NavigationRouter")
	if active_secondary_screen:
		active_secondary_screen.queue_free()
		active_secondary_screen = null
	var scenario_scene = load("res://scenes/ui/screens/ScenarioSelectScreen.tscn")
	if scenario_scene:
		active_secondary_screen = scenario_scene.instantiate()
		active_secondary_screen.name = "ScenarioSelectScreen"
		if modal_mgr:
			modal_mgr.push_modal(active_secondary_screen, true, "NavigationRouter")
		else:
			var ui_layer = get_tree().root.get_node_or_null("MainShell/UILayer/NavigationUI")
			if not ui_layer: ui_layer = get_tree().root.get_node_or_null("MainShell/UILayer")
			if ui_layer: ui_layer.add_child(active_secondary_screen)
		active_secondary_screen.setup(universe_id, world_id, subcategory_id)
		_update_nav_log("ScenarioSelectScreen", false)
		active_secondary_screen.return_requested.connect(func(): _on_world_selected(universe_id, world_id))
		active_secondary_screen.scenario_selected.connect(func(u, w, sub, mech): _on_scenario_selected(u, w, sub, mech, true))

func _on_scenario_selected(universe_id: Variant, world_id: Variant, subcategory_id: Variant, scenario_type: Variant, manual_override: bool = false):
	var u_id = normalize_id(universe_id)
	var w_id = normalize_id(world_id)
	var sub_id = normalize_id(subcategory_id)
	var s_type = normalize_id(scenario_type)
	if StructuredLogger and StructuredLogger.has_method("log_event_trace"):
		StructuredLogger.log_event_trace(self, "external_call", "_on_scenario_selected(" + u_id + ", " + w_id + ", " + sub_id + ", " + s_type + ")")
	print("[ROUTER] Scenario Selected: ", u_id, " -> ", w_id, " -> ", sub_id, " -> ", s_type, " (manual=", manual_override, ")")
	if GameplayDirector:
		GameplayDirector.record_mechanic_used("%s::%s::%s" % [u_id, w_id, sub_id], s_type)
	_is_transitioning_to_landing = false
	_is_transition_completed = false
	current_scenario_chain_index = 1
	active_universe_selection = u_id
	active_world_selection = w_id
	active_subcategory_selection = sub_id
	active_scenario_selection = s_type if manual_override else ""
	var modal_mgr = ModalWindowManager if ModalWindowManager else get_tree().root.get_node_or_null("ModalWindowManager")
	if modal_mgr: modal_mgr.pop_all_modals(null, "NavigationRouter")
	if active_secondary_screen:
		active_secondary_screen.queue_free()
		active_secondary_screen = null

	_show_gameplay_hud()

	if ThemeManager: ThemeManager.apply_theme(u_id)
	var portal_mgr = get_tree().root.get_node_or_null("MainShell/WorldLayer/TunnelLayer/Tier3_PortalLayer")
	print("STEP 2: PORTAL LOOKUP = ", portal_mgr)

	if portal_mgr == null:
		print("[ROUTER] Portal Manager not found in scene tree (Standalone/Benchmark mode). Skipping 3D portal spawn.")
	elif portal_mgr.has_method("apply_theme"):
		portal_mgr.apply_theme(ThemeManager.get_active_theme() if ThemeManager else {}, u_id, w_id)
		print("STEP 3: CALLING SPAWN")
		portal_mgr.spawn_lens_portal("0")
		print("STEP 4: SPAWN CALL COMPLETED")

	print("STEP 1: PLAY REQUEST RECEIVED")
	print("UNIVERSE BOOT START")
	print("[SCENARIO ENGINE] Initiating ScenarioManager lifecycle...")
	print("[SCENARIO ENGINE] Accessing ContentRegistry...")
	print("[SCENARIO ENGINE] Loading Scenario...")

	var orch = ExperienceOrchestrator if ExperienceOrchestrator else get_tree().root.get_node_or_null("ExperienceOrchestrator")
	var profile = PlayerProfile if PlayerProfile else get_tree().root.get_node_or_null("PlayerProfile")
	if orch:
		orch.active_universe = u_id
		orch.active_world = w_id
		orch.active_spike = s_type
		orch.active_state.current_universe = u_id
		orch.active_state.current_world = w_id
		orch.active_state.current_scenario = s_type
		orch.active_state.navigation_state = "GameplayHUD"
		if orch.has_method("_update_visual_identity"):
			orch._update_visual_identity(u_id, w_id)

	var nav_state = NavigationState if NavigationState else get_tree().root.get_node_or_null("NavigationState")
	var s_seed = str(profile.lifetime_sessions if profile else 0).hash()
	if nav_state and nav_state.has_method("lock_transition_context"):
		nav_state.lock_transition_context(u_id, w_id, s_type, "0", s_seed, sub_id)

	print("[SCENARIO ENGINE] Scenario 1 Ready: ", s_type.capitalize().replace("_", " "))
	handle_navigation_event({"type": "portal_selected"})
	call_deferred("on_scene_transition_complete")

func handle_navigation_event(event: Dictionary):
	if event.get("type") == "portal_selected":
		var nav_state = NavigationState if NavigationState else get_tree().root.get_node_or_null("NavigationState")
		var ctx = nav_state.get_transition_context() if (nav_state and nav_state.has_method("get_transition_context")) else {}
		
		var registry = ContentRegistry if ContentRegistry else get_tree().root.get_node_or_null("ContentRegistry")
		var validated = registry.ensure_valid_selection({"universe_id": ctx.get("universe_id", active_universe_selection), "world_id": ctx.get("world_id", active_world_selection)}) if registry else {"universe_id": ctx.get("universe_id", active_universe_selection), "world_id": ctx.get("world_id", active_world_selection)}
		var u_id = validated["universe_id"]
		var w_id = validated["world_id"]
		var sub_id = ctx.get("subcategory_id", "")
		var s_id = ctx.get("scenario_id", "memory_cascade")
		var c_id = ctx.get("chunk_id", "0")
		var d_seed = ctx.get("deterministic_seed", 12345)
		
		print("STEP 8: LOADING SCENARIO")
		print("[ROUTER] Executing continuous scene shift to Destination: { \"universe\": \"" + u_id + "\", \"world\": \"" + w_id + "\", \"chunk_id\": \"" + c_id + "\" }")
		
		var _orch = ExperienceOrchestrator if ExperienceOrchestrator else get_tree().root.get_node_or_null("ExperienceOrchestrator")
		var _profile = PlayerProfile if PlayerProfile else get_tree().root.get_node_or_null("PlayerProfile")
		var seed_str = str(d_seed) + u_id + w_id + sub_id + s_id
		var observation = ObservationCollection.next_observation(u_id, w_id, sub_id, s_id, seed_str) if ObservationCollection else {}
		var scenario_payload = ObservationBuilder.build_payload(observation, s_id, {"universe": u_id, "world": w_id, "subcategory": sub_id}) if (ObservationBuilder and not observation.is_empty()) else {}
		
		if scenario_payload.is_empty():
			scenario_payload = {
				"id": s_id, "universe": u_id, "world": w_id, "subcategory": sub_id, "type": s_id,
				"rules": {"sequence_length": 3, "correct_answer": "Eye of Horus", "wrong_answers": ["Ankh", "Scarab", "Djed"], "legacy_prompt": "DEITY SYMBOL"}
			}
			
		var cascade_scene = load("res://scenes/scenarios/" + _snake_to_pascal(s_id) + ".tscn")
		if cascade_scene == null:
			cascade_scene = preload("res://scenes/scenarios/MemoryCascade.tscn")
			
		var cascade = cascade_scene.instantiate()
		
		if cascade.has_method("inject_payload"):
			cascade.inject_payload(scenario_payload, d_seed)
			
		var world_layer = get_tree().root.get_node_or_null("MainShell/WorldLayer")
		if world_layer:
			world_layer.add_child(cascade)
			print("SCENARIO SPAWNED")
			cascade.completed.connect(_on_cascade_completed)
		else:
			print("[ROUTER] WorldLayer not found (Standalone/Benchmark mode). Mounting scenario directly to root.")
			get_tree().root.add_child(cascade)
			print("SCENARIO SPAWNED")
			cascade.completed.connect(_on_cascade_completed)
		emit_signal("routed_to", ctx)
	else:
		print("[ROUTER] Unknown routing event: ", event)

func _snake_to_pascal(snake: String) -> String:
	var parts = snake.split("_")
	var result = ""
	for part in parts:
		result += part.capitalize()
	return result

func _on_cascade_completed():
	if StructuredLogger and StructuredLogger.has_method("log_event_trace"):
		StructuredLogger.log_event_trace(self, "external_call", "_on_cascade_completed()")
	print("[ROUTER] Observation Spike resolved (Answer submitted). Checking Ad Gate before Slingshot.")
	
	if AdManager and AdManager.check_and_show_ad():
		await AdManager.ad_finished
	
	if SystemHealthMonitor:
		SystemHealthMonitor.pop_context(SystemHealthMonitor.ExecContext.SCENARIO_ACTIVE)
		SystemHealthMonitor.queue_telemetry_dump("Post-Scenario Return")
		
	var tunnel = get_tree().root.get_node_or_null("MainShell/WorldLayer/TunnelLayer")
	if tunnel and tunnel.has_method("trigger_slingshot"):
		tunnel.trigger_slingshot()
		
	if current_scenario_chain_index < 3:
		current_scenario_chain_index += 1
		print("[SCENARIO ENGINE] Advancing to Next Scenario (Index: ", current_scenario_chain_index, " / 3)...")
		print("[SCENARIO ENGINE] Loading Scenario...")
		
		var nav_state = NavigationState if NavigationState else get_tree().root.get_node_or_null("NavigationState")
		var old_ctx = nav_state.get_transition_context() if (nav_state and nav_state.has_method("get_transition_context")) else {}
		var u_id = old_ctx.get("universe_id", active_universe_selection)
		var w_id = old_ctx.get("world_id", active_world_selection)
		var sub_id = old_ctx.get("subcategory_id", active_subcategory_selection)
		
		var profile = PlayerProfile if PlayerProfile else get_tree().root.get_node_or_null("PlayerProfile")
		var next_spike = active_scenario_selection
		if next_spike == "":
			next_spike = GameplayDirector.choose_mechanic(u_id, w_id, sub_id, "", {"chain_index": current_scenario_chain_index}) if GameplayDirector else "rapid_classification"
		if next_spike == "":
			next_spike = "rapid_classification"
		
		var s_seed = str(profile.lifetime_sessions if profile else 0).hash() + current_scenario_chain_index
		if nav_state and nav_state.has_method("lock_transition_context"):
			nav_state.lock_transition_context(u_id, w_id, next_spike, str(current_scenario_chain_index), s_seed, sub_id)
			
		print("[SCENARIO ENGINE] Scenario ", current_scenario_chain_index, " Ready: ", next_spike.capitalize().replace("_", " "))
		handle_navigation_event({"type": "portal_selected"})
	else:
		print("[SCENARIO ENGINE] 3-Scenario progression chain complete. Invoking Mirror Update...")
		current_scenario_chain_index = 1
		toggle_mirror_modal()
