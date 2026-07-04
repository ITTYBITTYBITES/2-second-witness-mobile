extends SceneTree

func _init():
	print("--- OBSERVATION ENGINE v2.0 VERIFICATION ---")
	
	var builder = load("res://scripts/content/ObservationBuilder.gd").new()
	var collection = load("res://scripts/content/ObservationCollection.gd").new()
	
	# 1. LEGACY v1.0 TEST (Painting)
	var legacy_cko = {
		"id": "legacy_painting_001",
		"rules": {
			"prompt": "Who painted the Mona Lisa?",
			"correct_answer": "Da Vinci",
			"wrong_answers": ["Gogh", "Vermeer", "Dali"]
		}
	}
	
	print("\n[TEST] Legacy v1.0 Adapter")
	var legacy_payload = builder.build_payload(legacy_cko, "rapid_classification")
	print("ID: ", legacy_payload.id)
	print("Prompt: ", legacy_payload.rules.prompt)
	print("Correct: ", legacy_payload.rules.correct_answer)
	assert(legacy_payload.rules.correct_answer == "Da Vinci")
	
	# 2. CKO v2.0 TEST (Sculpture)
	var cko_v2 = {
		"observation_id": "sculpture_marble_001",
		"universe": "creative_arts",
		"world": "sculpture",
		"subcategory": "marble",
		"concept": "David",
		"recognized_answer": "Michelangelo",
		"distractor_family": ["Donatello", "Bernini", "Canova"],
		"difficulty": 2,
		"visual_cues": { "material": "marble", "color": "#FFFFFF" }
	}
	
	print("\n[TEST] CKO v2.0 Dynamic Transformations")
	
	var mechanics = ["rapid_classification", "signal_vs_noise", "odd_one_out", "stroop_test"]
	for mech in mechanics:
		var payload = builder.build_payload(cko_v2, mech)
		print("\nMECHANIC: ", mech.to_upper())
		print("  Payload ID: ", payload.id)
		print("  Prompt:     ", payload.rules.prompt)
		print("  Correct:    ", payload.rules.correct_answer)
		
		match mech:
			"rapid_classification":
				assert(payload.rules.prompt == "David")
				assert(payload.rules.correct_answer == "Michelangelo")
			"signal_vs_noise":
				assert(payload.rules.prompt == "FIND: Michelangelo")
			"odd_one_out":
				assert(payload.rules.prompt == "ANOMALY DETECTION")
				assert(payload.rules.wrong_answers.size() <= 3)
			"stroop_test":
				assert(payload.rules.visual_interference == "#FFFFFF")

	print("\n[TEST] Collection v2.0 Standardization & Caching")
	var standardized = collection.standardize(cko_v2)
	print("Standardized ID: ", standardized.id)
	print("Standardized Mechanic: ", standardized.mechanic)
	assert(standardized.mechanic == "dynamic")
	
	var cached = collection.standardize(cko_v2)
	assert(cached == standardized)
	print("Caching verified.")

	print("\n--- VERIFICATION SUCCESSFUL ---")
	quit()
