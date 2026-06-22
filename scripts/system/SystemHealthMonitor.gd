extends Node

enum PerformanceProfile { HIGH, MID, LOW }
var current_profile: int = PerformanceProfile.MID

# Execution Contexts for Causal Attribution
enum ExecContext { IDLE, CHUNK_STREAMING, TRANSITION, SCENARIO_ACTIVE }
var current_context: int = ExecContext.IDLE

# Android Hard Constraints
const MEMORY_WARNING_MB = 900.0
const MEMORY_CRITICAL_MB = 1200.0
const FPS_MINIMUM = 45.0

var _degrade_timer: float = 0.0

# Ring Buffers for Frame Pacing (Eliminating Observer Effect / GC Pollution)
const BUFFER_SIZE = 600 # Fixed size ~10 seconds at 60fps
var _frame_buffers: Dictionary = {}
var _buffer_indices: Dictionary = {}
var _buffer_counts: Dictionary = {}

func _ready():
	print("[HEALTH MONITOR] Online. Enforcing Android Budget Constraints.")
	
	# Initialize Ring Buffers per Context using PackedFloat64Array to prevent heap fragmentation
	for ctx in ExecContext.values():
		var arr = PackedFloat64Array()
		arr.resize(BUFFER_SIZE)
		_frame_buffers[ctx] = arr
		_buffer_indices[ctx] = 0
		_buffer_counts[ctx] = 0

func set_context(ctx: int):
	current_context = ctx

func _process(delta):
	# Push to Segmented Ring Buffer
	var idx = _buffer_indices[current_context]
	_frame_buffers[current_context][idx] = delta
	_buffer_indices[current_context] = (idx + 1) % BUFFER_SIZE
	_buffer_counts[current_context] = min(_buffer_counts[current_context] + 1, BUFFER_SIZE)

	# Memory pressure evaluation
	var mem_mb = OS.get_static_memory_usage() / 1048576.0
	var fps = Engine.get_frames_per_second()
	
	if fps < FPS_MINIMUM or mem_mb > MEMORY_WARNING_MB:
		_degrade_timer += delta
		if _degrade_timer > 3.0:
			_degrade_quality()
			_degrade_timer = 0.0
	else:
		_degrade_timer = max(0.0, _degrade_timer - delta)

func dump_telemetry(event_trigger: String):
	# Resource Identity Tracking (Catching Godot hidden reference retention)
	var obj_count = Performance.get_monitor(Performance.OBJECT_COUNT)
	var node_count = Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
	var tex_count = Performance.get_monitor(Performance.RENDER_TEXTURE_COUNT)
	var mat_count = Performance.get_monitor(Performance.RENDER_MATERIAL_COUNT)
	var mem_mb = OS.get_static_memory_usage() / 1048576.0
	
	print("\n=== [TELEMETRY DUMP: %s] ===" % event_trigger)
	print("Memory: %.2fMB | Objects: %d | Nodes: %d | Textures: %d | Materials: %d" % [mem_mb, obj_count, node_count, tex_count, mat_count])
	
	for ctx in ExecContext.values():
		var count = _buffer_counts[ctx]
		if count == 0: continue
		
		# Extract active samples
		var samples = PackedFloat64Array()
		samples.resize(count)
		for i in range(count):
			samples[i] = _frame_buffers[ctx][i]
			
		samples.sort()
		var p50 = samples[int(count * 0.5)] * 1000.0
		var p95 = samples[int(count * 0.95)] * 1000.0
		var p99 = samples[int(count * 0.99)] * 1000.0
		
		var ctx_name = ExecContext.keys()[ctx]
		print("Context [%s] -> P50: %.2fms | P95: %.2fms | P99: %.2fms" % [ctx_name, p50, p95, p99])
	
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
