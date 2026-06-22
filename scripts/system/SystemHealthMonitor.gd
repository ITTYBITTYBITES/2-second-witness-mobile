extends Node

enum PerformanceProfile { HIGH, MID, LOW }
var current_profile: int = PerformanceProfile.MID

# Context Bitmasking to prevent Context Aliasing (Overlapping execution states)
enum ExecContext { 
	IDLE = 1, 
	CHUNK_STREAMING = 2, 
	TRANSITION = 4, 
	SCENARIO_ACTIVE = 8 
}
var active_contexts: int = ExecContext.IDLE

# Android Hard Constraints
const MEMORY_WARNING_MB = 900.0
const MEMORY_CRITICAL_MB = 1200.0
const FPS_MINIMUM = 45.0

var _degrade_timer: float = 0.0

# Ring Buffers for Frame Pacing
const BUFFER_SIZE = 600
var _frame_buffers: Dictionary = {}
var _buffer_indices: Dictionary = {}
var _buffer_counts: Dictionary = {}

# Resource Ownership Attribution (Causal Tracking)
var _tracked_resources: Array[Dictionary] = [] # Array of {"tag": String, "ref": WeakRef}

func _ready():
	print("[HEALTH MONITOR] Online. Enforcing Android Budget Constraints.")
	for ctx in [1, 2, 4, 8]:
		var arr = PackedFloat64Array()
		arr.resize(BUFFER_SIZE)
		_frame_buffers[ctx] = arr
		_buffer_indices[ctx] = 0
		_buffer_counts[ctx] = 0

func push_context(ctx: int):
	active_contexts |= ctx
	active_contexts &= ~ExecContext.IDLE # Remove IDLE if we are doing work

func pop_context(ctx: int):
	active_contexts &= ~ctx
	if active_contexts == 0:
		active_contexts = ExecContext.IDLE

func track_allocation(resource: Resource, owner_tag: String):
	_tracked_resources.append({"tag": owner_tag, "ref": weakref(resource)})

func _process(delta):
	# Push to all currently active segment buffers (solves context aliasing)
	for ctx in [1, 2, 4, 8]:
		if (active_contexts & ctx) != 0:
			var idx = _buffer_indices[ctx]
			_frame_buffers[ctx][idx] = delta
			_buffer_indices[ctx] = (idx + 1) % BUFFER_SIZE
			_buffer_counts[ctx] = min(_buffer_counts[ctx] + 1, BUFFER_SIZE)

	var mem_mb = OS.get_static_memory_usage() / 1048576.0
	var fps = Engine.get_frames_per_second()
	
	if fps < FPS_MINIMUM or mem_mb > MEMORY_WARNING_MB:
		_degrade_timer += delta
		if _degrade_timer > 3.0:
			_degrade_quality()
			_degrade_timer = 0.0
	else:
		_degrade_timer = max(0.0, _degrade_timer - delta)

# Quiescence-Gated Dump (Ensures event atomicity)
func queue_telemetry_dump(event_trigger: String):
	# Await two frames to guarantee the Godot MessageQueue, deferred calls, and signals have fully drained
	await get_tree().process_frame
	await get_tree().process_frame
	_execute_dump(event_trigger)

func _execute_dump(event_trigger: String):
	var mem_mb = OS.get_static_memory_usage() / 1048576.0
	
	# Evaluate Resource Leak Attribution
	var active_tags = {}
	var alive_resources = []
	for item in _tracked_resources:
		if item["ref"].get_ref():
			alive_resources.append(item)
			var tag = item["tag"]
			active_tags[tag] = active_tags.get(tag, 0) + 1
	_tracked_resources = alive_resources # Prune dead weakrefs
	
	print("\n=== [TELEMETRY DUMP: %s] ===" % event_trigger)
	print("Static Memory: %.2fMB" % mem_mb)
	
	if not active_tags.is_empty():
		print("Active Custom Allocations: ", JSON.stringify(active_tags))
	
	for ctx in [1, 2, 4, 8]:
		var count = _buffer_counts[ctx]
		if count == 0: continue
		
		var samples = PackedFloat64Array()
		samples.resize(count)
		var total_time_sec = 0.0
		
		for i in range(count):
			var val = _frame_buffers[ctx][i]
			samples[i] = val
			total_time_sec += val
			
		samples.sort()
		var p50 = samples[int(count * 0.5)] * 1000.0
		var p95 = samples[int(count * 0.95)] * 1000.0
		var p99 = samples[int(count * 0.99)] * 1000.0
		
		# Map bitmask back to name
		var ctx_name = "UNKNOWN"
		match ctx:
			1: ctx_name = "IDLE"
			2: ctx_name = "CHUNK_STREAMING"
			4: ctx_name = "TRANSITION"
			8: ctx_name = "SCENARIO_ACTIVE"
		
		# Time-Normalized Reporting prevents overwrite blindness distortion
		print("Context [%s] (Window: %.2fs) -> P50: %.2fms | P95: %.2fms | P99: %.2fms" % [ctx_name, total_time_sec, p50, p95, p99])
	
	print("==================================\n")

func _degrade_quality():
	if current_profile == PerformanceProfile.HIGH:
		set_profile(PerformanceProfile.MID)
	elif current_profile == PerformanceProfile.MID:
		set_profile(PerformanceProfile.LOW)
	else:
		print("[HEALTH MONITOR] CRITICAL: System stressed. Already at LOW profile.")

func set_profile(profile: int):
	current_profile = profile
	var prof_name = PerformanceProfile.keys()[profile]
	print("[HEALTH MONITOR] Scaling Performance Profile to: ", prof_name)
	_dispatch_budget_cuts(profile)

func _dispatch_budget_cuts(_profile: int):
	pass
