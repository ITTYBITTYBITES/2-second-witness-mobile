extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# THE COGNITIVE MIRROR
# ---------------------------------------------------------

var lifetime_sessions: int = 0
var universe_affinity: Dictionary = {}

var cognitive_traits = {
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
	
	if cognitive_traits.has(trait):
		var t = cognitive_traits[trait]
		t["attempts"] += 1
		if success:
			t["successes"] += 1
			t["total_rt_ms"] += reaction_time_ms
			
	save_profile()

func generate_insights() -> Array[String]:
	var insights: Array[String] = []
	
	# 1. Dominant Universe Insight
	var top_uni = ""
	var top_count = 0
	for u in universe_affinity.keys():
		if universe_affinity[u] > top_count:
			top_count = universe_affinity[u]
			top_uni = u
	
	if top_count > 0:
		var readable_uni = top_uni.capitalize().replace("_", " ")
		insights.append("%s remains your dominant universe." % readable_uni)
		
	# 2. Pattern vs Recall Insight
	var pat = cognitive_traits["pattern_recognition"]
	var rec = cognitive_traits["recall"]
	if pat["attempts"] >= 3 and rec["attempts"] >= 3:
		var pat_acc = float(pat["successes"]) / float(pat["attempts"])
		var rec_acc = float(rec["successes"]) / float(rec["attempts"])
		
		if pat_acc > rec_acc + 0.1:
			var diff = int((pat_acc - rec_acc) * 100)
			insights.append("You perform %d%% better on pattern tasks than recall tasks." % diff)
		elif rec_acc > pat_acc + 0.1:
			var diff = int((rec_acc - pat_acc) * 100)
			insights.append("You perform %d%% better on recall tasks than pattern tasks." % diff)
			
	# 3. Processing Speed / Decision Confidence Insight
	var spd = cognitive_traits["processing_speed"]
	var conf = cognitive_traits["decision_confidence"]
	
	if conf["attempts"] > 3:
		var avg_conf_rt = conf["total_rt_ms"] / float(conf["successes"]) if conf["successes"] > 0 else 3000.0
		if avg_conf_rt > 2000.0:
			insights.append("You hesitate longer when ambiguity is high.")
		elif avg_conf_rt < 800.0:
			insights.append("You demonstrate high decisiveness under uncertainty.")

	if spd["attempts"] > 3:
		var spd_acc = float(spd["successes"]) / float(spd["attempts"])
		if spd_acc > 0.8:
			insights.append("Your accuracy remains stable under time pressure.")
			
	if insights.is_empty():
		insights.append("Awaiting more cognitive data to form a profile...")
		
	return insights

func _load_profile():
	pass

func save_profile():
	pass
