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
	BootTracer.log_init("SamplingController")
	print("[SAMPLING CONTROLLER] Online. Enforcing trait exposure quotas.")
	_initialize_weekly_rotation()

func _initialize_weekly_rotation():
	var rot_mgr = WeeklyRotationManager if WeeklyRotationManager else Engine.get_main_loop().root.get_node_or_null("WeeklyRotationManager")
	if rot_mgr:
		current_week_seed = rot_mgr.get_current_seed()
		featured_universes = rot_mgr.get_active_universes().duplicate()
	else:
		var now_sec = int(Time.get_unix_time_from_system())
		var week_id = int(float(now_sec) / 604800.0)
		current_week_seed = week_id * 77777 + 2026
		var all_universes = []
		var registry = Engine.get_main_loop().root.get_node_or_null("ContentRegistry")
		if registry and registry.has_method("get_all_universes"):
			all_universes = registry.get_all_universes().duplicate()
		var rng_fallback = RandomNumberGenerator.new()
		rng_fallback.seed = current_week_seed
		for i in range(all_universes.size() - 1, 0, -1):
			var j = rng_fallback.randi() % (i + 1)
			var tmp = all_universes[i]
			all_universes[i] = all_universes[j]
			all_universes[j] = tmp
		featured_universes = []
		for i in range(min(6, all_universes.size())):
			featured_universes.append(all_universes[i])
	
	active_sampling_pool.clear()
	var reg = Engine.get_main_loop().root.get_node_or_null("ContentRegistry")
	var available_scenarios = reg.get_all_scenario_ids() if (reg and reg.has_method("get_all_scenario_ids") and not reg.get_all_scenario_ids().is_empty()) else scenario_manifest.keys().duplicate()
	var rng = RandomNumberGenerator.new()
	rng.seed = current_week_seed
	for i in range(available_scenarios.size() - 1, 0, -1):
		var j = rng.randi() % (i + 1)
		var tmp = available_scenarios[i]
		available_scenarios[i] = available_scenarios[j]
		available_scenarios[j] = tmp
	
	var fulfilled_quotas = {"memory": 0, "pattern": 0, "classification": 0, "decision": 0}
	for s in available_scenarios:
		var t_trait = scenario_manifest.get(s, "pattern")
		if not target_quotas.has(t_trait): t_trait = "pattern"
		if fulfilled_quotas[t_trait] < target_quotas[t_trait]:
			active_sampling_pool.append(s)
			fulfilled_quotas[t_trait] += 1
			
	print("[SAMPLING CONTROLLER] Weekly Scenario Pool Locked: ", active_sampling_pool)
	print("[SAMPLING CONTROLLER] Weekly Active Universes Locked (Exactly 6): ", featured_universes)

func get_next_scenario() -> String:
	if active_sampling_pool.is_empty():
		return "memory_cascade" 
	return active_sampling_pool[randi() % active_sampling_pool.size()]
