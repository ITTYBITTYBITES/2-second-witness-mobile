extends BaseScenario
@warning_ignore("unused_signal")
signal completed

@onready var bg = $VoidBG
@onready var sequence_label = $SequenceLabel
@onready var btn_a = $HBoxContainer/BtnA
@onready var btn_b = $HBoxContainer/BtnB
@onready var feedback_label = $FeedbackLabel

var _scenario_id: String = "pattern_continuation"
var _start_ticks_msec: int = 0
var correct_choice: String = "⬟"

func _apply_specific_rules(rules: Dictionary):
	_scenario_id = _scenario_payload["id"]
	sequence_label.text = _get_prompt_text(rules, "⬟  ⬟  ⬢  ⬟  ?")

func _ready():
	if _scenario_payload.is_empty():
		push_error("[SCENARIO FATAL] Scene loaded without payload injection.")
		queue_free()
		return
		
	# Standardize UI via Toolkit
	_style_question_label(sequence_label, 30)
	PresentationToolkit.apply_glass_style(get_node_or_null("HBoxContainer"))
	PresentationToolkit.make_prompt_banner(feedback_label, "CONTINUE THE PATTERN")
	
	btn_a.pressed.connect(func(): _on_answer(btn_a.text))
	btn_b.pressed.connect(func(): _on_answer(btn_b.text))
	
	# Transform buttons into response cards
	PresentationToolkit.make_response_card(btn_a, btn_a.text)
	PresentationToolkit.make_response_card(btn_b, btn_b.text)
	btn_a.add_theme_font_size_override("font_size", 18)
	btn_b.add_theme_font_size_override("font_size", 18)
	
	_generate_pattern()
	execute_render_pipeline()

func _generate_pattern():
	feedback_label.text = "Select the best continuation"
	btn_a.disabled = false
	btn_b.disabled = false
	var rules = _scenario_payload.get("rules", {})
	sequence_label.text = _get_prompt_text(rules, "⬟  ⬟  ⬢  ⬟  ?")
	var wrong_arr = rules.get("wrong_answers", [])
	if rules.has("correct_answer") and wrong_arr is Array and wrong_arr.size() > 0:
		correct_choice = _clean_payload_text(rules.get("correct_answer", "VERIFIED"))
		var wrong_choice = _clean_payload_text(wrong_arr[0])
		var choices = [correct_choice, wrong_choice]
		choices.shuffle()
		btn_a.text = choices[0]
		btn_b.text = choices[1]
	else:
		correct_choice = "⬟"
		if _deterministic_rng.randf() > 0.5:
			btn_a.text = "⬟"
			btn_b.text = "⬢"
		else:
			btn_a.text = "⬢"
			btn_b.text = "⬟"
		
	# Refresh card labels
	PresentationToolkit.make_response_card(btn_a, btn_a.text)
	PresentationToolkit.make_response_card(btn_b, btn_b.text)
	btn_a.add_theme_font_size_override("font_size", 18)
	btn_b.add_theme_font_size_override("font_size", 18)
	
	_start_ticks_msec = Time.get_ticks_msec()

func _on_answer(choice_text: String):
	var rt_ms = Time.get_ticks_msec() - _start_ticks_msec
	if choice_text == correct_choice:
		print("[PATTERN CONTINUATION] Success. Ejecting!")
		if AudioManager: AudioManager.play_sfx("ui_click")
		feedback_label.text = "SUCCESS! OBSERVATION VERIFIED!"
		sequence_label.text = "VERIFIED: " + correct_choice
		
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
