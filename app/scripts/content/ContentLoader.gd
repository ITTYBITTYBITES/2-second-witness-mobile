extends Node

@onready var registry = get_node("/root/ContentRegistry")

const BASE_BUNDLE_PATH = "res://data/content/base_bundle/"
const USER_CACHE_PATH = "user://live_content/"
const OBSERVATION_BANK_PATH = "res://data/observation_banks/"

var _is_indexed: bool = false
var _indexed_files: Dictionary = {} # [universe_id][world_id] = Array[String]
var _loaded_worlds: Dictionary = {} # "universe::world" = true
var _indexed_file_count: int = 0
var _indexed_world_count: int = 0

func _ready():
	if BootTracer: BootTracer.log_init("ContentLoader")
	print("[CONTENT LOADER] Online. Heavy JSON ingestion is lazy-loaded after splash / on demand.")
	# GOLD STANDARD: Ensure path indexing happens early so UI manifests are available
	ensure_indexed()

func ensure_indexed():
	if _is_indexed:
		return
	print("[CONTENT LOADER] Indexing Base Bundle paths without parsing payloads...")
	_indexed_files.clear()
	_loaded_worlds.clear()
	_indexed_file_count = 0
	_indexed_world_count = 0
	
	# Recursive crawl through all base bundle content
	_crawl_index(BASE_BUNDLE_PATH)

	if DirAccess.dir_exists_absolute(USER_CACHE_PATH + "patches/"):
		print("[CONTENT LOADER] OTA Patch paths detected. Indexing patch overrides...")
		_crawl_index(USER_CACHE_PATH + "patches/")
		
	# Critically important: Index manifests to populate subcategory metadata for UI
	_index_observation_bank_manifests(OBSERVATION_BANK_PATH)

	_is_indexed = true
	print("[CONTENT LOADER] Path index ready: ", _indexed_world_count, " worlds / ", _indexed_file_count, " JSON files indexed.")

func load_world_content(universe_id: Variant, world_id: Variant):
	ensure_indexed()
	var u_id = str(universe_id)
	var w_id = str(world_id)
	var load_key = u_id + "::" + w_id
	if _loaded_worlds.has(load_key):
		return

	if not _indexed_files.has(u_id) or not _indexed_files[u_id].has(w_id):
		print("[CONTENT LOADER] No indexed content for world: ", u_id, " / ", w_id)
		_loaded_worlds[load_key] = true
		return

	var files: Array = _indexed_files[u_id][w_id]
	print("[CONTENT LOADER] Lazy loading world payload: ", u_id, " / ", w_id, " (", files.size(), " files)")
	for path in files:
		_load_and_register_file(str(path))
	_loaded_worlds[load_key] = true
	print("[CONTENT LOADER] World payload ready: ", u_id, " / ", w_id)

func load_universe_content(universe_id: Variant):
	ensure_indexed()
	var u_id = str(universe_id)
	if not _indexed_files.has(u_id):
		return
	for w_id in _indexed_files[u_id].keys():
		load_world_content(u_id, w_id)

func load_all_content():
	ensure_indexed()
	for u_id in _indexed_files.keys():
		load_universe_content(u_id)

func _crawl_index(path: String):
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

		var full_path = _normalize_path(path + "/" + file_name)
		if dir.current_is_dir():
			_crawl_index(full_path)
		elif file_name.ends_with(".json"):
			_index_file_path(full_path)

		file_name = dir.get_next()

func _index_file_path(path: String):
	var rel = path
	if rel.begins_with(BASE_BUNDLE_PATH):
		rel = rel.replace(BASE_BUNDLE_PATH, "")
	elif rel.begins_with(USER_CACHE_PATH + "patches/"):
		rel = rel.replace(USER_CACHE_PATH + "patches/", "")
	else:
		return

	var parts = rel.split("/", false)
	if parts.size() < 3:
		return

	var u_id = str(parts[0])
	var w_id = str(parts[1])
	if not _indexed_files.has(u_id):
		_indexed_files[u_id] = {}
	if not _indexed_files[u_id].has(w_id):
		_indexed_files[u_id][w_id] = []
		_indexed_world_count += 1
		if registry == null:
			registry = Engine.get_main_loop().root.get_node_or_null("ContentRegistry")
		if registry and registry.has_method("register_world"):
			registry.register_world(u_id, w_id)

	_indexed_files[u_id][w_id].append(path)
	_indexed_file_count += 1

func _index_observation_bank_manifests(path: String):
	var dir = DirAccess.open(path)
	if not dir:
		return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue
		var full_path = _normalize_path(path + "/" + file_name)
		if dir.current_is_dir():
			_index_observation_bank_manifests(full_path)
		elif file_name == "world_manifest.json":
			_load_world_manifest(full_path)
		file_name = dir.get_next()

func _load_world_manifest(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return
	var json = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		file.close()
		return
	file.close()
	var data = json.get_data()
	if typeof(data) != TYPE_DICTIONARY:
		return
	if registry == null: registry = Engine.get_main_loop().root.get_node_or_null("ContentRegistry")
	if registry == null:
		return
	var u_id = data.get("universe", "")
	var w_id = data.get("world", "")
	if u_id == "" or w_id == "":
		return
	if registry.has_method("register_world"):
		registry.register_world(u_id, w_id, data)
	if registry.has_method("register_subcategory"):
		for sub in data.get("subcategories", []):
			if sub is Dictionary and sub.has("id"):
				registry.register_subcategory(u_id, w_id, sub["id"], sub)

func _load_and_register_file(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		if error == OK:
			var data = json.data
			if registry == null: registry = Engine.get_main_loop().root.get_node_or_null("ContentRegistry")
			if registry == null: return

			var items: Array = []
			if typeof(data) == TYPE_DICTIONARY:
				items = [data]
			elif typeof(data) == TYPE_ARRAY:
				items = data

			var registered := 0
			var skipped := 0
			for item in items:
				if typeof(item) != TYPE_DICTIONARY:
					continue
				var normalized = _normalize_item(item)
				if normalized.is_empty():
					skipped += 1
					continue
				if _validate_schema(normalized):
					registry.register_scenario(normalized)
					registered += 1
			if registered == 0 and skipped > 0:
				print("[CONTENT LOADER] ", path, ": 0 registered, ", skipped, " placeholder items skipped.")
		else:
			print("[CONTENT ERROR] JSON parse failed: ", path)
		file.close()

# Canonical registry schema: every observation MUST have id + universe + type.
# v3_entity (entity/features) -> type "dynamic" (mechanic-agnostic, JIT via _build_v3_payload)
# v2_compiled (prompt/correct_answer/distractors) -> rules block + mapped mechanic
# v1_legacy (already has id/type/rules) -> passthrough
func _normalize_item(item: Dictionary) -> Dictionary:
	if _is_placeholder(item):
		return {}
	var out: Dictionary = item.duplicate(true)
	# Canonical id
	if not out.has("id") and out.has("observation_id"):
		out["id"] = str(out["observation_id"])
	# CKO v3 entity: register as mechanic-agnostic "dynamic"
	if out.has("entity") and out.has("features"):
		out["type"] = "dynamic"
		if not out.has("subcategory"):
			out["subcategory"] = str(out.get("entity_type", ""))
		return out
	# v2_compiled question format: synthesize rules block + map mechanic
	if out.has("prompt") and out.has("correct_answer"):
		if not (out.get("rules") is Dictionary and out["rules"].size() > 0):
			out["rules"] = {
				"prompt": str(out.get("prompt", "")),
				"correct_answer": str(out.get("correct_answer", "")),
				"wrong_answers": out.get("distractors", []),
				"legacy_prompt": str(out.get("prompt", ""))
			}
		var otype = str(out.get("observation_type", "")).to_lower()
		out["type"] = _OBS_TYPE_TO_MECHANIC.get(otype, "rapid_classification")
	# v1_legacy: passthrough (placeholder gate above filters synthetic spikes)
	return out

# Quality gate: reject synthetic spikes_catalog placeholder content so it never ships.
const _PLACEHOLDER_PATTERNS = ["Verified Observation #", "Anomaly A#", "Distractor B#", "PROTOCOL SEQUENCE"]

func _is_placeholder(item: Dictionary) -> bool:
	var blobs: Array = [str(item.get("correct_answer", "")), str(item.get("prompt", ""))]
	var rules = item.get("rules", {})
	if rules is Dictionary:
		blobs.append(str(rules.get("correct_answer", "")))
		blobs.append(str(rules.get("prompt", rules.get("legacy_prompt", ""))))
	var distractors = item.get("distractors", rules.get("wrong_answers", []) if rules is Dictionary else [])
	if distractors is Array:
		for d in distractors:
			blobs.append(str(d))
	for blob in blobs:
		for p in _PLACEHOLDER_PATTERNS:
			if p in blob:
				return true
	return false

# Maps v2_compiled observation_type (question style) to an engine gameplay mechanic.
const _OBS_TYPE_TO_MECHANIC = {
	"rapid classification": "rapid_classification",
	"rapid recognition": "rapid_classification",
	"true / definition": "rapid_classification",
	"tool/technique recognition": "rapid_classification",
	"artist → artwork": "rapid_classification",
	"visual identification": "signal_vs_noise",
	"artwork → artist": "signal_vs_noise",
	"style recognition": "odd_one_out"
}

func _validate_schema(data: Dictionary) -> bool:
	return data.has("id") and data.has("universe") and data.has("type")

func _normalize_path(path: String) -> String:
	return path.replace("//", "/").replace("res:/", "res://").replace("user:/", "user://")
