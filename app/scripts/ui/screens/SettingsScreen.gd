extends CanvasLayer

signal return_requested

@onready var btn_close = $PanelContainer/MarginContainer/VBoxContainer/BtnClose
@onready var grid = $PanelContainer/MarginContainer/VBoxContainer/GridContainer

var _audio_level: int = 2

func _request_close():
	if AudioManager: AudioManager.play_sfx("ui_click")
	var modal_mgr = ModalWindowManager if ModalWindowManager else get_tree().root.get_node_or_null("ModalWindowManager")
	if modal_mgr:
		modal_mgr.pop_modal(self, "SettingsScreen")
	else:
		return_requested.emit()


func _ready():
	print("[SETTINGS] Settings modal active. Applying non-game platform preferences.")
	StyleInjector.apply_menu_style(self)
	
	var orch = get_tree().root.get_node_or_null("ExperienceOrchestrator")
	var uni = ""
	if orch and orch.get("active_state") != null:
		uni = orch.active_state.current_universe
	if uni == "":
		var registry = get_tree().root.get_node_or_null("ContentRegistry")
		if registry and registry.has_method("get_first_universe"):
			uni = registry.get_first_universe()
	_apply_universe_manifest(uni)
	
	btn_close.pressed.connect(_request_close)
	
	var bg = get_node_or_null("ColorRect")
	if bg: bg.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed:
			print("[SETTINGS] Background clicked. Closing settings.")
			_request_close()
	)
	
	for child in grid.get_children():
		if child is Button:
			child.pressed.connect(func():
				if AudioManager: AudioManager.play_sfx("ui_click")
				var txt = child.text
				print("[SETTINGS ACTION] Interacted with: ", txt)
				if txt.begins_with("Audio:"):
					_audio_level = (_audio_level + 1) % 3
					var db = 0.0 if _audio_level == 2 else (-6.0 if _audio_level == 1 else -80.0)
					AudioServer.set_bus_volume_db(0, db)
					AudioServer.set_bus_mute(0, _audio_level == 0)
					child.text = "Audio: Master " + ("100%" if _audio_level == 2 else ("50%" if _audio_level == 1 else "MUTE"))
					print("[SETTINGS] Master audio bus set to: ", db, " dB")
				elif txt.begins_with("Accessibility:"):
					var profile = PlayerProfile if PlayerProfile else get_tree().root.get_node_or_null("PlayerProfile")
					if profile:
						profile.motor_assist_enabled = not profile.motor_assist_enabled
						profile.colorblind_mode_enabled = profile.motor_assist_enabled
						profile.save_profile()
						child.text = "Accessibility: " + ("Motor & Color Assist ON" if profile.motor_assist_enabled else "Standard Profile")
						print("[SETTINGS] Accessibility profile updated: ", child.text)

			)

func _apply_universe_manifest(universe_id: String):
	var vim = VisualIdentityManager if VisualIdentityManager else get_tree().root.get_node_or_null("VisualIdentityManager")
	if vim and vim.has_method("apply_screen_identity"):
		vim.apply_screen_identity(self, universe_id, "", false)
	else:
		var bg = get_node_or_null("ColorRect") if get_node_or_null("ColorRect") else get_node_or_null("VoidBG")
		if bg and bg is ColorRect: bg.color = Color(0.04, 0.07, 0.12, 0.15)
