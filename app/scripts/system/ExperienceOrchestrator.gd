extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# EXPERIENCE ORCHESTRATOR (CENTRALIZED DECISION SERVICE)
# ---------------------------------------------------------
# Responsibilities: Player -> Mode -> Universe -> World -> Knowledge Item -> Spike -> Difficulty -> Presentation

signal session_personalized(orchestration_vector: Dictionary)

var current_mode: String = "discovery"
var active_universe: String = "history"
var active_world: String = "ancient_egypt"
var active_spike: String = "memory_cascade"
var current_difficulty: int = 1

var current_mission: Dictionary = {}
var current_exposure_index: int = 0

func _ready():
	if BootTracer: BootTracer.log_init("ExperienceOrchestrator")
	print("[ORCHESTRATOR] Online. Enforcing centralized progression decision tree.")

func determine_next_experience(player_profile: Node) -> Dictionary:
	if not is_instance_valid(player_profile):
		return _fallback_vector()
		
	# 1. Player & Mode Evaluation
	var total_sessions = player_profile.lifetime_sessions
	current_mode = "continuity" if total_sessions > 10 else "discovery"
	
	# 2. Universe & World Decision
	if current_mode == "discovery":
		active_universe = "history"
		active_world = "ancient_egypt"
	else:
		var recommended = player_profile.get_adaptive_recommendation()
		if recommended.has("universe"):
			active_universe = recommended["universe"]
			active_world = recommended.get("world", "ancient_egypt")
			
	# 3. Knowledge Item & Mission Exposure Selection
	var registry = get_node_or_null("/root/ContentRegistry")
	var sampling = get_node_or_null("/root/SamplingController")
	
	var mission_key = active_universe + "_" + active_world
	var missions = registry.curated_missions.get(mission_key, []) if registry and registry.get("curated_missions") != null else []
	
	if not missions.is_empty():
		var mission_idx = (total_sessions / 4) % missions.size()
		current_mission = missions[mission_idx]
		var chain = current_mission.get("mechanics_chain", ["memory_cascade"])
		current_exposure_index = total_sessions % chain.size()
		active_spike = chain[current_exposure_index]
		print("[ORCHESTRATOR] Curated Mission Active: ", current_mission.get("title", ""), " | Exposure ", current_exposure_index + 1, " / ", chain.size(), " (Mechanic: ", active_spike, ")")
	else:
		active_spike = sampling.get_next_scenario() if sampling else "memory_cascade"
		print("[ORCHESTRATOR] Fallback Sampling Mode Active (Mechanic: ", active_spike, ")")
	
	var seed_str = str(total_sessions) + active_universe + active_world
	var knowledge_payload = registry.resolve_scenario(active_universe, active_world, active_spike, seed_str) if registry else {}
	
	if knowledge_payload.is_empty():
		knowledge_payload = {
			"id": active_spike, "universe": active_universe, "world": active_world, "type": active_spike,
			"rules": {"correct_answer": "Eye of Horus", "wrong_answers": ["Ankh", "Scarab", "Djed"], "legacy_prompt": "DEITY SYMBOL"}
		}
		
	# 4. Difficulty & Presentation Calibration
	current_difficulty = clampi(1 + int(total_sessions / 10), 1, 5)
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
	
	session_personalized.emit(vector)
	return vector

func _fallback_vector() -> Dictionary:
	return {
		"mode": "discovery", "universe": "history", "world": "ancient_egypt",
		"knowledge_item": {"id": "memory_cascade", "universe": "history", "world": "ancient_egypt", "type": "memory_cascade", "rules": {}},
		"spike": "memory_cascade", "difficulty": 1, "presentation": {},
		"mission": {}, "exposure_index": 0
	}
