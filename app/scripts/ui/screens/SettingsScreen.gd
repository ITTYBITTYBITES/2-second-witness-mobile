extends CanvasLayer

signal return_requested

@onready var btn_close = $PanelContainer/MarginContainer/VBoxContainer/BtnClose
@onready var grid = $PanelContainer/MarginContainer/VBoxContainer/GridContainer

func _ready():
	print("[SETTINGS] Settings modal active. Applying non-game platform preferences.")
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
				print("[SETTINGS ACTION] Toggled preference: ", child.text)
				if child.text == "Restore Purchases":
					var profile = PlayerProfile if PlayerProfile else get_tree().root.get_node_or_null("PlayerProfile")
					if profile and profile.has_method("evaluate_entitlements"):
						profile.evaluate_entitlements()
						print("[RESTORE PURCHASES] Entitlements rehydrated successfully.")
			)
