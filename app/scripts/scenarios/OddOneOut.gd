extends BaseScenario
signal completed

@onready var feedback_label = $FeedbackLabel
@onready var grid = $GridContainer

var correct_idx = 0
var _scenario_id: String = "odd_one_out"
var _start_ticks_msec: int = 0

func _apply_specific_rules(rules: Dictionary):
	_scenario_id = _scenario_payload["id"]

func _ready():
	if _scenario_payload.is_empty():
		push_error("[SCENARIO FATAL] Scene loaded without payload injection.")
		queue_free()
		return
		
	_start_ticks_msec = Time.get_ticks_msec()
	feedback_label.text = "Find the Odd Shape"
	var shapes = ["⬢", "⬟", "◆", "▲", "■"]
	shapes.shuffle()
	var majority = shapes[0]
	var odd = shapes[1]
	
	correct_idx = _deterministic_rng.randi() % 4
	
	for i in range(4):
		var btn = grid.get_child(i)
		if i == correct_idx:
			btn.text = odd
		else:
			btn.text = majority
		btn.pressed.connect(func(): _on_answer(i))
		
	execute_render_pipeline()

func _on_answer(idx: int):
	var rt_ms = Time.get_ticks_msec() - _start_ticks_msec
	if idx == correct_idx:
		feedback_label.text = "SUCCESS! SLINGSHOT INITIATED!"
		PlayerProfile.record_cognitive_event("pattern_recognition", _scenario_id, _scenario_payload.get("universe", "history"), _scenario_payload.get("world", "ancient_egypt"), true, rt_ms)
		SessionTracker.record_spike_result("odd_one_out", true)
		for c in grid.get_children(): c.disabled = true
		await get_tree().create_timer(0.5).timeout
		completed.emit()
		queue_free()
	else:
		feedback_label.text = "ERROR! Try again."
		PlayerProfile.record_cognitive_event("pattern_recognition", _scenario_id, _scenario_payload.get("universe", "history"), _scenario_payload.get("world", "ancient_egypt"), false, rt_ms)
		SessionTracker.record_spike_result("odd_one_out", false)
