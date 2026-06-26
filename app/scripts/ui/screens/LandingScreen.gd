extends CanvasLayer

signal play_requested
signal profile_requested
signal discover_requested

func _ready():
	print("BUTTON READY: BtnPlay")
	
	var kernel = InteractionKernel if InteractionKernel else get_tree().root.get_node_or_null("InteractionKernel")
	if kernel: kernel.register_panel($Panel, "main_menu", kernel.UIState.MODAL_ACTIVE)
	
	$Panel/VBoxContainer/BtnPlay.pressed.connect(_on_play_pressed)
	$Panel/VBoxContainer/BtnProfile.pressed.connect(_on_profile_pressed)
	$Panel/VBoxContainer/BtnDiscover.pressed.connect(_on_discover_pressed)
	
	$Panel/VBoxContainer/BtnPlay.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed:
			print("GUI INPUT CLICK: BtnPlay")
			var k = InteractionKernel if InteractionKernel else get_tree().root.get_node_or_null("InteractionKernel")
			if k and not k.consume_provenance("BtnPlay", event): return
			if k: k.commit_intent({"type": "enter_stream"})
			else: play_requested.emit()
	)
	
	_check_directors_pass_status()

func _on_play_pressed():
	print("SIGNAL PRESSED: BtnPlay")
	print("BUTTON PRESSED: BtnPlay")
	var kernel = InteractionKernel if InteractionKernel else get_tree().root.get_node_or_null("InteractionKernel")
	if kernel and not kernel.consume_provenance("BtnPlay", null): return
	if kernel: kernel.commit_intent({"type": "enter_stream"})
	else: play_requested.emit()

func _on_profile_pressed():
	print("SIGNAL PRESSED: BtnProfile")
	print("BUTTON PRESSED: BtnProfile")
	var kernel = InteractionKernel if InteractionKernel else get_tree().root.get_node_or_null("InteractionKernel")
	if kernel and not kernel.consume_provenance("BtnProfile", null): return
	if kernel: kernel.commit_intent({"type": "toggle_utility", "utility_id": "mirror"})
	else: profile_requested.emit()

func _on_discover_pressed():
	print("SIGNAL PRESSED: BtnDiscover")
	print("BUTTON PRESSED: BtnDiscover")
	var kernel = InteractionKernel if InteractionKernel else get_tree().root.get_node_or_null("InteractionKernel")
	if kernel and not kernel.consume_provenance("BtnDiscover", null): return
	if kernel: kernel.commit_intent({"type": "scene_shift", "target": "WeeklyFeaturedScreen"})
	else: discover_requested.emit()

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
	var kernel = InteractionKernel if InteractionKernel else get_tree().root.get_node_or_null("InteractionKernel")
	if kernel and not kernel.consume_provenance("BtnDirectorsPass", null): return
	var gate_scene = preload("res://scenes/ui/screens/MonetizationGate.tscn")
	var gate = gate_scene.instantiate()
	var modal_mgr = ModalWindowManager if ModalWindowManager else get_tree().root.get_node_or_null("ModalWindowManager")
	if modal_mgr: modal_mgr.push_modal(gate, true)
	else: add_child(gate)
	
	gate.setup_directors_pass()
	gate.purchase_completed.connect(func():
		if modal_mgr: modal_mgr.pop_modal(gate)
		for child in $Panel/VBoxContainer.get_children():
			if child is Button and child.text == "★ DIRECTOR'S PASS":
				child.queue_free()
	)

func hide_screen():
	if AdManager: AdManager.hide_banner()
	print("[INTERACTION DESIGN] Initiating 500ms Transitional Alpha Masking window. Hitboxes visually present but input suppressed.")
	var kernel = InteractionKernel if InteractionKernel else get_tree().root.get_node_or_null("InteractionKernel")
	if kernel: kernel.begin_transition($Panel, "main_menu")
	var tween = get_tree().create_tween()
	if tween:
		tween.tween_property($Panel, "modulate:a", 0.0, 0.5)
		tween.tween_callback(func():
			if kernel: kernel.end_transition($Panel, kernel.UIState.HIDDEN, "main_menu")
			print("[INTERACTION DESIGN] Alpha Masking complete. Visual incoherence window closed.")
		)

func show_screen():
	if AdManager: AdManager.show_banner()
	var kernel = InteractionKernel if InteractionKernel else get_tree().root.get_node_or_null("InteractionKernel")
	if kernel: kernel.begin_transition($Panel, "main_menu")
	var tween = get_tree().create_tween()
	if tween:
		tween.tween_property($Panel, "modulate:a", 1.0, 0.5)
		tween.tween_callback(func():
			if kernel: kernel.end_transition($Panel, kernel.UIState.MODAL_ACTIVE, "main_menu")
		)
