extends CanvasLayer

signal purchase_completed

@onready var title_label = $PanelContainer/MarginContainer/VBoxContainer/Title
@onready var btn_buy = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/BtnBuy
@onready var btn_cancel = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/BtnCancel

var target_universe: String = ""

func setup(universe_id: String):
	target_universe = universe_id
	var pretty_name = universe_id.capitalize().replace("_", " ")
	title_label.text = "Unlock " + pretty_name + "?"

func _ready():
	btn_buy.pressed.connect(_on_buy)
	btn_cancel.pressed.connect(func(): queue_free())

func _on_buy():
	print("[MONETIZATION] Simulating Purchase Success for: ", target_universe)
	AudioManager.play_sfx("ui_click")
	purchase_completed.emit()
	queue_free()
