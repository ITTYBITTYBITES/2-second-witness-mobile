extends BaseScenario
signal completed

@onready var bg = $VoidBG
@onready var sequence_label = $SequenceLabel
@onready var btn_a = $HBoxContainer/BtnA
@onready var btn_b = $HBoxContainer/BtnB
@onready var feedback_label = $FeedbackLabel

var _scenario_id: String = "pattern_continuation"
var _start_ticks_msec: int = 0

func _apply_specific_rules(rules: Dictionary):
	_scenario_id = _scenario_payload["id"]
	sequence_label.text = rules.get("legacy_prompt", "⬟  ⬟  ⬢  ⬟  ?")

func _ready():
	if _scenario_payload.is_empty():
		push_error("[SCENARIO FATAL] Scene loaded without payload injection.")
		queue_free()
		return
		
	_start_ticks_msec = Time.get_ticks_msec()
	print("[PATTERN CONTINUATION] Spike Initiated.")
	feedback_label.text = "Select the next shape"
	
	btn_a.text = "⬟"
	btn_b.text = "⬢"
	
	btn_a.pressed.connect(func(): _on_answer(true))
	btn_b.pressed.connect(func(): _on_answer(false))
	
	execute_render_pipeline()

func _on_answer(is_correct: bool):
	var rt_ms = Time.get_ticks_msec() - _start_ticks_msec
	if is_correct:
		print("[PATTERN CONTINUATION] Success. Ejecting!")
		feedback_label.text = "SUCCESS! SLINGSHOT INITIATED!"
		sequence_label.text = "⬟  ⬟  ⬢  ⬟  ⬟"
		
		btn_a.disabled = true
		btn_b.disabled = true
		
		PlayerProfile.record_cognitive_event("pattern_recognition", _scenario_id, _scenario_payload.get("universe", "history"), _scenario_payload.get("world", "ancient_egypt"), true, rt_ms)
		SessionTracker.record_spike_result("pattern_continuation", true)
		
		await get_tree().create_timer(0.5).timeout
		completed.emit()
		queue_free()
	else:
		print("[PATTERN CONTINUATION] Error. Resetting.")
		PlayerProfile.record_cognitive_event("pattern_recognition", _scenario_id, _scenario_payload.get("universe", "history"), _scenario_payload.get("world", "ancient_egypt"), false, rt_ms)
		SessionTracker.record_spike_result("pattern_continuation", false)
		feedback_label.text = "ERROR! Try again."
