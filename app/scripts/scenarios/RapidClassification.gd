extends BaseScenario

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
	var correct = rules.get("correct_answer", "Organic")
	var wrong_arr = rules.get("wrong_answers", ["Mechanical"])
	var wrong = wrong_arr[0] if wrong_arr.size() > 0 else "Mechanical"
	
	target_label.text = rules.get("legacy_prompt", "TREE")
	
	# REPLACED randf() WITH DETERMINISTIC RNG
	if _deterministic_rng.randf() > 0.5:
		btn_organic.text = correct
		btn_mechanical.text = wrong
		target_is_organic = true
	else:
		btn_organic.text = wrong
		btn_mechanical.text = correct
		target_is_organic = false

func _ready():
	# If injection failed (e.g. running scene manually in editor), abort.
	if _scenario_payload.is_empty():
		push_error("[SCENARIO FATAL] Scene loaded without payload injection.")
		queue_free()
		return
		
	_start_ticks_msec = Time.get_ticks_msec()
	print("[RAPID CLASSIFICATION] Spike Initiated.")
	feedback_label.text = ""
	
	btn_organic.pressed.connect(func(): _on_answer(true))
	btn_mechanical.pressed.connect(func(): _on_answer(false))
	
	var tween = get_tree().create_tween()
	tween.tween_property(target_label, "modulate:a", 1.0, 0.1)
	tween.tween_interval(0.5) 
	tween.tween_property(target_label, "modulate:a", 0.0, 0.1)
	
	execute_render_pipeline()

func _on_answer(chose_organic: bool):
	var rt_ms = Time.get_ticks_msec() - _start_ticks_msec
	if chose_organic == target_is_organic:
		print("[RAPID CLASSIFICATION] Success. Ejecting!")
		feedback_label.text = "SUCCESS! SLINGSHOT INITIATED!"
		btn_organic.disabled = true
		btn_mechanical.disabled = true
		
		PlayerProfile.record_cognitive_event("rapid_classification", _scenario_id, _scenario_payload["universe"], "default", true, rt_ms)
		SessionTracker.record_spike_result("rapid_classification", true)
		
		await get_tree().create_timer(0.5).timeout
		completed.emit()
		queue_free()
	else:
		print("[RAPID CLASSIFICATION] Error. Resetting.")
		PlayerProfile.record_cognitive_event("rapid_classification", _scenario_id, _scenario_payload["universe"], "default", false, rt_ms)
		SessionTracker.record_spike_result("rapid_classification", false)
		feedback_label.text = "ERROR! Try again."
