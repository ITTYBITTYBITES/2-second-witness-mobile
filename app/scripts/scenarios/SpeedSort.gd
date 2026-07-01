extends BaseScenario
signal completed

@onready var target_label = $TargetLabel
@onready var feedback_label = $FeedbackLabel
@onready var btn_left = $BtnLeft
@onready var btn_right = $BtnRight

var is_even = true
var _scenario_id: String = "speed_sort"
var _start_ticks_msec: int = 0

func _apply_specific_rules(rules: Dictionary):
	_scenario_id = _scenario_payload["id"]

func _ready():
	if _scenario_payload.is_empty():
		push_error("[SCENARIO FATAL] Scene loaded without payload injection.")
		queue_free()
		return
		
	btn_left.pressed.connect(func(): _on_answer(true)) 
	btn_right.pressed.connect(func(): _on_answer(false)) 
	_generate_number()
	execute_render_pipeline()

func _generate_number():
	feedback_label.text = "Sort rapidly!"
	btn_left.disabled = false; btn_right.disabled = false
	var num = _deterministic_rng.randi() % 99 + 1
	is_even = (num % 2 == 0)
	target_label.text = str(num)
	_start_ticks_msec = Time.get_ticks_msec()

func _on_answer(chose_even: bool):
	var rt_ms = Time.get_ticks_msec() - _start_ticks_msec
	if chose_even == is_even:
		if AudioManager: AudioManager.play_sfx("ui_click")
		feedback_label.text = "SUCCESS! OBSERVATION VERIFIED!"
		PlayerProfile.record_cognitive_event("processing_speed", _scenario_id, _scenario_payload.get("universe", "history"), _scenario_payload.get("world", "ancient_egypt"), true, rt_ms)
		SessionTracker.record_spike_result("speed_sort", true)
		btn_left.disabled = true; btn_right.disabled = true
		await get_tree().create_timer(0.5).timeout
		completed.emit()
		queue_free()
	else:
		if AudioManager: AudioManager.play_sfx("ui_error")
		PlayerProfile.record_cognitive_event("processing_speed", _scenario_id, _scenario_payload.get("universe", "history"), _scenario_payload.get("world", "ancient_egypt"), false, rt_ms)
		feedback_label.text = "ERROR! Resetting..."
		SessionTracker.record_spike_result("speed_sort", false)
		btn_left.disabled = true; btn_right.disabled = true
		await get_tree().create_timer(0.5).timeout
		if is_inside_tree(): _generate_number()
