extends CanvasLayer

signal completed

@onready var bg = $VoidBG
@onready var btn_left = $HBoxContainer/BtnLeft
@onready var btn_center = $HBoxContainer/BtnCenter
@onready var btn_right = $HBoxContainer/BtnRight
@onready var feedback_label = $FeedbackLabel

var sequence = [1, 2, 0] # Center, Right, Left
var current_step = 0

var _start_ticks_msec: int = 0

func _ready():
	_start_ticks_msec = Time.get_ticks_msec()
	print("[MEMORY CASCADE] Entering the Void. Spike Initiated.")
	
	# Apply Semantic UI Styling
	var resolver = ThemeResolver.new()
	var style = resolver.resolve_theme({"universe": "science_lab", "type": "memory_cascade", "difficulty": 2})
	StyleInjector.apply(style, self)
	feedback_label.text = "Sequence: Center -> Right -> Left"
	
	btn_left.pressed.connect(func(): _on_btn_pressed(0))
	btn_center.pressed.connect(func(): _on_btn_pressed(1))
	btn_right.pressed.connect(func(): _on_btn_pressed(2))

func _on_btn_pressed(val: int):
	if sequence[current_step] == val:
		current_step += 1
		feedback_label.text = "Hit: " + str(current_step) + "/3"
		if current_step >= sequence.size():
			print("[MEMORY CASCADE] Sequence Complete. Ejecting!")
			feedback_label.text = "SUCCESS! SLINGSHOT INITIATED!"
			
			var rt_ms = Time.get_ticks_msec() - _start_ticks_msec
			PlayerProfile.record_cognitive_event("recall", "memory_cascade", "science_lab", true, rt_ms)
			SessionTracker.record_spike_result("memory_cascade", true)
			
			await get_tree().create_timer(0.5).timeout
			completed.emit()
			queue_free()
	else:
		print("[MEMORY CASCADE] Error. Resetting.")
		feedback_label.text = "ERROR! Resetting."
		var rt_ms = Time.get_ticks_msec() - _start_ticks_msec
		PlayerProfile.record_cognitive_event("recall", "memory_cascade", "science_lab", false, rt_ms)
		SessionTracker.record_spike_result("memory_cascade", false)
		current_step = 0
