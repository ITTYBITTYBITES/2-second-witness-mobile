extends Node

signal routed_to(destination: Dictionary)

func _ready():
	print("NavigationRouter initialized. Awaiting structured events.")

func handle_navigation_event(event: Dictionary):
	if event.get("type") == "portal_selected":
		var dest = event.get("destination", {})
		print("[ROUTER] Executing continuous scene shift to Destination: ", dest)
		
		# Vertical Slice v2: Weighted Scenario Rotation
		var cascade_scene_name = SamplingController.get_next_scenario()
		var cascade_scene = load("res://scenes/scenarios/" + _snake_to_pascal(cascade_scene_name) + ".tscn")
		
		if cascade_scene == null:
			cascade_scene = preload("res://scenes/scenarios/MemoryCascade.tscn")
			
		var cascade = cascade_scene.instantiate()
		
		# Attach to World Layer to visually suppress the tunnel
		var world_layer = get_tree().root.get_node("MainShell/WorldLayer")
		if world_layer:
			world_layer.add_child(cascade)
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
	print("[ROUTER] Cognitive Spike resolved. Passing control back to Tunnel for Slingshot.")
	SystemHealthMonitor.pop_context(SystemHealthMonitor.ExecContext.SCENARIO_ACTIVE)
	SystemHealthMonitor.queue_telemetry_dump("Post-Scenario Return")
	var tunnel = get_tree().root.get_node("MainShell/WorldLayer/TunnelLayer")
	if tunnel and tunnel.has_method("trigger_slingshot"):
		tunnel.trigger_slingshot()
