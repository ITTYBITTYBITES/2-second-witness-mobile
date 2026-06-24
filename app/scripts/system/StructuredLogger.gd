extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# IVC-0 RAW DATA APPEND-ONLY LOGGER
# ---------------------------------------------------------

var _device_hash: String = ""

func _ready():
	# Generate a unique hash for the device session
	_device_hash = str(OS.get_unique_id().hash()) + "_" + str(Time.get_unix_time_from_system())

func log_trial(scenario_id: String, universe_id: String, raw_rt: float, corrected_rt: float, success: bool, familiarity: int):
	var data = {
		"timestamp": Time.get_unix_time_from_system(),
		"device_hash": _device_hash,
		"scenario_id": scenario_id,
		"universe_id": universe_id,
		"success": success,
		"raw_rt_ms": raw_rt,
		"corrected_rt_ms": corrected_rt,
		"familiarity_index": familiarity
	}
	
	# Append-only write to device disk
	var file = FileAccess.open("user://ivc0_raw_data.jsonl", FileAccess.READ_WRITE)
	if not file:
		file = FileAccess.open("user://ivc0_raw_data.jsonl", FileAccess.WRITE)
	
	file.seek_end()
	file.store_string(JSON.stringify(data) + "\n")
	file.close()
	print("[STRUCTURED LOGGER] Trial logged -> ", data)
