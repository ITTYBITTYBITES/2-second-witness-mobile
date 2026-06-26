extends BaseScenario
signal completed

@onready var grid_container = $GridContainer
@onready var feedback_label = $FeedbackLabel

var sequence = []
var player_step = 0
var buttons = []
var _scenario_id: String = "spatial_recall"
var _start_ticks_msec: int = 0

func _apply_specific_rules(rules: Dictionary):
	_scenario_id = _scenario_payload["id"]

func _ready():
	if _scenario_payload.is_empty():
		push_error("[SCENARIO FATAL] Scene loaded without payload injection.")
		queue_free()
		return
		
	_start_ticks_msec = Time.get_ticks_msec()
	print("[SPATIAL RECALL] Spike Initiated.")
	feedback_label.text = "Memorize the flash!"
	
	for child in grid_container.get_children():
		if child is Button:
			buttons.append(child)
			child.pressed.connect(_on_btn_pressed.bind(buttons.find(child)))
			child.disabled = true 
			
	_play_sequence()
	execute_render_pipeline()

func _play_sequence():
	sequence.clear()
	for i in range(3):
		sequence.append(_deterministic_rng.randi() % 9)
		
	var tween = get_tree().create_tween()
	for idx in sequence:
		tween.tween_callback(func(): buttons[idx].modulate = Color(0, 1, 1, 1))
		tween.tween_interval(0.3)
		tween.tween_callback(func(): buttons[idx].modulate = Color(1, 1, 1, 1))
		tween.tween_interval(0.1)
		
	tween.tween_callback(func(): 
		feedback_label.text = "Repeat the sequence."
		for b in buttons: b.disabled = false
	)

func _on_btn_pressed(idx: int):
	var rt_ms = Time.get_ticks_msec() - _start_ticks_msec
	if sequence[player_step] == idx:
		player_step += 1
		if player_step >= sequence.size():
			feedback_label.text = "SUCCESS! SLINGSHOT INITIATED!"
			PlayerProfile.record_cognitive_event("spatial_tracking", _scenario_id, _scenario_payload.get("universe", "history"), _scenario_payload.get("world", "ancient_egypt"), true, rt_ms)
			SessionTracker.record_spike_result("spatial_recall", true)
			for b in buttons: b.disabled = true
			await get_tree().create_timer(0.5).timeout
			completed.emit()
			queue_free()
	else:
		PlayerProfile.record_cognitive_event("spatial_tracking", _scenario_id, _scenario_payload.get("universe", "history"), _scenario_payload.get("world", "ancient_egypt"), false, rt_ms)
		SessionTracker.record_spike_result("spatial_recall", false)
		feedback_label.text = "ERROR! Watch again."
		player_step = 0
		for b in buttons: b.disabled = true
		_play_sequence()
