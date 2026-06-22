extends CanvasLayer
signal completed

@onready var equation_label = $EquationLabel
@onready var btn_true = $HBoxContainer/BtnTrue
@onready var btn_false = $HBoxContainer/BtnFalse
@onready var feedback_label = $FeedbackLabel

var is_correct_equation: bool = true

func _ready():
	print("[MATH SURPRISE] Spike Initiated.")
	feedback_label.text = ""
	
	# Generate simple math equation
	var num1 = randi() % 10 + 1
	var num2 = randi() % 10 + 1
	var actual_sum = num1 + num2
	var displayed_sum = actual_sum
	
	if randf() > 0.5:
		is_correct_equation = false
		displayed_sum += (randi() % 3 + 1) * (1 if randf() > 0.5 else -1)
		
	equation_label.text = str(num1) + " + " + str(num2) + " = " + str(displayed_sum)
	
	btn_true.pressed.connect(func(): _on_answer(true))
	btn_false.pressed.connect(func(): _on_answer(false))

func _on_answer(chose_true: bool):
	if chose_true == is_correct_equation:
		print("[MATH SURPRISE] Success. Ejecting!")
		feedback_label.text = "SUCCESS! SLINGSHOT INITIATED!"
		SessionTracker.record_spike_result("math_surprise", true)
		
		btn_true.disabled = true
		btn_false.disabled = true
		
		await get_tree().create_timer(0.5).timeout
		completed.emit()
		queue_free()
	else:
		print("[MATH SURPRISE] Error. Resetting.")
		feedback_label.text = "ERROR! Try again."
		SessionTracker.record_spike_result("math_surprise", false)
