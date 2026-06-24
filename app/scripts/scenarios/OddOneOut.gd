extends CanvasLayer
signal completed

@onready var feedback_label = $FeedbackLabel
@onready var grid = $GridContainer

var correct_idx = 0

func _ready():
	feedback_label.text = "Find the Odd Shape"
	var shapes = ["⬢", "⬟", "◆", "▲", "■"]
	shapes.shuffle()
	var majority = shapes[0]
	var odd = shapes[1]
	
	correct_idx = randi() % 4
	
	for i in range(4):
		var btn = grid.get_child(i)
		if i == correct_idx:
			btn.text = odd
		else:
			btn.text = majority
		btn.pressed.connect(func(): _on_answer(i))

func _on_answer(idx: int):
	if idx == correct_idx:
		feedback_label.text = "SUCCESS! SLINGSHOT INITIATED!"
		SessionTracker.record_spike_result("odd_one_out", true)
		for c in grid.get_children(): c.disabled = true
		await get_tree().create_timer(0.5).timeout
		completed.emit()
		queue_free()
	else:
		feedback_label.text = "ERROR! Try again."
		SessionTracker.record_spike_result("odd_one_out", false)
