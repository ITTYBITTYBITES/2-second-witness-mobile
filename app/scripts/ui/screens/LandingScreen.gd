extends CanvasLayer

signal play_requested
signal profile_requested
signal discover_requested

func _ready():
	print("BUTTON READY: BtnPlay")
	
	# Full-screen input absorption delegated entirely to ModalWindowManager (Rule 2)
	$Panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	$Panel/VBoxContainer/BtnPlay.pressed.connect(_on_play_pressed)
	$Panel/VBoxContainer/BtnProfile.pressed.connect(_on_profile_pressed)
	$Panel/VBoxContainer/BtnDiscover.pressed.connect(_on_discover_pressed)
	
	$Panel/VBoxContainer/BtnPlay.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed:
			print("GUI INPUT CLICK: BtnPlay")
	)
	
	_check_directors_pass_status()

func _on_play_pressed():
	print("SIGNAL PRESSED: BtnPlay")
	print("BUTTON PRESSED: BtnPlay")
	play_requested.emit()

func _on_profile_pressed():
	print("SIGNAL PRESSED: BtnProfile")
	print("BUTTON PRESSED: BtnProfile")
	profile_requested.emit()

func _on_discover_pressed():
	print("SIGNAL PRESSED: BtnDiscover")
	print("BUTTON PRESSED: BtnDiscover")
	discover_requested.emit()

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
	if ModalWindowManager: ModalWindowManager.push_modal(gate, true)
	else: add_child(gate)
	
	gate.setup_directors_pass()
	gate.purchase_completed.connect(func():
		if ModalWindowManager: ModalWindowManager.pop_modal(gate)
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
