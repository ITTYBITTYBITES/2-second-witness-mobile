extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# FRAME-SYNCED EVENT LEDGER (DETERMINISTIC INTERACTION RUNTIME)
# ---------------------------------------------------------

signal epoch_resolved(epoch: int)

var current_epoch: int = 0
var _intent_ledger: Array[Dictionary] = []
var _is_flushing: bool = false

func _ready():
	BootTracer.log_init("InteractionLedger")
	print("[INTERACTION LEDGER] Online. Enforcing 4-Phase Event Ledger (Input -> Intent -> Resolution -> Commit).")

func commit_intent(intent: Dictionary):
	intent["epoch"] = current_epoch
	_intent_ledger.append(intent)
	print("[INTERACTION LEDGER] Intent recorded for Epoch ", current_epoch, ": ", intent.get("type", "UNKNOWN"))

func _process(_delta):
	if _intent_ledger.is_empty(): 
		current_epoch += 1
		return
		
	_is_flushing = true
	var current_intents = _intent_ledger.duplicate()
	_intent_ledger.clear()
	
	print("[INTERACTION LEDGER] Resolving Epoch ", current_epoch, " (Intents: ", current_intents.size(), ")")
	for intent in current_intents:
		_execute_commit(intent)
		
	_is_flushing = false
	epoch_resolved.emit(current_epoch)
	current_epoch += 1

func _execute_commit(intent: Dictionary):
	var intent_type = intent.get("type", "")
	match intent_type:
		"scene_shift":
			var target = intent.get("target", "")
			if target == "LandingScreen":
				NavigationRouter.show_landing_screen()
			elif target == "WeeklyFeaturedScreen":
				NavigationRouter._on_discover_requested()
			elif target == "PlayerProfileScreen":
				NavigationRouter._on_profile_requested()
				
		"enter_stream":
			NavigationRouter._on_play_requested()
			
		"play_universe":
			NavigationRouter._on_play_universe_requested(intent.get("universe_id", "science_lab"))
			
		_:
			print("[INTERACTION LEDGER] Unknown commit intent: ", intent_type)

func is_epoch_locked() -> bool:
	return _is_flushing
