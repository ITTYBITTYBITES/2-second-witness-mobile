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
var primary_context: int = ExecContext.IDLE # Deterministic causation tag

# Persistence Intent for Resource Tracking
enum PersistenceIntent { EPHEMERAL, CACHED, SHARED, PERSISTENT }

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
var _tracked_resources: Array[Dictionary] = [] # Array of {"tag": String, "ref": WeakRef, "intent": int}

func _ready():
	print("[HEALTH MONITOR] Online. Enforcing Android Budget Constraints.")
	for ctx in [1, 2, 4, 8]:
		var arr = PackedFloat64Array()
		arr.resize(BUFFER_SIZE)
		_frame_buffers[ctx] = arr
		_buffer_indices[ctx] = 0
		_buffer_counts[ctx] = 0

func push_context(ctx: int, is_primary: bool = false):
	active_contexts |= ctx
	active_contexts &= ~ExecContext.IDLE
	if is_primary or primary_context == ExecContext.IDLE:
		primary_context = ctx

func pop_context(ctx: int):
	active_contexts &= ~ctx
	if active_contexts == 0:
		active_contexts = ExecContext.IDLE
		primary_context = ExecContext.IDLE
	elif primary_context == ctx:
		# Fallback arbitration: pick the lowest set bit as the new primary
		primary_context = active_contexts & -active_contexts

func track_allocation(resource: Resource, owner_tag: String, intent: int = PersistenceIntent.EPHEMERAL):
	_tracked_resources.append({"tag": owner_tag, "ref": weakref(resource), "intent": intent})

func _process(delta):
	# Push to primary segment buffer (Solves context aliasing/causation duality)
	# We index by primary_context to ensure deterministic regression mapping
	var idx = _buffer_indices[primary_context]
	_frame_buffers[primary_context][idx] = delta
	_buffer_indices[primary_context] = (idx + 1) % BUFFER_SIZE
	_buffer_counts[primary_context] = min(_buffer_counts[primary_context] + 1, BUFFER_SIZE)

	var mem_mb = OS.get_static_memory_usage() / 1048576.0
	var fps = Engine.get_frames_per_second()
	
	# DISABLED FOR PROTOCOL 1 BENCHMARK PURITY
	# if fps < FPS_MINIMUM or mem_mb > MEMORY_WARNING_MB:
	# 	_degrade_timer += delta
	# 	if _degrade_timer > 3.0:
	# 		_degrade_quality()
	# 		_degrade_timer = 0.0
	# else:
	# 	_degrade_timer = max(0.0, _degrade_timer - delta)

# Quiescence-Gated Dump (CPU boundary only - GPU in-flight unverified)
func queue_telemetry_dump(event_trigger: String):
	# Await two frames to guarantee the Godot MessageQueue, deferred calls, and signals have fully drained
	await get_tree().process_frame
	await get_tree().process_frame
	_execute_dump(event_trigger)

func _execute_dump(event_trigger: String):
	var mem_mb = OS.get_static_memory_usage() / 1048576.0
	
	# Evaluate Resource Leak Attribution by Intent
	var active_tags = {}
	var alive_resources = []
	for item in _tracked_resources:
		if item["ref"].get_ref():
			alive_resources.append(item)
			var tag_intent = item["tag"] + " [" + PersistenceIntent.keys()[item["intent"]] + "]"
			active_tags[tag_intent] = active_tags.get(tag_intent, 0) + 1
	_tracked_resources = alive_resources # Prune dead weakrefs
	
	var dump_data = {
		"event": event_trigger,
		"static_memory_mb": mem_mb,
		"active_custom_allocations": active_tags,
		"contexts": {}
	}
	
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
		var sample_density = count / total_time_sec if total_time_sec > 0 else 0.0
		
		# Map bitmask back to name
		var ctx_name = "UNKNOWN"
		match ctx:
			1: ctx_name = "IDLE"
			2: ctx_name = "CHUNK_STREAMING"
			4: ctx_name = "TRANSITION"
			8: ctx_name = "SCENARIO_ACTIVE"
			
		dump_data["contexts"][ctx_name] = {
			"span_sec": total_time_sec,
			"density_hz": sample_density,
			"p50_ms": p50,
			"p95_ms": p95,
			"p99_ms": p99
		}
	
	var filename = "user://protocol1_run_%d.txt" % Time.get_unix_time_from_system()
	var file = FileAccess.open(filename, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(dump_data, "\t"))
		file.close()
		print("[TELEMETRY] Successfully wrote dump to ", filename)
	else:
		print("[TELEMETRY ERROR] Failed to write dump to file.")

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
