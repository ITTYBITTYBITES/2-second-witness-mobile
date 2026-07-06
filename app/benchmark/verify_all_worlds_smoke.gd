extends SceneTree

# ---------------------------------------------------------
# END-TO-END WORLD SMOKE TEST
# ---------------------------------------------------------
# For every published world: load, discover mechanics, generate
# one playable round per mechanic, validate payload.
#
# Answers: "Can every published world produce at least one
# playable round for every mechanic it advertises?"
#
# Runs in-app via VerificationRunner (autoloads resolve correctly).
# ---------------------------------------------------------

func _init():
	print("\n=================================================================")
	print("[WORLD SMOKE TEST] End-to-End Playable Round Validation")
	print("=================================================================\n")

	var loader = load("res://scripts/content/ContentLoader.gd").new()
	var registry = load("res://scripts/content/ContentRegistry.gd").new()
	var collection = load("res://scripts/content/ObservationCollection.gd").new()
	var builder = load("res://scripts/content/ObservationBuilder.gd").new()
	var director = load("res://scripts/content/GameplayDirector.gd").new()

	root.add_child(registry)
	registry._ready()
	root.add_child(loader)
	loader._ready()
	root.add_child(collection)
	root.add_child(director)

	loader.load_all_content()

	var worlds_passed: int = 0
	var worlds_failed: int = 0
	var total_rounds: int = 0
	var rounds_passed: int = 0
	var rounds_failed: int = 0
	var failures: Array = []

	for u_id in registry.get_all_universes():
		for w_id in registry.get_all_worlds_in_universe(u_id):
			var scenarios = registry.get_all_scenarios_in_world(u_id, w_id)
			if scenarios.is_empty():
				continue  # Skip empty worlds (not published yet)

			# Discover mechanics
			var raw_mechs = collection.get_available_mechanics(u_id, w_id, "")
			var mechs = MechanicResolver.expand_all(raw_mechs)
			if mechs.is_empty():
				failures.append(u_id + "/" + w_id + ": no mechanics discovered")
				worlds_failed += 1
				continue

			var world_ok: bool = true
			for mech in mechs:
				total_rounds += 1
				var obs = collection.next_observation(u_id, w_id, "", str(mech), "smoke_" + str(u_id) + "_" + str(w_id) + "_" + str(mech))
				if obs.is_empty():
					failures.append(u_id + "/" + w_id + " [" + str(mech) + "]: next_observation returned empty")
					rounds_failed += 1
					world_ok = false
					continue

				var payload = builder.build_payload(obs, str(mech), {"universe": u_id, "world": w_id})
				var rules = payload.get("rules", {})
				if rules.is_empty():
					failures.append(u_id + "/" + w_id + " [" + str(mech) + "]: build_payload produced empty rules")
					rounds_failed += 1
					world_ok = false
					continue

				var prompt = str(rules.get("prompt", ""))
				var answer = str(rules.get("correct_answer", ""))
				if prompt == "" or answer == "":
					failures.append(u_id + "/" + w_id + " [" + str(mech) + "]: empty prompt or answer")
					rounds_failed += 1
					world_ok = false
					continue

				rounds_passed += 1

			if world_ok:
				worlds_passed += 1
			else:
				worlds_failed += 1

	print("Worlds: ", worlds_passed, " passed / ", worlds_failed, " failed")
	print("Rounds: ", rounds_passed, " passed / ", rounds_failed, " failed (out of ", total_rounds, ")")

	if not failures.is_empty():
		print("\nFailures:")
		for f in failures:
			print("  ✗ ", f)

	print("\n=================================================================")
	if failures.is_empty():
		print("🏆 WORLD SMOKE TEST: ALL PASSED")
	else:
		print("❌ WORLD SMOKE TEST: " + str(failures.size()) + " FAILURE(S)")
	print("=================================================================\n")

	registry.free()
	loader.free()
	if collection.get_parent(): collection.free()
	if director.get_parent(): director.free()
	if builder.get_parent(): builder.free()
	quit(0 if failures.is_empty() else 1)
