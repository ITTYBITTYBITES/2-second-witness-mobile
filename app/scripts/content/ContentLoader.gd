extends Node

@onready var registry = get_node("/root/ContentRegistry")

const BASE_BUNDLE_PATH = "res://data/content/base_bundle/"
const USER_CACHE_PATH = "user://live_content/"

func _ready():
	print("[CONTENT LOADER] Initialized. Crawling Base Bundle...")
	_crawl_directory(BASE_BUNDLE_PATH)
	
	if DirAccess.dir_exists_absolute(USER_CACHE_PATH + "patches/"):
		print("[CONTENT LOADER] OTA Patches detected. Overwriting base registry...")
		_crawl_directory(USER_CACHE_PATH + "patches/")

func _crawl_directory(path: String):
	var dir = DirAccess.open(path)
	if not dir:
		print("[CONTENT ERROR] Cannot open directory: ", path)
		return
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue
			
		var full_path = path + "/" + file_name
		# If it's a directory, clean up the pathing (avoid //)
		full_path = full_path.replace("//", "/")
		full_path = full_path.replace("res:/", "res://")
		
		if dir.current_is_dir():
			_crawl_directory(full_path) 
		elif file_name.ends_with(".json"):
			_load_and_register_file(full_path)
			
		file_name = dir.get_next()

func _load_and_register_file(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		if error == OK:
			var data = json.data
			if typeof(data) == TYPE_DICTIONARY and _validate_schema(data):
				# Robust fallback to find the global ContentRegistry regardless of tree status
				if registry == null: 
					registry = Engine.get_main_loop().root.get_node_or_null("ContentRegistry")
				if registry != null: 
					registry.register_scenario(data)
			else:
				print("[CONTENT ERROR] Schema invalid: ", path)
		else:
			print("[CONTENT ERROR] JSON parse failed: ", path)

func _validate_schema(data: Dictionary) -> bool:
	return data.has("id") and data.has("universe") and data.has("type")
