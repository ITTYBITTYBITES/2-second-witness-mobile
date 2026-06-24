extends CanvasLayer

signal play_requested
signal profile_requested
signal discover_requested

func _ready():
	$Panel/VBoxContainer/BtnPlay.pressed.connect(func(): play_requested.emit())
	$Panel/VBoxContainer/BtnProfile.pressed.connect(func(): profile_requested.emit())
	$Panel/VBoxContainer/BtnDiscover.pressed.connect(func(): discover_requested.emit())
	
	# Add the Director's Pass Upsell to the main menu if they don't own it
	_check_directors_pass_status()

func _check_directors_pass_status():
	var profile = get_node_or_null("/root/PlayerProfile")
	if profile and not profile.has_directors_pass:
		var btn_dpass = Button.new()
		btn_dpass.custom_minimum_size = Vector2(0, 60)
		btn_dpass.add_theme_font_size_override("font_size", 20)
		btn_dpass.add_theme_color_override("font_color", Color(0.968, 0.145, 0.521))
		btn_dpass.text = "★ DIRECTOR'S PASS"
		btn_dpass.pressed.connect(_show_directors_pass_gate)
		$Panel/VBoxContainer.add_child(btn_dpass)

func _show_directors_pass_gate():
	var gate_scene = preload("res://scenes/ui/screens/MonetizationGate.tscn")
	var gate = gate_scene.instantiate()
	add_child(gate)
	gate.setup_directors_pass()
	gate.purchase_completed.connect(func():
		# Refresh UI so the button disappears
		for child in $Panel/VBoxContainer.get_children():
			if child is Button and child.text == "★ DIRECTOR'S PASS":
				child.queue_free()
	)

func hide_screen():
	AdManager.hide_banner()
	var tween = get_tree().create_tween()
	tween.tween_property($Panel, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): visible = false)

func show_screen():
	AdManager.show_banner()
	visible = true
	var tween = get_tree().create_tween()
	tween.tween_property($Panel, "modulate:a", 1.0, 0.5)
