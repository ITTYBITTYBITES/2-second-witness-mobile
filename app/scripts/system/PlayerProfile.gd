extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness 
# THE MEMORY MIRROR & MEANINGFUL PROGRESSION SYSTEM
# ---------------------------------------------------------

const SAVE_PATH = "user://profile.save"
const SAVE_SCHEMA_VERSION = 2 

var experience: int = 0
var current_level: int = 1
var player_title: String = "Observer"
var lifetime_sessions: int = 0
var current_streak: int = 1
var last_active_day: int = 0
var coins: int = 100

var universe_affinity: Dictionary = {}
var world_affinity: Dictionary = {}
var favorite_mechanic: String = "memory_cascade"
var unlocked_universes: Array = ["science_lab", "history"]
var unlocked_worlds: Array = ["cognitive_bias", "ancient_egypt"]
var has_directors_pass: bool = false
var purchase_receipt_log: Array = [] 
var unlocked_achievements: Array = []

var cognitive_baseline = {
	"pattern_recognition": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0},
	"recall": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0},
	"rapid_classification": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0},
	"spatial_tracking": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0},
	"decision_confidence": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0},
	"processing_speed": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0}
}

var current_week_drift = {
	"pattern_recognition": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0},
	"recall": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0},
	"rapid_classification": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0},
	"spatial_tracking": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0},
	"decision_confidence": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0},
	"processing_speed": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0}
}

var task_familiarity_index = {
	"memory_cascade": 0, "spatial_recall": 0, "sequence_reverse": 0,
	"pattern_continuation": 0, "odd_one_out": 0, "stroop_test": 0,
	"rapid_classification": 0, "speed_sort": 0, "signal_vs_noise": 0,
	"math_surprise": 0, "reflex_tap": 0, "risk_selection": 0
}

var rank_order_history = {
	"pattern_recognition": [], "recall": [], "rapid_classification": [],
	"spatial_tracking": [], "decision_confidence": [], "processing_speed": []
}

var session_summaries: Array = []
var last_recorded_metrics = {}

var motor_assist_enabled: bool = false
var colorblind_mode_enabled: bool = false
var device_hardware_offset_ms: float = 0.0

func _ready():
	if BootTracer: BootTracer.log_init("PlayerProfile")
	print("[2 SECOND WITNESS] Bayesian Ordering Inference Engine active.")
	_load_profile()
	evaluate_entitlements()
	_update_streak()

func _update_streak():
	var current_day = int(Time.get_unix_time_from_system() / 86400)
	if last_active_day == 0:
		last_active_day = current_day
		current_streak = 1
	elif current_day - last_active_day == 1:
		current_streak += 1
		last_active_day = current_day
	elif current_day - last_active_day > 1:
		current_streak = 1
		last_active_day = current_day
	save_profile()

func record_purchase_receipt(receipt: Dictionary):
	purchase_receipt_log.append(receipt)
	evaluate_entitlements()
	save_profile()

func evaluate_entitlements():
	unlocked_universes = ["science_lab", "history"]
	unlocked_worlds = ["cognitive_bias", "ancient_egypt"]
	has_directors_pass = false
	
	var sorted_log = purchase_receipt_log.duplicate()
	sorted_log.sort_custom(func(a, b): return a.get("timestamp", 0) < b.get("timestamp", 0))
	
	var processed_tx = {}
	for receipt in sorted_log:
		var tx_id = receipt.get("transaction_id", "")
		if processed_tx.has(tx_id): continue 
		processed_tx[tx_id] = true
		
		var item_id = receipt.get("item_id", "")
		if item_id == "directors_pass":
			has_directors_pass = true
		elif item_id.begins_with("universe_unlock_"):
			var uni = item_id.replace("universe_unlock_", "")
			if not unlocked_universes.has(uni):
				unlocked_universes.append(uni)

func record_cognitive_event(c_trait: String, scenario_id: String, universe_id: String, world_id: String, success: bool, reaction_time_ms: float):
	lifetime_sessions += 1
	universe_affinity[universe_id] = universe_affinity.get(universe_id, 0) + 1
	
	var world_key = universe_id + "_" + world_id
	world_affinity[world_key] = world_affinity.get(world_key, 0) + 1
	
	task_familiarity_index[scenario_id] = task_familiarity_index.get(scenario_id, 0) + 1
	
	var top_mech_count = 0
	for mech in task_familiarity_index.keys():
		if task_familiarity_index[mech] > top_mech_count:
			top_mech_count = task_familiarity_index[mech]
			favorite_mechanic = mech
	
	var xp_gained = (150 if success else 50) + int(max(0, 1000.0 - reaction_time_ms) / 10.0)
	experience += xp_gained
	current_level = 1 + int(float(experience) / 1000.0)
	
	var titles = ["Observer", "Pattern Explorer", "Focus Specialist", "Speed Architect", "Pattern Witness", "Liquid Master"]
	player_title = titles[clampi(current_level - 1, 0, titles.size() - 1)]
	
	if not unlocked_achievements.has("FIRST_STEP") and lifetime_sessions >= 1: unlocked_achievements.append("FIRST_STEP")
	if not unlocked_achievements.has("TEN_SPIKES") and lifetime_sessions >= 10: unlocked_achievements.append("TEN_SPIKES")
	if not unlocked_achievements.has("FAST_REFLEX") and reaction_time_ms < 500.0: unlocked_achievements.append("FAST_REFLEX")
	
	var marginal_percentile = 50.0
	var ordering_confidence = 0.95
	var permutation_entropy = 0.5
	var posterior_stability = 0.90
	
	if cognitive_baseline.has(c_trait):
		var b = cognitive_baseline[c_trait]
		b["attempts"] += 1
		if success:
			b["successes"] += 1
			b["total_rt_ms"] += reaction_time_ms
			
			if rank_order_history.has(c_trait):
				var hist: Array = rank_order_history[c_trait]
				hist.append(reaction_time_ms)
				hist.sort()
				
				var n = hist.size()
				var idx = hist.find(reaction_time_ms)
				marginal_percentile = (float(idx) / float(max(1, n - 1))) * 100.0
				
				if n > 5:
					var lower_idx = max(0, idx - 2)
					var upper_idx = min(n - 1, idx + 2)
					var local_spread = hist[upper_idx] - hist[lower_idx]
					
					ordering_confidence = clampf(local_spread / 50.0, 0.5, 0.99)
					permutation_entropy = clampf(1.0 - ordering_confidence, 0.01, 1.0)
					posterior_stability = clampf(float(n) / (float(n) + 10.0), 0.1, 0.99)
				
	if current_week_drift.has(c_trait):
		var d = current_week_drift[c_trait]
		d["attempts"] += 1
		if success:
			d["successes"] += 1
			d["total_rt_ms"] += reaction_time_ms
			
	last_recorded_metrics = {
		"marginal_rank_percentile": marginal_percentile,
		"ordering_confidence_interval": ordering_confidence,
		"permutation_entropy": permutation_entropy,
		"posterior_stability_score": posterior_stability
	}
	
	session_summaries.append({
		"timestamp": Time.get_unix_time_from_system(), "trait": c_trait,
		"scenario": scenario_id, "success": success, "rt_ms": reaction_time_ms
	})
	if session_summaries.size() > 50: session_summaries.pop_front()
			
	save_profile()

func get_adaptive_recommendation() -> Dictionary:
	var rec = {"universe": "history", "world": "ancient_egypt", "reason": "Expanding historical knowledge base."}
	var highest_hesitation_trait = ""
	var max_rt = 0.0
	
	for t in current_week_drift.keys():
		var d = current_week_drift[t]
		if d["successes"] > 0:
			var avg = d["total_rt_ms"] / float(d["successes"])
			if avg > max_rt:
				max_rt = avg
				highest_hesitation_trait = t
				
	if highest_hesitation_trait == "rapid_classification":
		rec = {"universe": "history", "world": "ancient_egypt", "reason": "High hesitation in rapid classification detected. Recommending History -> Ancient Egypt -> Stroop."}
	elif highest_hesitation_trait == "recall":
		rec = {"universe": "science_lab", "world": "neural_mapping", "reason": "Recall latency elevating. Recommending Science Lab -> Neural Mapping."}
	elif highest_hesitation_trait == "pattern_recognition":
		rec = {"universe": "creative_arts", "world": "color_theory", "reason": "You tend to solve structured problems. Creative Arts explores divergent thinking."}
	elif highest_hesitation_trait == "spatial_tracking":
		rec = {"universe": "frontier", "world": "arctic", "reason": "Your recent decisions suggest strong spatial reasoning. Recommend Frontier -> Arctic."}
		
	return rec

func _load_profile():
	if not FileAccess.file_exists(SAVE_PATH):
		print("[PROFILE] No existing save found. Generating new observation baseline.")
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json = JSON.new()
		var parse_result = json.parse(file.get_as_text())
		file.close()
		
		if parse_result == OK:
			var data = json.get_data()
			if typeof(data) == TYPE_DICTIONARY and data.has("schema_version"):
				_apply_loaded_data(data)
			else:
				print("[PROFILE FATAL] Save file format invalid. Falling back to clean slate.")
		else:
			print("[PROFILE FATAL] JSON Parse error. Save file corrupted. Falling back to clean slate.")

func _apply_loaded_data(data: Dictionary):
	if data["schema_version"] >= 1:
		lifetime_sessions = data.get("lifetime_sessions", 0)
		experience = data.get("experience", 0)
		current_level = data.get("current_level", 1)
		player_title = data.get("player_title", "Observer")
		current_streak = data.get("current_streak", 1)
		last_active_day = data.get("last_active_day", 0)
		coins = data.get("coins", 100)
		
		universe_affinity = data.get("universe_affinity", {})
		world_affinity = data.get("world_affinity", {})
		favorite_mechanic = data.get("favorite_mechanic", "memory_cascade")
		unlocked_universes = data.get("unlocked_universes", ["science_lab", "history"])
		unlocked_worlds = data.get("unlocked_worlds", ["cognitive_bias", "ancient_egypt"])
		has_directors_pass = data.get("has_directors_pass", false)
		purchase_receipt_log = data.get("purchase_receipt_log", [])
		unlocked_achievements = data.get("unlocked_achievements", [])
		
		_merge_dict(cognitive_baseline, data.get("cognitive_baseline", {}))
		_merge_dict(current_week_drift, data.get("current_week_drift", {}))
		_merge_dict(task_familiarity_index, data.get("task_familiarity_index", {}))
		_merge_dict(rank_order_history, data.get("rank_order_history", {}))
		session_summaries = data.get("session_summaries", [])
		
		motor_assist_enabled = data.get("motor_assist_enabled", false)
		colorblind_mode_enabled = data.get("colorblind_mode_enabled", false)
		device_hardware_offset_ms = data.get("device_hardware_offset_ms", 0.0)
		print("[PROFILE] Mathematical state restored successfully.")

func _merge_dict(target: Dictionary, source: Dictionary):
	for key in source.keys():
		target[key] = source[key]

func save_profile():
	var save_dict = {
		"schema_version": SAVE_SCHEMA_VERSION,
		"lifetime_sessions": lifetime_sessions,
		"experience": experience,
		"current_level": current_level,
		"player_title": player_title,
		"current_streak": current_streak,
		"last_active_day": last_active_day,
		"coins": coins,
		"universe_affinity": universe_affinity,
		"world_affinity": world_affinity,
		"favorite_mechanic": favorite_mechanic,
		"unlocked_universes": unlocked_universes,
		"unlocked_worlds": unlocked_worlds,
		"has_directors_pass": has_directors_pass,
		"purchase_receipt_log": purchase_receipt_log,
		"unlocked_achievements": unlocked_achievements,
		"cognitive_baseline": cognitive_baseline,
		"current_week_drift": current_week_drift,
		"task_familiarity_index": task_familiarity_index,
		"rank_order_history": rank_order_history,
		"session_summaries": session_summaries,
		"motor_assist_enabled": motor_assist_enabled,
		"colorblind_mode_enabled": colorblind_mode_enabled,
		"device_hardware_offset_ms": device_hardware_offset_ms
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_dict, "\t"))
		file.close()

func generate_insights() -> Array[String]:
	var insights: Array[String] = []
	insights.append("[color=#2ECC71]Player Title:[/color] " + player_title + " (Lvl " + str(current_level) + " | XP: " + str(experience) + ")")
	insights.append("[color=#4CC9F0]Active Streak:[/color] " + str(current_streak) + " days | [color=#F72585]Favorite Mechanic:[/color] " + favorite_mechanic.capitalize().replace("_", " "))
	insights.append("[color=#E6B800]Achievements Unlocked:[/color] " + str(unlocked_achievements.size()) + " (" + ", ".join(unlocked_achievements) + ")")
	
	var top_uni = ""
	var top_count = 0
	for u in universe_affinity.keys():
		if universe_affinity[u] > top_count:
			top_count = universe_affinity[u]
			top_uni = u
	
	if top_count > 0:
		var readable_uni = top_uni.capitalize().replace("_", " ")
		insights.append("%s remains your dominant universe." % readable_uni)
		
	var rec = get_adaptive_recommendation()
	insights.append("Recommendation: " + rec.get("reason", ""))
	
	if insights.is_empty():
		insights.append("Awaiting more observation data to form a profile...")
	return insights
