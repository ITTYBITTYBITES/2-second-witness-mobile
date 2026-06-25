extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# COHORT TELEMETRY UPLINK (PROBABILISTIC ORDERING INFERENCE)
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

func log_trial(scenario_id: String, universe_id: String, raw_rt: float, _corrected_rt: float, success: bool, familiarity: int):
	if IVC0_InstrumentConfig and not IVC0_InstrumentConfig.is_cohort_member:
		return 
		
	var content_version = GitHubSyncManager.get_active_content_version() if GitHubSyncManager else "unknown"
	
	# Platform Observation Channel (Piecewise Monotonic Stochastic Kernel)
	var platform_distortion_proxies = {}
	if Engine.get_main_loop().root.has_node("RuntimeMeasurementIsolation"):
		platform_distortion_proxies = Engine.get_main_loop().root.get_node("RuntimeMeasurementIsolation").close_trial_window()
		
	# Primary Output: Posterior over Permutations of Response Order under Stochastic Delay Kernel
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
