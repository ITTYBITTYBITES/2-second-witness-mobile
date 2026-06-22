@tool
extends EditorScript

# Editor-side linter to enforce FIDELITY_BUDGET_SPEC.md constraints

func _run():
	print("\n=============================================")
	print("[BUDGET LINTER] Analyzing res://assets...")
	print("=============================================\n")
	
	var dir = DirAccess.open("res://assets")
	if dir:
		_scan_dir("res://assets")
	
	print("\n=============================================")
	print("[BUDGET LINTER] Scan Complete.")
	print("=============================================\n")

func _scan_dir(path: String):
	var dir = DirAccess.open(path)
	if not dir: return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue
			
		var full_path = path + "/" + file_name
		if dir.current_is_dir():
			_scan_dir(full_path)
		else:
			_check_asset(full_path)
		
		file_name = dir.get_next()

func _check_asset(path: String):
	if path.ends_with(".png") or path.ends_with(".jpg"):
		var img = Image.load_from_file(path)
		if img:
			if img.get_width() > 2048 or img.get_height() > 2048:
				print("[VIOLATION] Texture too large (Max 2048x2048): ", path, " (", img.get_width(), "x", img.get_height(), ")")
	
	elif path.ends_with(".tres") or path.ends_with(".material"):
		var mat = ResourceLoader.load(path)
		if mat is StandardMaterial3D or mat is ShaderMaterial:
			# If it's a StandardMaterial3D, checking its transparency flag
			if mat is StandardMaterial3D and mat.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
				print("[WARNING] Material uses transparency. Overdraw cap is 2 layers. Monitor usage: ", path)
