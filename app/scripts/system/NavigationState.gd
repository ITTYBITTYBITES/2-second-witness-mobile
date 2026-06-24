extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# THE NAVIGATION STATE MACHINE
# ---------------------------------------------------------

enum NavigationMode {
	UNIVERSE_EXPLORATION,  # Pulls across all Worlds within a Universe
	WORLD_FOCUS,           # Locked to a specific World within a Universe
	ADAPTIVE_GUIDED        # AI-selected Worlds based on PlayerProfile weaknesses
}

var current_mode: int = NavigationMode.UNIVERSE_EXPLORATION

var active_universe_id: String = "science_lab"
var active_world_id: String = "" # Empty if in Exploration or Adaptive mode

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
