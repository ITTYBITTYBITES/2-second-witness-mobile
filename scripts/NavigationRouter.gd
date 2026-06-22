extends Node

signal routed_to(destination: Dictionary)

func _ready():
	print("NavigationRouter initialized. Awaiting structured events.")

func handle_navigation_event(event: Dictionary):
	if event.get("type") == "portal_selected":
		var dest = event.get("destination", {})
		print("[ROUTER] Executing continuous scene shift to Destination: ", dest)
		emit_signal("routed_to", dest)
		# Future: Actual Godot change_scene_to_file logic to the World Layer goes here
	else:
		print("[ROUTER] Unknown routing event: ", event)
