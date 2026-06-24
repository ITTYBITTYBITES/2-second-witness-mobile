extends CanvasLayer

signal mct0_complete

@onready var bg = $VoidBG
@onready var target_btn = $TargetBtn
@onready var prompt_label = $PromptLabel

var _current_trial = 0
var _target_trials = 5
var _start_ticks_msec: int = 0
var _recorded_rts: Array[float] = []

func _ready():
	print("[MCT-0] Mobile Calibration Trial Initiated.")
	prompt_label.text = "Calibrating Input Latency.\nTap the square instantly."
	target_btn.visible = false
	target_btn.pressed.connect(_on_tap)
	_start_next_trial()

func _start_next_trial():
	target_btn.visible = false
	var tween = get_tree().create_tween()
	var delay = randf_range(0.5, 2.0)
	tween.tween_interval(delay)
	tween.tween_callback(func():
		var x = randf_range(100, 800)
		var y = randf_range(100, 500)
		target_btn.position = Vector2(x, y)
		target_btn.visible = true
		_start_ticks_msec = Time.get_ticks_msec()
	)

func _on_tap():
	var rt = Time.get_ticks_msec() - _start_ticks_msec
	_recorded_rts.append(rt)
	target_btn.visible = false
	
	_current_trial += 1
	if _current_trial >= _target_trials:
		_calculate_and_lock_offset()
	else:
		_start_next_trial()

func _calculate_and_lock_offset():
	_recorded_rts.sort()
	var p50_rt = _recorded_rts[int(_recorded_rts.size() * 0.5)]
	
	# Assuming a theoretical "pure" baseline of 300ms for this simple task
	# Any variance above 300ms is attributed to device touch-quantization/refresh latency
	var offset = max(0.0, p50_rt - 300.0) 
	
	var profile = get_node("/root/PlayerProfile")
	if profile:
		profile.device_hardware_offset_ms = offset
		
	print("[MCT-0] Calibration Complete. Hardware Offset Locked: ", offset, "ms")
	
	await get_tree().create_timer(1.0).timeout
	mct0_complete.emit()
	queue_free()
