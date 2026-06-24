extends CanvasLayer
signal completed

@onready var bg = $VoidBG
@onready var btn_safe = $HBoxContainer/BtnSafe
@onready var btn_risk = $HBoxContainer/BtnRisk
@onready var feedback_label = $FeedbackLabel

var _start_ticks_msec: int = 0
var risk_succeeds: bool = false

func _ready():
	_start_ticks_msec = Time.get_ticks_msec()
	print("[RISK SELECTION] Spike Initiated.")
	feedback_label.text = "Choose your path."
	
	# 70% chance risk succeeds, 30% chance it fails and resets
	risk_succeeds = randf() > 0.3 
	
	btn_safe.pressed.connect(func(): _on_answer(false))
	btn_risk.pressed.connect(func(): _on_answer(true))

func _on_answer(chose_risk: bool):
	var rt_ms = Time.get_ticks_msec() - _start_ticks_msec
	
	if not chose_risk:
		# Safe choice always ejects immediately but records low confidence
		feedback_label.text = "SAFE EJECTION INITIATED."
		PlayerProfile.record_cognitive_event("decision_confidence", "risk_selection", "science_lab", true, rt_ms) # True because it wasn't a "failure"
		SessionTracker.record_spike_result("risk_selection_safe", true)
		_eject()
	else:
		if risk_succeeds:
			feedback_label.text = "RISK REWARDED! SLINGSHOT INITIATED!"
			PlayerProfile.record_cognitive_event("decision_confidence", "risk_selection", "science_lab", true, rt_ms)
			SessionTracker.record_spike_result("risk_selection_risk", true)
			_eject()
		else:
			print("[RISK SELECTION] Error. Resetting.")
			PlayerProfile.record_cognitive_event("decision_confidence", "risk_selection", "science_lab", false, rt_ms)
			SessionTracker.record_spike_result("risk_selection_risk", false)
			feedback_label.text = "RISK FAILED! Try again."

func _eject():
	btn_safe.disabled = true; btn_risk.disabled = true
	await get_tree().create_timer(0.5).timeout
	completed.emit()
	queue_free()
