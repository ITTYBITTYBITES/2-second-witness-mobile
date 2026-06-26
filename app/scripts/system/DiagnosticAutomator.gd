extends Node

const SAVE_PATH = "user://diagnostics.save"
const OFFLINE_QUEUE_PATH = "user://crash_queue.jsonl"
const SAVE_SCHEMA_VERSION = 1
const CRASH_UPLINK_ENDPOINT = "https://api.ittybittybites.com/telemetry/crash_uplink"

var crash_count: int = 0
var current_device_model: String = ""
var _http_request: HTTPRequest
var _pending_queue: Array[Dictionary] = []
var _is_transmitting: bool = false

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
	
	_http_request = HTTPRequest.new()
	_http_request.timeout = 5.0
	add_child(_http_request)
	_http_request.request_completed.connect(_on_uplink_completed)
	
	_load_offline_queue()
	if not _pending_queue.is_empty():
		print("[DIAGNOSTIC] Offline crash queue detected on boot. Attempting retransmission...")
		_transmit_next_item()

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
	var data = {
		"timestamp": Time.get_unix_time_from_system(),
		"device_model": current_device_model,
		"failure_vector": vector,
		"crash_count": crash_count,
		"active_content_version": GitHubSyncManager.get_active_content_version() if GitHubSyncManager else "unknown"
	}
	
	_pending_queue.append(data)
	_save_offline_queue()
	_transmit_next_item()

func _transmit_next_item():
	if _is_transmitting or _pending_queue.is_empty() or not is_instance_valid(_http_request): return
	_is_transmitting = true
	
	var data = _pending_queue[0]
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify(data)
	
	var err = _http_request.request(CRASH_UPLINK_ENDPOINT, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		print("[DIAGNOSTIC ERROR] Failed to initiate crash uplink HTTP request. Offline queue retained on disk.")
		_is_transmitting = false

func _on_uplink_completed(result, response_code, _headers, _body):
	_is_transmitting = false
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		print("[DIAGNOSTIC] Successfully transmitted crash failure signature (200 OK).")
		if not _pending_queue.is_empty():
			_pending_queue.pop_front()
			_save_offline_queue()
		_transmit_next_item()
	else:
		print("[DIAGNOSTIC WARNING] Server offline or timeout (Code: ", response_code, "). Retaining crash payload on disk for next boot.")

func _load_offline_queue():
	if not FileAccess.file_exists(OFFLINE_QUEUE_PATH): return
	var file = FileAccess.open(OFFLINE_QUEUE_PATH, FileAccess.READ)
	if file:
		_pending_queue.clear()
		while not file.eof_reached():
			var line = file.get_line().strip_edges()
			if line != "":
				var json = JSON.new()
				if json.parse(line) == OK and typeof(json.data) == TYPE_DICTIONARY:
					_pending_queue.append(json.data)
		file.close()

func _save_offline_queue():
	var file = FileAccess.open(OFFLINE_QUEUE_PATH, FileAccess.WRITE)
	if file:
		for item in _pending_queue:
			file.store_string(JSON.stringify(item) + "\n")
		file.close()

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
