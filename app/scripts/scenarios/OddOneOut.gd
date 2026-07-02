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
		
	_generate_grid()
	execute_render_pipeline()

func _generate_grid():
	feedback_label.text = "Find the Odd Shape"
	var shapes = ["⬢", "⬟", "◆", "▲", "■"]
	shapes.shuffle()
	var majority = shapes[0]
	var odd = shapes[1]
	correct_idx = _deterministic_rng.randi() % 4
	for i in range(4):
		var btn = grid.get_child(i)
		btn.disabled = false
		if i == correct_idx: btn.text = odd
		else: btn.text = majority
		if not btn.pressed.is_connected(_on_answer.bind(i)):
			btn.pressed.connect(_on_answer.bind(i))
	_start_ticks_msec = Time.get_ticks_msec()

func _on_answer(idx: int):
	var rt_ms = Time.get_ticks_msec() - _start_ticks_msec
	if idx == correct_idx:
		if AudioManager: AudioManager.play_sfx("ui_click")
		feedback_label.text = "SUCCESS! OBSERVATION VERIFIED!"
		for c in grid.get_children(): c.disabled = true
		execute_progression_event(true, rt_ms, "pattern_recognition")
	else:
		if AudioManager: AudioManager.play_sfx("ui_error")
		feedback_label.text = "ERROR! Resetting..."
		for c in grid.get_children(): c.disabled = true
		execute_progression_event(false, rt_ms, "pattern_recognition")
