extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# COGNITIVE SAMPLING & TRAIT STABILITY LAYER
# ---------------------------------------------------------

var current_week_seed: int = 0
var active_sampling_pool: Array[String] = []

# Featured Universes (The Rotation Layer)
var featured_universes: Array[String] = []

var target_quotas = {
	"memory": 2,
	"pattern": 2,
	"classification": 1,
	"decision": 1
}

var scenario_manifest = {
	"memory_cascade": "memory",
	"spatial_recall": "memory",
	"sequence_reverse": "memory",
	"pattern_continuation": "pattern",
	"odd_one_out": "pattern",
	"math_surprise": "pattern",
	"rapid_classification": "classification",
	"stroop_test": "classification",
	"speed_sort": "classification",
	"signal_vs_noise": "classification",
	"risk_selection": "decision",
	"reflex_tap": "decision"
}

func _ready():
	print("[SAMPLING CONTROLLER] Online. Enforcing trait exposure quotas.")
	_initialize_weekly_rotation()

func _initialize_weekly_rotation():
	current_week_seed = Time.get_date_dict_from_system()["week"] if Time.get_date_dict_from_system().has("week") else 42
	seed(current_week_seed)
	
	active_sampling_pool.clear()
	var available_scenarios = scenario_manifest.keys()
	available_scenarios.shuffle()
	
	var fulfilled_quotas = {"memory": 0, "pattern": 0, "classification": 0, "decision": 0}
	for s in available_scenarios:
		var trait = scenario_manifest[s]
		if fulfilled_quotas[trait] < target_quotas[trait]:
			active_sampling_pool.append(s)
			fulfilled_quotas[trait] += 1
			
	# Pick 3 Random Featured Universes for the Free Rotation
	var all_universes = ["science_lab", "tech_ops", "life_sciences", "society_mind", "creative_arts", "frontier"]
	all_universes.shuffle()
	featured_universes = [all_universes[0], all_universes[1], all_universes[2]]
			
	randomize()
	print("[SAMPLING CONTROLLER] Weekly Scenario Pool Locked: ", active_sampling_pool)
	print("[SAMPLING CONTROLLER] Weekly Featured Universes Locked: ", featured_universes)

func get_next_scenario() -> String:
	if active_sampling_pool.is_empty():
		return "memory_cascade" 
	return active_sampling_pool[randi() % active_sampling_pool.size()]
