extends Node

enum PerformanceProfile { HIGH, MID, LOW }
var current_profile: int = PerformanceProfile.MID

# Android Hard Constraints
const MEMORY_WARNING_MB = 900.0
const MEMORY_CRITICAL_MB = 1200.0
const FPS_MINIMUM = 45.0

var _degrade_timer: float = 0.0

func _ready():
	print("[HEALTH MONITOR] Online. Enforcing Android Budget Constraints.")

func _process(delta):
	var fps = Engine.get_frames_per_second()
	var mem_mb = OS.get_static_memory_usage() / 1048576.0

	# Watchdog condition check
	if fps < FPS_MINIMUM or mem_mb > MEMORY_WARNING_MB:
		_degrade_timer += delta
		if _degrade_timer > 3.0: # Sustained threshold breach
			_degrade_quality()
			_degrade_timer = 0.0
	else:
		_degrade_timer = max(0.0, _degrade_timer - delta)

func _degrade_quality():
	if current_profile == PerformanceProfile.HIGH:
		set_profile(PerformanceProfile.MID)
	elif current_profile == PerformanceProfile.MID:
		set_profile(PerformanceProfile.LOW)
	else:
		print("[HEALTH MONITOR] CRITICAL: System stressed. Already at LOW profile.")
		# At this point, we might trigger aggressive GC or purge offline caches

func set_profile(profile: int):
	current_profile = profile
	var prof_name = PerformanceProfile.keys()[profile]
	print("[HEALTH MONITOR] Scaling Performance Profile to: ", prof_name)
	
	# Broadcast to ChunkManager & Shader Environment to scale down
	# For example, pushing a 0.4x device_performance_factor for LOW profile.
	_dispatch_budget_cuts(profile)

func _dispatch_budget_cuts(_profile: int):
	# Example dispatch logic (handled via signals or direct Autoload hooks)
	pass
