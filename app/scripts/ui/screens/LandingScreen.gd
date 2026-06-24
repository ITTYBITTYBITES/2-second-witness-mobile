extends CanvasLayer

signal play_requested
signal profile_requested
signal discover_requested

func _ready():
	$Panel/VBoxContainer/BtnPlay.pressed.connect(func(): play_requested.emit())
	$Panel/VBoxContainer/BtnProfile.pressed.connect(func(): profile_requested.emit())
	$Panel/VBoxContainer/BtnDiscover.pressed.connect(func(): discover_requested.emit())

func hide_screen():
	var tween = get_tree().create_tween()
	tween.tween_property($Panel, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): visible = false)

func show_screen():
	visible = true
	var tween = get_tree().create_tween()
	tween.tween_property($Panel, "modulate:a", 1.0, 0.5)
