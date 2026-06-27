extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness (Liquid Memory V2)
# THE NAVIGATION STATE MACHINE & IMMUTABLE TRANSITION CONTEXT
# ---------------------------------------------------------

enum NavigationMode {
	UNIVERSE_EXPLORATION,  # Pulls across all Worlds within a Universe
	WORLD_FOCUS,           # Locked to a specific World within a Universe
	ADAPTIVE_GUIDED        # AI-selected Worlds based on PlayerProfile weaknesses
}

var current_mode: int = NavigationMode.UNIVERSE_EXPLORATION

var active_universe_id: String = "science_lab"
var active_world_id: String = "" # Empty if in Exploration or Adaptive mode

var current_transition_context: Dictionary = {}

func set_exploration_mode(universe_id: String):
	current_mode = NavigationMode.UNIVERSE_EXPLORATION
	active_universe_id = universe_id
	active_world_id = ""
	print("[NAVIGATION STATE] Mode set to Universe Exploration: ", universe_id)

func set_focus_mode(universe_id: String, world_id: String):
	current_mode = NavigationMode.WORLD_FOCUS
	active_universe_id = universe_id
	active_world_id = world_id
	print("[NAVIGATION STATE] Mode set to World Focus: ", universe_id, " -> ", world_id)

func set_adaptive_mode():
	current_mode = NavigationMode.ADAPTIVE_GUIDED
	active_universe_id = ""
	active_world_id = ""
	print("[NAVIGATION STATE] Mode set to Adaptive Guided Progression.")

func lock_transition_context(u_id: String, w_id: String, s_id: String, c_id: String, seed_val: int) -> Dictionary:
	current_transition_context = {
		"universe_id": u_id,
		"world_id": w_id,
		"scenario_id": s_id,
		"chunk_id": c_id,
		"deterministic_seed": seed_val
	}
	print("[NAVIGATION STATE] Immutable TransitionContext locked: ", current_transition_context)
	return current_transition_context

func get_transition_context() -> Dictionary:
	return current_transition_context
