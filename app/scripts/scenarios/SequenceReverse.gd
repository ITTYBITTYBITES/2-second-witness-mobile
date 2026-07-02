extends BaseScenario
signal completed

@onready var feedback_label = $FeedbackLabel
@onready var sequence_label = $SequenceLabel
@onready var btn_1 = $HBoxContainer/Btn1
@onready var btn_2 = $HBoxContainer/Btn2
@onready var btn_3 = $HBoxContainer/Btn3

var correct_idx = 0
var _scenario_id: String = "sequence_reverse"
var _start_ticks_msec: int = 0

func _apply_specific_rules(rules: Dictionary):
	_scenario_id = _scenario_payload["id"]

func _ready():
	if _scenario_payload.is_empty():
		push_error("[SCENARIO FATAL] Scene loaded without payload injection.")
		queue_free()
		return
		
	btn_1.pressed.connect(func(): _on_answer(0))
	btn_2.pressed.connect(func(): _on_answer(1))
	btn_3.pressed.connect(func(): _on_answer(2))
	_setup_round()
	execute_render_pipeline()

func _setup_round():
	feedback_label.text = "Memorize..."
	btn_1.disabled = true; btn_2.disabled = true; btn_3.disabled = true
	var n1 = _deterministic_rng.randi() % 9 + 1
	var n2 = _deterministic_rng.randi() % 9 + 1
	var n3 = _deterministic_rng.randi() % 9 + 1
	var original = str(n1) + "  " + str(n2) + "  " + str(n3)
	var reversed_str = str(n3) + "  " + str(n2) + "  " + str(n1)
	var fake1 = str(n1) + "  " + str(n3) + "  " + str(n2)
	var fake2 = str(n2) + "  " + str(n1) + "  " + str(n3)
	
	sequence_label.text = original
	
	var options = [reversed_str, fake1, fake2]
	options.shuffle()
	correct_idx = options.find(reversed_str)
	
	btn_1.text = options[0]
	btn_2.text = options[1]
	btn_3.text = options[2]
	
	_start_ticks_msec = Time.get_ticks_msec()
	var tween = get_tree().create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(func():
		if is_inside_tree():
			sequence_label.text = "WHAT WAS THE REVERSE?"
			btn_1.disabled = false; btn_2.disabled = false; btn_3.disabled = false
	)

func _on_answer(idx: int):
	var rt_ms = Time.get_ticks_msec() - _start_ticks_msec
	if idx == correct_idx:
		if AudioManager: AudioManager.play_sfx("ui_click")
		feedback_label.text = "SUCCESS! OBSERVATION VERIFIED!"
		btn_1.disabled = true; btn_2.disabled = true; btn_3.disabled = true
		execute_progression_event(true, rt_ms, "recall")
	else:
		if AudioManager: AudioManager.play_sfx("ui_error")
		feedback_label.text = "ERROR! Resetting..."
		btn_1.disabled = true; btn_2.disabled = true; btn_3.disabled = true
		execute_progression_event(false, rt_ms, "recall")
