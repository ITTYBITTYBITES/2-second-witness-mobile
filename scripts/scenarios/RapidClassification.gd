extends CanvasLayer

signal completed

@onready var bg = $VoidBG
@onready var target_label = $TargetLabel
@onready var btn_organic = $HBoxContainer/BtnOrganic
@onready var btn_mechanical = $HBoxContainer/BtnMechanical
@onready var feedback_label = $FeedbackLabel

var target_is_organic: bool = true

func _ready():
	print("[RAPID CLASSIFICATION] Spike Initiated.")
	feedback_label.text = ""
	
	# Randomize target
	if randf() > 0.5:
		target_label.text = "TREE"
		target_is_organic = true
	else:
		target_label.text = "GEAR"
		target_is_organic = false
		
	btn_organic.pressed.connect(func(): _on_answer(true))
	btn_mechanical.pressed.connect(func(): _on_answer(false))
	
	# Flash the word briefly
	var tween = get_tree().create_tween()
	tween.tween_property(target_label, "modulate:a", 1.0, 0.1)
	tween.tween_interval(0.5) # Visible for 500ms
	tween.tween_property(target_label, "modulate:a", 0.0, 0.1)

func _on_answer(chose_organic: bool):
	if chose_organic == target_is_organic:
		print("[RAPID CLASSIFICATION] Success. Ejecting!")
		feedback_label.text = "SUCCESS! SLINGSHOT INITIATED!"
		
		btn_organic.disabled = true
		btn_mechanical.disabled = true
		
		await get_tree().create_timer(0.5).timeout
		completed.emit()
		queue_free()
	else:
		print("[RAPID CLASSIFICATION] Error. Resetting.")
		feedback_label.text = "ERROR! Try again."
