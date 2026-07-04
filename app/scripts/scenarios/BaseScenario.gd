extends CanvasLayer
class_name BaseScenario

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# COGNITIVE TASK KERNEL (STRICT INJECTION BASE)
# ---------------------------------------------------------

var _scenario_payload: Dictionary = {}
var _deterministic_rng: RandomNumberGenerator
var current_trial: int = 1
var target_trials: int = 5
var _used_content_ids: Dictionary = {}
var _last_payload_refresh_trial: int = 1

func normalize_id(id: Variant) -> String:
	return str(id)

func _clean_payload_text(value: Variant) -> String:
	var text = str(value).strip_edges()
	var trace_idx = text.find(" // TRACE")
	if trace_idx >= 0:
		text = text.substr(0, trace_idx).strip_edges()
	return text

func _get_prompt_text(rules: Dictionary, fallback: String = "OBSERVE") -> String:
	var prompt = rules.get("prompt", "")
	if str(prompt).strip_edges() == "":
		prompt = rules.get("legacy_prompt", fallback)
	var clean = _clean_payload_text(prompt)
	return clean if clean != "" else fallback

func _remember_current_content_id():
	var sid = normalize_id(_scenario_payload.get("id", ""))
	if sid != "":
		_used_content_ids[sid] = true

func _refresh_payload_for_current_trial():
	var registry = ContentRegistry if ContentRegistry else get_tree().root.get_node_or_null("ContentRegistry")
	if not registry or not registry.has_method("get_all_scenarios_in_world"):
		return
	var u_id = normalize_id(_scenario_payload.get("universe", ""))
	var w_id = normalize_id(_scenario_payload.get("world", ""))
	var t_id = normalize_id(_scenario_payload.get("type", ""))
	if u_id == "" or w_id == "" or t_id == "":
		return
	var all_items = registry.get_all_scenarios_in_world(u_id, w_id)
	var pool: Array = []
	for item in all_items:
		if item is Dictionary and normalize_id(item.get("type", "")) == t_id:
			pool.append(item)
	if pool.size() <= 1:
		return
	var start_idx = abs((normalize_id(_deterministic_rng.seed if _deterministic_rng else 0) + ":" + t_id + ":" + str(current_trial)).hash()) % pool.size()
	var selected: Dictionary = {}
	for offset in range(pool.size()):
		var candidate = pool[(start_idx + offset) % pool.size()]
		var c_id = normalize_id(candidate.get("id", ""))
		if not _used_content_ids.has(c_id):
			selected = candidate
			break
	if selected.is_empty():
		selected = pool[start_idx]
	_scenario_payload = selected.duplicate(true)
	_scenario_payload["id"] = normalize_id(_scenario_payload.get("id", t_id))
	_scenario_payload["universe"] = u_id
	_scenario_payload["world"] = w_id
	_scenario_payload["type"] = t_id
	_remember_current_content_id()
	_last_payload_refresh_trial = current_trial
	var engine = get_node_or_null("/root/ScenarioExecutionEngine")
	if engine and engine.get("active_scenario") == self:
		engine.active_payload = _scenario_payload
	print("[BASE SCENARIO] Refreshed trial content: ", _scenario_payload["id"])

func _cap_target_trials_to_available_content():
	var registry = ContentRegistry if ContentRegistry else get_tree().root.get_node_or_null("ContentRegistry")
	if not registry or not registry.has_method("get_all_scenarios_in_world"):
		return
	var u_id = normalize_id(_scenario_payload.get("universe", ""))
	var w_id = normalize_id(_scenario_payload.get("world", ""))
	var t_id = normalize_id(_scenario_payload.get("type", ""))
	var count = 0
	for item in registry.get_all_scenarios_in_world(u_id, w_id):
		if item is Dictionary and normalize_id(item.get("type", "")) == t_id:
			count += 1
	if count > 0 and target_trials > count:
		target_trials = count
		if current_trial > target_trials:
			current_trial = 1
		print("[BASE SCENARIO] Trial count capped to available unique content: ", target_trials)

func _style_question_label(lbl: Label, font_size: int = 30):
	if lbl == null:
		return
	lbl.set_anchors_preset(Control.PRESET_TOP_WIDE)
	lbl.offset_left = 96
	lbl.offset_top = 96
	lbl.offset_right = -96
	lbl.offset_bottom = 236
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.clip_text = false
	lbl.add_theme_font_size_override("font_size", font_size)

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
	_remember_current_content_id()

	var orch = Engine.get_main_loop().root.get_node_or_null("ExperienceOrchestrator") if Engine.get_main_loop() else null
	if orch and "current_exposure_index" in orch and "current_mission" in orch and orch.current_mission.has("mechanics_chain"):
		current_trial = orch.current_exposure_index + 1
		target_trials = max(1, orch.current_mission["mechanics_chain"].size())
	elif payload.has("target_trials"):
		target_trials = int(payload["target_trials"])
	_cap_target_trials_to_available_content()
	_last_payload_refresh_trial = current_trial

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

	enforce_attentional_strata()
	LayoutFreezer.unfreeze()

	var orch = get_node_or_null("/root/ExperienceOrchestrator")
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

var _cockpit_header_panel: PanelContainer = null
var _cockpit_footer_status: RichTextLabel = null

func _register_with_execution_engine():
	var engine = get_node_or_null("/root/ScenarioExecutionEngine")
	if not engine:
		print("[BASE SCENARIO] ScenarioExecutionEngine not found in root. Running in standalone benchmark mode.")
		_mount_cockpit_instrument_overlay()
		return
	engine.register_scenario_instance(self, _scenario_payload, _deterministic_rng.seed if _deterministic_rng else 12345)
	_mount_cockpit_instrument_overlay()

func _mount_cockpit_instrument_overlay():
	if get_node_or_null("CockpitHeader") != null: return

	var u_id = _scenario_payload.get("universe", "science_lab")
	var w_id = _scenario_payload.get("world", "cognitive_bias")
	var s_id = _scenario_payload.get("id", "memory_cascade")
	var t_id = _scenario_payload.get("type", "memory")

	var pretty_uni = str(u_id).capitalize().replace("_", " ")
	var pretty_world = str(w_id).capitalize().replace("_", " ")
	var pretty_proto = str(s_id).capitalize().replace("_", " ")
	var pretty_trait = str(t_id).capitalize().replace("_", " ")
	if pretty_trait == "Memory": pretty_trait = "RECALL & WORKING MEMORY"
	elif pretty_trait == "Pattern": pretty_trait = "PATTERN RECOGNITION"
	elif pretty_trait == "Classification": pretty_trait = "RAPID CLASSIFICATION"
	elif pretty_trait == "Decision": pretty_trait = "DECISION CONFIDENCE"

	var orch = Engine.get_main_loop().root.get_node_or_null("ExperienceOrchestrator") if Engine.get_main_loop() else null
	var scenario_title = str(_scenario_payload.get("title", _scenario_payload.get("mission_title", "")))
	if scenario_title == "" and orch and "current_mission" in orch and orch.current_mission.has("title") and orch.current_mission["title"] != "":
		scenario_title = str(orch.current_mission["title"])
	if scenario_title == "":
		scenario_title = pretty_proto

	var progress_str = "TRIAL %d OF %d" % [current_trial, target_trials]

	_cockpit_header_panel = PanelContainer.new()
	_cockpit_header_panel.name = "CockpitHeader"
	_cockpit_header_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_cockpit_header_panel.offset_left = 0
	_cockpit_header_panel.offset_top = 0
	_cockpit_header_panel.offset_right = 0
	_cockpit_header_panel.offset_bottom = 54
	_cockpit_header_panel.custom_minimum_size = Vector2(0, 54)
	_cockpit_header_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cockpit_header_panel.z_index = 100
	PresentationToolkit.apply_cockpit_bar_style(_cockpit_header_panel, "bottom", Color("#00D4FF"))

	var h_margin = MarginContainer.new()
	h_margin.add_theme_constant_override("margin_left", 24)
	h_margin.add_theme_constant_override("margin_right", 24)
	h_margin.add_theme_constant_override("margin_top", 8)
	h_margin.add_theme_constant_override("margin_bottom", 8)
	_cockpit_header_panel.add_child(h_margin)

	var h_box = HBoxContainer.new()
	h_box.add_theme_constant_override("separation", 20)
	h_margin.add_child(h_box)

	var lbl_title = RichTextLabel.new()
	lbl_title.text = "[color=#00D4FF]●[/color] [b]2 SECOND WITNESS[/b] [color=#667799]| ACTIVE OBSERVATION[/color]"
	PresentationToolkit.style_rich_text_label(lbl_title, 16, 300.0)
	h_box.add_child(lbl_title)

	var lbl_proto = RichTextLabel.new()
	lbl_proto.text = "[center][b][color=#8595FF]%s[/color][/b] [color=#445566]▶[/color] [b][color=#E6B800]%s[/color][/b] [color=#667799]// SCENARIO:[/color] [b][color=#FFFFFF]%s[/color][/b][/center]" % [pretty_uni.to_upper(), pretty_world.to_upper(), scenario_title.to_upper()]
	PresentationToolkit.style_rich_text_label(lbl_proto, 16, 0.0, true)
	h_box.add_child(lbl_proto)

	var lbl_chain = RichTextLabel.new()
	lbl_chain.text = "[right][color=#8595FF]PROGRESS:[/color] [color=#00D4FF]%s[/color][/right]" % progress_str
	PresentationToolkit.style_rich_text_label(lbl_chain, 16, 180.0)
	h_box.add_child(lbl_chain)

	add_child(_cockpit_header_panel)

	var f_panel = PanelContainer.new()
	f_panel.name = "CockpitFooter"
	f_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	f_panel.offset_left = 0
	f_panel.offset_top = -40
	f_panel.offset_right = 0
	f_panel.offset_bottom = 0
	f_panel.custom_minimum_size = Vector2(0, 40)
	f_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	f_panel.z_index = 100
	PresentationToolkit.apply_cockpit_bar_style(f_panel, "top", Color("#00D4FF"))

	var f_margin = MarginContainer.new()
	f_margin.add_theme_constant_override("margin_left", 24)
	f_margin.add_theme_constant_override("margin_right", 24)
	f_margin.add_theme_constant_override("margin_top", 6)
	f_margin.add_theme_constant_override("margin_bottom", 6)
	f_panel.add_child(f_margin)

	var f_box = HBoxContainer.new()
	f_margin.add_child(f_box)

	var lbl_target = RichTextLabel.new()
	lbl_target.text = "[color=#667799]TARGET DOMAIN:[/color] [b][color=#2ECC71]%s[/color][/b]" % pretty_trait.to_upper()
	PresentationToolkit.style_rich_text_label(lbl_target, 14, 300.0)
	f_box.add_child(lbl_target)

	_cockpit_footer_status = RichTextLabel.new()
	_cockpit_footer_status.text = "[center][color=#00D4FF]STATUS: OBSERVING STREAM — AWAITING WITNESS RESPONSE...[/color][/center]"
	PresentationToolkit.style_rich_text_label(_cockpit_footer_status, 14, 0.0, true)
	f_box.add_child(_cockpit_footer_status)

	var lbl_lat = RichTextLabel.new()
	lbl_lat.text = "[right][color=#667799]OBSERVATION STREAM:[/color] [color=#E6B800]SYNCHRONIZED[/color][/right]"
	PresentationToolkit.style_rich_text_label(lbl_lat, 14, 200.0)
	f_box.add_child(lbl_lat)

	var plates_script = load("res://scripts/ui/ProgressionHUDPlates.gd")
	if plates_script:
		var plates_node = plates_script.new()
		plates_node.setup(u_id, w_id)
		add_child(plates_node)
	var tunnel_shader = Engine.get_main_loop().root.get_node_or_null("MainShell/WorldLayer/TunnelLayer/Tier1_ShaderField/ShaderRect") if Engine.get_main_loop() else null
	if tunnel_shader and tunnel_shader.has_method("modulate_for_scenario"):
		tunnel_shader.modulate_for_scenario(str(_scenario_payload.get("type", "general")), _scenario_payload)
	add_child(f_panel)
	print("[COCKPIT] Persistent Observation Instrument HUD successfully mounted with PresentationToolkit glass skin.")

func engine_generate_hook():
	if current_trial != _last_payload_refresh_trial:
		_refresh_payload_for_current_trial()
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

func execute_progression_event(is_success: bool, rt_ms: float, trait_id: String = ""):
	var s_id = _scenario_payload.get("id", "unknown")
	var u_id = _scenario_payload.get("universe", "history")
	var w_id = _scenario_payload.get("world", "ancient_egypt")
	var t_id = trait_id if trait_id != "" else _scenario_payload.get("type", "general")

	if is_success:
		if is_instance_valid(_cockpit_footer_status):
			_cockpit_footer_status.text = "[center][color=#2ECC71][b]STATUS: OBSERVATION VERIFIED — RECORDING PATTERN DATA (%d ms)[/b][/color][/center]" % int(rt_ms)
		if is_instance_valid(_cockpit_header_panel):
			PresentationToolkit.set_cockpit_bar_state(_cockpit_header_panel, "bottom", "success")
	else:
		if is_instance_valid(_cockpit_footer_status):
			_cockpit_footer_status.text = "[center][color=#FF5555][b]STATUS: OBSERVATION NOISE DETECTED — RECALIBRATING...[/b][/color][/center]"
		if is_instance_valid(_cockpit_header_panel):
			PresentationToolkit.set_cockpit_bar_state(_cockpit_header_panel, "bottom", "failure")

	var engine = get_node_or_null("/root/ScenarioExecutionEngine")
	if engine and engine.has_method("submit_answer"):
		engine.submit_answer(is_success, rt_ms)
	else:
		var interp = Engine.get_main_loop().root.get_node_or_null("ProgressionInterpreter")
		if interp and interp.has_method("process_progression_event"):
			interp.process_progression_event(interp.ProgressionEventType.SESSION_COMPLETE, 1 if is_success else 0, {
				"scenario_id": s_id,
				"universe_id": u_id,
				"world_id": w_id,
				"success": is_success,
				"reaction_time_ms": rt_ms,
				"trait": t_id
			})
		else:
			var profile = Engine.get_main_loop().root.get_node_or_null("PlayerProfile") if Engine.get_main_loop() else null
			var tracker = Engine.get_main_loop().root.get_node_or_null("SessionTracker") if Engine.get_main_loop() else null
			if profile and profile.has_method("record_cognitive_event"): profile.record_cognitive_event(t_id, s_id, u_id, w_id, is_success, rt_ms)
			if tracker and tracker.has_method("record_spike_result"): tracker.record_spike_result(s_id, is_success)

		if is_success:
			await get_tree().create_timer(0.5).timeout
			if is_inside_tree():
				if current_trial < target_trials:
					print("[BASE SCENARIO STANDALONE] Trial %d / %d completed. Advancing..." % [current_trial, target_trials])
					current_trial += 1
					update_progress_display()
					advance_to_next_trial()
				else:
					print("[BASE SCENARIO STANDALONE] All trials completed! Concluding scenario.")
					if has_user_signal("completed") or has_signal("completed"):
						emit_signal("completed")
					queue_free()
		else:
			await get_tree().create_timer(0.5).timeout
			if is_inside_tree():
				if has_method("engine_reset_hook"): engine_reset_hook()
				if has_method("engine_generate_hook"): engine_generate_hook()

func update_progress_display():
	var progress_str = "TRIAL %d OF %d" % [current_trial, target_trials]
	if get_node_or_null("CockpitHeader"):
		for child in get_node("CockpitHeader").find_children("*", "RichTextLabel", true, false):
			if "PROGRESS:" in child.text or "CHAIN:" in child.text or "TRIAL " in child.text:
				child.text = "[right][color=#8595FF]PROGRESS:[/color] [color=#00D4FF]%s[/color][/right]" % progress_str

func advance_to_next_trial():
	print("[BASE SCENARIO] Advancing scenario to Trial %d / %d" % [current_trial, target_trials])
	_refresh_payload_for_current_trial()
	if is_instance_valid(_cockpit_footer_status):
		_cockpit_footer_status.text = "[center][color=#00D4FF]STATUS: OBSERVING STREAM — AWAITING WITNESS RESPONSE...[/color][/center]"
	if is_instance_valid(_cockpit_header_panel):
		PresentationToolkit.set_cockpit_bar_state(_cockpit_header_panel, "bottom", "neutral")
	if get_node_or_null("FeedbackLabel"):
		get_node("FeedbackLabel").text = ""
	elif get_node_or_null("feedback_label"):
		get_node("feedback_label").text = ""
	engine_reset_hook()
	engine_generate_hook()
	var engine = get_node_or_null("/root/ScenarioExecutionEngine")
	if engine and engine.has_method("_transition_to_state"):
		engine._transition_to_state(engine.LifecycleState.INPUT_WINDOW)

func report_scenario_result(is_success: bool, rt_ms: float = -1.0):
	execute_progression_event(is_success, rt_ms)

func enforce_attentional_strata():
	var bg = get_node_or_null("VoidBG") if get_node_or_null("VoidBG") else get_node_or_null("ColorRect")
	if bg and bg is ColorRect:
		bg.color = Color(0.04, 0.07, 0.12, 0.35) # Ensure persistent animated TunnelLayer remains visible behind scenario

	var pal = {}
	var vim = Engine.get_main_loop().root.get_node_or_null("VisualIdentityManager") if Engine.get_main_loop() else null
	if vim and vim.has_method("get_universe_identity"):
		pal = vim.get_universe_identity(_scenario_payload.get("universe", "science_lab")).get("palette", {})
	var primary_c = pal.get("primary", Color("#00D4FF"))
	var accent_c = pal.get("accent", Color("#80E5FF"))
	var dark_outline = Color(0.02, 0.04, 0.08, 0.95)

	_apply_stratum_recursive(self, primary_c, accent_c, dark_outline)

func _apply_stratum_recursive(node: Node, primary_c: Color, accent_c: Color, dark_outline: Color):
	for child in node.get_children():
		if child.name == "CockpitHeader" or child.name == "CockpitFooter" or child.name == "VoidBG" or child.name == "ProgressionHUDPlates":
			continue

		if child is Label or child is RichTextLabel:
			var n = child.name.to_lower()
			if "feedback" in n or "prompt" in n or "title" in n or "instruction" in n:
				if child is Label:
					child.add_theme_font_size_override("font_size", 24)
					child.add_theme_color_override("font_color", primary_c)
					child.add_theme_color_override("font_outline_color", dark_outline)
					child.add_theme_constant_override("outline_size", 6)
					child.add_theme_constant_override("shadow_offset_x", 0)
					child.add_theme_constant_override("shadow_offset_y", 3)
					child.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
				elif child is RichTextLabel:
					child.add_theme_font_size_override("normal_font_size", 22)
					child.add_theme_color_override("default_color", primary_c)
					child.add_theme_color_override("font_outline_color", dark_outline)
					child.add_theme_constant_override("outline_size", 5)
			elif "target" in n or "equation" in n or "sequence" in n or "number" in n:
				if child is Label:
					child.add_theme_font_size_override("font_size", 36)
					child.add_theme_color_override("font_color", Color(0.98, 0.98, 1.0))
					child.add_theme_color_override("font_outline_color", dark_outline)
					child.add_theme_constant_override("outline_size", 3)
				elif child is RichTextLabel:
					child.add_theme_font_size_override("normal_font_size", 32)
					child.add_theme_color_override("default_color", Color(0.98, 0.98, 1.0))
					child.add_theme_color_override("font_outline_color", dark_outline)
					child.add_theme_constant_override("outline_size", 3)
		elif child is Button:
			child.add_theme_font_size_override("font_size", 18)
			child.add_theme_color_override("font_color", Color(0.92, 0.96, 1.0))
			child.add_theme_color_override("font_outline_color", dark_outline)
			child.add_theme_constant_override("outline_size", 2)

		_apply_stratum_recursive(child, primary_c, accent_c, dark_outline)
