extends Node

signal routed_to(destination: Dictionary)

func _ready():
	print("NavigationRouter initialized. Awaiting structured events.")

func handle_navigation_event(event: Dictionary):
	if event.get("type") == "portal_selected":
		var dest = event.get("destination", {})
		print("[ROUTER] Executing continuous scene shift to Destination: ", dest)
		
		# Vertical Slice v2: Weighted Scenario Rotation
		# 50% Memory Cascade | 25% Pattern Continuation | 25% Rapid Classification
		var roll = randf()
		var cascade_scene
		
		if roll < 0.5:
			cascade_scene = preload("res://scenes/scenarios/MemoryCascade.tscn")
		elif roll < 0.75:
			cascade_scene = preload("res://scenes/scenarios/PatternContinuation.tscn")
		else:
			cascade_scene = preload("res://scenes/scenarios/RapidClassification.tscn")
			
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
	var tunnel = get_tree().root.get_node("MainShell/WorldLayer/TunnelLayer")
	if tunnel and tunnel.has_method("trigger_slingshot"):
		tunnel.trigger_slingshot()
