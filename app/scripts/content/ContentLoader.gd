extends Node

@onready var registry = get_node("/root/ContentRegistry")
@onready var sync_manager = null # Assigned later

const BASE_BUNDLE_PATH = "res://data/content/base_bundle/"
const GITHUB_CACHE_PATH = "user://github_cache/"

func _ready():
	print("ContentLoader initialized. Executing Offline-First build strategy.")
	_ingest_base_bundle()
	
	# Future: Trigger GitHubSyncManager check here.

func _ingest_base_bundle():
	# In a real Godot project this recursively walks BASE_BUNDLE_PATH
	# Here we simulate finding the specific mock file
	_load_and_register_file(BASE_BUNDLE_PATH + "society_mind/cognitive_bias/stroop_042.json")

func _load_and_register_file(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		if error == OK:
			var data = json.data
			if _validate_schema(data):
				registry.register_scenario(data)
				print("[CONTENT LOADER] Ingested Scenario: ", data.get("id"))
			else:
				print("[CONTENT ERROR] Schema invalid: ", path)
		else:
			print("[CONTENT ERROR] JSON parse failed: ", path)

func _validate_schema(data: Dictionary) -> bool:
	return data.has("id") and data.has("universe") and data.has("world") and data.has("type")
