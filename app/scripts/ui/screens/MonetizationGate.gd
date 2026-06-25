extends CanvasLayer

signal purchase_completed

@onready var title_label = $PanelContainer/MarginContainer/VBoxContainer/Title
@onready var subtitle_label = $PanelContainer/MarginContainer/VBoxContainer/Subtitle
@onready var btn_buy = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/BtnBuy
@onready var btn_cancel = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/BtnCancel

var target_item_id: String = ""

func setup_universe_unlock(universe_id: String):
	target_item_id = StoreManager.PRODUCT_UNIVERSE_UNLOCK + universe_id
	var pretty_name = universe_id.capitalize().replace("_", " ")
	title_label.text = "Unlock " + pretty_name
	subtitle_label.text = "Permanently add this universe to your collection for $2.99."
	btn_buy.text = "UNLOCK ($2.99)"

func setup_directors_pass():
	target_item_id = StoreManager.PRODUCT_DIRECTORS_PASS
	title_label.text = "The Director's Pass"
	title_label.add_theme_color_override("font_color", Color(0.968, 0.145, 0.521))
	subtitle_label.text = "Permanently remove all interstitial and forced advertisements from the experience.\n\n$7.99"
	btn_buy.text = "REMOVE ADS ($7.99)"

func _ready():
	btn_buy.pressed.connect(_on_buy)
	btn_cancel.pressed.connect(func():
		if ModalWindowManager: ModalWindowManager.pop_modal(self)
		queue_free()
	)
	
	$ColorRect.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed:
			print("[MONETIZATION GATE] Background clicked. Closing gate.")
			AudioManager.play_sfx("ui_click")
			if ModalWindowManager: ModalWindowManager.pop_modal(self)
			queue_free()
	)

func _on_buy():
	btn_buy.disabled = true
	btn_buy.text = "PROCESSING..."
	
	StoreManager.initiate_purchase(target_item_id)
	await StoreManager.purchase_completed
	
	AudioManager.play_sfx("ui_click")
	purchase_completed.emit()
	if ModalWindowManager: ModalWindowManager.pop_modal(self)
	queue_free()
