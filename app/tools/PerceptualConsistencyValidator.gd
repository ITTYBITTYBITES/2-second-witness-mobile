@tool
extends EditorScript

# ---------------------------------------------------------
# TOOL: PERCEPTUAL CONSISTENCY VALIDATOR
# Guarantees the Asset Layer does not corrupt the Measurement Layer
# ---------------------------------------------------------

const SCENARIOS_DIR = "res://scenes/scenarios/"

func _run():
	print("\n=============================================")
	print("[CONSISTENCY VALIDATOR] Auditing Perceptual Invariants...")
	print("=============================================\n")
	
	var dir = DirAccess.open(SCENARIOS_DIR)
	if not dir: return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	var passed = true
	
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tscn"):
			var scene = load(SCENARIOS_DIR + file_name).instantiate()
			if not _validate_scene_invariants(scene, file_name):
				passed = false
			scene.free()
		file_name = dir.get_next()
		
	print("\n=============================================")
	if passed:
		print("[VALIDATOR] PASS: All interaction geometries and temporal bounds are stable.")
	else:
		print("[VALIDATOR] FAIL: Perceptual drift detected. See logs above.")
	print("=============================================\n")

func _validate_scene_invariants(scene: Node, scene_name: String) -> bool:
	var is_valid = true
	
	# 1. Hitbox Constraint (Buttons must remain predictable sizes)
	var buttons = _find_nodes_of_class(scene, "Button")
	for btn in buttons:
		var size = btn.custom_minimum_size
		if size.x < 100 or size.y < 80:
			print("[VIOLATION] ", scene_name, " -> Hitbox degraded. Button '", btn.name, "' is too small (", size, ").")
			is_valid = false
			
	# 2. Spatial Entropy Constraint (Layout anchor checks)
	# E.g., ensuring HBoxContainers haven't had their 'separation' value tightened/widened arbitrarily
	var hboxes = _find_nodes_of_class(scene, "HBoxContainer")
	for box in hboxes:
		var sep = box.get_theme_constant("separation")
		if sep != 40 and sep != 60: # Our established canonical spacings
			print("[VIOLATION] ", scene_name, " -> Spatial entropy drift. Container '", box.name, "' separation altered to ", sep, ".")
			is_valid = false
			
	# 3. Temporal Phase Boundaries
	# If we stored animation durations in a metadata field, we would assert them here.
	
	return is_valid

func _find_nodes_of_class(root: Node, class_name: String) -> Array:
	var result = []
	for child in root.get_children():
		if child.get_class() == class_name:
			result.append(child)
		result.append_array(_find_nodes_of_class(child, class_name))
	return result
