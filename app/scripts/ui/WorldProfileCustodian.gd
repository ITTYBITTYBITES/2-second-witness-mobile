extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# WORLD PROFILE CUSTODIAN (PERCEPTUAL CONTRACTS)
# ---------------------------------------------------------

var _profiles: Dictionary = {}
var _profile_file_count: int = 0

func _ready():
	if BootTracer: BootTracer.log_init("WorldProfileCustodian")
	print("[WORLD PROFILE CUSTODIAN] Online. Compiling unified presentation contracts.")
	_profile_file_count = 0
	_crawl_profiles("res://data/themes")
	print("[WORLD PROFILE] Registry compiled: ", _profiles.size(), " profiles from ", _profile_file_count, " files.")

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
				_profile_file_count += 1
				if data.has("world"):
					_profiles[data["world"]] = data
				if data.has("id"):
					_profiles[data["id"]] = data
		file.close()

func get_profile(world_id: String) -> Dictionary:
	if _profiles.has(world_id):
		return _profiles[world_id]
	return _default_profile(world_id)

func _default_profile(world_id: String) -> Dictionary:
	var registry = Engine.get_main_loop().root.get_node_or_null("ContentRegistry") if Engine.get_main_loop() else null
	var palette = {"primary": Color(0.9, 0.7, 0.1), "bg": Color(0.1, 0.08, 0.05)}
	if registry and registry.has_method("get_world_identity"):
		var identity = registry.get_world_identity("", world_id)
		var reg_palette = identity.get("palette", {})
		if reg_palette.has("primary"): palette["primary"] = reg_palette["primary"]
		if reg_palette.has("bg"): palette["bg"] = reg_palette["bg"]
	return {
		"world": world_id,
		"lens": {"mesh": "neutral_lens", "fog_density": 0.8, "colors": palette},
		"tunnel": {"density": 0.8, "speed_multiplier": 1.2, "flow_type": "linear"},
		"audio": {"ambience": "ambient_default", "ui_stem": "ui_click"},
		"typography": {"font": "default", "spacing": 2.0},
		"animation": {"camera_sway": 1.5, "transition_ms": 900},
		"ui": {"glass_opacity": 0.9, "border_color": palette["primary"]},
		"feedback": {"style": "diagnostic"}
	}
