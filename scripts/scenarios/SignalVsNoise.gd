extends CanvasLayer
signal completed

@onready var bg = $VoidBG
@onready var target_label = $TargetLabel
@onready var noise_container = $NoiseContainer
@onready var btn_match = $HBoxContainer/BtnMatch
@onready var btn_ignore = $HBoxContainer/BtnIgnore
@onready var feedback_label = $FeedbackLabel

var _start_ticks_msec: int = 0
var target_symbol: String = "◆"
var is_signal: bool = false

func _ready():
	_start_ticks_msec = Time.get_ticks_msec()
	print("[SIGNAL VS NOISE] Spike Initiated.")
	feedback_label.text = "Find: " + target_symbol
	
	is_signal = randf() > 0.5
	
	var symbols = ["⬢", "⬟", "▲", "■", "●", "★", "✖", "✦"]
	for i in range(15):
		var lbl = Label.new()
		lbl.add_theme_font_size_override("font_size", randi_range(24, 64))
		lbl.text = symbols[randi() % symbols.size()]
		lbl.modulate = Color(randf_range(0.3, 0.7), randf_range(0.3, 0.7), randf_range(0.3, 0.7))
		lbl.position = Vector2(randf_range(100, 800), randf_range(100, 500))
		noise_container.add_child(lbl)
		
	if is_signal:
		var lbl = Label.new()
		lbl.add_theme_font_size_override("font_size", 48)
		lbl.text = target_symbol
		lbl.modulate = Color(1, 1, 1) # Higher contrast
		lbl.position = Vector2(randf_range(200, 700), randf_range(200, 400))
		noise_container.add_child(lbl)

	btn_match.pressed.connect(func(): _on_answer(true))
	btn_ignore.pressed.connect(func(): _on_answer(false))

func _on_answer(chose_match: bool):
	var rt_ms = Time.get_ticks_msec() - _start_ticks_msec
	if chose_match == is_signal:
		print("[SIGNAL VS NOISE] Success. Ejecting!")
		feedback_label.text = "SUCCESS! SLINGSHOT INITIATED!"
		PlayerProfile.record_cognitive_event("rapid_classification", "signal_vs_noise", "science_lab", true, rt_ms)
		SessionTracker.record_spike_result("signal_vs_noise", true)
		btn_match.disabled = true; btn_ignore.disabled = true
		await get_tree().create_timer(0.5).timeout
		completed.emit()
		queue_free()
	else:
		print("[SIGNAL VS NOISE] Error. Resetting.")
		PlayerProfile.record_cognitive_event("rapid_classification", "signal_vs_noise", "science_lab", false, rt_ms)
		SessionTracker.record_spike_result("signal_vs_noise", false)
		feedback_label.text = "ERROR! Try again."
