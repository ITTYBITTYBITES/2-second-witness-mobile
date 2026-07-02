extends BaseScenario
signal completed

@onready var equation_label = $EquationLabel
@onready var btn_true = $HBoxContainer/BtnTrue
@onready var btn_false = $HBoxContainer/BtnFalse
@onready var feedback_label = $FeedbackLabel

var is_correct_equation: bool = true
var _scenario_id: String = "math_surprise"
var _start_ticks_msec: int = 0

func _apply_specific_rules(rules: Dictionary):
	_scenario_id = _scenario_payload["id"]

func _ready():
	if _scenario_payload.is_empty():
		push_error("[SCENARIO FATAL] Scene loaded without payload injection.")
		queue_free()
		return
		
	_start_ticks_msec = Time.get_ticks_msec()
	print("[MATH SURPRISE] Spike Initiated.")
	feedback_label.text = ""
	
	btn_true.pressed.connect(func(): _on_answer(true))
	btn_false.pressed.connect(func(): _on_answer(false))
	_generate_problem()
	execute_render_pipeline()

func _generate_problem():
	feedback_label.text = ""
	btn_true.disabled = false
	btn_false.disabled = false
	var num1 = _deterministic_rng.randi() % 10 + 1
	var num2 = _deterministic_rng.randi() % 10 + 1
	var actual_sum = num1 + num2
	var displayed_sum = actual_sum
	if _deterministic_rng.randf() > 0.5:
		is_correct_equation = false
		displayed_sum += (_deterministic_rng.randi() % 3 + 1) * (1 if _deterministic_rng.randf() > 0.5 else -1)
	else:
		is_correct_equation = true
	equation_label.text = str(num1) + " + " + str(num2) + " = " + str(displayed_sum)
	_start_ticks_msec = Time.get_ticks_msec()

func _on_answer(chose_true: bool):
	var rt_ms = Time.get_ticks_msec() - _start_ticks_msec
	if chose_true == is_correct_equation:
		print("[MATH SURPRISE] Success. Ejecting!")
		if AudioManager: AudioManager.play_sfx("ui_click")
		feedback_label.text = "SUCCESS! OBSERVATION VERIFIED!"
		btn_true.disabled = true
		btn_false.disabled = true
		execute_progression_event(true, rt_ms, "processing_speed")
	else:
		print("[MATH SURPRISE] Error. Resetting.")
		if AudioManager: AudioManager.play_sfx("ui_error")
		feedback_label.text = "ERROR! Resetting..."
		btn_true.disabled = true
		btn_false.disabled = true
		execute_progression_event(false, rt_ms, "processing_speed")
