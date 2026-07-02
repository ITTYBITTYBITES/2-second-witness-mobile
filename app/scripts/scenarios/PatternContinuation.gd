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
		
	btn_a.pressed.connect(func(): _on_answer(btn_a.text == "⬟"))
	btn_b.pressed.connect(func(): _on_answer(btn_b.text == "⬟"))
	_generate_pattern()
	execute_render_pipeline()

func _generate_pattern():
	feedback_label.text = "Select the next shape"
	btn_a.disabled = false
	btn_b.disabled = false
	if _deterministic_rng.randf() > 0.5:
		btn_a.text = "⬟"
		btn_b.text = "⬢"
	else:
		btn_a.text = "⬢"
		btn_b.text = "⬟"
	_start_ticks_msec = Time.get_ticks_msec()

func _on_answer(is_correct: bool):
	var rt_ms = Time.get_ticks_msec() - _start_ticks_msec
	if is_correct:
		print("[PATTERN CONTINUATION] Success. Ejecting!")
		if AudioManager: AudioManager.play_sfx("ui_click")
		feedback_label.text = "SUCCESS! OBSERVATION VERIFIED!"
		sequence_label.text = "⬟  ⬟  ⬢  ⬟  ⬟"
		
		btn_a.disabled = true
		btn_b.disabled = true
		execute_progression_event(true, rt_ms, "pattern_recognition")
	else:
		print("[PATTERN CONTINUATION] Error. Resetting.")
		if AudioManager: AudioManager.play_sfx("ui_error")
		feedback_label.text = "ERROR! Resetting..."
		btn_a.disabled = true
		btn_b.disabled = true
		execute_progression_event(false, rt_ms, "pattern_recognition")
