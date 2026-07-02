extends Node
class_name MirrorNarratorNode

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness (2-second-witness-mobile)
# THE MIRROR NARRATOR (AUTHORITATIVE NARRATION SERVICE)
# Converts PlayerProfile statistical data into natural language companion guidance.
# ---------------------------------------------------------

func _ready():
	if BootTracer: BootTracer.log_init("MirrorNarrator")
	print("[MIRROR NARRATOR] Online. Transforming observation data into living reflection.")

# Stage 1: Since Your Last Session
func get_last_session_summary(profile: Node) -> Array[String]:
	var summary: Array[String] = []
	if not is_instance_valid(profile) or profile.lifetime_sessions <= 1:
		summary.append("Your observation journey is just beginning.")
		summary.append("Complete your first world to start forming patterns.")
		summary.append("Every interaction refines your reflection.")
		return summary
		
	# Analyze drift vs baseline
	var base = profile.cognitive_baseline
	var week = profile.current_week_drift
	
	# Check recall or pattern improvement
	var recall_base_rt = _get_avg_rt(base, "recall")
	var recall_week_rt = _get_avg_rt(week, "recall")
	if recall_base_rt > 0 and recall_week_rt > 0 and recall_week_rt < recall_base_rt:
		var pct = int(((recall_base_rt - recall_week_rt) / recall_base_rt) * 100.0)
		if pct > 0:
			summary.append("Recall speed improved by %d%% since your last session." % pct)
	else:
		summary.append("Your observation pacing is stabilizing across tasks.")
		
	# Check strongest skill
	var strongest_trait = _get_highest_accuracy_trait(base)
	var pretty_strongest = strongest_trait.capitalize().replace("_", " ") if strongest_trait != "" else "Pattern Recognition"
	summary.append("%s remains your strongest observation skill." % pretty_strongest)
	
	# Check streak
	var streak = profile.current_streak
	if streak > 1:
		summary.append("You have maintained an active %d-day observation streak." % streak)
	else:
		summary.append("You have completed %d total observation sessions." % profile.lifetime_sessions)
		
	return summary

# Stage 2: Who Am I Becoming? (Evolving Journey Narration)
func get_journey_narration(profile: Node) -> Dictionary:
	var sessions = profile.lifetime_sessions if is_instance_valid(profile) else 0
	var conf_title = "Developing Reflection"
	var conf_narration = "We are just beginning to understand how you observe."
	
	if sessions <= 5:
		conf_title = "Forming Reflection"
		conf_narration = "We are just beginning to understand how you observe."
	elif sessions <= 20:
		conf_title = "Adapting Patterns"
		conf_narration = "Your observation patterns are adapting and taking shape."
	elif sessions <= 100:
		conf_title = "Established Cadence"
		conf_narration = "Your observation cadence has become remarkably consistent."
	else:
		conf_title = "Disciplined Observer"
		conf_narration = "Few observers demonstrate this level of disciplined consistency."
		
	var base = profile.cognitive_baseline if is_instance_valid(profile) else {}
	var total_att = 0
	var total_succ = 0
	var total_rt = 0.0
	for k in base.keys():
		var d = base[k]
		total_att += d.get("attempts", 0)
		total_succ += d.get("successes", 0)
		total_rt += d.get("total_rt_ms", 0.0)
		
	var overall_acc = (float(total_succ) / float(total_att)) if total_att > 0 else 0.75
	var overall_rt = (total_rt / float(total_att)) if total_att > 0 else 750.0
	
	var style_narration = "You are developing a balanced observation cadence across visual and memory challenges."
	if overall_rt < 650.0 and overall_acc >= 0.75:
		style_narration = "Your current observation style emphasizes rapid speed while maintaining strong accuracy."
	elif overall_acc >= 0.85 and overall_rt >= 650.0:
		style_narration = "Your current approach favors steady, deliberate accuracy over rapid pacing."
		
	return {
		"confidence_title": conf_title,
		"confidence_narration": conf_narration,
		"style_narration": style_narration,
		"level": profile.current_level if is_instance_valid(profile) else 1,
		"xp": profile.experience if is_instance_valid(profile) else 0,
		"sessions": sessions,
		"streak": profile.current_streak if is_instance_valid(profile) else 1
	}

# Stage 3: What The Mirror Sees (Visual Strength Groupings)
func get_strength_cards(profile: Node) -> Dictionary:
	var base = profile.cognitive_baseline if is_instance_valid(profile) else {}
	var trait_names = {
		"pattern_recognition": "Pattern Recognition", "recall": "Recall",
		"rapid_classification": "Rapid Classification", "spatial_tracking": "Spatial Tracking",
		"decision_confidence": "Decision Confidence", "processing_speed": "Processing Speed"
	}
	
	var all_traits: Array[Dictionary] = []
	for k in trait_names.keys():
		var d = base.get(k, {"attempts": 1, "successes": 1, "total_rt_ms": 750.0})
		var att = d.get("attempts", 0)
		var succ = d.get("successes", 0)
		var acc = (float(succ) / float(att)) if att > 0 else 0.75
		var avg_rt = (d.get("total_rt_ms", 0.0) / float(att)) if att > 0 else 750.0
		all_traits.append({
			"id": k,
			"title": trait_names[k],
			"acc": acc,
			"attempts": att,
			"success_rate": "%d%%" % int(acc * 100.0),
			"avg_rt": "%d ms" % int(avg_rt),
			"trend": "Consistent observation pacing"
		})
		
	all_traits.sort_custom(func(a, b): return a["acc"] > b["acc"])
	
	var strength_group: Array[Dictionary] = []
	var improving_group: Array[Dictionary] = []
	var practice_group: Array[Dictionary] = []
	
	for i in range(all_traits.size()):
		var item = all_traits[i]
		if i < 2 or item["acc"] >= 0.8:
			item["stars"] = "★★★★★"
			strength_group.append(item)
		elif i < 4 or item["acc"] >= 0.65:
			item["stars"] = "★★★★☆"
			improving_group.append(item)
		else:
			item["stars"] = "★★☆☆☆"
			practice_group.append(item)
			
	return {
		"strength": strength_group,
		"improving": improving_group,
		"needs_practice": practice_group
	}

# Stage 4: Insights (Natural Coaching Guidance)
func get_insights(profile: Node) -> Array[String]:
	var insights: Array[String] = []
	if not is_instance_valid(profile) or profile.lifetime_sessions == 0:
		insights.append("Your observation profile will begin forming after your first completed world.")
		return insights
		
	var base = profile.cognitive_baseline
	var strongest = _get_highest_accuracy_trait(base)
	var weakest = _get_lowest_accuracy_trait(base)
	
	var trait_names = {
		"pattern_recognition": "spotting hidden patterns", "recall": "recalling sequential details",
		"rapid_classification": "categorizing complex visual signals", "spatial_tracking": "tracking spatial movement",
		"decision_confidence": "making confident decisions under pressure", "processing_speed": "processing rapid visual shifts"
	}
	
	var strong_desc = trait_names.get(strongest, "spotting hidden patterns")
	insights.append("Your greatest strength is %s. You solve these challenges with confidence and precision." % strong_desc)
	
	if weakest != "" and weakest != strongest:
		var weak_title = weakest.capitalize().replace("_", " ")
		insights.append("Your next opportunity: %s challenges take slightly longer to process. A few more sessions will noticeably build your speed and confidence." % weak_title)
	else:
		insights.append("Your observation cadence across different challenge types is exceptionally balanced.")
		
	# Check universe match
	var aff = profile.universe_affinity
	var top_uni = ""
	var top_val = -1
	for u in aff.keys():
		if aff[u] > top_val:
			top_val = aff[u]
			top_uni = u
	if top_uni != "":
		insights.append("Your observation style naturally flourishes within the %s universe." % top_uni.capitalize().replace("_", " "))
		
	return insights

# Stage 5: Continue Your Journey (Actionable Recommendation CTA)
func get_next_recommendation(profile: Node) -> Dictionary:
	var rec: Dictionary = {}
	if is_instance_valid(profile) and profile.has_method("get_adaptive_recommendation"):
		rec = profile.get_adaptive_recommendation()
	else:
		rec = {"universe": "science_lab", "world": "cognitive_bias", "reason": "Your recent sessions suggest this world will strengthen memory while reinforcing your strongest observation skills."}
		
	var u_id = rec.get("universe", "science_lab")
	var w_id = rec.get("world", "cognitive_bias")
	var pretty_uni = u_id.capitalize().replace("_", " ")
	var pretty_world = w_id.capitalize().replace("_", " ")
	
	return {
		"universe": u_id,
		"world": w_id,
		"display_title": "%s — %s" % [pretty_uni, pretty_world],
		"narrative_reason": rec.get("reason", "Your recent sessions suggest this world will build speed while reinforcing your strongest observation skills."),
		"cta_text": "BEGIN OBSERVATION"
	}

# Surprise Narration (Infrequent Milestone Messages)
func get_surprise_narration(profile: Node) -> String:
	if not is_instance_valid(profile): return ""
	var sessions = profile.lifetime_sessions
	var streak = profile.current_streak
	
	if sessions == 10:
		return "Something interesting happened today... Your observation style has shifted noticeably over the past week."
	elif sessions == 25:
		return "For the first time, your spatial tracking precision exceeded your average pattern recognition speed."
	elif streak == 7:
		return "You are becoming remarkably consistent, even during complex visual challenges."
	elif sessions == 50:
		return "The Mirror reflects an observer who adapts effortlessly to new environments."
	return ""

# Internal Helpers
func _get_avg_rt(dict_map: Dictionary, trait_key: String) -> float:
	var d = dict_map.get(trait_key, {})
	var att = d.get("attempts", 0)
	if att > 0:
		return d.get("total_rt_ms", 0.0) / float(att)
	return 0.0

func _get_highest_accuracy_trait(base: Dictionary) -> String:
	var best_k = ""
	var best_val = -1.0
	for k in base.keys():
		var d = base[k]
		var att = d.get("attempts", 0)
		if att > 0:
			var acc = float(d.get("successes", 0)) / float(att)
			if acc > best_val:
				best_val = acc
				best_k = k
	return best_k

func _get_lowest_accuracy_trait(base: Dictionary) -> String:
	var worst_k = ""
	var worst_val = 2.0
	for k in base.keys():
		var d = base[k]
		var att = d.get("attempts", 0)
		if att > 0:
			var acc = float(d.get("successes", 0)) / float(att)
			if acc < worst_val:
				worst_val = acc
				worst_k = k
	return worst_k
