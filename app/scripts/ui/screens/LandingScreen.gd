extends CanvasLayer

signal play_requested
signal profile_requested
signal discover_requested
signal settings_requested

func _ready():
	print("BUTTON READY: BtnPlay")
	StyleInjector.apply_menu_style(self)
	
	var kernel = InteractionKernel if InteractionKernel else get_tree().root.get_node_or_null("InteractionKernel")
	if kernel: kernel.register_panel($Panel, "main_menu", kernel.UIState.MODAL_ACTIVE)
	
	var btn_play = $Panel/VBoxContainer/BtnPlay
	var btn_discover = $Panel/VBoxContainer/BtnDiscover
	var btn_profile = $Panel/VBoxContainer/BtnProfile
	var btn_settings = $Panel/VBoxContainer/BtnSettings
	
	btn_play.text = "BEGIN"
	btn_discover.text = "DISCOVER"
	btn_profile.text = "MIRROR"
	btn_settings.text = "SETTINGS"
	
	btn_play.pressed.connect(_on_play_pressed)
	btn_profile.pressed.connect(_on_profile_pressed)
	btn_discover.pressed.connect(_on_discover_pressed)
	btn_settings.pressed.connect(_on_settings_pressed)
	
	btn_play.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed:
			print("GUI INPUT CLICK: BtnPlay")
			var k = InteractionKernel if InteractionKernel else get_tree().root.get_node_or_null("InteractionKernel")
			if k and not k.consume_provenance("BtnPlay", event): return
			if k: k.commit_intent({"type": "enter_stream"})
			else: play_requested.emit()
	)
	
	var footer = $Panel/FooterContainer
	if footer:
		var btn_privacy = footer.get_node_or_null("BtnPrivacy")
		var btn_version = footer.get_node_or_null("BtnVersion")
		var btn_restore = footer.get_node_or_null("BtnRestore")
		if btn_privacy: btn_privacy.pressed.connect(func(): print("[PRIVACY] 2 Second Witness gathers observations strictly on device. Zero external tracking."))
		if btn_version: btn_version.pressed.connect(func(): print("[VERSION] Version 1.0.0 (Godot 4.6.3 Engine Governing Substrate)"))
		if btn_restore: btn_restore.pressed.connect(func():
			print("[RESTORE PURCHASES] Querying event-sourced transaction ledger...")
			var profile = PlayerProfile if PlayerProfile else get_tree().root.get_node_or_null("PlayerProfile")
			if profile and profile.has_method("evaluate_entitlements"): profile.evaluate_entitlements()
			print("[RESTORE PURCHASES] Entitlements rehydrated successfully.")
		)
	
	_check_directors_pass_status()
	_check_returning_user_welcome()

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

func _on_settings_pressed():
	print("SIGNAL PRESSED: BtnSettings")
	print("BUTTON PRESSED: BtnSettings")
	var kernel = InteractionKernel if InteractionKernel else get_tree().root.get_node_or_null("InteractionKernel")
	if kernel and not kernel.consume_provenance("BtnSettings", null): return
	if kernel: kernel.commit_intent({"type": "toggle_utility", "utility_id": "settings"})
	else: settings_requested.emit()

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

func _check_returning_user_welcome():
	var profile = get_node_or_null("/root/PlayerProfile")
	if profile and profile.lifetime_sessions > 1:
		var welcome_lbl = Label.new()
		welcome_lbl.text = "Welcome back.\nTwo new History worlds have been added."
		welcome_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		welcome_lbl.add_theme_color_override("font_color", Color(0.85, 0.95, 1.0))
		welcome_lbl.add_theme_font_size_override("font_size", 20)
		$Panel/VBoxContainer.add_child(welcome_lbl)
	else:
		var onboard_lbl = Label.new()
		onboard_lbl.text = "WELCOME TO 2 SECOND WITNESS\nTest your cognitive speed and visual recall across 6 weekly featured Universes.\nTap BEGIN to enter the stream or DISCOVER to select a World."
		onboard_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		onboard_lbl.add_theme_color_override("font_color", Color(0.298, 0.788, 0.941))
		onboard_lbl.add_theme_font_size_override("font_size", 18)
		$Panel/VBoxContainer.add_child(onboard_lbl)
		$Panel/VBoxContainer.move_child(onboard_lbl, 0)

func _show_directors_pass_gate():
	var kernel = InteractionKernel if InteractionKernel else get_tree().root.get_node_or_null("InteractionKernel")
	if kernel and not kernel.consume_provenance("BtnDirectorsPass", null): return
	var gate_scene = preload("res://scenes/ui/screens/MonetizationGate.tscn")
	var gate = gate_scene.instantiate()
	var modal_mgr = ModalWindowManager if ModalWindowManager else get_tree().root.get_node_or_null("ModalWindowManager")
	if modal_mgr: modal_mgr.push_modal(gate, true, "LandingScreen")
	else: add_child(gate)
	
	gate.setup_directors_pass()
	gate.purchase_completed.connect(func():
		if modal_mgr: modal_mgr.pop_modal(gate, "MonetizationGate")
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
