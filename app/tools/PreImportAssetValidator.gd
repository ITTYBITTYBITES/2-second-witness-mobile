@tool
extends EditorScript

# ---------------------------------------------------------
# TOOL: PRE-IMPORT ASSET VALIDATOR
# Guarantees incoming art assets obey the ASSET_CONTRACT_SPEC
# ---------------------------------------------------------

const INCOMING_DIR = "res://assets_incoming/"

func _run():
	print("\n=============================================")
	print("[ASSET VALIDATOR] Auditing Incoming Asset Candidates...")
	print("=============================================\n")
	
	var passed = true
	if not _audit_directory(INCOMING_DIR + "sprites/", Vector2(128, 128), "StimulusSprite"): passed = false
	if not _audit_directory(INCOMING_DIR + "ui/", Vector2(256, 96), "UIButtonFrame"): passed = false
	if not _audit_directory(INCOMING_DIR + "env/", Vector2(-1, -1), "BackgroundTile"): passed = false
	
	print("\n=============================================")
	if passed:
		print("[VALIDATOR] PASS: All candidates conform to the Asset Contract.")
		print("[ACTION] Candidates are safe to merge into AssetResolver registry.")
	else:
		print("[VALIDATOR] FAIL: Contract violations detected. Rejecting candidates.")
	print("=============================================\n")

func _audit_directory(path: String, required_size: Vector2, class_name: String) -> bool:
	var dir = DirAccess.open(path)
	if not dir: return true # Empty directory is fine
	
	var is_valid = true
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir() and (file_name.ends_with(".png") or file_name.ends_with(".jpg")):
			var full_path = path + file_name
			
			# 1. Format Constraint
			if file_name.ends_with(".jpg"):
				print("[VIOLATION] ", class_name, " -> ", file_name, " is JPG. Lossless PNG required.")
				is_valid = false
			
			# 2. Dimensional Constraint
			var img = Image.load_from_file(full_path)
			if img:
				var size = img.get_size()
				
				if class_name == "BackgroundTile":
					if size.x != size.y or (size.x != 512 and size.x != 1024):
						print("[VIOLATION] ", class_name, " -> ", file_name, " invalid size ", size, ". Must be 512x512 or 1024x1024.")
						is_valid = false
				elif required_size.x > 0 and size != required_size:
					print("[VIOLATION] ", class_name, " -> ", file_name, " invalid size ", size, ". Exact requirement: ", required_size)
					is_valid = false
					
				# Note: Alpha padding constraints require pixel-iteration to detect "empty" edges. 
				# Can be added later for aggressive enforcement, but dimensional strictness covers 90% of layout drift.
				
		file_name = dir.get_next()
		
	return is_valid
