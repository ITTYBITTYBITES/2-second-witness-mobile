extends Node
class_name LayoutQuiescenceGate

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# THE SETTLEMENT GUARANTEE
# ---------------------------------------------------------

signal layout_stabilized

var _is_waiting: bool = false
var _stable_frames: int = 0
var _required_stable_frames: int = 3 # Guarantee Godot's internal multi-pass reflow is exhausted

# Track the hash of the geometry to detect micro-shifts
var _last_geometry_hash: int = 0

func begin_quiescence_wait(target: CanvasLayer):
	_target_layer = target
	_is_waiting = true
	_stable_frames = 0
	_last_geometry_hash = _hash_geometry(target)
	print("[QUIESCENCE GATE] Observing layout stabilization...")

var _target_layer: CanvasLayer

func _process(_delta):
	if not _is_waiting or not is_instance_valid(_target_layer):
		return
		
	var current_hash = _hash_geometry(_target_layer)
	
	if current_hash == _last_geometry_hash:
		_stable_frames += 1
		if _stable_frames >= _required_stable_frames:
			_is_waiting = false
			print("[QUIESCENCE GATE] Layout stabilized after ", _required_stable_frames, " frames. Handing off to Freezer.")
			emit_signal("layout_stabilized")
	else:
		# Layout shifted (e.g. Font atlas finished baking, Container reflowed)
		print("[QUIESCENCE GATE] Transient shift detected. Resetting stability counter.")
		_stable_frames = 0
		_last_geometry_hash = current_hash

func _hash_geometry(node: Node) -> int:
	var h = 0
	for child in node.get_children():
		if child is Control:
			# Hash the exact size and position vectors
			h = hash(h + hash(child.size) + hash(child.position))
		h = hash(h + _hash_geometry(child))
	return h
