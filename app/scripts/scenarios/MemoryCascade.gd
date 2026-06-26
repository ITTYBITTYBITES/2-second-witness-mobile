extends BaseScenario

signal completed

@onready var bg = $VoidBG
@onready var btn_left = $HBoxContainer/BtnLeft
@onready var btn_center = $HBoxContainer/BtnCenter
@onready var btn_right = $HBoxContainer/BtnRight
@onready var feedback_label = $FeedbackLabel

var sequence = [] 
var current_step = 0
var _scenario_id: String = "memory_cascade"
var _start_ticks_msec: int = 0
var _initial_feedback_text: String = ""

func _apply_specific_rules(rules: Dictionary):
	_scenario_id = _scenario_payload["id"]
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
	print("SCENARIO READY")
	if _scenario_payload.is_empty():
		push_error("SCENARIO PAYLOAD EMPTY")
		queue_free()
		return
		
	_start_ticks_msec = Time.get_ticks_msec()
	print("[MEMORY CASCADE] Entering the Void. Spike Initiated.")
	
	if feedback_label and _initial_feedback_text != "":
		feedback_label.text = _initial_feedback_text
	
	btn_left.pressed.connect(func(): _on_btn_pressed(0))
	btn_center.pressed.connect(func(): _on_btn_pressed(1))
	btn_right.pressed.connect(func(): _on_btn_pressed(2))
	
	execute_render_pipeline()

func _on_btn_pressed(val: int):
	var rt_ms = Time.get_ticks_msec() - _start_ticks_msec
	if sequence[current_step] == val:
		current_step += 1
		feedback_label.text = "Hit: " + str(current_step) + "/" + str(sequence.size())
		if current_step >= sequence.size():
			feedback_label.text = "SUCCESS! SLINGSHOT INITIATED!"
			PlayerProfile.record_cognitive_event("recall", _scenario_id, _scenario_payload.get("universe", "science_lab"), _scenario_payload.get("world", "default"), true, rt_ms)
			SessionTracker.record_spike_result("memory_cascade", true)
			await get_tree().create_timer(0.5).timeout
			completed.emit()
			queue_free()
	else:
		feedback_label.text = "ERROR! Resetting."
		PlayerProfile.record_cognitive_event("recall", _scenario_id, _scenario_payload.get("universe", "science_lab"), _scenario_payload.get("world", "default"), false, rt_ms)
		SessionTracker.record_spike_result("memory_cascade", false)
		current_step = 0
