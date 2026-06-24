@tool
extends EditorScript

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# AUTOMATED PLAY STORE EXPORT PREP
# ---------------------------------------------------------

func _run():
	print("\n=============================================")
	print("[EXPORT PREP] Preparing Godot for Google Play Release...")
	print("=============================================\n")
	
	# 1. Force AdManager to LIVE mode
	var ad_manager_path = "res://scripts/system/AdManager.gd"
	var file = FileAccess.open(ad_manager_path, FileAccess.READ_WRITE)
	if file:
		var content = file.get_as_text()
		content = content.replace("const USE_LIVE_ADS = false", "const USE_LIVE_ADS = true")
		file.seek(0)
		file.store_string(content)
		file.close()
		print("✅ AdManager.gd: Forced USE_LIVE_ADS to TRUE.")
	else:
		print("❌ FAILED to open AdManager.gd")
		
	# 2. Auto-increment the Version Code in export_presets.cfg
	var preset_path = "res://export_presets.cfg"
	var p_file = FileAccess.open(preset_path, FileAccess.READ_WRITE)
	if p_file:
		var content = p_file.get_as_text()
		
		# Find the current version code using regex
		var regex = RegEx.new()
		regex.compile("version/code=(\\d+)")
		var result = regex.search(content)
		
		if result:
			var old_code_str = result.get_string(1)
			var new_code = old_code_str.to_int() + 1
			content = content.replace("version/code=" + old_code_str, "version/code=" + str(new_code))
			
			# Simple version name bump (e.g. 1.0.0 -> 1.0.1)
			var name_regex = RegEx.new()
			name_regex.compile("version/name=\"1\\.0\\.(\\d+)\"")
			var name_result = name_regex.search(content)
			if name_result:
				var old_patch = name_result.get_string(1)
				var new_patch = old_patch.to_int() + 1
				content = content.replace("version/name=\"1.0." + old_patch + "\"", "version/name=\"1.0." + str(new_patch) + "\"")
			
			p_file.seek(0)
			p_file.store_string(content)
			print("✅ export_presets.cfg: Auto-incremented version code to ", new_code)
		else:
			print("❌ FAILED to find version/code in export_presets.cfg")
		p_file.close()
	else:
		print("❌ FAILED to open export_presets.cfg")
		
	print("\n=============================================")
	print("[EXPORT PREP COMPLETE]")
	print("WARNING: AdMob is now LIVE. Do not press Play in Editor.")
	print("Please go to Project -> Export -> Export AAB now.")
	print("=============================================\n")
