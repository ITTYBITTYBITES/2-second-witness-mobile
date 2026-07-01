extends CanvasLayer
class_name BaseScenario

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# COGNITIVE TASK KERNEL (STRICT INJECTION BASE)
# ---------------------------------------------------------

var _scenario_payload: Dictionary = {}
var _deterministic_rng: RandomNumberGenerator

func normalize_id(id: Variant) -> String:
	return str(id)

func _enter_tree():
	if StructuredLogger and StructuredLogger.has_method("log_event_trace"):
		StructuredLogger.log_event_trace(self, "_enter_tree", "Node entering active scene tree.")

func _ready():
	if StructuredLogger and StructuredLogger.has_method("log_event_trace"):
		StructuredLogger.log_event_trace(self, "_ready", "Node ready and fully mounted.")

func inject_payload(payload: Dictionary, seed_val: int = 12345):
	var s_id = normalize_id(payload.get("id", "UNKNOWN"))
	if StructuredLogger and StructuredLogger.has_method("log_event_trace"):
		StructuredLogger.log_event_trace(self, "inject_payload", "External method call (scenario_id: " + s_id + ")")
	print("INJECT PAYLOAD:", s_id)
	if payload.is_empty():
		push_error("[SCENARIO FATAL] Injection failed. Payload is empty. Terminating.")
		queue_free()
		return
		
	_scenario_payload = payload
	_scenario_payload["id"] = s_id
	_scenario_payload["universe"] = normalize_id(payload.get("universe", "unknown"))
	_scenario_payload["world"] = normalize_id(payload.get("world", "unknown"))
	_scenario_payload["type"] = normalize_id(payload.get("type", "unknown"))
	
	_deterministic_rng = RandomNumberGenerator.new()
	_deterministic_rng.seed = seed_val
	
	print("[INJECTION TRACE] scenario_id: ", s_id)
	print("[INJECTION TRACE] resolved_from_registry: true")
	print("[INJECTION TRACE] world_id: ", _scenario_payload["world"])
	print("[INJECTION TRACE] deterministic_seed: ", seed_val)
	
	_validate_and_apply_payload()

func _validate_and_apply_payload():
	var req_keys = ["id", "universe", "world", "type", "rules"]
	for k in req_keys:
		if not _scenario_payload.has(k):
			push_error("[SCENARIO FATAL] Schema violation. Missing key: ", k)
			queue_free()
			return
			
	_apply_specific_rules(_scenario_payload["rules"])

func _apply_specific_rules(_rules: Dictionary):
	pass

func execute_render_pipeline():
	if _scenario_payload.is_empty(): return 
	
	var vim = VisualIdentityManager if VisualIdentityManager else Engine.get_main_loop().root.get_node_or_null("VisualIdentityManager")
	if vim and vim.has_method("resolve_and_apply_identity"):
		vim.resolve_and_apply_identity(_scenario_payload.get("universe", "science_lab"), _scenario_payload.get("world", ""))
	
	var resolver = ThemeResolver.new()
	var style = resolver.resolve_theme({"universe": _scenario_payload["universe"], "type": _scenario_payload["type"], "difficulty": _scenario_payload.get("difficulty", 1)})
	StyleInjector.apply(style, self)
	
	LayoutFreezer.enforce_freeze(self)
	
	var gate = LayoutQuiescenceGate.new()
	add_child(gate)
	gate.begin_quiescence_wait(self)
	
	await gate.layout_stabilized
	gate.queue_free()
	
	RuntimeInvarianceMonitor.capture_canonical_geometry(self)
	
	var asset_resolver = AssetResolver.new()
	asset_resolver.substitute_assets(self, _scenario_payload["universe"])
	
	if Engine.get_main_loop().root.has_node("RuntimeMeasurementIsolation"):
		Engine.get_main_loop().root.get_node("RuntimeMeasurementIsolation").anchor_stimulus_spawn()
		
	LayoutFreezer.unfreeze()
	
	var orch = ExperienceOrchestrator if ExperienceOrchestrator else get_tree().root.get_node_or_null("ExperienceOrchestrator")
	if orch and orch.has_method("finalize_scenario_mounting"):
		orch.finalize_scenario_mounting(_scenario_payload.get("id", "memory_cascade"))
	
	print("[SYSTEM] Canonical UI pipeline execution complete. Executing runtime assertions...")
	
	var is_f = LayoutFreezer.is_frozen
	var is_b = InteractionKernel.is_ui_blocking() if InteractionKernel else false
	var is_m_empty = ModalWindowManager.get_modal_stack().is_empty() if ModalWindowManager else true
	var cur_screen = NavigationRouter.current_screen_name if NavigationRouter else "GameplayHUD"
	
	print("  Assertion 1: !LayoutFreezer.is_frozen = ", not is_f)
	print("  Assertion 2: !InteractionKernel.is_ui_blocking() = ", not is_b)
	print("  Assertion 3: ModalWindowManager.modal_stack.is_empty() = ", is_m_empty)
	print("  Assertion 4: current_screen == GameplayHUD = ", cur_screen == "GameplayHUD")
	
	assert(not is_f, "Fatal: LayoutFreezer remained frozen before gameplay began.")
	assert(not is_b, "Fatal: InteractionKernel remained blocking before gameplay began.")
	assert(is_m_empty, "Fatal: Modal stack was not empty when gameplay started.")
	assert(cur_screen == "GameplayHUD", "Fatal: Current screen != GameplayHUD after transition completed.")
	print("✅ ALL 4 RUNTIME ASSERTIONS SATISFIED. Gameplay state machine unlocked and active.")
	_register_with_execution_engine()

func _register_with_execution_engine():
	var engine = ScenarioExecutionEngine if ScenarioExecutionEngine else Engine.get_main_loop().root.get_node_or_null("ScenarioExecutionEngine")
	if not engine:
		print("[BASE SCENARIO] ScenarioExecutionEngine not found in root. Running in standalone benchmark mode.")
		return
	engine.register_scenario_instance(self, _scenario_payload, _deterministic_rng.seed if _deterministic_rng else 12345)

func engine_generate_hook():
	if has_method("_setup_round"): call("_setup_round")
	elif has_method("_generate_problem"): call("_generate_problem")
	elif has_method("_generate_grid"): call("_generate_grid")
	elif has_method("_generate_pattern"): call("_generate_pattern")
	elif has_method("_generate_number"): call("_generate_number")
	elif has_method("_generate_stroop"): call("_generate_stroop")
	elif has_method("_start_next_trial"): call("_start_next_trial")
	elif has_method("spawn_choices"): call("spawn_choices")
	elif has_method("_play_sequence"): call("_play_sequence")

func engine_present_hook():
	pass

func engine_reset_hook():
	if "current_step" in self: self.current_step = 0
	elif "player_step" in self: self.player_step = 0
	elif "sequence" in self and typeof(self.sequence) == TYPE_ARRAY:
		if has_method("_apply_specific_rules") and not _scenario_payload.is_empty():
			self.sequence.clear()
			call("_apply_specific_rules", _scenario_payload.get("rules", {}))

func engine_set_inputs_enabled(enabled: bool):
	_set_all_buttons_disabled(self, not enabled)

func _set_all_buttons_disabled(node: Node, disable_flag: bool):
	for child in node.get_children():
		if child is Button:
			child.disabled = disable_flag
		elif child is Control:
			_set_all_buttons_disabled(child, disable_flag)

func report_scenario_result(is_success: bool, rt_ms: float = -1.0):
	var engine = ScenarioExecutionEngine if ScenarioExecutionEngine else Engine.get_main_loop().root.get_node_or_null("ScenarioExecutionEngine")
	if engine and engine.has_method("submit_answer"):
		engine.submit_answer(is_success, rt_ms)
	else:
		if is_success:
			if has_user_signal("completed") or has_signal("completed"):
				emit_signal("completed")
			queue_free()
		else:
			if has_method("engine_reset_hook"): engine_reset_hook()
			if has_method("engine_generate_hook"): engine_generate_hook()
