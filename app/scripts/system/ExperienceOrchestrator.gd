extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# EXPERIENCE ORCHESTRATOR (AUTHORITATIVE RUNTIME GOVERNANCE)
# Single Source of Truth for: ContentGraph + ExecutionEngine + VisualIdentity + Navigation
# ---------------------------------------------------------

signal experience_state_changed(active_state: Object)
signal session_personalized(orchestration_vector: Dictionary)

class ActiveExperienceState extends RefCounted:
	var current_universe: String = "science_lab"
	var current_world: String = ""
	var current_scenario: String = ""
	var visual_identity: Dictionary = {}
	var execution_state: int = 0
	var navigation_state: String = "LandingScreen"

var active_state: ActiveExperienceState = ActiveExperienceState.new()
var current_mode: String = "discovery"
var active_universe: String = "history"
var active_world: String = "ancient_egypt"
var active_spike: String = "memory_cascade"
var current_difficulty: int = 1

var current_mission: Dictionary = {}
var current_exposure_index: int = 0

func normalize_id(id: Variant) -> String:
	return str(id)

func _ready():
	if BootTracer: BootTracer.log_init("ExperienceOrchestrator")
	print("[ORCHESTRATOR] Online. Single source of truth for runtime experience loop.")
	_bind_subsystems()

func _bind_subsystems():
	var exec_engine = Engine.get_main_loop().root.get_node_or_null("ScenarioExecutionEngine")
	if exec_engine:
		if exec_engine.has_signal("scenario_registered") and not exec_engine.scenario_registered.is_connected(_on_scenario_registered):
			exec_engine.scenario_registered.connect(_on_scenario_registered)
		if exec_engine.has_signal("state_changed") and not exec_engine.state_changed.is_connected(_on_execution_state_changed):
			exec_engine.state_changed.connect(_on_execution_state_changed)
		if exec_engine.has_signal("scenario_resolved") and not exec_engine.scenario_resolved.is_connected(_on_scenario_resolved):
			exec_engine.scenario_resolved.connect(_on_scenario_resolved)

func get_authoritative_state() -> ActiveExperienceState:
	return active_state

func request_navigation_transition(target_screen: String, payload: Dictionary = {}):
	print("[ORCHESTRATOR] Authoritative Navigation Transition -> ", target_screen)
	_cleanup_active_gameplay_if_needed(target_screen)
	active_state.navigation_state = target_screen
	
	var router = Engine.get_main_loop().root.get_node_or_null("NavigationRouter")
	if router:
		match target_screen:
			"LandingScreen": if router.has_method("show_landing_screen"): router.show_landing_screen()
			"WeeklyFeaturedScreen": if router.has_method("_on_discover_requested"): router._on_discover_requested()
			"WorldSelectScreen": if router.has_method("_on_play_universe_requested"): router._on_play_universe_requested(payload.get("universe_id", active_state.current_universe))
			"PlayerProfileScreen": if router.has_method("_on_profile_requested"): router._on_profile_requested()
			"GameplayHUD": if router.has_method("_on_world_selected"): router._on_world_selected(payload.get("universe_id", active_state.current_universe), payload.get("world_id", active_state.current_world))
			
	experience_state_changed.emit(active_state)

func _cleanup_active_gameplay_if_needed(new_screen: String):
	if new_screen != "GameplayHUD":
		var exec_engine = Engine.get_main_loop().root.get_node_or_null("ScenarioExecutionEngine")
		if exec_engine and exec_engine.get("active_scenario") != null:
			var sc = exec_engine.active_scenario
			if is_instance_valid(sc): sc.queue_free()
			exec_engine.active_scenario = null
			if exec_engine.has_method("_transition_to_state"):
				exec_engine._transition_to_state(0) # IDLE

func request_universe_selection(universe_id: String):
	var u_id = normalize_id(universe_id)
	print("[ORCHESTRATOR] Authoritative Universe Selection -> ", u_id)
	active_state.current_universe = u_id
	active_state.current_world = ""
	active_state.current_scenario = ""
	active_universe = u_id
	active_world = ""
	
	_update_visual_identity(u_id, "")
	request_navigation_transition("WorldSelectScreen", {"universe_id": u_id})

func request_world_selection(universe_id: String, world_id: String):
	var u_id = normalize_id(universe_id)
	var w_id = normalize_id(world_id)
	print("[ORCHESTRATOR] Authoritative World Selection -> ", u_id, " / ", w_id)
	active_state.current_universe = u_id
	active_state.current_world = w_id
	active_universe = u_id
	active_world = w_id
	
	_update_visual_identity(u_id, w_id)
	
	var vector = determine_next_experience(Engine.get_main_loop().root.get_node_or_null("PlayerProfile"), u_id, w_id)
	var s_id = vector.get("spike", "memory_cascade")
	active_state.current_scenario = s_id
	active_spike = s_id
	
	request_navigation_transition("GameplayHUD", {"universe_id": u_id, "world_id": w_id})
	
	experience_state_changed.emit(active_state)

func _update_visual_identity(u_id: String, w_id: String):
	var vim = Engine.get_main_loop().root.get_node_or_null("VisualIdentityManager")
	if vim and vim.has_method("resolve_and_apply_identity"):
		active_state.visual_identity = vim.resolve_and_apply_identity(u_id, w_id)
	experience_state_changed.emit(active_state)

func _on_scenario_registered(s_id: String, u_id: String, w_id: String):
	active_state.current_scenario = s_id
	active_state.current_universe = u_id
	active_state.current_world = w_id
	active_spike = s_id
	active_universe = u_id
	active_world = w_id
	active_state.navigation_state = "GameplayHUD"
	_update_visual_identity(u_id, w_id)
	print("[ORCHESTRATOR] Synchronized active experience state to scenario mounting: ", s_id)

func _on_execution_state_changed(new_state: int, _state_name: String):
	active_state.execution_state = new_state
	experience_state_changed.emit(active_state)

func _on_scenario_resolved(s_id: String, success: bool, rt_ms: float):
	print("[ORCHESTRATOR] Scenario resolved under orchestrator governance: ", s_id, " (Success: ", success, ", RT: ", rt_ms, " ms)")

func reset_session_state():
	print("[ORCHESTRATOR] Full Session State Reset Initiated.")
	active_state = ActiveExperienceState.new()
	request_navigation_transition("LandingScreen")

func determine_next_experience(player_profile: Node, target_universe: String = "", target_world: String = "") -> Dictionary:
	if not is_instance_valid(player_profile):
		return _fallback_vector()
		
	# 1. Player & Mode Evaluation
	var total_sessions = player_profile.lifetime_sessions
	current_mode = "continuity" if total_sessions > 10 else "discovery"
	
	# 2. Universe & World Decision
	if target_universe != "" and target_world != "":
		active_universe = normalize_id(target_universe)
		active_world = normalize_id(target_world)
		current_mode = "targeted_exploration"
	elif current_mode == "discovery":
		active_universe = "history"
		active_world = "ancient_egypt"
	else:
		var recommended = player_profile.get_adaptive_recommendation()
		if recommended.has("universe"):
			active_universe = normalize_id(recommended["universe"])
			active_world = normalize_id(recommended.get("world", "ancient_egypt"))
			
	# 3. Knowledge Item & Mission Exposure Selection
	var registry = get_node_or_null("/root/ContentRegistry")
	var sampling = get_node_or_null("/root/SamplingController")
	
	active_universe = normalize_id(active_universe)
	active_world = normalize_id(active_world)
	
	var mission_key = active_universe + "_" + active_world
	var missions = registry.curated_missions.get(mission_key, []) if registry and registry.get("curated_missions") != null else []
	
	if not missions.is_empty():
		var mission_idx = (total_sessions / 4) % missions.size()
		current_mission = missions[mission_idx]
		var chain = current_mission.get("mechanics_chain", ["memory_cascade"])
		current_exposure_index = total_sessions % chain.size()
		active_spike = normalize_id(chain[current_exposure_index])
		print("[ORCHESTRATOR] Curated Mission Active: ", current_mission.get("title", ""), " | Exposure ", current_exposure_index + 1, " / ", chain.size(), " (Mechanic: ", active_spike, ")")
	else:
		active_spike = normalize_id(sampling.get_next_scenario() if sampling else "memory_cascade")
		print("[ORCHESTRATOR] Fallback Sampling Mode Active (Mechanic: ", active_spike, ")")
	
	var seed_str = str(total_sessions) + active_universe + active_world
	var knowledge_payload = registry.resolve_scenario(active_universe, active_world, active_spike, seed_str) if registry else {}
	
	if knowledge_payload.is_empty():
		knowledge_payload = {
			"id": active_spike, "universe": active_universe, "world": active_world, "type": active_spike,
			"rules": {"correct_answer": "Eye of Horus", "wrong_answers": ["Ankh", "Scarab", "Djed"], "legacy_prompt": "DEITY SYMBOL"}
		}
		
	# 4. Difficulty & Presentation Calibration
	current_difficulty = clamp(1 + int(total_sessions / 10), 1, 5)
	var presentation_profile = WorldProfileCustodian.get_profile(active_world) if Engine.get_main_loop().root.has_node("WorldProfileCustodian") else {}
	
	var vector = {
		"mode": current_mode,
		"universe": active_universe,
		"world": active_world,
		"knowledge_item": knowledge_payload,
		"spike": active_spike,
		"difficulty": current_difficulty,
		"presentation": presentation_profile,
		"mission": current_mission,
		"exposure_index": current_exposure_index
	}
	
	active_state.current_universe = active_universe
	active_state.current_world = active_world
	active_state.current_scenario = active_spike
	_update_visual_identity(active_universe, active_world)
	
	session_personalized.emit(vector)
	return vector

func finalize_scenario_mounting(scenario_id: String):
	print("[ORCHESTRATOR] Finalizing scenario mounting for: ", scenario_id)
	var kernel = InteractionKernel if InteractionKernel else get_tree().root.get_node_or_null("InteractionKernel")
	if kernel and kernel.has_method("release_input_lock"):
		kernel.release_input_lock(kernel.current_epoch if kernel.get("current_epoch") != null else 0)
	print("[ORCHESTRATOR] Scenario state = READY. GameplayHUD active. Input Release Contract fulfilled.")

func _fallback_vector() -> Dictionary:
	return {
		"mode": "discovery", "universe": "history", "world": "ancient_egypt",
		"knowledge_item": {"id": "memory_cascade", "universe": "history", "world": "ancient_egypt", "type": "memory_cascade", "rules": {}},
		"spike": "memory_cascade", "difficulty": 1, "presentation": {},
		"mission": {}, "exposure_index": 0
	}
