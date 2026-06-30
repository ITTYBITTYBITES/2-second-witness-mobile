extends CanvasLayer

signal return_requested

@onready var btn_close = $PanelContainer/MarginContainer/VBoxContainer/BtnClose
@onready var grid = $PanelContainer/MarginContainer/VBoxContainer/GridContainer

func _ready():
	print("[SETTINGS] Settings modal active. Applying non-game platform preferences.")
	
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
				print("[SETTINGS ACTION] Toggled preference: ", child.text)
				if child.text == "Restore Purchases":
					var profile = PlayerProfile if PlayerProfile else get_tree().root.get_node_or_null("PlayerProfile")
					if profile and profile.has_method("evaluate_entitlements"):
						profile.evaluate_entitlements()
						print("[RESTORE PURCHASES] Entitlements rehydrated successfully.")
			)

func _apply_universe_manifest(universe_id: String):
	var u_manifest_path = "res://universes/" + universe_id + "/universe.json"
	if FileAccess.file_exists(u_manifest_path):
		var file = FileAccess.open(u_manifest_path, FileAccess.READ)
		if file:
			var json = JSON.new()
			if json.parse(file.get_as_text()) == OK:
				var data = json.get_data()
				var u_reg = UniverseRegistry if UniverseRegistry else get_tree().root.get_node_or_null("UniverseRegistry")
				var local_reg = load("res://scripts/ui/UniverseRegistry.gd").new() if not u_reg else u_reg
				
				var banner_key = "banner_" + universe_id
				var banner_path = local_reg.get_physical_path(banner_key)
				print("[THEME INTEGRATION] SettingsScreen successfully resolved manifest banner: ", banner_path)
				
				var renderer = UniverseRenderer.new()
				var def = renderer.universe_definitions.get(universe_id, renderer.universe_definitions["science_lab"])
				var bg = get_node_or_null("ColorRect")
				if bg and bg is ColorRect:
					bg.color = def["palette"]["bg"]
					print("[THEME INTEGRATION] Applied universe background color to SettingsScreen: ", bg.color)
					
				var title_label = get_node_or_null("PanelContainer/MarginContainer/VBoxContainer/Title")
				if title_label:
					title_label.add_theme_color_override("font_color", def["palette"]["primary"])
					
				if not u_reg: local_reg.free()
			file.close()
