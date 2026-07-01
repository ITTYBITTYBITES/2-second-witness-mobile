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
	var vim = VisualIdentityManager if VisualIdentityManager else get_tree().root.get_node_or_null("VisualIdentityManager")
	if vim and vim.has_method("apply_screen_identity"):
		vim.apply_screen_identity(self, universe_id, "", true)
	else:
		var bg = get_node_or_null("ColorRect")
		if bg and bg is ColorRect: bg.color = Color(0.04, 0.07, 0.12, 0.15)

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
