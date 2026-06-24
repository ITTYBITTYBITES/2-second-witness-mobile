extends CanvasLayer
signal completed

@onready var target_label = $TargetLabel
@onready var feedback_label = $FeedbackLabel
@onready var btn_left = $BtnLeft
@onready var btn_right = $BtnRight

var is_even = true

func _ready():
	feedback_label.text = "Sort rapidly!"
	
	var num = randi() % 99 + 1
	is_even = (num % 2 == 0)
	target_label.text = str(num)
	
	btn_left.pressed.connect(func(): _on_answer(true)) # Even
	btn_right.pressed.connect(func(): _on_answer(false)) # Odd

func _on_answer(chose_even: bool):
	if chose_even == is_even:
		feedback_label.text = "SUCCESS! SLINGSHOT INITIATED!"
		SessionTracker.record_spike_result("speed_sort", true)
		btn_left.disabled = true; btn_right.disabled = true
		await get_tree().create_timer(0.5).timeout
		completed.emit()
		queue_free()
	else:
		feedback_label.text = "ERROR! Try again."
		SessionTracker.record_spike_result("speed_sort", false)
