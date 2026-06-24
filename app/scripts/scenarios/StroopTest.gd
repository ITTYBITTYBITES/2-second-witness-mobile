extends CanvasLayer
signal completed

@onready var target_label = $TargetLabel
@onready var feedback_label = $FeedbackLabel
@onready var container = $HBoxContainer

var colors = [Color(1, 0, 0), Color(0, 1, 0), Color(0, 0, 1), Color(1, 1, 0)]
var color_names = ["RED", "GREEN", "BLUE", "YELLOW"]
var target_color_idx = 0
var _scenario_id: String = "stroop_test"

func inject_payload(payload: Dictionary):
	if payload.is_empty(): return
	
	_scenario_id = payload.get("id", _scenario_id)
	
	var rules = payload.get("rules", {})
	var prompt = rules.get("legacy_prompt", "")
	if prompt != "":
		# Override the default color names if the JSON has specific text
		color_names = [prompt, rules.get("correct_answer", "GREEN"), "BLUE", "YELLOW"]
		
func _ready():
	feedback_label.text = "Select the TEXT COLOR, not the word."
	
	var word_idx = randi() % 4
	target_color_idx = randi() % 4
	
	target_label.text = color_names[word_idx]
	target_label.add_theme_color_override("font_color", colors[target_color_idx])
	
	var options = [target_color_idx]
	while options.size() < 3:
		var r = randi() % 4
		if not options.has(r): options.append(r)
	options.shuffle()
	
	for i in range(3):
		var btn = container.get_child(i)
		btn.text = color_names[options[i]]
		btn.pressed.connect(func(): _on_answer(options[i]))

func _on_answer(idx: int):
	if idx == target_color_idx:
		feedback_label.text = "SUCCESS! SLINGSHOT INITIATED!"
		SessionTracker.record_spike_result("stroop_test", true)
		for c in container.get_children(): c.disabled = true
		await get_tree().create_timer(0.5).timeout
		completed.emit()
		queue_free()
	else:
		feedback_label.text = "ERROR! Try again."
		SessionTracker.record_spike_result("stroop_test", false)
