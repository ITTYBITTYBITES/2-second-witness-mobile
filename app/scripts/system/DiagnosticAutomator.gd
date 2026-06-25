extends Node

const SAVE_PATH = "user://diagnostics.save"
const SAVE_SCHEMA_VERSION = 1

var crash_count: int = 0
var current_device_model: String = ""

var failure_vectors = {
	"gpu_timeout": 0,
	"memory_exhaustion": 0,
	"shader_compile_fail": 0
}

func _ready():
	BootTracer.log_init("DiagnosticAutomator")
	current_device_model = OS.get_model_name()
	_load_diagnostic_state()
	print("[DIAGNOSTIC] Monitoring device: ", current_device_model)
	_apply_self_healing_patches()

func log_critical_failure(vector: String):
	crash_count += 1
	if failure_vectors.has(vector):
		failure_vectors[vector] += 1
	_save_diagnostic_state()
	_uplink_failure_signature(vector)

func _apply_self_healing_patches():
	if crash_count >= 2:
		print("[SELF HEALING] Multiple crashes detected on this hardware. Engaging failsafes.")
		if failure_vectors["gpu_timeout"] > 0 or failure_vectors["shader_compile_fail"] > 0:
			SystemHealthMonitor.set_profile(SystemHealthMonitor.PerformanceProfile.LOW)
		if failure_vectors["memory_exhaustion"] > 0:
			var pool = get_node_or_null("/root/MainShell/WorldLayer/TunnelLayer/Tier2_InstancedGeometry/ChunkPool")
			if pool and pool.has_method("reset_pool"):
				pool.reset_pool(2) 

func _uplink_failure_signature(vector: String):
	pass

func _load_diagnostic_state():
	if not FileAccess.file_exists(SAVE_PATH): return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			var data = json.get_data()
			if typeof(data) == TYPE_DICTIONARY and data.get("schema_version", 0) == SAVE_SCHEMA_VERSION:
				crash_count = data.get("crash_count", 0)
				var saved_vectors = data.get("failure_vectors", {})
				for k in saved_vectors.keys():
					failure_vectors[k] = saved_vectors[k]
		file.close()

func _save_diagnostic_state():
	var save_dict = {
		"schema_version": SAVE_SCHEMA_VERSION,
		"crash_count": crash_count,
		"failure_vectors": failure_vectors
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_dict, "\t"))
		file.close()
