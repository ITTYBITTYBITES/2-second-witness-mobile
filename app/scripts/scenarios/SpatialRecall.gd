extends CanvasLayer
signal completed

@onready var grid_container = $GridContainer
@onready var feedback_label = $FeedbackLabel

var sequence = []
var player_step = 0
var buttons = []

func _ready():
	print("[SPATIAL RECALL] Spike Initiated.")
	feedback_label.text = "Memorize the flash!"
	
	# Gather all 9 buttons from the 3x3 grid
	for child in grid_container.get_children():
		if child is Button:
			buttons.append(child)
			child.pressed.connect(_on_btn_pressed.bind(buttons.find(child)))
			child.disabled = true # Lock inputs during flash
			
	_play_sequence()

func _play_sequence():
	# Generate random 3-step spatial sequence
	sequence.clear()
	for i in range(3):
		sequence.append(randi() % 9)
		
	var tween = get_tree().create_tween()
	# Flash each button in sequence
	for idx in sequence:
		tween.tween_callback(func(): buttons[idx].modulate = Color(0, 1, 1, 1))
		tween.tween_interval(0.3)
		tween.tween_callback(func(): buttons[idx].modulate = Color(1, 1, 1, 1))
		tween.tween_interval(0.1)
		
	tween.tween_callback(func(): 
		feedback_label.text = "Repeat the sequence."
		for b in buttons: b.disabled = false
	)

func _on_btn_pressed(idx: int):
	if sequence[player_step] == idx:
		player_step += 1
		if player_step >= sequence.size():
			feedback_label.text = "SUCCESS! SLINGSHOT INITIATED!"
			SessionTracker.record_spike_result("spatial_recall", true)
			for b in buttons: b.disabled = true
			await get_tree().create_timer(0.5).timeout
			completed.emit()
			queue_free()
	else:
		SessionTracker.record_spike_result("spatial_recall", false)
		feedback_label.text = "ERROR! Watch again."
		player_step = 0
		for b in buttons: b.disabled = true
		_play_sequence()
