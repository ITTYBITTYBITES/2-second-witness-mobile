extends SceneTree

var failures: Array[String] = []
var loaded_count: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var paths: Array[String] = []
	_collect_scripts("res://src", paths)
	paths.sort()
	for path: String in paths:
		var resource: Resource = load(path)
		if resource == null:
			failures.append(path)
			push_error("[SOURCE-LOAD FAIL] %s" % path)
		else:
			loaded_count += 1
	print("[SOURCE-LOAD SUMMARY] %d loaded, %d failed" % [loaded_count, failures.size()])
	quit(0 if failures.is_empty() else 1)

func _collect_scripts(directory_path: String, output: Array[String]) -> void:
	var directory := DirAccess.open(directory_path)
	if directory == null:
		failures.append(directory_path)
		return
	directory.list_dir_begin()
	var entry := directory.get_next()
	while not entry.is_empty():
		if entry != "." and entry != "..":
			var full_path := directory_path.path_join(entry)
			if directory.current_is_dir():
				_collect_scripts(full_path, output)
			elif entry.ends_with(".gd"):
				output.append(full_path)
		entry = directory.get_next()
	directory.list_dir_end()
