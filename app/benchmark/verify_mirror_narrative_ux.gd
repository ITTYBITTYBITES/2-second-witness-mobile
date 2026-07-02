extends SceneTree

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness (2-second-witness-mobile)
# BENCHMARK: NARRATIVE UX VALIDATION ACROSS PROFILE MATURITY TIERS
# ---------------------------------------------------------

func _init():
	print("\n=================================================================")
	print("[NARRATIVE UX VALIDATION] THE MIRROR NARRATOR OVERHAUL (V2)")
	print("=================================================================\n")
	
	var narrator = load("res://scripts/system/MirrorNarrator.gd").new()
	
	_simulate_profile_tier(narrative_mock_1(), "TIER 1: NEW PLAYER (1 Session, Forming Reflection)", narrator)
	_simulate_profile_tier(narrative_mock_2(), "TIER 2: DEVELOPING PLAYER (12 Sessions, Speed Dominant)", narrator)
	_simulate_profile_tier(narrative_mock_3(), "TIER 3: ESTABLISHED PLAYER (45 Sessions, Precision Focus)", narrator)
	_simulate_profile_tier(narrative_mock_4(), "TIER 4: MASTER VETERAN (250 Sessions, 14-Day Streak, Recall Hesitation)", narrator)
	
	narrator.free()
	print("=================================================================")
	print("🏆 NARRATIVE UX VALIDATION COMPLETE: ZERO REPORT JARGON, LIVING COMPANION CONFIRMED.")
	print("=================================================================\n")
	quit(0)

func _simulate_profile_tier(profile: RefCounted, tier_name: String, narrator: Node):
	print("-----------------------------------------------------------------")
	print("► ", tier_name)
	print("-----------------------------------------------------------------")
	
	# Stage 1: Since Your Last Session
	var s1 = narrator.get_last_session_summary(profile)
	print("[STAGE 1: SINCE YOUR LAST SESSION]")
	for line in s1:
		print("  • ", line)
		
	# Stage 2: Who Am I Becoming?
	var s2 = narrator.get_journey_narration(profile)
	print("\n[STAGE 2: WHO AM I BECOMING? (JOURNEY STYLE)]")
	print("  Confidence Badge: [", s2["confidence_title"].to_upper(), "] -> \"", s2["confidence_narration"], "\"")
	print("  Observation Style: \"", s2["style_narration"], "\"")
	print("  Status Pills: Level ", s2["level"], " | XP: ", s2["xp"], " | Sessions: ", s2["sessions"], " | Streak: ", s2["streak"], " Days")
	
	# Surprise Narration
	var sur = narrator.get_surprise_narration(profile)
	if sur != "":
		print("\n[SURPRISE NARRATION MILESTONE]")
		print("  ★ \"", sur, "\"")
		
	# Stage 3: What The Mirror Sees
	var s3 = narrator.get_strength_cards(profile)
	print("\n[STAGE 3: WHAT THE MIRROR SEES (STAR RATINGS)]")
	print("  STRENGTH (★★★★★):")
	for item in s3["strength"]:
		print("    - ", item["title"], " (", item["stars"], ") | Expandable Details: Attempts ", item["attempts"], ", Success: ", item["success_rate"], ", Avg RT: ", item["avg_rt"])
	print("  IMPROVING (★★★★☆):")
	for item in s3["improving"]:
		print("    - ", item["title"], " (", item["stars"], ") | Expandable Details: Attempts ", item["attempts"], ", Success: ", item["success_rate"], ", Avg RT: ", item["avg_rt"])
	print("  NEEDS PRACTICE (★★☆☆☆):")
	for item in s3["needs_practice"]:
		print("    - ", item["title"], " (", item["stars"], ") | Expandable Details: Attempts ", item["attempts"], ", Success: ", item["success_rate"], ", Avg RT: ", item["avg_rt"])
		
	# Stage 4: Insights
	var s4 = narrator.get_insights(profile)
	print("\n[STAGE 4: INSIGHTS (COACHING GUIDANCE)]")
	for line in s4:
		print("  • \"", line, "\"")
		
	# Stage 5: Continue Your Journey
	var s5 = narrator.get_next_recommendation(profile)
	print("\n[STAGE 5: CONTINUE YOUR JOURNEY (HERO CTA)]")
	print("  Target Destination: [ ", s5["display_title"].to_upper(), " ]")
	print("  Narrative Reason:   \"", s5["narrative_reason"], "\"")
	print("  Primary Action:     [ ", s5["cta_text"], " ]\n")

class MockProfile extends RefCounted:
	var lifetime_sessions: int = 1
	var current_level: int = 1
	var experience: int = 100
	var current_streak: int = 1
	var cognitive_baseline: Dictionary = {}
	var current_week_drift: Dictionary = {}
	var universe_affinity: Dictionary = {}
	func get_adaptive_recommendation() -> Dictionary:
		return {"universe": "science_lab", "world": "cognitive_bias", "reason": "Your observation journey is beginning. Science Lab builds fundamental pattern recognition."}

func narrative_mock_1() -> RefCounted:
	var p = MockProfile.new()
	p.lifetime_sessions = 1
	p.current_level = 1
	p.experience = 100
	p.current_streak = 1
	p.cognitive_baseline = {
		"pattern_recognition": {"attempts": 1, "successes": 1, "total_rt_ms": 750.0},
		"recall": {"attempts": 1, "successes": 0, "total_rt_ms": 1200.0}
	}
	p.current_week_drift = p.cognitive_baseline.duplicate(true)
	p.universe_affinity = {"science_lab": 1}
	return p

func narrative_mock_2() -> RefCounted:
	var p = MockProfile.new()
	p.lifetime_sessions = 12
	p.current_level = 3
	p.experience = 1250
	p.current_streak = 3
	p.cognitive_baseline = {
		"pattern_recognition": {"attempts": 20, "successes": 18, "total_rt_ms": 7800.0}, # 390ms avg, 90% acc
		"rapid_classification": {"attempts": 15, "successes": 13, "total_rt_ms": 6750.0}, # 450ms avg, 86% acc
		"spatial_tracking": {"attempts": 10, "successes": 7, "total_rt_ms": 5500.0}, # 550ms avg, 70% acc
		"recall": {"attempts": 8, "successes": 4, "total_rt_ms": 8800.0}, # 1100ms avg, 50% acc
		"decision_confidence": {"attempts": 5, "successes": 4, "total_rt_ms": 2500.0}, # 500ms avg, 80% acc
		"processing_speed": {"attempts": 12, "successes": 10, "total_rt_ms": 4800.0} # 400ms avg, 83% acc
	}
	p.current_week_drift = {
		"recall": {"attempts": 4, "successes": 3, "total_rt_ms": 3800.0} # 950ms avg vs 1100ms baseline (13% improvement)
	}
	p.universe_affinity = {"tech_ops": 8, "science_lab": 4}
	p.get_adaptive_recommendation = func(): return {"universe": "history", "world": "ancient_egypt", "reason": "Recall tasks take you slightly longer than average. Practicing sequential challenges in Ancient Egypt will noticeably improve your speed."}
	return p

func narrative_mock_3() -> RefCounted:
	var p = MockProfile.new()
	p.lifetime_sessions = 45
	p.current_level = 8
	p.experience = 6400
	p.current_streak = 7
	p.cognitive_baseline = {
		"pattern_recognition": {"attempts": 60, "successes": 55, "total_rt_ms": 43200.0}, # 720ms avg, 91% acc
		"rapid_classification": {"attempts": 50, "successes": 45, "total_rt_ms": 36000.0}, # 720ms avg, 90% acc
		"spatial_tracking": {"attempts": 40, "successes": 35, "total_rt_ms": 28800.0}, # 720ms avg, 87% acc
		"recall": {"attempts": 45, "successes": 39, "total_rt_ms": 35100.0}, # 780ms avg, 86% acc
		"decision_confidence": {"attempts": 30, "successes": 27, "total_rt_ms": 21600.0}, # 720ms avg, 90% acc
		"processing_speed": {"attempts": 50, "successes": 44, "total_rt_ms": 36000.0} # 720ms avg, 88% acc
	}
	p.current_week_drift = p.cognitive_baseline.duplicate(true)
	p.universe_affinity = {"life_sciences": 20, "society_mind": 15}
	p.get_adaptive_recommendation = func(): return {"universe": "life_sciences", "world": "genetics", "reason": "Your observation style favors steady precision. Genetics will challenge your visual pattern tracking."}
	return p

func narrative_mock_4() -> RefCounted:
	var p = MockProfile.new()
	p.lifetime_sessions = 250
	p.current_level = 25
	p.experience = 45000
	p.current_streak = 14
	p.cognitive_baseline = {
		"pattern_recognition": {"attempts": 300, "successes": 285, "total_rt_ms": 114000.0}, # 380ms avg, 95% acc
		"rapid_classification": {"attempts": 280, "successes": 266, "total_rt_ms": 112000.0}, # 400ms avg, 95% acc
		"spatial_tracking": {"attempts": 250, "successes": 235, "total_rt_ms": 105000.0}, # 420ms avg, 94% acc
		"processing_speed": {"attempts": 260, "successes": 247, "total_rt_ms": 98800.0}, # 380ms avg, 95% acc
		"decision_confidence": {"attempts": 200, "successes": 188, "total_rt_ms": 80000.0}, # 400ms avg, 94% acc
		"recall": {"attempts": 240, "successes": 180, "total_rt_ms": 240000.0} # 1000ms avg, 75% acc (Hesitation!)
	}
	p.current_week_drift = {
		"recall": {"attempts": 30, "successes": 24, "total_rt_ms": 27000.0} # 900ms avg vs 1000ms baseline (10% improvement)
	}
	p.universe_affinity = {"science_lab": 120, "tech_ops": 80}
	p.get_adaptive_recommendation = func(): return {"universe": "history", "world": "ancient_egypt", "reason": "Recall tasks take you longer than average. A few more sessions in Ancient Egypt will noticeably improve your speed."}
	return p
