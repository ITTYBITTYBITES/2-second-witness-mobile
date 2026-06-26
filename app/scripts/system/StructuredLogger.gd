extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# COHORT TELEMETRY UPLINK & RUNTIME EVENT LEDGER
# ---------------------------------------------------------

var _http_request: HTTPRequest
const TELEMETRY_ENDPOINT = "https://api.ittybittybites.com/telemetry/ingest"

var runtime_event_ledger: Array[Dictionary] = []

func _ready():
	if BootTracer: BootTracer.log_init("StructuredLogger")
	if IVC0_InstrumentConfig and not IVC0_InstrumentConfig.is_cohort_member:
		set_process(false)
		return
		
	_http_request = HTTPRequest.new()
	add_child(_http_request)

func log_event_trace(node: Node, event_type: String, details: String = ""):
	var usec = Time.get_ticks_usec()
	var instance_id = node.get_instance_id() if node and node.has_method("get_instance_id") else 0
	var n_name = node.name if node else "UnknownNode"
	
	var entry = {
		"timestamp_usec": usec,
		"instance_id": instance_id,
		"node_name": n_name,
		"event_type": event_type,
		"details": details
	}
	
	runtime_event_ledger.append(entry)
	print(str("[EVENT LEDGER: %012d] [%s#%d] %s %s") % [usec, n_name, instance_id, event_type, details])

func dump_runtime_event_ledger():
	print("\n┌─────────────────────────────────────────────────────────────────────────────┐")
	print("│                       RUNTIME EVENT LEDGER ORDERING TRACE                   │")
	print("├──────────────────────┬────────────────────────┬─────────────┬───────────────┤")
	print("│    TIMESTAMP (μs)    │      NODE INSTANCE     │  EVENT TYPE │    DETAILS    │")
	print("├──────────────────────┼────────────────────────┼─────────────┼───────────────┤")
	for e in runtime_event_ledger:
		var n_inst = str(e["node_name"]) + "#" + str(e["instance_id"])
		print("│ " + _pad(str(e["timestamp_usec"]), 20) + " │ " + _pad(n_inst, 22) + " │ " + _pad(str(e["event_type"]), 11) + " │ " + _pad(str(e["details"]), 13) + " │")
	print("└──────────────────────┴────────────────────────┴─────────────┴───────────────┘\n")

func _pad(s: String, length: int) -> String:
	var res = s
	while res.length() < length:
		res += " "
	return res

func log_trial(scenario_id: String, universe_id: String, raw_rt: float, _corrected_rt: float, success: bool, familiarity: int):
	if IVC0_InstrumentConfig and not IVC0_InstrumentConfig.is_cohort_member:
		return 
		
	var content_version = GitHubSyncManager.get_active_content_version() if GitHubSyncManager else "unknown"
	
	var platform_distortion_proxies = {}
	if Engine.get_main_loop().root.has_node("RuntimeMeasurementIsolation"):
		platform_distortion_proxies = Engine.get_main_loop().root.get_node("RuntimeMeasurementIsolation").close_trial_window()
		
	var probabilistic_ordering_inference = PlayerProfile.last_recorded_metrics if PlayerProfile else {}
	
	var data = {
		"timestamp": Time.get_unix_time_from_system(),
		"device_hash": IVC0_InstrumentConfig.device_hash,
		"content_version": content_version,
		"scenario_id": scenario_id,
		"universe_id": universe_id,
		"success": success,
		"familiarity_index": familiarity,
		"core_measurement": {
			"probabilistic_ordering_inference": probabilistic_ordering_inference
		},
		"observation_channel": {
			"device_distorted_raw_ms": raw_rt,
			"platform_distortion_proxies": platform_distortion_proxies
		}
	}
	
	_cache_to_disk(data)
	_uplink_to_server(data)

func _cache_to_disk(data: Dictionary):
	var file = FileAccess.open("user://cohort_telemetry.jsonl", FileAccess.READ_WRITE)
	if not file:
		file = FileAccess.open("user://cohort_telemetry.jsonl", FileAccess.WRITE)
	
	file.seek_end()
	file.store_string(JSON.stringify(data) + "\n")
	file.close()

func _uplink_to_server(data: Dictionary):
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify(data)
	
	_http_request.request(TELEMETRY_ENDPOINT, headers, HTTPClient.METHOD_POST, body)
