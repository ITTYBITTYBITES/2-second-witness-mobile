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
	
	var num1 = _deterministic_rng.randi() % 10 + 1
	var num2 = _deterministic_rng.randi() % 10 + 1
	var actual_sum = num1 + num2
	var displayed_sum = actual_sum
	
	if _deterministic_rng.randf() > 0.5:
		is_correct_equation = false
		displayed_sum += (_deterministic_rng.randi() % 3 + 1) * (1 if _deterministic_rng.randf() > 0.5 else -1)
		
	equation_label.text = str(num1) + " + " + str(num2) + " = " + str(displayed_sum)
	
	btn_true.pressed.connect(func(): _on_answer(true))
	btn_false.pressed.connect(func(): _on_answer(false))
	
	execute_render_pipeline()

func _on_answer(chose_true: bool):
	var rt_ms = Time.get_ticks_msec() - _start_ticks_msec
	if chose_true == is_correct_equation:
		print("[MATH SURPRISE] Success. Ejecting!")
		feedback_label.text = "SUCCESS! SLINGSHOT INITIATED!"
		PlayerProfile.record_cognitive_event("processing_speed", _scenario_id, _scenario_payload.get("universe", "history"), _scenario_payload.get("world", "ancient_egypt"), true, rt_ms)
		SessionTracker.record_spike_result("math_surprise", true)
		
		btn_true.disabled = true
		btn_false.disabled = true
		
		await get_tree().create_timer(0.5).timeout
		completed.emit()
		queue_free()
	else:
		print("[MATH SURPRISE] Error. Resetting.")
		feedback_label.text = "ERROR! Try again."
		PlayerProfile.record_cognitive_event("processing_speed", _scenario_id, _scenario_payload.get("universe", "history"), _scenario_payload.get("world", "ancient_egypt"), false, rt_ms)
		SessionTracker.record_spike_result("math_surprise", false)
