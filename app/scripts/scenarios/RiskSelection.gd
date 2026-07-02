extends BaseScenario
signal completed

@onready var bg = $VoidBG
@onready var btn_safe = $HBoxContainer/BtnSafe
@onready var btn_risk = $HBoxContainer/BtnRisk
@onready var feedback_label = $FeedbackLabel

var _scenario_id: String = "risk_selection"
var _start_ticks_msec: int = 0
var risk_succeeds: bool = false

func _apply_specific_rules(rules: Dictionary):
	_scenario_id = _scenario_payload["id"]

func _ready():
	if _scenario_payload.is_empty():
		push_error("[SCENARIO FATAL] Scene loaded without payload injection.")
		queue_free()
		return
		
	_start_ticks_msec = Time.get_ticks_msec()
	print("[RISK SELECTION] Spike Initiated.")
	feedback_label.text = "Choose your path."
	
	risk_succeeds = _deterministic_rng.randf() > 0.3 
	
	btn_safe.pressed.connect(func(): _on_answer(false))
	btn_risk.pressed.connect(func(): _on_answer(true))
	
	execute_render_pipeline()

func _on_answer(chose_risk: bool):
	var rt_ms = Time.get_ticks_msec() - _start_ticks_msec
	
	if not chose_risk:
		feedback_label.text = "SAFE EJECTION INITIATED."
		btn_safe.disabled = true; btn_risk.disabled = true
		execute_progression_event(true, rt_ms, "decision_confidence")
	else:
		if risk_succeeds:
			feedback_label.text = "RISK REWARDED! OBSERVATION VERIFIED!"
			btn_safe.disabled = true; btn_risk.disabled = true
			execute_progression_event(true, rt_ms, "decision_confidence")
		else:
			print("[RISK SELECTION] Error. Resetting.")
			if AudioManager: AudioManager.play_sfx("ui_error")
			feedback_label.text = "RISK FAILED! Resetting..."
			btn_safe.disabled = true; btn_risk.disabled = true
			execute_progression_event(false, rt_ms, "decision_confidence")

func _eject():
	btn_safe.disabled = true; btn_risk.disabled = true
	await get_tree().create_timer(0.5).timeout
	completed.emit()
	queue_free()
