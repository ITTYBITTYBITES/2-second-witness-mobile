extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# THE COGNITIVE MIRROR (WITH PERSISTENCE)
# ---------------------------------------------------------

const SAVE_PATH = "user://profile.save"
const SAVE_SCHEMA_VERSION = 1

var lifetime_sessions: int = 0
var universe_affinity: Dictionary = {}
var world_affinity: Dictionary = {}

var unlocked_universes: Array = ["science_lab"]
var unlocked_worlds: Array = ["cognitive_bias"]
var has_directors_pass: bool = false

var cognitive_baseline = {
	"pattern_recognition": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0},
	"recall": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0},
	"rapid_classification": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0},
	"spatial_tracking": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0},
	"decision_confidence": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0},
	"processing_speed": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0}
}

var current_week_drift = {
	"pattern_recognition": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0},
	"recall": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0},
	"rapid_classification": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0},
	"spatial_tracking": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0},
	"decision_confidence": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0},
	"processing_speed": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0}
}

var task_familiarity_index = {
	"memory_cascade": 0, "spatial_recall": 0, "sequence_reverse": 0,
	"pattern_continuation": 0, "odd_one_out": 0, "stroop_test": 0,
	"rapid_classification": 0, "speed_sort": 0, "signal_vs_noise": 0,
	"math_surprise": 0, "reflex_tap": 0, "risk_selection": 0
}

# Accessibility & Hardware
var motor_assist_enabled: bool = false
var colorblind_mode_enabled: bool = false
var device_hardware_offset_ms: float = 0.0

func _ready():
	print("[2 SECOND WITNESS] Cognitive Insight Engine active.")
	_load_profile()

func record_cognitive_event(trait: String, scenario_id: String, universe: String, success: bool, reaction_time_ms: float):
	lifetime_sessions += 1
	universe_affinity[universe] = universe_affinity.get(universe, 0) + 1
	
	var world_key = universe + "_default" # Fallback if specific world isn't passed
	world_affinity[world_key] = world_affinity.get(world_key, 0) + 1
	
	task_familiarity_index[scenario_id] = task_familiarity_index.get(scenario_id, 0) + 1
	
	if cognitive_baseline.has(trait):
		var b = cognitive_baseline[trait]
		b["attempts"] += 1
		if success:
			b["successes"] += 1
			b["total_rt_ms"] += reaction_time_ms
			
	if current_week_drift.has(trait):
		var d = current_week_drift[trait]
		d["attempts"] += 1
		if success:
			d["successes"] += 1
			d["total_rt_ms"] += reaction_time_ms
			
	save_profile()

func _load_profile():
	if not FileAccess.file_exists(SAVE_PATH):
		print("[PROFILE] No existing save found. Generating new cognitive baseline.")
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json = JSON.new()
		var parse_result = json.parse(file.get_as_text())
		file.close()
		
		if parse_result == OK:
			var data = json.get_data()
			if typeof(data) == TYPE_DICTIONARY and data.has("schema_version"):
				_apply_loaded_data(data)
			else:
				print("[PROFILE FATAL] Save file format invalid. Falling back to clean slate.")
		else:
			print("[PROFILE FATAL] JSON Parse error. Save file corrupted. Falling back to clean slate.")

func _apply_loaded_data(data: Dictionary):
	# Schema Versioning allows us to write migration logic here later if the schema changes
	if data["schema_version"] == 1:
		lifetime_sessions = data.get("lifetime_sessions", 0)
		universe_affinity = data.get("universe_affinity", {})
		world_affinity = data.get("world_affinity", {})
		unlocked_universes = data.get("unlocked_universes", ["science_lab"])
		unlocked_worlds = data.get("unlocked_worlds", ["cognitive_bias"])
		has_directors_pass = data.get("has_directors_pass", false)
		
		# Merge dictionaries to ensure missing keys from updates don't crash the engine
		_merge_dict(cognitive_baseline, data.get("cognitive_baseline", {}))
		_merge_dict(current_week_drift, data.get("current_week_drift", {}))
		_merge_dict(task_familiarity_index, data.get("task_familiarity_index", {}))
		
		motor_assist_enabled = data.get("motor_assist_enabled", false)
		colorblind_mode_enabled = data.get("colorblind_mode_enabled", false)
		device_hardware_offset_ms = data.get("device_hardware_offset_ms", 0.0)
		print("[PROFILE] Mathematical state restored successfully.")

func _merge_dict(target: Dictionary, source: Dictionary):
	for key in source.keys():
		target[key] = source[key]

func save_profile():
	var save_dict = {
		"schema_version": SAVE_SCHEMA_VERSION,
		"lifetime_sessions": lifetime_sessions,
		"universe_affinity": universe_affinity,
		"world_affinity": world_affinity,
		"unlocked_universes": unlocked_universes,
		"unlocked_worlds": unlocked_worlds,
		"has_directors_pass": has_directors_pass,
		"cognitive_baseline": cognitive_baseline,
		"current_week_drift": current_week_drift,
		"task_familiarity_index": task_familiarity_index,
		"motor_assist_enabled": motor_assist_enabled,
		"colorblind_mode_enabled": colorblind_mode_enabled,
		"device_hardware_offset_ms": device_hardware_offset_ms
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_dict, "\t"))
		file.close()

func generate_insights() -> Array[String]:
	var insights: Array[String] = []
	var top_uni = ""
	var top_count = 0
	for u in universe_affinity.keys():
		if universe_affinity[u] > top_count:
			top_count = universe_affinity[u]
			top_uni = u
	
	if top_count > 0:
		var readable_uni = top_uni.capitalize().replace("_", " ")
		insights.append("%s remains your dominant universe." % readable_uni)
		
	if insights.is_empty():
		insights.append("Awaiting more cognitive data to form a profile...")
	return insights
