extends Node
class_name BootStateMachine

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# THE INITIAL BOOT STATE MACHINE (DETERMINISTIC 1-TIME BOOT)
# ---------------------------------------------------------

enum BootState {
	BOOT_START,
	INITIALIZE_SINGLETONS,
	LOAD_PLAYER_PROFILE,
	LOAD_SETTINGS,
	LOAD_UNIVERSE_REGISTRY,
	VERIFY_CONTENT,
	INITIALIZE_AUDIO,
	READY,
	TRANSITION_TO_LANDING
}

signal state_changed(state: int, progress: float, message: String)
signal boot_failed(reason: String)

var current_state: int = BootState.BOOT_START

func advance_state(new_state: int):
	current_state = new_state
	var msg = ""
	var prog = 0.0
	
	match new_state:
		BootState.BOOT_START:
			msg = "Preparing Observation..."
			prog = 0.10
		BootState.INITIALIZE_SINGLETONS:
			msg = "Loading Witness Archive..."
			prog = 0.25
		BootState.LOAD_PLAYER_PROFILE:
			msg = "Building World Index..."
			prog = 0.40
		BootState.LOAD_SETTINGS:
			msg = "Synchronizing Player Profile..."
			prog = 0.55
		BootState.LOAD_UNIVERSE_REGISTRY:
			msg = "Loading Universes..."
			prog = 0.70
		BootState.VERIFY_CONTENT:
			msg = "Preparing Session..."
			prog = 0.85
		BootState.INITIALIZE_AUDIO:
			msg = "Preparing Session..."
			prog = 0.95
		BootState.READY:
			msg = "Ready"
			prog = 1.00
		BootState.TRANSITION_TO_LANDING:
			msg = "Ready"
			prog = 1.00
			
	print("[BOOT STATE] Advanced to State: ", BootState.keys()[new_state], " | Progress: ", prog, " | Message: ", msg)
	state_changed.emit(new_state, prog * 100.0, msg)

func trigger_boot_failure(reason: String):
	boot_failed.emit(reason)
