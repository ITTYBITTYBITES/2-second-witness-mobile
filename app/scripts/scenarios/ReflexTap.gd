extends BaseScenario
signal completed

@onready var feedback_label = $FeedbackLabel
@onready var target_btn = $TargetBtn

var _scenario_id: String = "reflex_tap"
var _start_ticks_msec: int = 0

func _apply_specific_rules(rules: Dictionary):
	_scenario_id = _scenario_payload["id"]

func _ready():
	if _scenario_payload.is_empty():
		push_error("[SCENARIO FATAL] Scene loaded without payload injection.")
		queue_free()
		return
		
	_start_ticks_msec = Time.get_ticks_msec()
	feedback_label.text = "Get ready..."
	target_btn.visible = false
	target_btn.pressed.connect(_on_tap)
	
	var tween = get_tree().create_tween()
	var delay = _deterministic_rng.randf_range(0.5, 2.0)
	tween.tween_interval(delay)
	tween.tween_callback(func():
		var x = _deterministic_rng.randf_range(100, 800)
		var y = _deterministic_rng.randf_range(100, 500)
		target_btn.position = Vector2(x, y)
		target_btn.visible = true
		feedback_label.text = "TAP!"
	)
	
	execute_render_pipeline()

func _on_tap():
	var rt_ms = Time.get_ticks_msec() - _start_ticks_msec
	target_btn.visible = false
	feedback_label.text = "SUCCESS! SLINGSHOT INITIATED!"
	PlayerProfile.record_cognitive_event("processing_speed", _scenario_id, _scenario_payload.get("universe", "history"), _scenario_payload.get("world", "ancient_egypt"), true, rt_ms)
	SessionTracker.record_spike_result("reflex_tap", true)
	await get_tree().create_timer(0.5).timeout
	completed.emit()
	queue_free()
