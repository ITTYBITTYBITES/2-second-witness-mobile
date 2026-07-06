extends Node

signal theme_applied(theme_data: Dictionary)

var active_theme_id: String = ""
var active_theme_data: Dictionary = {}
var _theme_registry: Dictionary = {}
var _theme_file_count: int = 0

func _ready():
	BootTracer.log_init("ThemeManager")
	print("ThemeManager initialized. Compiling visual identities...")
	_load_all_themes()

func _load_all_themes():
	_theme_file_count = 0
	var dir = DirAccess.open("res://data/themes")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".json"):
				_load_theme_file("res://data/themes/" + file_name)
			file_name = dir.get_next()
	print("[THEME] Registry compiled: ", _theme_registry.size(), " identities from ", _theme_file_count, " files.")

func _load_theme_file(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		if error == OK:
			var data = json.data
			if data.has("id"):
				_theme_registry[data["id"]] = data
				_theme_file_count += 1
			else:
				print("[THEME ERROR] Missing ID in ", path)
		else:
			print("[THEME ERROR] Failed to parse JSON at ", path)

var _is_transitioning: bool = false

func apply_theme(theme_id: String):
	if _is_transitioning:
		print("[THEME ERROR] Transition in progress. Ignoring theme request.")
		return
		
	if _theme_registry.has(theme_id):
		_is_transitioning = true
		active_theme_id = theme_id
		active_theme_data = _theme_registry[theme_id]
		print("[THEME] Applying Theme Identity: ", active_theme_data["display_name"])
		emit_signal("theme_applied", active_theme_data)
		_is_transitioning = false
	else:
		print("[THEME ERROR] Theme not found in registry: ", theme_id)

func get_active_theme() -> Dictionary:
	return active_theme_data
