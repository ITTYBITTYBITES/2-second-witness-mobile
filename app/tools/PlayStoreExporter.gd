@tool
extends EditorScript

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# AUTOMATED PLAY STORE EXPORT PREP
# ---------------------------------------------------------

# --- CONFIGURATION -----------------------------------------
# If you need to manually jump the version to match your Google Play Console history,
# set these to the target values and set OVERRIDE_VERSION to true.
const OVERRIDE_VERSION = true
const TARGET_VERSION_CODE = 31      # Example: The integer Google Play expects
const TARGET_VERSION_NAME = "3.1.0" # Example: The string the user sees on the store
# ---------------------------------------------------------

func _run():
	print("\n=============================================")
	print("[EXPORT PREP] Preparing Godot for Google Play Release...")
	print("=============================================\n")
	
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
		
	var preset_path = "res://export_presets.cfg"
	var p_file = FileAccess.open(preset_path, FileAccess.READ_WRITE)
	if p_file:
		var content = p_file.get_as_text()
		
		var code_regex = RegEx.new()
		code_regex.compile("version/code=(\\d+)")
		var name_regex = RegEx.new()
		name_regex.compile("version/name=\"([^\"]+)\"")
		
		var code_result = code_regex.search(content)
		var name_result = name_regex.search(content)
		
		if code_result and name_result:
			var old_code_str = code_result.get_string(1)
			var old_name_str = name_result.get_string(1)
			
			var new_code = ""
			var new_name = ""
			
			if OVERRIDE_VERSION:
				new_code = str(TARGET_VERSION_CODE)
				new_name = TARGET_VERSION_NAME
				print("⚠️ OVERRIDE ACTIVE: Forcing version to match Play Console constraints.")
			else:
				new_code = str(old_code_str.to_int() + 1)
				# Simple semantic bump assuming format X.Y.Z
				var parts = old_name_str.split(".")
				if parts.size() == 3:
					new_name = "%s.%s.%s" % [parts[0], parts[1], str(parts[2].to_int() + 1)]
				else:
					new_name = old_name_str + ".1"
			
			content = content.replace("version/code=" + old_code_str, "version/code=" + new_code)
			content = content.replace("version/name=\"" + old_name_str + "\"", "version/name=\"" + new_name + "\"")
			
			p_file.seek(0)
			p_file.store_string(content)
			print("✅ export_presets.cfg: Version bumped to Code: ", new_code, " | Name: ", new_name)
		else:
			print("❌ FAILED to find version formatting in export_presets.cfg")
		p_file.close()
	else:
		print("❌ FAILED to open export_presets.cfg")
		
	print("\n=============================================")
	print("[EXPORT PREP COMPLETE]")
	print("WARNING: AdMob is now LIVE. Do not press Play in Editor.")
	print("Please go to Project -> Export -> Export AAB now.")
	print("=============================================\n")
