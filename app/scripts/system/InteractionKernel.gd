extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# SINGLE MINIMAL INTERACTION KERNEL (PROVENANCE-CONSISTENT)
# ---------------------------------------------------------
# Compresses Arbiter, Ledger, Epoch, and Idempotency into a single 
# deterministic reduction system for non-deterministic event emission graphs.

enum UIState { HIDDEN, PASSIVE_VISIBLE, MODAL_ACTIVE, TRANSITIONAL_LOCK }
enum InputModality { POINTER, FOCUS }

signal ui_lock_state_changed(is_blocking: bool)
signal epoch_resolved(epoch: int)

# --- 1. ARBITER DOMAIN (Input Filtering & Modality Locks) ---
var _registered_panels: Dictionary = {}
var _active_pointer_domains: Dictionary = {}
var _active_focus_domains: Dictionary = {}
var _pending_mutations: Array[Dictionary] = []
var _transitional_suppression_lock: bool = false
var _active_transitions_count: int = 0
var _mutation_scheduled: bool = false

# --- 2. LEDGER DOMAIN (Mutation Serialization) ---
var current_epoch: int = 0
var _intent_buffer: Array[Dictionary] = []
var _is_committing_side_effects: bool = false
var _mutation_trace_log: Array[Dictionary] = []

# --- 3. IDEMPOTENCY DOMAIN (Event Provenance Binding) ---
var _last_pointer_event_hash: int = 0
var _consumed_provenance_tokens: Dictionary = {}

func _ready():
	BootTracer.log_init("InteractionKernel")
	print("[INTERACTION KERNEL] Online. Enforcing event-origin consistency (1 physical input -> 1 consumable token).")

# =========================================================
# IDEMPOTENCY LAYER (Input Provenance Binding)
# =========================================================
func consume_provenance(event_id: String, event: InputEvent = null) -> bool:
	if event != null:
		_last_pointer_event_hash = hash(event.get_instance_id()) if event.has_method("get_instance_id") else event.hash()
		
	var provenance_token = event_id + ":" + str(_last_pointer_event_hash)
	if _consumed_provenance_tokens.has(provenance_token):
		print("[KERNEL IDEMPOTENCY] Suppressed cross-epoch late emission for token: ", provenance_token)
		return false
		
	_consumed_provenance_tokens[provenance_token] = true
	if _consumed_provenance_tokens.size() > 500: _consumed_provenance_tokens.clear()
	return true

# =========================================================
# ARBITER LAYER (Modality Exclusivity & Transition Locks)
# =========================================================
func register_panel(panel: Control, domain: String = "default", initial_state: int = UIState.HIDDEN, block_focus: bool = true):
	if not is_instance_valid(panel): return
	_registered_panels[panel] = {"domain": domain, "state": initial_state, "block_focus": block_focus}
	set_panel_state(panel, initial_state, domain, block_focus)

func unregister_panel(panel: Control):
	if _registered_panels.has(panel):
		var domain = _registered_panels[panel]["domain"]
		if _active_pointer_domains.get(domain) == panel: _active_pointer_domains.erase(domain)
		if _active_focus_domains.get(domain) == panel: _active_focus_domains.erase(domain)
		_registered_panels.erase(panel)
		_schedule_mutation()

func set_panel_state(panel: Control, state: int, domain: String = "default", block_focus: bool = true):
	if not is_instance_valid(panel): return
	if _registered_panels.has(panel):
		_registered_panels[panel]["state"] = state
		_registered_panels[panel]["domain"] = domain
		_registered_panels[panel]["block_focus"] = block_focus
	else:
		_registered_panels[panel] = {"domain": domain, "state": state, "block_focus": block_focus}
		
	_pending_mutations.append({"panel": panel, "state": state, "domain": domain, "block_focus": block_focus})
	_schedule_mutation()

func begin_transition(panel: Control, domain: String = "default"):
	_active_transitions_count += 1
	set_panel_state(panel, UIState.TRANSITIONAL_LOCK, domain)
	print("[KERNEL ARBITER] Transitional Lock INTENT declared. Suppressing input race conditions.")

func end_transition(panel: Control, final_state: int, domain: String = "default"):
	_active_transitions_count = max(0, _active_transitions_count - 1)
	set_panel_state(panel, final_state, domain)
	print("[KERNEL ARBITER] Transition resolution INTENT declared. Remaining active locks: ", _active_transitions_count)

func _schedule_mutation():
	if not _mutation_scheduled:
		_mutation_scheduled = true
		call_deferred("_apply_batched_mutations")

func _apply_batched_mutations():
	_mutation_scheduled = false
	for mutation in _pending_mutations:
		var panel = mutation["panel"]
		var state = mutation["state"]
		var domain = mutation["domain"]
		var block_focus = mutation["block_focus"]
		if not is_instance_valid(panel): continue
		
		match state:
			UIState.HIDDEN:
				panel.visible = false
				panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
				if _active_pointer_domains.get(domain) == panel: _active_pointer_domains.erase(domain)
				if _active_focus_domains.get(domain) == panel: _active_focus_domains.erase(domain)
				
			UIState.PASSIVE_VISIBLE:
				panel.visible = true
				panel.mouse_filter = Control.MOUSE_FILTER_PASS
				if _active_pointer_domains.get(domain) == panel: _active_pointer_domains.erase(domain)
				if _active_focus_domains.get(domain) == panel: _active_focus_domains.erase(domain)
				
			UIState.MODAL_ACTIVE:
				panel.visible = true
				var existing_pointer = _active_pointer_domains.get(domain)
				if is_instance_valid(existing_pointer) and existing_pointer != panel:
					print("[KERNEL ARBITER] Pointer Exclusivity enforced. Stripping STOP from domain '", domain, "': ", existing_pointer.name)
					existing_pointer.mouse_filter = Control.MOUSE_FILTER_PASS
				_active_pointer_domains[domain] = panel
				panel.mouse_filter = Control.MOUSE_FILTER_STOP
				
				if block_focus:
					var existing_focus = _active_focus_domains.get(domain)
					if is_instance_valid(existing_focus) and existing_focus != panel:
						print("[KERNEL ARBITER] Focus Exclusivity enforced. Stripping focus lock from domain '", domain, "': ", existing_focus.name)
					_active_focus_domains[domain] = panel
				
			UIState.TRANSITIONAL_LOCK:
				panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
				if _active_pointer_domains.get(domain) == panel: _active_pointer_domains.erase(domain)
				if _active_focus_domains.get(domain) == panel: _active_focus_domains.erase(domain)
				
	_pending_mutations.clear()
	_transitional_suppression_lock = (_active_transitions_count > 0)
	var is_blocking = is_ui_blocking()
	ui_lock_state_changed.emit(is_blocking)

func is_ui_blocking() -> bool:
	return _transitional_suppression_lock or not _active_pointer_domains.is_empty() or not _active_focus_domains.is_empty()

# =========================================================
# LEDGER LAYER (Deferred Command Bus & Re-entrancy Guard)
# =========================================================
func commit_intent(intent: Dictionary):
	if _is_committing_side_effects:
		print("[KERNEL WARNING] 0.0ms Tolerance Enforced. Suppressed re-entrant signal during active commit execution: ", intent.get("type", "UNKNOWN"))
		return
		
	intent["epoch"] = current_epoch
	intent["timestamp_usec"] = Time.get_ticks_usec()
	_intent_buffer.append(intent)
	print("[KERNEL LEDGER] Intent buffered for Epoch ", current_epoch, ": ", intent.get("type", "UNKNOWN"))

func _process(_delta):
	if not _intent_buffer.is_empty() and not _is_committing_side_effects:
		call_deferred("_drain_command_buffer")
	else:
		current_epoch += 1
		_consumed_provenance_tokens.clear()

func _drain_command_buffer():
	if _intent_buffer.is_empty() or _is_committing_side_effects: return
	
	_is_committing_side_effects = true
	var current_commands = _intent_buffer.duplicate()
	_intent_buffer.clear()
	
	var start_commit_usec = Time.get_ticks_usec()
	print("[KERNEL LEDGER] Draining Command Buffer for Epoch ", current_epoch, " (Commands: ", current_commands.size(), ")")
	
	# Guarantee no orphaned transition locks persist across command boundaries
	_active_transitions_count = 0
	_transitional_suppression_lock = false
	
	for command in current_commands:
		var incoherence_lag_ms = (start_commit_usec - command["timestamp_usec"]) / 1000.0
		if incoherence_lag_ms > 33.3:
			print("[KERNEL WARNING] Subsystem incoherence lag exceeded 33.3ms threshold: ", incoherence_lag_ms, " ms")
			
		_execute_serialized_command(command)
		
		_mutation_trace_log.append({
			"epoch": current_epoch, "type": command.get("type", "unknown"),
			"incoherence_lag_ms": incoherence_lag_ms, "resolved_usec": Time.get_ticks_usec()
		})
		
	if _mutation_trace_log.size() > 1000: _mutation_trace_log.pop_front()
	_is_committing_side_effects = false
	epoch_resolved.emit(current_epoch)
	current_epoch += 1
	_consumed_provenance_tokens.clear()

func _execute_serialized_command(command: Dictionary):
	var command_type = command.get("type", "")
	match command_type:
		"scene_shift":
			var target = command.get("target", "")
			if target == "LandingScreen": NavigationRouter.show_landing_screen()
			elif target == "WeeklyFeaturedScreen": NavigationRouter._on_discover_requested()
			elif target == "PlayerProfileScreen": NavigationRouter._on_profile_requested()
		"enter_stream": NavigationRouter._on_play_requested()
		"play_universe": NavigationRouter._on_play_universe_requested(command.get("universe_id", "science_lab"))
		"ad_resolved": if AdManager: AdManager.ad_finished.emit()
		"ad_rewarded": if AdManager: AdManager.reward_granted.emit()
		"sync_completed": if GitHubSyncManager: GitHubSyncManager.sync_completed.emit(command.get("status", "success"))
		_: print("[KERNEL LEDGER] Unknown serialized command: ", command_type)

func is_epoch_locked() -> bool: return _is_committing_side_effects
func get_mutation_trace_log() -> Array[Dictionary]: return _mutation_trace_log
