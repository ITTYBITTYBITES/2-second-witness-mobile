extends Node

signal routed_to(destination: Dictionary)

func _ready():
	print("NavigationRouter initialized. Awaiting structured events.")

func handle_navigation_event(event: Dictionary):
	if event.get("type") == "portal_selected":
		var dest = event.get("destination", {})
		print("[ROUTER] Executing continuous scene shift to Destination: ", dest)
		
		# Vertical Slice v2: Weighted Scenario Rotation
		var cascade_scene
		
		# 10 Cognitive Spikes (Milestone 1)
		var roll = randi() % 10
		
		if roll == 0:
			cascade_scene = preload("res://scenes/scenarios/MemoryCascade.tscn")
		elif roll == 1:
			cascade_scene = preload("res://scenes/scenarios/SpatialRecall.tscn")
		elif roll == 2:
			cascade_scene = preload("res://scenes/scenarios/SequenceReverse.tscn")
		elif roll == 3:
			cascade_scene = preload("res://scenes/scenarios/PatternContinuation.tscn")
		elif roll == 4:
			cascade_scene = preload("res://scenes/scenarios/OddOneOut.tscn")
		elif roll == 5:
			cascade_scene = preload("res://scenes/scenarios/StroopTest.tscn")
		elif roll == 6:
			cascade_scene = preload("res://scenes/scenarios/RapidClassification.tscn")
		elif roll == 7:
			cascade_scene = preload("res://scenes/scenarios/SpeedSort.tscn")
		elif roll == 8:
			cascade_scene = preload("res://scenes/scenarios/MathSurprise.tscn")
		else:
			cascade_scene = preload("res://scenes/scenarios/ReflexTap.tscn")
			
		var cascade = cascade_scene.instantiate()
		
		# Attach to World Layer to visually suppress the tunnel
		var world_layer = get_tree().root.get_node("MainShell/WorldLayer")
		if world_layer:
			world_layer.add_child(cascade)
			cascade.completed.connect(_on_cascade_completed)
		emit_signal("routed_to", dest)
	else:
		print("[ROUTER] Unknown routing event: ", event)

func _on_cascade_completed():
	print("[ROUTER] Cognitive Spike resolved. Passing control back to Tunnel for Slingshot.")
	SystemHealthMonitor.pop_context(SystemHealthMonitor.ExecContext.SCENARIO_ACTIVE)
	SystemHealthMonitor.queue_telemetry_dump("Post-Scenario Return")
	var tunnel = get_tree().root.get_node("MainShell/WorldLayer/TunnelLayer")
	if tunnel and tunnel.has_method("trigger_slingshot"):
		tunnel.trigger_slingshot()
