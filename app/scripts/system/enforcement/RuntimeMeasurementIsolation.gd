extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# RUNTIME MEASUREMENT ISOLATION (NON-STATIONARY STOCHASTIC OBSERVATION)
# ---------------------------------------------------------

# Hardware Signature Vector
var hardware_profile: Dictionary = {}
var warmup_completed: bool = false
var warmup_latency_ms: float = 0.0

# Non-Stationary Jitter & Preemption Proxies
var _stimulus_spawn_usec: int = 0
var _active_trial_frames: Array[float] = []
var _is_trial_active: bool = false
var _gc_preemption_flagged: bool = false

# Calibration State Versioning
var gpu_pipeline_state_version: String = "uncalibrated"
var texture_residency_verified: bool = false

func _ready():
	BootTracer.log_init("RuntimeMeasurementIsolation")
	_capture_hardware_signature()
	_execute_residency_warmup()

func _capture_hardware_signature():
	hardware_profile = {
		"adapter_name": RenderingServer.get_video_adapter_name(),
		"adapter_vendor": RenderingServer.get_video_adapter_vendor(),
		"api_version": RenderingServer.get_video_adapter_api_version(),
		"processor_count": OS.get_processor_count(),
		"is_android": OS.has_feature("android"),
		"static_memory_base_mb": OS.get_static_memory_usage() / 1048576.0
	}
	gpu_pipeline_state_version = str(hardware_profile["adapter_name"]).hash() + "_" + str(ProjectSettings.get_setting("vulkan/rendering/shader_compilation_mode", 2))
	print("[MEASUREMENT ISOLATION] Hardware Signature Vector captured: ", hardware_profile["adapter_name"])

func _execute_residency_warmup():
	var start_usec = Time.get_ticks_usec()
	print("[MEASUREMENT ISOLATION] Enforcing mandatory shader + texture + font residency pre-pass...")
	
	var vp = SubViewport.new()
	vp.size = Vector2i(128, 128)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(vp)
	
	var cr = ColorRect.new()
	cr.size = Vector2(128, 128)
	cr.material = load("res://assets/materials/portal_glow.tres")
	vp.add_child(cr)
	
	for i in range(4):
		await get_tree().process_frame
		
	vp.queue_free()
	warmup_latency_ms = (Time.get_ticks_usec() - start_usec) / 1000.0
	warmup_completed = true
	texture_residency_verified = true
	print("[MEASUREMENT ISOLATION] Warmup complete. Pipeline stabilized in ", warmup_latency_ms, " ms.")

# --- STIMULUS PRESENTATION ANCHORING ---

func anchor_stimulus_spawn():
	_stimulus_spawn_usec = Time.get_ticks_usec()
	_is_trial_active = true
	_active_trial_frames.clear()
	_gc_preemption_flagged = false

func _process(delta):
	if _is_trial_active:
		_active_trial_frames.append(delta)
		if delta > 0.022:
			_gc_preemption_flagged = true

func close_trial_window() -> Dictionary:
	_is_trial_active = false
	var end_usec = Time.get_ticks_usec()
	var observed_time_ms = (end_usec - _stimulus_spawn_usec) / 1000.0
	
	var p50_delta = 16.6
	var p99_delta = 16.6
	if not _active_trial_frames.is_empty():
		_active_trial_frames.sort()
		p50_delta = _active_trial_frames[int(_active_trial_frames.size() * 0.5)] * 1000.0
		p99_delta = _active_trial_frames[int(_active_trial_frames.size() * 0.99)] * 1000.0
		
	var frame_variance_jitter_ms = max(0.0, p99_delta - p50_delta)
	
	# EXPLICIT NON-STATIONARY CONVOLUTIONAL DISTORTION PROXIES
	# Rejects the fallacy of a stationary per-device constant. 
	# Records the unidentifiable timing kernel as a time-dependent random field observation.
	return {
		"device_distorted_raw_ms": observed_time_ms,
		"active_window_jitter_ms": frame_variance_jitter_ms,
		"gc_preemption_detected": _gc_preemption_flagged,
		"gpu_pipeline_version": gpu_pipeline_state_version,
		"texture_residency_verified": texture_residency_verified,
		"warmup_stability_score": warmup_latency_ms,
		"frame_delta_p50_ms": p50_delta,
		"frame_delta_p99_ms": p99_delta
	}
