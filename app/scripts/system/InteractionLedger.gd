extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# GOVERNED MUTATION SUBSTRATE & EVENT IDEMPOTENCY BOUNDARY
# ---------------------------------------------------------

signal epoch_resolved(epoch: int)

var current_epoch: int = 0
var _intent_buffer: Array[Dictionary] = []
var _is_committing_side_effects: bool = false
var _mutation_trace_log: Array[Dictionary] = []
var _consumed_events_this_epoch: Dictionary = {}

func _ready():
	BootTracer.log_init("InteractionLedger")
	print("[INTERACTION LEDGER] Online. Enforcing per-epoch event idempotency and single-consumption semantics.")

func consume_event(event_id: String) -> bool:
	if _consumed_events_this_epoch.has(event_id):
		print("[INTERACTION LEDGER] Idempotency Guard: Suppressed duplicate activation for '", event_id, "' in Epoch ", current_epoch)
		return false
	_consumed_events_this_epoch[event_id] = true
	return true

func commit_intent(intent: Dictionary):
	if _is_committing_side_effects:
		print("[INTERACTION LEDGER WARNING] 0.0ms Tolerance Enforced. Suppressed re-entrant signal during active commit execution: ", intent.get("type", "UNKNOWN"))
		return
		
	intent["epoch"] = current_epoch
	intent["timestamp_usec"] = Time.get_ticks_usec()
	_intent_buffer.append(intent)
	print("[INTERACTION LEDGER] Intent buffered for Epoch ", current_epoch, ": ", intent.get("type", "UNKNOWN"))

func _process(_delta):
	if not _intent_buffer.is_empty() and not _is_committing_side_effects:
		call_deferred("_drain_command_buffer")
	else:
		current_epoch += 1
		_consumed_events_this_epoch.clear()

func _drain_command_buffer():
	if _intent_buffer.is_empty() or _is_committing_side_effects: return
	
	_is_committing_side_effects = true
	var current_commands = _intent_buffer.duplicate()
	_intent_buffer.clear()
	
	var start_commit_usec = Time.get_ticks_usec()
	print("[INTERACTION LEDGER] Draining Command Buffer for Epoch ", current_epoch, " (Commands: ", current_commands.size(), ")")
	
	for command in current_commands:
		var incoherence_lag_ms = (start_commit_usec - command["timestamp_usec"]) / 1000.0
		if incoherence_lag_ms > 33.3:
			print("[INTERACTION LEDGER WARNING] Subsystem incoherence lag exceeded 33.3ms threshold: ", incoherence_lag_ms, " ms")
			
		_execute_serialized_command(command)
		
		_mutation_trace_log.append({
			"epoch": current_epoch,
			"type": command.get("type", "unknown"),
			"incoherence_lag_ms": incoherence_lag_ms,
			"resolved_usec": Time.get_ticks_usec()
		})
		
	if _mutation_trace_log.size() > 1000: _mutation_trace_log.pop_front()
		
	_is_committing_side_effects = false
	epoch_resolved.emit(current_epoch)
	current_epoch += 1
	_consumed_events_this_epoch.clear()

func _execute_serialized_command(command: Dictionary):
	var command_type = command.get("type", "")
	match command_type:
		"scene_shift":
			var target = command.get("target", "")
			if target == "LandingScreen":
				NavigationRouter.show_landing_screen()
			elif target == "WeeklyFeaturedScreen":
				NavigationRouter._on_discover_requested()
			elif target == "PlayerProfileScreen":
				NavigationRouter._on_profile_requested()
				
		"enter_stream":
			NavigationRouter._on_play_requested()
			
		"play_universe":
			NavigationRouter._on_play_universe_requested(command.get("universe_id", "science_lab"))
			
		"ad_resolved":
			if AdManager: AdManager.ad_finished.emit()
			
		"ad_rewarded":
			if AdManager: AdManager.reward_granted.emit()
			
		"sync_completed":
			if GitHubSyncManager: GitHubSyncManager.sync_completed.emit(command.get("status", "success"))
			
		_:
			print("[INTERACTION LEDGER] Unknown serialized command: ", command_type)

func is_epoch_locked() -> bool:
	return _is_committing_side_effects

func get_mutation_trace_log() -> Array[Dictionary]:
	return _mutation_trace_log
