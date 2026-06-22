extends Node

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		print("[DEBUG] Forcing Iris selection via Spacebar fallback.")
		var portal_layer = get_tree().root.get_node_or_null("MainShell/WorldLayer/TunnelLayer/Tier3_PortalLayer")
		if portal_layer and portal_layer.get_child_count() > 0:
			var portal = portal_layer.get_child(portal_layer.get_child_count() - 1)
			if portal and portal.has_method("select_portal"):
				portal.select_portal()
