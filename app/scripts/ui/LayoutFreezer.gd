extends Node
class_name LayoutFreezer

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# THE LAYOUT IMMUTABILITY CONTRACT (WITH UNFREEZE RESTORATION)
# ---------------------------------------------------------

static var _frozen_nodes: Dictionary = {}
static var is_frozen: bool = false

static func enforce_freeze(target_ui: CanvasLayer):
	print("[FREEZE STATE] ACTIVE")
	print("[LAYOUT FREEZER] Executing absolute geometry lock on CanvasLayer.")
	is_frozen = true
	if target_ui.get_tree():
		target_ui.get_viewport().gui_release_focus()
	_recursive_freeze(target_ui)

static func _recursive_freeze(node: Node):
	for child in node.get_children():
		if child is Control:
			var fixed_size = child.size
			var fixed_pos = child.position
			var orig_flags_h = child.size_flags_horizontal
			var orig_flags_v = child.size_flags_vertical
			var orig_min = child.custom_minimum_size
			
			_frozen_nodes[child] = {
				"size": fixed_size, "pos": fixed_pos,
				"flags_h": orig_flags_h, "flags_v": orig_flags_v,
				"min": orig_min
			}
			
			child.custom_minimum_size = fixed_size
			child.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			child.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
			
			if child is Label:
				child.autowrap_mode = TextServer.AUTOWRAP_OFF
				child.clip_text = true
				
			child.set_deferred("size", fixed_size)
			child.set_deferred("position", fixed_pos)
			
		_recursive_freeze(child)

static func unfreeze(target_ui: CanvasLayer = null):
	print("[FREEZE STATE] CLEARED")
	print("[LAYOUT FREEZER] Executing unfreeze. Restoring layout container responsiveness.")
	is_frozen = false
	if target_ui:
		_recursive_unfreeze(target_ui)
	else:
		for child in _frozen_nodes.keys():
			if is_instance_valid(child):
				var data = _frozen_nodes[child]
				child.custom_minimum_size = data["min"]
				child.size_flags_horizontal = data["flags_h"]
				child.size_flags_vertical = data["flags_v"]
		_frozen_nodes.clear()

static func _recursive_unfreeze(node: Node):
	for child in node.get_children():
		if child is Control and _frozen_nodes.has(child):
			var data = _frozen_nodes[child]
			child.custom_minimum_size = data["min"]
			child.size_flags_horizontal = data["flags_h"]
			child.size_flags_vertical = data["flags_v"]
			_frozen_nodes.erase(child)
		_recursive_unfreeze(child)
