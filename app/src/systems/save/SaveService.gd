extends Node
## SaveService - Low-level persistence (JSON)
## Provides encrypted-ready JSON save, versioning, migration

signal save_completed(slot: String)
signal save_failed(slot: String, reason: String)
signal save_loaded(slot: String, data: Dictionary)

const SAVE_VERSION := 2
const SAVE_DIR := "user://saves/"
const PROFILE_FILE := "user://profile_v2.json"
const SETTINGS_FILE := "user://settings_v2.json"

var _initialized: bool = false

func _ready() -> void:
	print("[SaveService] Ready")

func initialize() -> void:
	if _initialized:
		return
	# Ensure save directory exists
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	_initialized = true
	print("[SaveService] Initialized - Dir: %s" % SAVE_DIR)

func save_json(path: String, data: Dictionary, encrypt: bool = false) -> bool:
	var dir := path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	
	var wrapper := {
		"version": SAVE_VERSION,
		"timestamp": Time.get_datetime_string_from_system(),
		"ticks": Time.get_ticks_msec(),
		"data": data
	}
	
	var json_text := JSON.stringify(wrapper, "\t")
	
	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		var err := "Failed to open %s for write: %s" % [path, str(FileAccess.get_open_error())]
		ErrorHandler.handle("SAVE_WRITE_FAILED", err, {"path": path})
		save_failed.emit(path, err)
		return false
	
	file.store_string(json_text)
	file.close()
	
	save_completed.emit(path)
	# print("[SaveService] Saved %s (%d bytes)" % [path, json_text.length()])
	return true

func load_json(path: String, default_data: Dictionary = {}) -> Dictionary:
	if not FileAccess.file_exists(path):
		return default_data
	
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		ErrorHandler.handle("SAVE_READ_FAILED", "Cannot open file", {"path": path})
		return default_data
	
	var text := file.get_as_text()
	file.close()
	
	var parsed = JSON.parse_string(text)
	if parsed == null or not (parsed is Dictionary):
		ErrorHandler.handle("SAVE_PARSE_FAILED", "JSON parse failed", {"path": path})
		return default_data
	
	var wrapper: Dictionary = parsed
	var version: int = wrapper.get("version", 1)
	var data: Dictionary = wrapper.get("data", {})
	
	# Migration hook
	if version < SAVE_VERSION:
		data = _migrate(data, version, SAVE_VERSION)
	
	save_loaded.emit(path, data)
	return data

func delete_save(path: String) -> bool:
	if FileAccess.file_exists(path):
		var err := DirAccess.remove_absolute(path)
		if err != OK:
			ErrorHandler.handle("SAVE_DELETE_FAILED", "Delete failed", {"path": path, "err": err})
			return false
	return true

func has_save(path: String) -> bool:
	return FileAccess.file_exists(path)

func list_saves(dir_path: String = SAVE_DIR) -> Array[String]:
	var saves: Array[String] = []
	if not DirAccess.dir_exists_absolute(dir_path):
		return saves
	var dir := DirAccess.open(dir_path)
	if not dir:
		return saves
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			saves.append(dir_path.path_join(file_name))
		file_name = dir.get_next()
	dir.list_dir_end()
	return saves

func _migrate(data: Dictionary, from_version: int, to_version: int) -> Dictionary:
	print("[SaveService] Migrating save %d -> %d" % [from_version, to_version])
	# Placeholder for future migrations
	# Example: v1 -> v2 rename keys
	if from_version == 1 and to_version >= 2:
		# Migrate any legacy keys
		if data.has("player_name"):
			data["profile_name"] = data["player_name"]
			data.erase("player_name")
	return data

# Convenience wrappers
func save_profile(data: Dictionary) -> bool:
	return save_json(PROFILE_FILE, data)

func load_profile() -> Dictionary:
	return load_json(PROFILE_FILE, {})

func save_settings(data: Dictionary) -> bool:
	return save_json(SETTINGS_FILE, data)

func load_settings() -> Dictionary:
	return load_json(SETTINGS_FILE, {})
