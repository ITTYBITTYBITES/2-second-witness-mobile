extends PortalBase

func _get_portal_type() -> String:
	return "universe_portal"

func _on_theme_applied(_theme_data: Dictionary):
	# The Theme dictates the macro shape and environmental preview
	print("[UNIVERSE PORTAL] Morphing macro shape language for: ", _theme_data.get("display_name", "Unknown"))
	# No Monetization Allowed Here.
