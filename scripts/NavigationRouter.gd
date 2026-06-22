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
		var roll = randi() % 5
		var cascade_scene
		
		# Expanded Cognitive Spike Array
		# 0: Memory Cascade
		# 1: Pattern Continuation
		# 2: Rapid Classification
		# 3: Spatial Recall (Memory)
		# 4: Math Surprise (Novelty)
		var roll = randi() % 5
		
		if roll == 0:
			cascade_scene = preload("res://scenes/scenarios/MemoryCascade.tscn")
		elif roll == 1:
			cascade_scene = preload("res://scenes/scenarios/PatternContinuation.tscn")
		elif roll == 2:
			cascade_scene = preload("res://scenes/scenarios/RapidClassification.tscn")
		elif roll == 3:
			cascade_scene = preload("res://scenes/scenarios/SpatialRecall.tscn")
		else:
			cascade_scene = preload("res://scenes/scenarios/MathSurprise.tscn")
			
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
