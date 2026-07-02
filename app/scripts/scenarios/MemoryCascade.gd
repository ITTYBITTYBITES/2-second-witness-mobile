extends BaseScenario

signal completed

@onready var bg = $VoidBG
@onready var container = $HBoxContainer
@onready var btn_left = $HBoxContainer/BtnLeft
@onready var btn_center = $HBoxContainer/BtnCenter
@onready var btn_right = $HBoxContainer/BtnRight
@onready var feedback_label = $FeedbackLabel

var sequence = [] 
var current_step = 0
var _scenario_id: String = "memory_cascade"
var _start_ticks_msec: int = 0
var _initial_feedback_text: String = ""
var answer_buttons: Array[Button] = []

func _enter_tree():
	super._enter_tree()

func _apply_specific_rules(rules: Dictionary):
	_scenario_id = normalize_id(_scenario_payload.get("id", "memory_cascade"))
	var length = rules.get("sequence_length", 3)
	
	for i in range(length):
		sequence.append(_deterministic_rng.randi() % 3)
		
	var seq_str = ""
	for val in sequence:
		if val == 0: seq_str += "Left -> "
		elif val == 1: seq_str += "Center -> "
		elif val == 2: seq_str += "Right -> "
	
	seq_str = seq_str.strip_edges().trim_suffix("->")
	_initial_feedback_text = "Sequence: " + seq_str
	if feedback_label:
		feedback_label.text = _initial_feedback_text

func _ready():
	super._ready()
	print("SCENARIO READY")
	if _scenario_payload.is_empty():
		push_error("SCENARIO PAYLOAD EMPTY")
		queue_free()
		return
		
	_start_ticks_msec = Time.get_ticks_msec()
	print("[MEMORY CASCADE] Entering the Void. Spike Initiated.")
	
	if feedback_label and _initial_feedback_text != "":
		feedback_label.text = _initial_feedback_text
	
	build_ui()
	execute_render_pipeline()

func build_ui():
	print("[MEMORY CASCADE] build_ui(): Initiating UI construction...")
	spawn_choices()

func spawn_choices():
	print("[MEMORY CASCADE] spawn_choices(): Instantiating answer buttons...")
	answer_buttons = [btn_left, btn_center, btn_right]
	print("[MEMORY CASCADE] answer_buttons.size(): ", answer_buttons.size())
	
	for i in range(answer_buttons.size()):
		var button = answer_buttons[i]
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		button.disabled = false
		button.visible = true
		button.process_mode = Node.PROCESS_MODE_INHERIT
		
		print("[MEMORY CASCADE] Button Text: ", button.text)
		print("  visible == ", button.visible)
		print("  disabled == ", button.disabled)
		print("  mouse_filter == ", button.mouse_filter)
		print("  process_mode == ", button.process_mode)
		print("  size == ", button.size)
		print("  global_position == ", button.global_position)
		
		if not button.pressed.is_connected(_on_btn_pressed.bind(i)):
			button.pressed.connect(_on_btn_pressed.bind(i))
			
	print("[MEMORY CASCADE] All interactive controls are visible and enabled. Input signals connected.")

func _on_btn_pressed(val: int):
	print("[MEMORY CASCADE] Answer button pressed: ", val)
	print("[MEMORY CASCADE] Choice selected: ", val)
	evaluate_answer(val)

func evaluate_answer(val: int):
	print("[MEMORY CASCADE] Scenario evaluated")
	var rt_ms = Time.get_ticks_msec() - _start_ticks_msec
	var correct_index = sequence[current_step]
	var selected_index = val
	
	print("[MEMORY CASCADE] correct_index: ", correct_index)
	print("[MEMORY CASCADE] selected_index: ", selected_index)
	
	if selected_index == correct_index:
		print("[MEMORY CASCADE] Correct answer")
		current_step += 1
		if feedback_label: feedback_label.text = "Hit: " + str(current_step) + "/" + str(sequence.size())
		if current_step >= sequence.size():
			scenario_complete(rt_ms)
	else:
		print("[MEMORY CASCADE] Incorrect answer")
		scenario_failed(rt_ms)

func scenario_complete(rt_ms: float):
	print("[MEMORY CASCADE] scenario_complete(): Success path executing...")
	if feedback_label: feedback_label.text = "SUCCESS! OBSERVATION VERIFIED!"
	if StructuredLogger and StructuredLogger.has_method("log_event_trace"):
		StructuredLogger.log_event_trace(self, "signal_dispatch", "Emitting 'completed' signal.")
	execute_progression_event(true, rt_ms, "recall")

func scenario_failed(rt_ms: float):
	print("[MEMORY CASCADE] scenario_failed(): Failure path executing...")
	if feedback_label: feedback_label.text = "ERROR! Resetting."
	current_step = 0
	execute_progression_event(false, rt_ms, "recall")

func timeout():
	print("[MEMORY CASCADE] Timer expired")
	print("[MEMORY CASCADE] timeout(): Scenario timed out.")
	scenario_failed(Time.get_ticks_msec() - _start_ticks_msec)
