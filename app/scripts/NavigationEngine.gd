extends Node

signal transition_sequence_started
signal navigation_event(payload: Dictionary)

enum PortalState {
	LOCKED,
	VISIBLE,
	AVAILABLE,
	ACTIVE
}

func _ready():
	print("NavigationEngine initialized. Serving as Navigation Layer truth source.")
	# Late connection to Router to handle load order
	call_deferred("_connect_to_router")

func _connect_to_router():
	navigation_event.connect(NavigationRouter.handle_navigation_event)

func process_selection(_portal_node: Node3D, portal_type: String, destination_data: Dictionary):
	print("[NAV ENGINE] Portal selected: ", portal_type, " -> ", destination_data)
	
	# Step 1-4: Trigger visual sequence (Tunnel slows, portal expands, others fade, theme transition)
	emit_signal("transition_sequence_started")
	
	# Step 5: Package strict schema output for Router
	var payload = {
		"type": "portal_selected",
		"destination": destination_data
	}
	
	# Simulate the duration of the continuous motion transition (No hard cuts)
	var active_theme = ThemeManager.get_active_theme()
	var duration_ms = active_theme.get("transition", {}).get("duration_ms", 900)
	await get_tree().create_timer(duration_ms / 1000.0).timeout
	
	# Send command to Router for actual Scene shift to World Layer
	emit_signal("navigation_event", payload)
