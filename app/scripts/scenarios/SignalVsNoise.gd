extends BaseScenario
signal completed

@onready var target_label = $TargetLabel
@onready var noise_container = $NoiseContainer
@onready var btn_match = $HBoxContainer/BtnMatch
@onready var btn_ignore = $HBoxContainer/BtnIgnore
@onready var feedback_label = $FeedbackLabel

var _start_ticks_msec: int = 0
var target_symbol: String = "◆"
var noise_symbols: Array = ["⬢", "⬟", "▲", "■", "●", "★", "✖", "✦"]
var is_signal: bool = false
var _scenario_id: String = "signal_vs_noise"

func _apply_specific_rules(rules: Dictionary):
	_scenario_id = _scenario_payload["id"]
	# The JSON schema determines the target symbol and the pool of noise symbols
	target_symbol = rules.get("correct_answer", "◆")
	noise_symbols = rules.get("wrong_answers", ["⬢", "⬟", "▲", "■", "●", "★", "✖", "✦"])
	
	btn_match.pressed.connect(func(): _on_answer(true))
	btn_ignore.pressed.connect(func(): _on_answer(false))
	_setup_round()
	execute_render_pipeline()

func _setup_round():
	for c in noise_container.get_children(): c.queue_free()
	feedback_label.text = "Find: " + target_symbol
	btn_match.disabled = false; btn_ignore.disabled = false
	is_signal = _deterministic_rng.randf() > 0.5
	for i in range(15):
		var lbl = Label.new()
		lbl.add_theme_font_size_override("font_size", _deterministic_rng.randi_range(24, 64))
		lbl.text = noise_symbols[_deterministic_rng.randi() % noise_symbols.size()]
		lbl.modulate = Color(_deterministic_rng.randf_range(0.3, 0.7), _deterministic_rng.randf_range(0.3, 0.7), _deterministic_rng.randf_range(0.3, 0.7))
		lbl.position = Vector2(_deterministic_rng.randf_range(100, 800), _deterministic_rng.randf_range(100, 500))
		noise_container.add_child(lbl)
	if is_signal:
		var lbl = Label.new()
		lbl.add_theme_font_size_override("font_size", 48)
		lbl.text = target_symbol
		lbl.modulate = Color(1, 1, 1)
		lbl.position = Vector2(_deterministic_rng.randf_range(200, 700), _deterministic_rng.randf_range(200, 400))
		noise_container.add_child(lbl)
	_start_ticks_msec = Time.get_ticks_msec()

func _on_answer(chose_match: bool):
	var rt_ms = Time.get_ticks_msec() - _start_ticks_msec
	if chose_match == is_signal:
		if AudioManager: AudioManager.play_sfx("ui_click")
		feedback_label.text = "SUCCESS! OBSERVATION VERIFIED!"
		btn_match.disabled = true; btn_ignore.disabled = true
		execute_progression_event(true, rt_ms, "rapid_classification")
	else:
		if AudioManager: AudioManager.play_sfx("ui_error")
		feedback_label.text = "ERROR! Resetting..."
		btn_match.disabled = true; btn_ignore.disabled = true
		execute_progression_event(false, rt_ms, "rapid_classification")
