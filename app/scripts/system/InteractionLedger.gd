extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# DEFERRED STATE RECONCILIATION & CENTRAL COMMAND BUS
# ---------------------------------------------------------

signal epoch_resolved(epoch: int)

var current_epoch: int = 0
var _intent_buffer: Array[Dictionary] = []
var _is_committing_side_effects: bool = false

func _ready():
	BootTracer.log_init("InteractionLedger")
	print("[INTERACTION LEDGER] Online. Enforcing Command Buffer Semantics and strict engine-wide side-effect governance.")

func commit_intent(intent: Dictionary):
	if _is_committing_side_effects:
		print("[INTERACTION LEDGER WARNING] Suppressed re-entrant signal during active commit execution: ", intent.get("type", "UNKNOWN"))
		return
		
	intent["epoch"] = current_epoch
	_intent_buffer.append(intent)
	print("[INTERACTION LEDGER] Intent buffered for Epoch ", current_epoch, ": ", intent.get("type", "UNKNOWN"))

func _process(_delta):
	if not _intent_buffer.is_empty() and not _is_committing_side_effects:
		call_deferred("_drain_command_buffer")
	else:
		current_epoch += 1

func _drain_command_buffer():
	if _intent_buffer.is_empty() or _is_committing_side_effects: return
	
	_is_committing_side_effects = true
	var current_commands = _intent_buffer.duplicate()
	_intent_buffer.clear()
	
	print("[INTERACTION LEDGER] Draining Command Buffer for Epoch ", current_epoch, " (Commands: ", current_commands.size(), ")")
	for command in current_commands:
		_execute_serialized_command(command)
		
	_is_committing_side_effects = false
	epoch_resolved.emit(current_epoch)
	current_epoch += 1

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
