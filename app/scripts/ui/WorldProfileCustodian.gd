extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# WORLD PROFILE CUSTODIAN (PERCEPTUAL CONTRACTS)
# ---------------------------------------------------------

var _profiles: Dictionary = {}

func _ready():
	if BootTracer: BootTracer.log_init("WorldProfileCustodian")
	print("[WORLD PROFILE CUSTODIAN] Online. Compiling unified presentation contracts.")
	_crawl_profiles("res://data/themes")

func _crawl_profiles(path: String):
	var dir = DirAccess.open(path)
	if not dir: return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue
		var full_path = path + "/" + file_name
		full_path = full_path.replace("//", "/").replace("res:/", "res://")
		if dir.current_is_dir():
			_crawl_profiles(full_path)
		elif file_name.ends_with(".json"):
			_load_profile_file(full_path)
		file_name = dir.get_next()

func _load_profile_file(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var json = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			var data = json.get_data()
			if typeof(data) == TYPE_DICTIONARY:
				if data.has("world"):
					_profiles[data["world"]] = data
					print("[WORLD PROFILE] Loaded presentation asset: ", data["world"])
				if data.has("id"):
					_profiles[data["id"]] = data
					print("[WORLD PROFILE] Loaded presentation asset ID: ", data["id"])
		file.close()

func get_profile(world_id: String) -> Dictionary:
	if _profiles.has(world_id):
		return _profiles[world_id]
	return _default_profile()

func _default_profile() -> Dictionary:
	return {
		"world": "ancient_egypt",
		"lens": {"mesh": "eye_of_horus", "fog_density": 0.8, "colors": {"primary": Color(0.9, 0.7, 0.1), "bg": Color(0.1, 0.08, 0.05)}},
		"tunnel": {"density": 0.8, "speed_multiplier": 1.2, "flow_type": "linear"},
		"audio": {"ambience": "desert_winds", "ui_stem": "stone_click"},
		"typography": {"font": "hieroglyphic", "spacing": 2.0},
		"animation": {"camera_sway": 1.5, "transition_ms": 900},
		"ui": {"glass_opacity": 0.9, "border_color": Color(0.9, 0.7, 0.1)},
		"feedback": {"style": "archaeological"}
	}
