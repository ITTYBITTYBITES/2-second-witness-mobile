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
	subtitle_label.text = "Unlock all Universes instantly. Gain access to the exclusive Golden Astrolabe Cockpit Lens.\n\n$7.99"
	btn_buy.text = "GET PASS ($7.99)"

func _ready():
	btn_buy.pressed.connect(_on_buy)
	btn_cancel.pressed.connect(func(): queue_free())

func _on_buy():
	btn_buy.disabled = true
	btn_buy.text = "PROCESSING..."
	
	StoreManager.initiate_purchase(target_item_id)
	await StoreManager.purchase_completed
	
	AudioManager.play_sfx("ui_click")
	purchase_completed.emit()
	queue_free()
