extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# PROGRESSION INTERPRETER — SINGLE SOURCE OF TRUTH
# ---------------------------------------------------------
# Authoritative event interpreter and routing arbiter for all
# cognitive observation continuity, streak tracking, world
# mastery, and pre-activation selection screen context.
# ---------------------------------------------------------

signal progression_event_processed(event_type: int, value: Variant, context: Dictionary, timestamp: float)

enum ProgressionEventType {
	SESSION_COMPLETE,
	STREAK_EXTENDED,
	WORLD_PROGRESS,
	WORLD_UNLOCKED,
	MASTERY_INCREASE,
	MIRROR_UPDATE
}

func _ready():
	if Engine.get_main_loop() and Engine.get_main_loop().root.get_node_or_null("BootTracer"):
		var tracer = Engine.get_main_loop().root.get_node_or_null("BootTracer")
		if tracer.has_method("log_init"):
			tracer.log_init("ProgressionInterpreter")
	print("[PROGRESSION INTERPRETER] Online. Authoritative single source of truth for cognitive observation continuity.")

func process_progression_event(event_type: int, value: Variant, context: Dictionary = {}, timestamp: float = -1.0):
	if timestamp < 0.0:
		timestamp = Time.get_unix_time_from_system()
		
	print("[PROGRESSION INTERPRETER] Processing Event Type %d | Value: %s | Context: %s" % [event_type, str(value), str(context)])
	
	match event_type:
		ProgressionEventType.SESSION_COMPLETE:
			_handle_session_complete(value, context, timestamp)
		ProgressionEventType.MIRROR_UPDATE:
			progression_event_processed.emit(ProgressionEventType.MIRROR_UPDATE, value, context, timestamp)
		_:
			progression_event_processed.emit(event_type, value, context, timestamp)

func _handle_session_complete(value: Variant, context: Dictionary, timestamp: float):
	var s_id = str(context.get("scenario_id", "unknown"))
	var u_id = str(context.get("universe_id", "history"))
	var w_id = str(context.get("world_id", "ancient_egypt"))
	var success = bool(context.get("success", bool(value) if typeof(value) == TYPE_BOOL else (int(value) > 0)))
	var rt_ms = float(context.get("reaction_time_ms", 500.0))
	var c_trait = str(context.get("trait", _resolve_trait_for_scenario(s_id)))
	
	var profile = Engine.get_main_loop().root.get_node_or_null("PlayerProfile") if Engine.get_main_loop() else null
	var tracker = Engine.get_main_loop().root.get_node_or_null("SessionTracker") if Engine.get_main_loop() else null
	
	var old_mastery = get_world_mastery_percentage(u_id, w_id)
	var old_streak = profile.current_streak if profile else 1
	var old_unlocked = profile.unlocked_universes.duplicate() if (profile and "unlocked_universes" in profile) else []
	
	if profile and profile.has_method("record_cognitive_event"):
		profile.record_cognitive_event(c_trait, s_id, u_id, w_id, success, rt_ms)
	if tracker and tracker.has_method("record_spike_result"):
		tracker.record_spike_result(s_id, success)
		
	var new_mastery = get_world_mastery_percentage(u_id, w_id)
	var new_streak = profile.current_streak if profile else 1
	var new_unlocked = profile.unlocked_universes if (profile and "unlocked_universes" in profile) else []
	
	progression_event_processed.emit(ProgressionEventType.SESSION_COMPLETE, 1 if success else 0, context, timestamp)
	
	if new_streak > old_streak:
		print("[PROGRESSION INTERPRETER] Continuity Streak Extended: ", old_streak, " -> ", new_streak)
		progression_event_processed.emit(ProgressionEventType.STREAK_EXTENDED, new_streak, {"old": old_streak, "new": new_streak, "universe_id": u_id, "world_id": w_id}, timestamp)
		
	if new_mastery > old_mastery:
		print("[PROGRESSION INTERPRETER] Mastery Increased for %s: %d%% -> %d%%" % [w_id, old_mastery, new_mastery])
		progression_event_processed.emit(ProgressionEventType.MASTERY_INCREASE, new_mastery, {"old": old_mastery, "new": new_mastery, "universe_id": u_id, "world_id": w_id}, timestamp)
		
	progression_event_processed.emit(ProgressionEventType.WORLD_PROGRESS, new_mastery, {"universe_id": u_id, "world_id": w_id, "mastery": new_mastery}, timestamp)
	
	for uni in new_unlocked:
		if not old_unlocked.has(uni):
			print("[PROGRESSION INTERPRETER] New Universe Unlocked: ", uni)
			progression_event_processed.emit(ProgressionEventType.WORLD_UNLOCKED, uni, {"universe_id": uni}, timestamp)

func _resolve_trait_for_scenario(scenario_id: String) -> String:
	match scenario_id.to_lower():
		"math_surprise": return "processing_speed"
		"memory_cascade": return "recall"
		"odd_one_out", "pattern_continuation", "stroop_test": return "pattern_recognition"
		"rapid_classification", "signal_vs_noise": return "rapid_classification"
		"reflex_tap", "speed_sort": return "processing_speed"
		"risk_selection": return "decision_confidence"
		"sequence_reverse", "spatial_recall": return "recall"
		_: return "general"

func get_world_mastery_percentage(universe_id: String, world_id: String) -> int:
	var profile = Engine.get_main_loop().root.get_node_or_null("PlayerProfile") if Engine.get_main_loop() else null
	if not profile: return 0
	var world_key = universe_id + "_" + world_id
	var affinity = profile.world_affinity.get(world_key, 0) if "world_affinity" in profile else 0
	return clamp(int((float(affinity) / 500.0) * 100.0), 0, 100)

func get_current_streak() -> int:
	var profile = Engine.get_main_loop().root.get_node_or_null("PlayerProfile") if Engine.get_main_loop() else null
	return profile.current_streak if (profile and "current_streak" in profile) else 1

func get_total_sessions() -> int:
	var profile = Engine.get_main_loop().root.get_node_or_null("PlayerProfile") if Engine.get_main_loop() else null
	return profile.lifetime_sessions if (profile and "lifetime_sessions" in profile) else 0

func get_mastery_tier_name(universe_id: String, world_id: String) -> String:
	var lm = Engine.get_main_loop().root.get_node_or_null("LensMorphology") if Engine.get_main_loop() else null
	if lm and lm.has_method("get_world_mastery"):
		var tier = lm.get_world_mastery(universe_id, world_id)
		match tier:
			0: return "BASE"
			1: return "DEVELOPING"
			2: return "COMPLEX"
			3: return "ZENITH"
	return "BASE"

func get_universe_progression_context(universe_id: String) -> Dictionary:
	var profile = Engine.get_main_loop().root.get_node_or_null("PlayerProfile") if Engine.get_main_loop() else null
	var sessions = profile.lifetime_sessions if (profile and "lifetime_sessions" in profile) else 0
	var streak = profile.current_streak if (profile and "current_streak" in profile) else 1
	var fav_trait = profile.favorite_mechanic.capitalize().replace("_", " ") if (profile and "favorite_mechanic" in profile and profile.favorite_mechanic != "") else "Pattern Recognition"
	
	var u_affinity = profile.universe_affinity.get(universe_id, 0) if (profile and "universe_affinity" in profile) else 0
	var u_mastery_pct = clamp(int((float(u_affinity) / 1000.0) * 100.0), 0, 100)
	var tier_str = "DEVELOPING" if u_mastery_pct > 20 else ("COMPLEX" if u_mastery_pct > 50 else ("ZENITH" if u_mastery_pct == 100 else "BASE"))
	
	return {
		"global_mastery_trend": "GLOBAL MASTERY: %d%% (%s)" % [u_mastery_pct, tier_str],
		"continuity": "TOTAL OBSERVATIONS: %d | STREAK: %d DAYS" % [sessions, streak],
		"profile_overview": "PRIMARY FOCUS: %s" % fav_trait.to_upper()
	}

func get_world_progression_context(universe_id: String, world_id: String) -> Dictionary:
	var profile = Engine.get_main_loop().root.get_node_or_null("PlayerProfile") if Engine.get_main_loop() else null
	var world_key = universe_id + "_" + world_id
	var affinity = profile.world_affinity.get(world_key, 0) if (profile and "world_affinity" in profile) else 0
	var mastery_pct = get_world_mastery_percentage(universe_id, world_id)
	var tier_name = get_mastery_tier_name(universe_id, world_id)
	
	var trend_str = "CONSISTENT" if affinity > 10 else ("FORMING" if affinity > 0 else "INITIALIZING")
	
	return {
		"world_mastery": "WORLD MASTERY: %d%% (%s TIER)" % [mastery_pct, tier_name],
		"recent_trend": "RECENT TREND: %s" % trend_str,
		"recency": "RECENCY: %d OBSERVATIONS IN LOG" % affinity
	}

func get_scenario_progression_context(scenario_id: String) -> Dictionary:
	var tracker = Engine.get_main_loop().root.get_node_or_null("SessionTracker") if Engine.get_main_loop() else null
	var profile = Engine.get_main_loop().root.get_node_or_null("PlayerProfile") if Engine.get_main_loop() else null
	
	var attempts = 0
	var successes = 0
	if tracker and "spike_stats" in tracker and tracker.spike_stats.has(scenario_id):
		attempts = tracker.spike_stats[scenario_id].get("attempts", 0)
		successes = tracker.spike_stats[scenario_id].get("successes", 0)
	elif profile and "task_familiarity_index" in profile:
		attempts = profile.task_familiarity_index.get(scenario_id, 0)
		successes = int(attempts * 0.8)
		
	var rate = int((float(successes) / float(max(1, attempts))) * 100.0) if attempts > 0 else 100
	var readiness = "OPTIMAL" if (attempts > 5 and rate >= 70) else ("CALIBRATING" if attempts > 0 else "PRIMED")
	var streak_est = clamp(successes % 5 + (1 if successes > 0 else 0), 0, 10)
	
	return {
		"readiness": "PROTOCOL READINESS: %s" % readiness,
		"recent_perf": "SUCCESS RATE: %d%% (%d ATTEMPTS)" % [rate, attempts],
		"entry_streak": "MECHANIC STREAK: %d CONSISTENT" % streak_est
	}
