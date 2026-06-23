extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# THE COGNITIVE MIRROR (WITH DRIFT CONTROL)
# ---------------------------------------------------------

var lifetime_sessions: int = 0
var universe_affinity: Dictionary = {}

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

func _ready():
	print("[2 SECOND WITNESS] Cognitive Insight Engine active.")
	_load_profile()

func record_cognitive_event(trait: String, universe: String, success: bool, reaction_time_ms: float):
	lifetime_sessions += 1
	universe_affinity[universe] = universe_affinity.get(universe, 0) + 1
	
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
		
		if weekly_rt < (baseline_rt * 0.8): # 20% faster this week
			insights.append("Your pattern recognition speed has sharply increased this week.")
		elif weekly_rt > (baseline_rt * 1.2): # 20% slower this week
			insights.append("You are exhibiting unusual hesitation in pattern tasks this week.")
			
	if insights.is_empty():
		insights.append("Awaiting more cognitive data to form a profile...")
		
	return insights

func _load_profile():
	pass

func save_profile():
	pass
