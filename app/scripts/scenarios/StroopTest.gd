extends BaseScenario
signal completed

@onready var target_label = $TargetLabel
@onready var feedback_label = $FeedbackLabel
@onready var container = $HBoxContainer

var colors = [Color(1, 0, 0), Color(0, 1, 0), Color(0, 0, 1), Color(1, 1, 0)]
var color_names = ["RED", "GREEN", "BLUE", "YELLOW"]
var target_color_idx = 0
var _scenario_id: String = "stroop_test"
var _start_ticks_msec: int = 0

func _apply_specific_rules(rules: Dictionary):
	_scenario_id = _scenario_payload["id"]
	var prompt = rules.get("legacy_prompt", "")
	if prompt != "":
		color_names = [prompt, rules.get("correct_answer", "GREEN"), "BLUE", "YELLOW"]
		
func _ready():
	if _scenario_payload.is_empty():
		push_error("[SCENARIO FATAL] Scene loaded without payload injection.")
		queue_free()
		return
		
	_generate_stroop()
	execute_render_pipeline()

func _generate_stroop():
	feedback_label.text = "Select the TEXT COLOR, not the word."
	var word_idx = _deterministic_rng.randi() % 4
	target_color_idx = _deterministic_rng.randi() % 4
	target_label.text = color_names[word_idx]
	target_label.add_theme_color_override("font_color", colors[target_color_idx])
	var options = [target_color_idx]
	while options.size() < 3:
		var r = _deterministic_rng.randi() % 4
		if not options.has(r): options.append(r)
	options.shuffle()
	for i in range(3):
		var btn = container.get_child(i)
		btn.disabled = false
		btn.text = color_names[options[i]]
		if not btn.pressed.is_connected(_on_answer.bind(options[i])):
			btn.pressed.connect(_on_answer.bind(options[i]))
	_start_ticks_msec = Time.get_ticks_msec()

func _on_answer(idx: int):
	var rt_ms = Time.get_ticks_msec() - _start_ticks_msec
	if idx == target_color_idx:
		feedback_label.text = "SUCCESS! OBSERVATION VERIFIED!"
		AudioManager.play_sfx("ui_click")
		for c in container.get_children(): c.disabled = true
		execute_progression_event(true, rt_ms, "pattern_recognition")
	else:
		feedback_label.text = "ERROR! Resetting..."
		AudioManager.play_sfx("ui_error")
		for c in container.get_children(): c.disabled = true
		execute_progression_event(false, rt_ms, "pattern_recognition")
