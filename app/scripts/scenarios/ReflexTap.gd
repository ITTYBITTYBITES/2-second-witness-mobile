extends CanvasLayer
signal completed

@onready var feedback_label = $FeedbackLabel
@onready var target_btn = $TargetBtn

func _ready():
	feedback_label.text = "Get ready..."
	target_btn.visible = false
	target_btn.pressed.connect(_on_tap)
	
	var tween = get_tree().create_tween()
	var delay = randf_range(0.5, 2.0)
	tween.tween_interval(delay)
	tween.tween_callback(func():
		var x = randf_range(100, 800)
		var y = randf_range(100, 500)
		target_btn.position = Vector2(x, y)
		target_btn.visible = true
		feedback_label.text = "TAP!"
	)

func _on_tap():
	target_btn.visible = false
	feedback_label.text = "SUCCESS! SLINGSHOT INITIATED!"
	SessionTracker.record_spike_result("reflex_tap", true)
	await get_tree().create_timer(0.5).timeout
	completed.emit()
	queue_free()
