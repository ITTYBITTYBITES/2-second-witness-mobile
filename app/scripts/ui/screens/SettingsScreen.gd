extends CanvasLayer

signal return_requested

@onready var btn_close = $PanelContainer/MarginContainer/VBoxContainer/BtnClose
@onready var grid = $PanelContainer/MarginContainer/VBoxContainer/GridContainer

var _audio_level: int = 2
var _privacy_mode: int = 0
var _telemetry: bool = false

func _ready():
	print("[SETTINGS] Settings modal active. Applying non-game platform preferences.")
	StyleInjector.apply_menu_style(self)
	
	var nav = get_node_or_null("/root/NavigationRouter")
	var uni = nav.active_universe_selection if nav else "history"
	_apply_universe_manifest(uni)
	
	btn_close.pressed.connect(func():
		if AudioManager: AudioManager.play_sfx("ui_click")
		var modal_mgr = ModalWindowManager if ModalWindowManager else get_tree().root.get_node_or_null("ModalWindowManager")
		if modal_mgr: modal_mgr.pop_modal(self, "SettingsScreen")
		return_requested.emit()
	)
	
	var bg = get_node_or_null("ColorRect")
	if bg: bg.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed:
			print("[SETTINGS] Background clicked. Closing settings.")
			if AudioManager: AudioManager.play_sfx("ui_click")
			var modal_mgr = ModalWindowManager if ModalWindowManager else get_tree().root.get_node_or_null("ModalWindowManager")
			if modal_mgr: modal_mgr.pop_modal(self, "SettingsScreen")
			return_requested.emit()
	)
	
	for child in grid.get_children():
		if child is Button:
			child.pressed.connect(func():
				if AudioManager: AudioManager.play_sfx("ui_click")
				var txt = child.text
				print("[SETTINGS ACTION] Interacted with: ", txt)
				if txt.begins_with("Theme:"):
					var rot_mgr = WeeklyRotationManager if WeeklyRotationManager else get_tree().root.get_node_or_null("WeeklyRotationManager")
					var reg = ContentRegistry if ContentRegistry else get_tree().root.get_node_or_null("ContentRegistry")
					var themes = rot_mgr.get_full_universe_library() if (rot_mgr and rot_mgr.has_method("get_full_universe_library")) else (reg.get_all_universes() if (reg and reg.has_method("get_all_universes") and not reg.get_all_universes().is_empty()) else ["science_lab", "history", "tech_ops", "life_sciences", "creative_arts", "society_mind", "frontier"])
					var cur = ThemeManager.active_theme_id if ThemeManager and ThemeManager.active_theme_id != "" else "science_lab"
					var idx = (themes.find(cur) + 1) % themes.size()
					var next_theme = themes[idx]
					if ThemeManager: ThemeManager.apply_theme(next_theme)
					child.text = "Theme: " + next_theme.capitalize().replace("_", " ")
					_apply_universe_manifest(next_theme)
				elif txt.begins_with("Accessibility:"):
					var profile = PlayerProfile if PlayerProfile else get_tree().root.get_node_or_null("PlayerProfile")
					if profile:
						profile.motor_assist_enabled = not profile.motor_assist_enabled
						profile.colorblind_mode_enabled = profile.motor_assist_enabled
						profile.save_profile()
						child.text = "Accessibility: " + ("ON" if profile.motor_assist_enabled else "OFF")
						print("[SETTINGS] Accessibility motor assist set to: ", profile.motor_assist_enabled)
				elif txt.begins_with("Audio:"):
					_audio_level = (_audio_level + 1) % 3
					var db = 0.0 if _audio_level == 2 else (-6.0 if _audio_level == 1 else -80.0)
					AudioServer.set_bus_volume_db(0, db)
					AudioServer.set_bus_mute(0, _audio_level == 0)
					child.text = "Audio: Master " + ("100%" if _audio_level == 2 else ("50%" if _audio_level == 1 else "MUTE"))
					print("[SETTINGS] Master audio bus set to: ", db, " dB")
				elif txt.begins_with("Privacy:"):
					_privacy_mode = (_privacy_mode + 1) % 2
					child.text = "Privacy: " + ("Local Only" if _privacy_mode == 0 else "Anonymized Uplink")
					if StructuredLogger: StructuredLogger.log_event_trace(self, "privacy_changed", "Privacy mode set to " + child.text)
				elif txt.begins_with("Telemetry:"):
					_telemetry = not _telemetry
					child.text = "Telemetry: " + ("ON" if _telemetry else "OFF")
					print("[SETTINGS] Diagnostic telemetry set to: ", _telemetry)
				elif txt.begins_with("Export Data") or txt.begins_with("Exported"):
					var profile = PlayerProfile if PlayerProfile else get_tree().root.get_node_or_null("PlayerProfile")
					if profile:
						var export_str = JSON.stringify(profile.generate_insights(), "\t")
						var file = FileAccess.open("user://exported_profile_data.json", FileAccess.WRITE)
						if file:
							file.store_string(export_str)
							file.close()
							child.text = "Exported to user://"
							print("[SETTINGS] Profile data successfully exported to user://exported_profile_data.json")
				elif txt.begins_with("About"):
					print("[SETTINGS ABOUT] 2 Second Witness v2.0.0 — Liquid Memory Engine.")
					child.text = "v2.0.0 Verified"
				elif txt.begins_with("Restore Purchases"):
					var profile = PlayerProfile if PlayerProfile else get_tree().root.get_node_or_null("PlayerProfile")
					if profile and profile.has_method("evaluate_entitlements"):
						profile.evaluate_entitlements()
						profile.save_profile()
						child.text = "Purchases Restored"
						print("[RESTORE PURCHASES] Entitlements rehydrated successfully.")
				elif txt.begins_with("Support") or txt.begins_with("support@"):
					print("[SETTINGS SUPPORT] Support contact: support@ittybittybites.com")
					child.text = "support@ittybittybites.com"
			)

func _apply_universe_manifest(universe_id: String):
	var vim = VisualIdentityManager if VisualIdentityManager else get_tree().root.get_node_or_null("VisualIdentityManager")
	if vim and vim.has_method("apply_screen_identity"):
		vim.apply_screen_identity(self, universe_id, "", true)
	else:
		var bg = get_node_or_null("ColorRect") if get_node_or_null("ColorRect") else get_node_or_null("VoidBG")
		if bg and bg is ColorRect: bg.color = Color(0.04, 0.07, 0.12, 0.15)
