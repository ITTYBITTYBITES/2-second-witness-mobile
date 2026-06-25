extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# COHORT TELEMETRY UPLINK
# ---------------------------------------------------------

var _http_request: HTTPRequest
const TELEMETRY_ENDPOINT = "https://api.ittybittybites.com/telemetry/ingest"

func _ready():
	BootTracer.log_init("StructuredLogger")
	if IVC0_InstrumentConfig and not IVC0_InstrumentConfig.is_cohort_member:
		set_process(false)
		return
		
	_http_request = HTTPRequest.new()
	add_child(_http_request)

func log_trial(scenario_id: String, universe_id: String, raw_rt: float, corrected_rt: float, success: bool, familiarity: int):
	if IVC0_InstrumentConfig and not IVC0_InstrumentConfig.is_cohort_member:
		return 
		
	# INJECT DETERMINISTIC VERSION PINNING
	var content_version = GitHubSyncManager.get_active_content_version() if GitHubSyncManager else "unknown"
	
	var data = {
		"timestamp": Time.get_unix_time_from_system(),
		"device_hash": IVC0_InstrumentConfig.device_hash,
		"content_version": content_version, # Critical for scientific validity
		"scenario_id": scenario_id,
		"universe_id": universe_id,
		"success": success,
		"raw_rt_ms": raw_rt,
		"corrected_rt_ms": corrected_rt,
		"familiarity_index": familiarity
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
	
	# Silently fire and forget. 
	_http_request.request(TELEMETRY_ENDPOINT, headers, HTTPClient.METHOD_POST, body)
