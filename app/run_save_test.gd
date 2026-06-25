extends SceneTree

func _init():
	print("\n--- SIMULATING APP BOOT 1 ---")
	var profile = load("res://scripts/system/PlayerProfile.gd").new()
	profile._ready()
	
	print("\n--- SIMULATING COGNITIVE EVENTS ---")
	profile.record_cognitive_event("pattern_recognition", "rapid_classification", "science_lab", true, 850.0)
	profile.record_cognitive_event("pattern_recognition", "rapid_classification", "science_lab", false, 1200.0)
	profile.record_cognitive_event("recall", "memory_cascade", "tech_ops", true, 600.0)
	
	print("\n--- SIMULATING APP KILL & REBOOT ---")
	profile.free()
	
	var profile2 = load("res://scripts/system/PlayerProfile.gd").new()
	profile2._ready()
	
	print("\n--- VALIDATING PERSISTED DATA ---")
	print("Lifetime Sessions: ", profile2.lifetime_sessions)
	print("Universe Affinity (Science Lab): ", profile2.universe_affinity.get("science_lab", 0))
	print("Pattern Successes: ", profile2.cognitive_baseline["pattern_recognition"]["successes"])
	print("Task Familiarity (Memory Cascade): ", profile2.task_familiarity_index.get("memory_cascade", 0))
	
	quit()
