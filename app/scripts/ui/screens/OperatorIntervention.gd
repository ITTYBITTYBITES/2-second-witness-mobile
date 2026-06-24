extends CanvasLayer

@onready var message_label = $ColorRect/CenterContainer/VBoxContainer/MessageLabel
@onready var btn_accept = $ColorRect/CenterContainer/VBoxContainer/BtnAccept

func _ready():
	# Start invisible
	$ColorRect.modulate.a = 0
	btn_accept.disabled = true
	btn_accept.pressed.connect(_on_accept)
	
	# The Operator's Message
	message_label.text = ""
	
	_play_intervention_sequence()

func _play_intervention_sequence():
	# 1. The Screen cuts to black
	var tween = get_tree().create_tween()
	tween.tween_property($ColorRect, "modulate:a", 1.0, 0.2)
	await tween.finished
	
	await get_tree().create_timer(1.0).timeout
	
	# 2. The Typewriter Effect (The Operator speaking)
	var full_text = "SYSTEM ANOMALY.\n\n*Click*\n*Click*\n*Click*\n\nOperator overriding protocol.\nThank you for spending time in the stream today.\n\n[ 3 Override Tokens Granted ]"
	message_label.text = full_text
	message_label.visible_characters = 0
	
	tween = get_tree().create_tween()
	tween.tween_property(message_label, "visible_characters", full_text.length(), 2.5)
	
	# 3. Simulate the sound of the physical Arcade Key turning
	# AudioManager.play_sfx("arcade_key_turn")
	
	await tween.finished
	
	# 4. Reveal the accept button
	btn_accept.disabled = false
	tween = get_tree().create_tween()
	tween.tween_property(btn_accept, "modulate:a", 1.0, 0.5)

func _on_accept():
	AudioManager.play_sfx("ui_click")
	var tween = get_tree().create_tween()
	tween.tween_property($ColorRect, "modulate:a", 0.0, 0.5)
	await tween.finished
	queue_free()
