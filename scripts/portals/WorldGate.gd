extends PortalBase

func _get_portal_type() -> String:
	return "world_gate"

func _on_theme_applied(_theme_data: Dictionary):
	print("[WORLD GATE] Updating mid-layer structural visuals per theme rules.")
	# No Monetization Allowed Here.
