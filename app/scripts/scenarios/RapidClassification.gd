extends CanvasLayer

signal completed

@onready var bg = $VoidBG
@onready var target_label = $TargetLabel
@onready var btn_organic = $HBoxContainer/BtnOrganic
@onready var btn_mechanical = $HBoxContainer/BtnMechanical
@onready var feedback_label = $FeedbackLabel

var target_is_organic: bool = true
var _scenario_id: String = "rapid_classification"

func inject_payload(payload: Dictionary):
	if payload.is_empty(): return
	
	_scenario_id = payload.get("id", _scenario_id)
	
	var rules = payload.get("rules", {})
	var correct = rules.get("correct_answer", "Organic")
	var wrong_arr = rules.get("wrong_answers", ["Mechanical"])
	var wrong = wrong_arr[0] if wrong_arr.size() > 0 else "Mechanical"
	
	target_label.text = rules.get("legacy_prompt", "TREE")
	
	# Since it's a binary choice, we just assign the correct answer to one button and wrong to the other
	if randf() > 0.5:
		btn_organic.text = correct
		btn_mechanical.text = wrong
		target_is_organic = true
	else:
		btn_organic.text = wrong
		btn_mechanical.text = correct
		target_is_organic = false

func _ready():
	print("[RAPID CLASSIFICATION] Spike Initiated.")
	feedback_label.text = ""
	
	# If no payload was injected, fallback to defaults
	if target_label.text == "TARGET":
		if randf() > 0.5:
			target_label.text = "TREE"
			btn_organic.text = "Organic"
			btn_mechanical.text = "Mechanical"
			target_is_organic = true
		else:
			target_label.text = "GEAR"
			btn_organic.text = "Mechanical"
			btn_mechanical.text = "Organic"
			target_is_organic = false
		
	btn_organic.pressed.connect(func(): _on_answer(true))
	btn_mechanical.pressed.connect(func(): _on_answer(false))
	
	# Flash the word briefly
	var tween = get_tree().create_tween()
	tween.tween_property(target_label, "modulate:a", 1.0, 0.1)
	tween.tween_interval(0.5) # Visible for 500ms
	tween.tween_property(target_label, "modulate:a", 0.0, 0.1)

func _on_answer(chose_organic: bool):
	if chose_organic == target_is_organic:
		print("[RAPID CLASSIFICATION] Success. Ejecting!")
		feedback_label.text = "SUCCESS! SLINGSHOT INITIATED!"
		
		btn_organic.disabled = true
		btn_mechanical.disabled = true
		
		SessionTracker.record_spike_result("rapid_classification", true)
		
		await get_tree().create_timer(0.5).timeout
		completed.emit()
		queue_free()
	else:
		print("[RAPID CLASSIFICATION] Error. Resetting.")
		SessionTracker.record_spike_result("rapid_classification", false)
		feedback_label.text = "ERROR! Try again."
