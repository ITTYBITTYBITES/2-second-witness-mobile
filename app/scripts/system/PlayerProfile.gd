extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# THE COGNITIVE MIRROR (WITH ADAPTATION MODELING)
# ---------------------------------------------------------

var lifetime_sessions: int = 0
var universe_affinity: Dictionary = {}
n# Accessibility Cohorts (Prevents false cognitive degradation flags)
var motor_assist_enabled: bool = false
var colorblind_mode_enabled: bool = false

# Baseline Trait Vector (Slow-moving historical average)
var cognitive_baseline = {
	"pattern_recognition": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0},
	"recall": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0},
	"rapid_classification": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0},
	"spatial_tracking": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0},
	"decision_confidence": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0},
	"processing_speed": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0}
}

# Weekly Delta Vector (Fast-moving session drift)
var current_week_drift = {
	"pattern_recognition": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0},
	"recall": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0},
	"rapid_classification": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0},
	"spatial_tracking": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0},
	"decision_confidence": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0},
	"processing_speed": {"attempts": 0, "successes": 0, "total_rt_ms": 0.0}
}

# The Adaptation Tracker (Isolating Skill Acquisition from Cognition)
var task_familiarity_index = {
	"memory_cascade": 0,
	"spatial_recall": 0,
	"sequence_reverse": 0,
	"pattern_continuation": 0,
	"odd_one_out": 0,
	"stroop_test": 0,
	"rapid_classification": 0,
	"speed_sort": 0,
	"signal_vs_noise": 0,
	"math_surprise": 0,
	"reflex_tap": 0,
	"risk_selection": 0
}

func _ready():
	print("[2 SECOND WITNESS] Cognitive Insight Engine active.")
	_load_profile()

func record_cognitive_event(trait: String, scenario_id: String, universe: String, success: bool, reaction_time_ms: float):
	lifetime_sessions += 1
	universe_affinity[universe] = universe_affinity.get(universe, 0) + 1
	
	# Increment familiarity (The Adaptation Tracker)
	task_familiarity_index[scenario_id] = task_familiarity_index.get(scenario_id, 0) + 1
	
	# Update slow-moving baseline
	if cognitive_baseline.has(trait):
		var b = cognitive_baseline[trait]
		b["attempts"] += 1
		if success:
			b["successes"] += 1
			b["total_rt_ms"] += reaction_time_ms
			
	# Update fast-moving weekly drift
	if current_week_drift.has(trait):
		var d = current_week_drift[trait]
		d["attempts"] += 1
		if success:
			d["successes"] += 1
			d["total_rt_ms"] += reaction_time_ms
			
	save_profile()

func generate_insights() -> Array[String]:
	var insights: Array[String] = []
	
	var pat = cognitive_baseline["pattern_recognition"]
	var rec = cognitive_baseline["recall"]
	
	if pat["attempts"] >= 3 and rec["attempts"] >= 3:
		var pat_acc = float(pat["successes"]) / float(pat["attempts"])
		var rec_acc = float(rec["successes"]) / float(rec["attempts"])
		
		if pat_acc > rec_acc + 0.1:
			var diff = int((pat_acc - rec_acc) * 100)
			insights.append("Historically, you perform %d%% better on pattern tasks than recall tasks." % diff)
			
	# Anomaly Detection: Compare fast-moving drift to slow-moving baseline
	var pat_drift = current_week_drift["pattern_recognition"]
	if pat_drift["attempts"] >= 3 and pat["attempts"] >= 10:
		var baseline_rt = pat["total_rt_ms"] / float(pat["successes"]) if pat["successes"] > 0 else 2000.0
		var weekly_rt = pat_drift["total_rt_ms"] / float(pat_drift["successes"]) if pat_drift["successes"] > 0 else 2000.0
		
		# Contextualize with Familiarity Index to prevent false "cognitive improvement" narratives
		var is_highly_familiar = false
		for scenario in ["pattern_continuation", "odd_one_out", "math_surprise"]:
			if task_familiarity_index[scenario] > 20: # User has learned the instrument
				is_highly_familiar = true
				break
		
		if weekly_rt < (baseline_rt * 0.8): 
			if is_highly_familiar:
				insights.append("Your structural familiarity with pattern tasks has optimized your reaction time.")
			else:
				insights.append("Your raw pattern recognition speed has sharply increased this week.")
				
	if insights.is_empty():
		insights.append("Awaiting more cognitive data to form a profile...")
		
	return insights

func _load_profile():
	pass

func save_profile():
	pass
