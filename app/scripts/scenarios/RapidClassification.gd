extends BaseScenario

@warning_ignore("unused_signal")
signal completed

@onready var target_label = $TargetLabel
@onready var btn_organic = $HBoxContainer/BtnOrganic
@onready var btn_mechanical = $HBoxContainer/BtnMechanical
@onready var feedback_label = $FeedbackLabel

var target_is_organic: bool = true
var _scenario_id: String = "rapid_classification"
var _start_ticks_msec: int = 0

func _apply_specific_rules(rules: Dictionary):
	_scenario_id = _scenario_payload["id"]

func _ready():
	# If injection failed (e.g. running scene manually in editor), abort.
	if _scenario_payload.is_empty():
		push_error("[SCENARIO FATAL] Scene loaded without payload injection.")
		queue_free()
		return
		
	# Standardize UI via Toolkit
	_style_question_label(target_label, 30)
	PresentationToolkit.apply_glass_style(get_node_or_null("HBoxContainer"))
	PresentationToolkit.make_prompt_banner(target_label, "CLASSIFY TARGET")
	
	btn_organic.pressed.connect(func(): _on_answer(true))
	btn_mechanical.pressed.connect(func(): _on_answer(false))
	
	# Transform buttons into response cards
	PresentationToolkit.make_response_card(btn_organic, "ORGANIC")
	PresentationToolkit.make_response_card(btn_mechanical, "MECHANICAL")
	
	_setup_round()
	execute_render_pipeline()

func _setup_round():
	feedback_label.text = ""
	btn_organic.disabled = false
	btn_mechanical.disabled = false
	var rules = _scenario_payload.get("rules", {})
	var correct = _clean_payload_text(rules.get("correct_answer", "Organic"))
	var wrong_arr = rules.get("wrong_answers", ["Mechanical"])
	var wrong = _clean_payload_text(wrong_arr[0]) if wrong_arr.size() > 0 else "Mechanical"
	
	target_label.text = _get_prompt_text(rules, str(correct))
	
	if _deterministic_rng.randf() > 0.5:
		btn_organic.text = correct
		btn_mechanical.text = wrong
		target_is_organic = true
	else:
		btn_organic.text = wrong
		btn_mechanical.text = correct
		target_is_organic = false
	PresentationToolkit.make_response_card(btn_organic, btn_organic.text)
	PresentationToolkit.make_response_card(btn_mechanical, btn_mechanical.text)
	btn_organic.add_theme_font_size_override("font_size", 18)
	btn_mechanical.add_theme_font_size_override("font_size", 18)
		
	_start_ticks_msec = Time.get_ticks_msec()
	target_label.modulate.a = 1.0

func _on_answer(chose_organic: bool):
	var rt_ms = Time.get_ticks_msec() - _start_ticks_msec
	if chose_organic == target_is_organic:
		print("[RAPID CLASSIFICATION] Success. Ejecting!")
		if AudioManager: AudioManager.play_sfx("ui_click")
		feedback_label.text = "SUCCESS! OBSERVATION VERIFIED!"
		btn_organic.disabled = true
		btn_mechanical.disabled = true
		execute_progression_event(true, rt_ms, "rapid_classification")
	else:
		print("[RAPID CLASSIFICATION] Error. Resetting.")
		if AudioManager: AudioManager.play_sfx("ui_error")
		feedback_label.text = "ERROR! Resetting..."
		btn_organic.disabled = true
		btn_mechanical.disabled = true
		execute_progression_event(false, rt_ms, "rapid_classification")
