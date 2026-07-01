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
		PlayerProfile.record_cognitive_event("decision_confidence", _scenario_id, _scenario_payload.get("universe", "history"), _scenario_payload.get("world", "ancient_egypt"), true, rt_ms)
		SessionTracker.record_spike_result("risk_selection_safe", true)
		_eject()
	else:
		if risk_succeeds:
			feedback_label.text = "RISK REWARDED! SLINGSHOT INITIATED!"
			PlayerProfile.record_cognitive_event("decision_confidence", _scenario_id, _scenario_payload.get("universe", "history"), _scenario_payload.get("world", "ancient_egypt"), true, rt_ms)
			SessionTracker.record_spike_result("risk_selection_risk", true)
			_eject()
		else:
			print("[RISK SELECTION] Error. Resetting.")
			if AudioManager: AudioManager.play_sfx("ui_error")
			PlayerProfile.record_cognitive_event("decision_confidence", _scenario_id, _scenario_payload.get("universe", "history"), _scenario_payload.get("world", "ancient_egypt"), false, rt_ms)
			SessionTracker.record_spike_result("risk_selection_risk", false)
			feedback_label.text = "RISK FAILED! Resetting..."
			btn_safe.disabled = true; btn_risk.disabled = true
			await get_tree().create_timer(0.5).timeout
			if is_inside_tree():
				btn_safe.disabled = false; btn_risk.disabled = false
				feedback_label.text = "Choose your path."
				risk_succeeds = _deterministic_rng.randf() > 0.3
				_start_ticks_msec = Time.get_ticks_msec()

func _eject():
	btn_safe.disabled = true; btn_risk.disabled = true
	await get_tree().create_timer(0.5).timeout
	completed.emit()
	queue_free()
