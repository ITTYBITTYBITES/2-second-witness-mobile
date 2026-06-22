extends CanvasLayer

signal completed

@onready var bg = $VoidBG
@onready var sequence_label = $SequenceLabel
@onready var btn_a = $HBoxContainer/BtnA
@onready var btn_b = $HBoxContainer/BtnB
@onready var feedback_label = $FeedbackLabel

func _ready():
	print("[PATTERN CONTINUATION] Spike Initiated.")
	sequence_label.text = "⬟  ⬟  ⬢  ⬟  ?"
	feedback_label.text = "Select the next shape"
	
	# '⬢' is Button B, '⬟' is Button A. The pattern implies the next is '⬟' or '⬢'.
	# Let's say the pattern is A, A, B, A, A... so next is A.
	btn_a.text = "⬟"
	btn_b.text = "⬢"
	
	btn_a.pressed.connect(func(): _on_answer(true))  # Correct
	btn_b.pressed.connect(func(): _on_answer(false)) # Incorrect

func _on_answer(is_correct: bool):
	if is_correct:
		print("[PATTERN CONTINUATION] Success. Ejecting!")
		feedback_label.text = "SUCCESS! SLINGSHOT INITIATED!"
		sequence_label.text = "⬟  ⬟  ⬢  ⬟  ⬟"
		
		btn_a.disabled = true
		btn_b.disabled = true
		
		await get_tree().create_timer(0.5).timeout
		completed.emit()
		queue_free()
	else:
		print("[PATTERN CONTINUATION] Error. Resetting.")
		feedback_label.text = "ERROR! Try again."
