extends Node

enum PerformanceProfile { HIGH, MID, LOW }
var current_profile: int = PerformanceProfile.MID

# Android Hard Constraints
const MEMORY_WARNING_MB = 900.0
const MEMORY_CRITICAL_MB = 1200.0
const FPS_MINIMUM = 45.0

var _degrade_timer: float = 0.0

# Empirical Instrumentation: Frame Pacing
var _frame_times: Array = []
var _time_since_dump: float = 0.0

func _ready():
	print("[HEALTH MONITOR] Online. Enforcing Android Budget Constraints.")

func _process(delta):
	var mem_mb = OS.get_static_memory_usage() / 1048576.0
	
	# Track frame pacing for 99th percentile analysis
	_frame_times.append(delta)
	_time_since_dump += delta
	
	if _time_since_dump >= 10.0: # Dump telemetry every 10 seconds
		_dump_telemetry(mem_mb)
		_time_since_dump = 0.0
		_frame_times.clear()

	# Watchdog condition check (using naive FPS for immediate triggers, but logging precise deltas)
	var fps = Engine.get_frames_per_second()
	if fps < FPS_MINIMUM or mem_mb > MEMORY_WARNING_MB:
		_degrade_timer += delta
		if _degrade_timer > 3.0: # Sustained threshold breach
			_degrade_quality()
			_degrade_timer = 0.0
	else:
		_degrade_timer = max(0.0, _degrade_timer - delta)

func _dump_telemetry(mem_mb: float):
	if _frame_times.is_empty(): return
	
	_frame_times.sort()
	var p50 = _frame_times[int(_frame_times.size() * 0.5)] * 1000.0
	var p95 = _frame_times[int(_frame_times.size() * 0.95)] * 1000.0
	var p99 = _frame_times[int(_frame_times.size() * 0.99)] * 1000.0
	
	print(str("[TELEMETRY] Mem: %.2fMB | Frame Times (ms) -> P50: %.2f | P95: %.2f | P99: %.2f" % [mem_mb, p50, p95, p99]))

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
