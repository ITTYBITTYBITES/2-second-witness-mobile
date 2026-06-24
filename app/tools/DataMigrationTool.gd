@tool
extends EditorScript

# Paths
const LEGACY_UNIVERSES_PATH = "res://Legacy_Project/godot/data/universes.json"
const LEGACY_WORLDS_DIR = "res://Legacy_Project/godot/data/worlds/"
const NEW_BASE_BUNDLE_DIR = "res://data/content/base_bundle/"

# Legacy-to-V2 Universe ID Mapping (Based on the new ThemeManager keys)
var universe_mapping = {
	"science": "science_lab",
	"life": "life_sciences",
	"society": "society_mind",
	"tech": "tech_ops",
	"creative": "creative_arts",
	"frontier": "frontier" # Assuming this maps; we will fallback if not
}

# The Target Schema Format (as defined in our architecture)
# {
#   "id": "stroop_042",
#   "universe": "society_mind",
#   "world": "cognitive_bias",
#   "type": "stroop_test",
#   "difficulty": 3,
#   "rewards": { "xp": 50, "currency": 10 },
#   "rules": { "time_limit": 2.0, "attempts": 1, "bias_tag": "interference_control" },
#   "presentation": { "title": "Color Conflict Test", "visual_theme_override": null }
# }

var _report = {
	"total_files_scanned": 0,
	"total_scenarios_migrated": 0,
	"failed_migrations": []
}

func _run():
	print("\n=============================================")
	print("[MIGRATION TOOL] Initiating Legacy Data Conversion...")
	print("=============================================\n")
	
	_ensure_dir(NEW_BASE_BUNDLE_DIR)
	_process_worlds()
	_dump_report()

func _ensure_dir(path: String):
	if not DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)

func _process_worlds():
	var dir = DirAccess.open(LEGACY_WORLDS_DIR)
	if not dir:
		_fail_report("global", "Cannot open legacy worlds directory: " + LEGACY_WORLDS_DIR)
		return
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			_report["total_files_scanned"] += 1
			_migrate_world_file(LEGACY_WORLDS_DIR + file_name)
		file_name = dir.get_next()

func _migrate_world_file(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		_fail_report(path, "File unreadable.")
		return
		
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	if error != OK:
		_fail_report(path, "JSON Parse Error.")
		return
		
	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		_fail_report(path, "Root is not a dictionary.")
		return
		
	# 1. Strip deprecated fields (corridor, color, icon)
	var legacy_world_id = data.get("id", "unknown_world")
	var legacy_universe_id = data.get("universe", "unknown_universe")
	
	# 2. Map Universe ID
	var v2_universe_id = universe_mapping.get(legacy_universe_id, legacy_universe_id)
	
	# 3. Create output directory for this world
	var target_dir = NEW_BASE_BUNDLE_DIR + v2_universe_id + "/" + legacy_world_id + "/"
	_ensure_dir(target_dir)
	
	# 4. Iterate and transform scenarios
	var scenarios = data.get("scenarios", [])
	if typeof(scenarios) != TYPE_ARRAY:
		_fail_report(path, "Scenarios block missing or malformed.")
		return
		
	var idx = 0
	for legacy_scen in scenarios:
		idx += 1
		_transform_and_save(legacy_scen, v2_universe_id, legacy_world_id, idx, target_dir, path)

func _transform_and_save(legacy: Dictionary, v2_uni: String, v2_world: String, index: int, target_dir: String, source_path: String):
	# Validation: Ensure required fields exist in legacy format
	if not legacy.has("question") or not legacy.has("correct"):
		_fail_report(source_path, "Scenario " + str(index) + " missing 'question' or 'correct'.")
		return
	
	var type = "rapid_classification" # Defaulting for now based on legacy flash/question format
	if legacy.has("stroop") and legacy["stroop"] > 0:
		type = "stroop_test"
		
	var new_id = v2_world + "_" + str(index).pad_zeros(3)
	
	var v2_scenario = {
		"id": new_id,
		"universe": v2_uni,
		"world": v2_world,
		"type": type,
		"difficulty": legacy.get("difficulty", 1),
		"rewards": {
			"xp": 10 * legacy.get("difficulty", 1),
			"currency": 0
		},
		"rules": {
			"time_limit": 5.0, # Baseline
			"attempts": 1,
			"legacy_flash": legacy.get("flash", ""),
			"legacy_prompt": legacy.get("prompt", ""),
			"correct_answer": legacy.get("correct", ""),
			"wrong_answers": legacy.get("wrong", [])
		},
		"presentation": {
			"title": legacy.get("question", "Identify"),
			"visual_theme_override": null
		}
	}
	
	var out_path = target_dir + new_id + ".json"
	var file = FileAccess.open(out_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(v2_scenario, "\t"))
		file.close()
		_report["total_scenarios_migrated"] += 1
	else:
		_fail_report(out_path, "Failed to write output file.")

func _fail_report(target: String, reason: String):
	_report["failed_migrations"].append({"target": target, "reason": reason})

func _dump_report():
	var report_path = "res://tools/migration_report.json"
	var file = FileAccess.open(report_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_report, "\t"))
		file.close()
	
	print("[MIGRATION COMPLETE]")
	print("Files Scanned: ", _report["total_files_scanned"])
	print("Scenarios Migrated: ", _report["total_scenarios_migrated"])
	print("Failures: ", _report["failed_migrations"].size())
	print("Detailed report saved to: ", report_path)
