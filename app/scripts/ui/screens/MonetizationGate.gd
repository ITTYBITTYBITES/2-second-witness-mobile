extends CanvasLayer

signal purchase_completed

@onready var title_label = $PanelContainer/MarginContainer/VBoxContainer/Title
@onready var subtitle_label = $PanelContainer/MarginContainer/VBoxContainer/Subtitle
@onready var btn_buy = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/BtnBuy
@onready var btn_cancel = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/BtnCancel

var target_item_id: String = ""

func setup_universe_unlock(universe_id: String):
	target_item_id = StoreManager.PRODUCT_UNIVERSE_UNLOCK + universe_id if StoreManager else "universe_unlock_" + universe_id
	var pretty_name = universe_id.capitalize().replace("_", " ")
	if title_label: title_label.text = "Unlock " + pretty_name
	if subtitle_label: subtitle_label.text = "Universe Preview: Explore advanced observation mechanics, 12+ dedicated worlds, and rich pattern profiling.\n\nIncludes permanent access to all existing and future scenarios in this universe."
	if btn_buy: btn_buy.text = "PURCHASE ($2.99)"
	if btn_cancel: btn_cancel.text = "CONTINUE FREE"
	_apply_universe_manifest(universe_id)

func setup(universe_id: String):
	setup_universe_unlock(universe_id)

func setup_directors_pass():
	target_item_id = StoreManager.PRODUCT_DIRECTORS_PASS if StoreManager else "directors_pass"
	if title_label:
		title_label.text = "The Director's Pass"
		title_label.add_theme_color_override("font_color", Color(0.968, 0.145, 0.521))
	if subtitle_label: subtitle_label.text = "Permanently remove all interstitial and forced advertisements from the experience.\n\n$7.99"
	if btn_buy: btn_buy.text = "PURCHASE ($7.99)"
	if btn_cancel: btn_cancel.text = "CONTINUE FREE"

func _apply_universe_manifest(universe_id: String):
	var u_manifest_path = "res://universes/" + universe_id + "/universe.json"
	if FileAccess.file_exists(u_manifest_path):
		var file = FileAccess.open(u_manifest_path, FileAccess.READ)
		if file:
			var json = JSON.new()
			if json.parse(file.get_as_text()) == OK:
				var _data = json.get_data()
				var local_reg = UniverseRegistry.new()
				
				var banner_key = "banner_" + universe_id
				var banner_path = local_reg.get_physical_path(banner_key)
				print("[THEME INTEGRATION] MonetizationGate successfully resolved manifest banner: ", banner_path)
				
				var renderer = UniverseRenderer.new()
				var def = renderer.universe_definitions.get(universe_id, renderer.universe_definitions["science_lab"])
				var bg = get_node_or_null("ColorRect")
				if bg and bg is ColorRect:
					bg.color = def["palette"]["bg"]
					bg.color.a = 0.15 # Preserve persistent animated TunnelLayer outer frame visibility
					print("[THEME INTEGRATION] Applied universe background color to MonetizationGate: ", bg.color)
					
				var panel = get_node_or_null("PanelContainer")
				if panel and panel.has_theme_stylebox_override("panel"):
					var sb = panel.get_theme_stylebox("panel").duplicate()
					sb.bg_color = def["palette"]["bg"]
					sb.bg_color.a = 0.95
					panel.add_theme_stylebox_override("panel", sb)
					
				if title_label:
					title_label.add_theme_color_override("font_color", def["palette"]["primary"])
					
				if not u_reg: local_reg.free()
			file.close()

func _ready():
	StyleInjector.apply_menu_style(self)
	if btn_buy: btn_buy.pressed.connect(_on_buy)
	if btn_cancel:
		btn_cancel.text = "CONTINUE FREE"
		btn_cancel.pressed.connect(func():
			var modal_mgr = ModalWindowManager if ModalWindowManager else get_tree().root.get_node_or_null("ModalWindowManager")
			if modal_mgr: modal_mgr.pop_modal(self, "MonetizationGate")
		)
	
	var bg = get_node_or_null("ColorRect")
	if bg: bg.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed:
			print("[MONETIZATION GATE] Background clicked. Continuing free.")
			if AudioManager: AudioManager.play_sfx("ui_click")
			var modal_mgr = ModalWindowManager if ModalWindowManager else get_tree().root.get_node_or_null("ModalWindowManager")
			if modal_mgr: modal_mgr.pop_modal(self, "MonetizationGate")
	)

func _on_buy():
	if btn_buy:
		btn_buy.disabled = true
		btn_buy.text = "PROCESSING..."
	
	var store = StoreManager if StoreManager else get_tree().root.get_node_or_null("StoreManager")
	if store:
		store.initiate_purchase(target_item_id)
		await store.purchase_completed
	
	if AudioManager: AudioManager.play_sfx("ui_click")
	print("[MONETIZATION GATE] Purchase succeeded. Universe immediately unlocked. Worlds selectable. No restart required.")
	purchase_completed.emit()
	var modal_mgr = ModalWindowManager if ModalWindowManager else get_tree().root.get_node_or_null("ModalWindowManager")
	if modal_mgr: modal_mgr.pop_modal(self, "MonetizationGate")
