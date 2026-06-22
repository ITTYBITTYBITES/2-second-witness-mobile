extends CanvasLayer
signal completed

@onready var feedback_label = $FeedbackLabel
@onready var sequence_label = $SequenceLabel
@onready var btn_1 = $HBoxContainer/Btn1
@onready var btn_2 = $HBoxContainer/Btn2
@onready var btn_3 = $HBoxContainer/Btn3

var correct_idx = 0

func _ready():
	feedback_label.text = "Memorize..."
	# Generate 3 random numbers
	var n1 = randi() % 9 + 1
	var n2 = randi() % 9 + 1
	var n3 = randi() % 9 + 1
	var original = str(n1) + "  " + str(n2) + "  " + str(n3)
	var reversed_str = str(n3) + "  " + str(n2) + "  " + str(n1)
	var fake1 = str(n1) + "  " + str(n3) + "  " + str(n2)
	var fake2 = str(n2) + "  " + str(n1) + "  " + str(n3)
	
	sequence_label.text = original
	
	var options = [reversed_str, fake1, fake2]
	options.shuffle()
	correct_idx = options.find(reversed_str)
	
	btn_1.text = options[0]
	btn_2.text = options[1]
	btn_3.text = options[2]
	
	btn_1.disabled = true; btn_2.disabled = true; btn_3.disabled = true
	btn_1.pressed.connect(func(): _on_answer(0))
	btn_2.pressed.connect(func(): _on_answer(1))
	btn_3.pressed.connect(func(): _on_answer(2))
	
	var tween = get_tree().create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(func():
		sequence_label.text = "WHAT WAS THE REVERSE?"
		btn_1.disabled = false; btn_2.disabled = false; btn_3.disabled = false
	)

func _on_answer(idx: int):
	if idx == correct_idx:
		feedback_label.text = "SUCCESS! SLINGSHOT INITIATED!"
		SessionTracker.record_spike_result("sequence_reverse", true)
		btn_1.disabled = true; btn_2.disabled = true; btn_3.disabled = true
		await get_tree().create_timer(0.5).timeout
		completed.emit()
		queue_free()
	else:
		feedback_label.text = "ERROR! Try again."
		SessionTracker.record_spike_result("sequence_reverse", false)
