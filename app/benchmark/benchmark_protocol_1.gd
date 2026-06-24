extends Node3D

@onready var chunk_pool = $ChunkPool
@onready var stream_controller = $StreamController
@onready var health_monitor = $SystemHealthMonitor

var _test_densities = [1.0, 1.25, 1.50, 1.75, 2.00, 2.50]
var active_test_density: float = 1.0
var active_universe: String = "creative_arts" # Test the swap

var target_loops = 5
var current_loops = 0

var landing_screen_scene = preload("res://scenes/ui/screens/LandingScreen.tscn")
var profile_screen_scene = preload("res://scenes/ui/screens/PlayerProfileScreen.tscn")
var active_ui_layer = null

func _ready():
	randomize()
	active_test_density = _test_densities[randi() % _test_densities.size()]
	
	var universes = ["science_lab", "tech_ops", "life_sciences", "society_mind", "creative_arts", "frontier"]
	active_universe = universes[randi() % universes.size()]
	
	seed(12345)
	stream_controller.chunk_pool = chunk_pool
	
	var base_chunks = 5
	var test_chunks = int(base_chunks * active_test_density)
	chunk_pool.reset_pool(test_chunks, active_universe)
	
	for i in range(test_chunks):
		chunk_pool.spawn_at_offset(i * -50.0)
	
	stream_controller.set_flow_speed(1.0) 
	health_monitor.push_context(health_monitor.ExecContext.CHUNK_STREAMING, true)
	
	NavigationEngine.navigation_event.connect(_on_loop_completed)
	
	var shader = get_node_or_null("/root/MainShell/WorldLayer/TunnelLayer/Tier1_ShaderField/ShaderRect")
	if shader:
		var renderer = UniverseRenderer.new()
		var def = renderer.universe_definitions.get(active_universe)
		shader.apply_theme({"palette": def["palette"]}, active_universe)
	
	_show_landing()

func _show_landing():
	if active_ui_layer: active_ui_layer.queue_free()
	var landing = landing_screen_scene.instantiate()
	add_child(landing)
	active_ui_layer = landing
	
	landing.play_requested.connect(func(): _start_session("science_lab"))
	landing.profile_requested.connect(_show_profile)
	landing.discover_requested.connect(_show_discovery)
	
	var portal_layer = get_node_or_null("/root/MainShell/WorldLayer/TunnelLayer/Tier3_PortalLayer")
	if portal_layer:
		for child in portal_layer.get_children():
			child.queue_free()

func _show_discovery():
	if active_ui_layer: active_ui_layer.queue_free()
	var discovery_scene = preload("res://scenes/ui/screens/WeeklyFeaturedScreen.tscn")
	var discovery = discovery_scene.instantiate()
	add_child(discovery)
	active_ui_layer = discovery
	
	discovery.return_requested.connect(_show_landing)
	discovery.play_universe_requested.connect(_start_session)

func _start_session(universe_id: String, world_id: String = ""):
	active_universe = universe_id
	
	if active_ui_layer and active_ui_layer.has_method("hide_screen"):
		active_ui_layer.hide_screen()
		
	# Tell the Navigation State Machine what we are focusing on
	if world_id == "":
		NavigationState.set_exploration_mode(universe_id)
	else:
		NavigationState.set_focus_mode(universe_id, world_id)
		
	# Instantly swap the tunnel environment to match the selected universe and world
	var base_chunks = 5
	var test_chunks = int(base_chunks * active_test_density)
	chunk_pool.reset_pool(test_chunks, active_universe)
	for i in range(test_chunks):
		chunk_pool.spawn_at_offset(i * -50.0)
		
	var shader = get_node_or_null("/root/MainShell/WorldLayer/TunnelLayer/Tier1_ShaderField/ShaderRect")
	if shader:
		var renderer = UniverseRenderer.new()
		var world_renderer = WorldRenderer.new()
		var def = renderer.universe_definitions.get(active_universe, renderer.universe_definitions["science_lab"])
		
		# Apply World Modifiers to the Universe Base
		def = world_renderer.get_world_modifiers(world_id, def)
		shader.apply_theme(def, active_universe, world_id)
		
	current_loops = 0
	
	var portal_layer = get_node_or_null("/root/MainShell/WorldLayer/TunnelLayer/Tier3_PortalLayer")
	if portal_layer:
		var initial_iris = preload("res://scripts/portals/ScenarioNode.gd").new()
		initial_iris.position = Vector3(0, 0, -20)
		initial_iris.setup(2, {"universe": active_universe, "world": world_id, "chunk_id": "start"})
		portal_layer.add_child(initial_iris)

func _show_profile():
	if active_ui_layer: active_ui_layer.queue_free()
	var profile = profile_screen_scene.instantiate()
	add_child(profile)
	active_ui_layer = profile
	
	var btn = Button.new()
	btn.text = "RETURN TO MENU"
	btn.custom_minimum_size = Vector2(200, 50)
	btn.position = Vector2(20, 20)
	btn.pressed.connect(_show_landing)
	profile.add_child(btn)

func _on_loop_completed(payload: Dictionary):
	current_loops += 1
	if current_loops >= target_loops:
		await get_tree().create_timer(3.0).timeout 
		var portal_layer = get_node_or_null("/root/MainShell/WorldLayer/TunnelLayer/Tier3_PortalLayer")
		if portal_layer:
			for child in portal_layer.get_children():
				child.queue_free()
		_show_profile()
