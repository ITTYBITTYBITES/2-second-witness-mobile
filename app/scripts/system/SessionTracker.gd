extends Node

var session_start_time: float = 0.0
var total_loops: int = 0
var spikes_completed: int = 0
var spikes_failed: int = 0
var spike_stats: Dictionary = {} # { "stroop_042": { "attempts": 2, "successes": 1 } }

func _ready():
	BootTracer.log_init("SessionTracker")
	session_start_time = Time.get_unix_time_from_system()
	print("[SESSION TRACKER] Session started at timestamp: ", session_start_time)
	
	# Hook into global systems
	NavigationEngine.transition_sequence_started.connect(_on_loop_started)

func _on_loop_started():
	total_loops += 1

func record_spike_result(scenario_id: String, success: bool):
	if not spike_stats.has(scenario_id):
		spike_stats[scenario_id] = { "attempts": 0, "successes": 0 }
		
	spike_stats[scenario_id]["attempts"] += 1
	
	if success:
		spikes_completed += 1
		spike_stats[scenario_id]["successes"] += 1
	else:
		spikes_failed += 1
		
	_dump_analytics()

func _dump_analytics():
	var current_time = Time.get_unix_time_from_system()
	var duration_sec = current_time - session_start_time
	
	var log_data = {
		"session_duration_seconds": duration_sec,
		"total_loops_initiated": total_loops,
		"total_spikes_completed": spikes_completed,
		"total_spikes_failed": spikes_failed,
		"spike_breakdown": spike_stats
	}
	
	# In production, this writes to user://session_logs.json
	print("\n--- [ANALYTICS DUMP] ---")
	print(JSON.stringify(log_data, "\t"))
	print("------------------------\n")
