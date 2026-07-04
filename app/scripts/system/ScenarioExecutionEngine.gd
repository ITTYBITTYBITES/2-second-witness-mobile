extends Node
class_name ScenarioExecutionEngineNode

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness 
# SCENARIO EXECUTION ENGINE (AUTHORITATIVE RUNTIME GOVERNANCE)
# ---------------------------------------------------------

enum LifecycleState {
	IDLE,
	INIT,
	GENERATE,
	PRESENT,
	INPUT_WINDOW,
	EVALUATE,
	RESULT,
	RESET
}

signal state_changed(new_state: int, state_name: String)
signal scenario_registered(scenario_id: String, universe_id: String, world_id: String)
signal input_window_started(scenario_id: String)
signal scenario_resolved(scenario_id: String, success: bool, rt_ms: float)
signal scenario_completed(scenario_id: String, rt_ms: float)

var current_state: int = LifecycleState.IDLE
var active_scenario: Node = null
var active_payload: Dictionary = {}
var engine_start_ticks: int = 0
var is_input_enabled: bool = false
var _is_transitioning: bool = false

func _ready():
	if BootTracer: BootTracer.log_init("ScenarioExecutionEngine")
	print("[SCENARIO ENGINE] Online. Authoritative governance over gameplay lifecycle and timing.")

func register_scenario_instance(scenario_node: Node, payload: Dictionary, _seed_val: int):
	active_scenario = scenario_node
	active_payload = payload
	var s_id = payload.get("id", "UNKNOWN")
	var u_id = payload.get("universe", "UNKNOWN")
	var w_id = payload.get("world", "UNKNOWN")
	
	print("[SCENARIO ENGINE] Registering active scenario: ", s_id, " (Universe: ", u_id, ", World: ", w_id, ")")
	scenario_registered.emit(s_id, u_id, w_id)
	
	_transition_to_state(LifecycleState.INIT)

func _transition_to_state(new_state: int):
	current_state = new_state
	var state_name = _get_state_name(new_state)
	print("[SCENARIO ENGINE LIFECYCLE] -> ", state_name)
	state_changed.emit(new_state, state_name)
	
	match new_state:
		LifecycleState.INIT:
			is_input_enabled = false
			_disable_scenario_inputs()
			call_deferred("_transition_to_state", LifecycleState.GENERATE)
		LifecycleState.GENERATE:
			if is_instance_valid(active_scenario) and active_scenario.has_method("engine_generate_hook"):
				active_scenario.engine_generate_hook()
			call_deferred("_transition_to_state", LifecycleState.PRESENT)
		LifecycleState.PRESENT:
			is_input_enabled = false
			_disable_scenario_inputs()
			if is_instance_valid(active_scenario) and active_scenario.has_method("engine_present_hook"):
				active_scenario.engine_present_hook()
			var diff = active_payload.get("difficulty", 1)
			var invariance_ms = clamp(350 - (int(diff) * 40), 150, 350)
			await get_tree().create_timer(invariance_ms / 1000.0).timeout
			if is_instance_valid(active_scenario) and current_state == LifecycleState.PRESENT:
				_transition_to_state(LifecycleState.INPUT_WINDOW)
		LifecycleState.INPUT_WINDOW:
			is_input_enabled = true
			_enable_scenario_inputs()
			engine_start_ticks = Time.get_ticks_msec()
			input_window_started.emit(active_payload.get("id", "unknown"))
		LifecycleState.EVALUATE:
			is_input_enabled = false
			_disable_scenario_inputs()
		LifecycleState.RESULT:
			pass # Evaluation outcome processed in submit_answer
		LifecycleState.RESET:
			is_input_enabled = false
			_disable_scenario_inputs()
			if is_instance_valid(active_scenario) and active_scenario.has_method("engine_reset_hook"):
				active_scenario.engine_reset_hook()
			await get_tree().create_timer(0.4).timeout
			if is_instance_valid(active_scenario):
				_transition_to_state(LifecycleState.GENERATE)

func submit_answer(is_success: bool, custom_rt: float = -1.0):
	if current_state != LifecycleState.INPUT_WINDOW and current_state != LifecycleState.PRESENT:
		print("[SCENARIO ENGINE WARNING] Answer submitted outside active window (State: ", _get_state_name(current_state), "). Processing regardless for resilience.")
		
	_transition_to_state(LifecycleState.EVALUATE)
	
	var rt_ms = custom_rt if custom_rt >= 0.0 else float(Time.get_ticks_msec() - engine_start_ticks)
	var s_id = active_payload.get("id", "unknown")
	var u_id = active_payload.get("universe", "history")
	var w_id = active_payload.get("world", "ancient_egypt")
	
	print("[SCENARIO ENGINE EVALUATE] Result: ", "SUCCESS" if is_success else "FAILURE", " | Reaction Time: ", rt_ms, " ms")
	
	_transition_to_state(LifecycleState.RESULT)
	scenario_resolved.emit(s_id, is_success, rt_ms)
	
	if is_success:
		var interp = Engine.get_main_loop().root.get_node_or_null("ProgressionInterpreter")
		if interp and interp.has_method("process_progression_event"):
			interp.process_progression_event(interp.ProgressionEventType.SESSION_COMPLETE, 1, {
				"scenario_id": s_id, "universe_id": u_id, "world_id": w_id, "success": true, "reaction_time_ms": rt_ms, "trait": active_payload.get("type", "general")
			})
		else:
			if PlayerProfile: PlayerProfile.record_cognitive_event("general", s_id, u_id, w_id, true, rt_ms)
			if SessionTracker: SessionTracker.record_spike_result(s_id, true)
		await get_tree().create_timer(0.5).timeout
		if is_instance_valid(active_scenario):
			var cur_t = active_scenario.get("current_trial")
			var tot_t = active_scenario.get("target_trials")
			if cur_t != null and tot_t != null and int(cur_t) < int(tot_t):
				print("[SCENARIO ENGINE] Trial %d / %d completed. Advancing stream..." % [int(cur_t), int(tot_t)])
				active_scenario.current_trial = int(cur_t) + 1
				if active_scenario.has_method("update_progress_display"):
					active_scenario.update_progress_display()
				if active_scenario.has_method("advance_to_next_trial"):
					active_scenario.advance_to_next_trial()
				else:
					_transition_to_state(LifecycleState.RESET)
			else:
				print("[SCENARIO ENGINE] All trials in scenario completed! Executing milestone verification...")
				if is_instance_valid(active_scenario):
					if active_scenario.has_method("_set_all_buttons_disabled"):
						active_scenario._set_all_buttons_disabled(active_scenario, true)
					var f_lbl = active_scenario.get_node_or_null("FeedbackLabel") if active_scenario.get_node_or_null("FeedbackLabel") else active_scenario.get_node_or_null("feedback_label")
					if f_lbl and f_lbl is Label:
						f_lbl.text = "STREAM VERIFIED (%d TRIALS)" % [int(tot_t)]
						f_lbl.modulate = Color("#00FF66")
					var footer = active_scenario.get_node_or_null("CockpitFooter")
					if footer:
						for child in footer.find_children("*", "RichTextLabel", true, false):
							if "STATUS:" in child.text:
								child.text = "[center][color=#00FF66][b]STATUS: OBSERVATION STREAM VERIFIED — RECORDING COMPLETE[/b][/color][/center]"
				
				var audio = Engine.get_main_loop().root.get_node_or_null("AudioManager") if Engine.get_main_loop() else null
				if audio and audio.has_method("play_sfx"):
					audio.play_sfx("ui_click")
					
				await get_tree().create_timer(1.0).timeout
				print("[SCENARIO ENGINE] Concluding scenario and returning to menu/Mirror.")
				scenario_completed.emit(s_id, rt_ms)
				if is_instance_valid(active_scenario):
					if active_scenario.has_user_signal("completed") or active_scenario.has_signal("completed"):
						active_scenario.emit_signal("completed")
					active_scenario.queue_free()
				active_scenario = null
				current_state = LifecycleState.IDLE
	else:
		var interp = Engine.get_main_loop().root.get_node_or_null("ProgressionInterpreter")
		if interp and interp.has_method("process_progression_event"):
			interp.process_progression_event(interp.ProgressionEventType.SESSION_COMPLETE, 0, {
				"scenario_id": s_id, "universe_id": u_id, "world_id": w_id, "success": false, "reaction_time_ms": rt_ms, "trait": active_payload.get("type", "general")
			})
		else:
			if PlayerProfile: PlayerProfile.record_cognitive_event("general", s_id, u_id, w_id, false, rt_ms)
			if SessionTracker: SessionTracker.record_spike_result(s_id, false)
		_transition_to_state(LifecycleState.RESET)

func _disable_scenario_inputs():
	if is_instance_valid(active_scenario) and active_scenario.has_method("engine_set_inputs_enabled"):
		active_scenario.engine_set_inputs_enabled(false)

func _enable_scenario_inputs():
	if is_instance_valid(active_scenario) and active_scenario.has_method("engine_set_inputs_enabled"):
		active_scenario.engine_set_inputs_enabled(true)

func _get_state_name(state_enum: int) -> String:
	match state_enum:
		LifecycleState.IDLE: return "IDLE"
		LifecycleState.INIT: return "INIT"
		LifecycleState.GENERATE: return "GENERATE"
		LifecycleState.PRESENT: return "PRESENT"
		LifecycleState.INPUT_WINDOW: return "INPUT_WINDOW"
		LifecycleState.EVALUATE: return "EVALUATE"
		LifecycleState.RESULT: return "RESULT"
		LifecycleState.RESET: return "RESET"
	return "UNKNOWN"
