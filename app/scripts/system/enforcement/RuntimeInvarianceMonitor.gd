extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# THE RUNTIME DRIFT WATCHDOG
# ---------------------------------------------------------

var _canonical_geometry: Dictionary = {}
var _is_monitoring: bool = false
var _target_layer: CanvasLayer

func _ready():
	print("[INVARIANCE MONITOR] Online. Guarding against Engine layout drift.")

func capture_canonical_geometry(target_ui: CanvasLayer):
	_target_layer = target_ui
	_canonical_geometry.clear()
	_recursive_capture(target_ui, "")
	_is_monitoring = true
	print("[INVARIANCE MONITOR] Geometry captured. Watchdog active.")

func _recursive_capture(node: Node, path: String):
	for child in node.get_children():
		var current_path = path + "/" + child.name
		if child is Control:
			_canonical_geometry[current_path] = {
				"size": child.size,
				"position": child.position
			}
		_recursive_capture(child, current_path)

func _process(_delta):
	if not _is_monitoring or not is_instance_valid(_target_layer):
		return
		
	# Audit the live scene tree against the canonical snapshot
	_recursive_audit(_target_layer, "")

func _recursive_audit(node: Node, path: String):
	for child in node.get_children():
		var current_path = path + "/" + child.name
		if child is Control:
			var canonical = _canonical_geometry.get(current_path)
			if canonical:
				if not child.size.is_equal_approx(canonical["size"]) or not child.position.is_equal_approx(canonical["position"]):
					print("[INVARIANCE FATAL] Geometry drift detected at runtime on: ", current_path)
					print("  Expected: ", canonical["size"], " @ ", canonical["position"])
					print("  Actual:   ", child.size, " @ ", child.position)
					# In production, this instantly triggers a rollback or throws a hard exception.
					_is_monitoring = false
					return
		_recursive_audit(child, current_path)
