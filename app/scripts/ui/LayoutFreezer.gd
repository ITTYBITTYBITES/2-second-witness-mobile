extends Node
class_name LayoutFreezer

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# THE LAYOUT IMMUTABILITY CONTRACT
# ---------------------------------------------------------

static func enforce_freeze(target_ui: CanvasLayer):
	print("[LAYOUT FREEZER] Executing absolute geometry lock on CanvasLayer.")
	
	# 1. Force the engine to resolve all pending container layouts immediately
	if target_ui.get_tree():
		target_ui.get_viewport().gui_release_focus() # Clear interaction state
	
	_recursive_freeze(target_ui)

static func _recursive_freeze(node: Node):
	for child in node.get_children():
		if child is Control:
			# A. Record the exact rect Godot calculated
			var fixed_size = child.size
			var fixed_pos = child.position
			
			# B. Nuke the container's ability to resize it
			child.custom_minimum_size = fixed_size
			
			# C. If it's inside a Container, rip it out of the solver's control
			# by explicitly setting size flags to 0 (SIZE_SHRINK_BEGIN) or overriding anchors.
			child.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			child.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
			
			# D. Disable text autowrap expansion
			if child is Label:
				child.autowrap_mode = TextServer.AUTOWRAP_OFF
				child.clip_text = true
				
			# E. Force it back to its canonical position/size just in case the flags shifted it
			child.set_deferred("size", fixed_size)
			child.set_deferred("position", fixed_pos)
			
		_recursive_freeze(child)
