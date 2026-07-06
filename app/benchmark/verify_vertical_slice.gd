extends SceneTree

# ---------------------------------------------------------
# VERTICAL SLICE REGRESSION TEST
# ---------------------------------------------------------
# Verifies the full playable chain that was broken by the
# "mechanic" vs "type" field name mismatch:
#
#   subcategories → mechanics → choose_mechanic →
#   next_observation → build_payload → valid rules
#
# This test runs in-app (not standalone -s) via the
# VerificationRunner, so autoloads resolve correctly.
#
# Usage via runner:
#   godot --headless --path app res://benchmark/VerificationRunner.tscn
#         -- res://benchmark/verify_vertical_slice.gd
# ---------------------------------------------------------

func _init():
	print("\n=================================================================")
	print("[VERTICAL SLICE] Full Playable Chain Regression Test")
	print("=================================================================\n")

	var builder = load("res://scripts/content/ObservationBuilder.gd").new()
	var collection = load("res://scripts/content/ObservationCollection.gd").new()
	var loader = load("res://scripts/content/ContentLoader.gd").new()
	var registry = load("res://scripts/content/ContentRegistry.gd").new()
	var director = load("res://scripts/content/GameplayDirector.gd").new()

	root.add_child(registry)
	registry._ready()
	root.add_child(loader)
	loader._ready()
	root.add_child(collection)
	root.add_child(director)

	var failures: int = 0

	# TEST 1: creative_arts/painting (v2_compiled)
	print("--- TEST 1: creative_arts/painting (v2_compiled) ---")
	loader.load_world_content("creative_arts", "painting")
	var m1 = collection.get_available_mechanics("creative_arts", "painting", "")
	if m1.is_empty():
		push_error("FAIL: get_available_mechanics returned empty for creative_arts/painting")
		failures += 1
	else:
		print("  mechanics: ", m1)
	var c1 = director.choose_mechanic("creative_arts", "painting", "")
	if c1 == "" or c1 == "dynamic":
		push_error("FAIL: choose_mechanic returned '" + c1 + "' for creative_arts/painting")
		failures += 1
	else:
		print("  chosen: ", c1)
		var o1 = collection.next_observation("creative_arts", "painting", "", c1, "vs1")
		var p1 = builder.build_payload(o1, c1, {})
		if p1.get("rules", {}).is_empty():
			push_error("FAIL: build_payload produced empty rules")
			failures += 1
		else:
			print("  served: '", str(p1["rules"].get("prompt","")).substr(0,40), "'")

	# TEST 2: history/ancient_greece (v3_entity, type=dynamic)
	print("\n--- TEST 2: history/ancient_greece (v3_entity) ---")
	loader.load_world_content("history", "ancient_greece")
	var m2 = collection.get_available_mechanics("history", "ancient_greece", "")
	if m2.is_empty():
		push_error("FAIL: get_available_mechanics returned empty for history/ancient_greece")
		failures += 1
	else:
		print("  raw mechanics: ", m2)
	var c2 = director.choose_mechanic("history", "ancient_greece", "")
	if c2 == "" or c2 == "dynamic":
		push_error("FAIL: choose_mechanic returned '" + c2 + "' — dynamic was not expanded to a real mechanic")
		failures += 1
	else:
		print("  chosen (expanded from dynamic): ", c2)
		var o2 = collection.next_observation("history", "ancient_greece", "", c2, "vs2")
		var p2 = builder.build_payload(o2, c2, {})
		if p2.get("rules", {}).is_empty():
			push_error("FAIL: build_payload produced empty rules for history content")
			failures += 1
		else:
			print("  served: '", str(p2["rules"].get("prompt","")).substr(0,40), "'")

	# TEST 3: MechanicResolver.expand
	print("\n--- TEST 3: MechanicResolver ---")
	var expanded = MechanicResolver.expand("dynamic")
	if expanded.size() != 5:
		push_error("FAIL: MechanicResolver.expand('dynamic') should return 5 mechanics, got " + str(expanded.size()))
		failures += 1
	else:
		print("  expand('dynamic'): ", expanded.size(), " mechanics")
	if not MechanicResolver.is_playable("rapid_classification"):
		push_error("FAIL: is_playable('rapid_classification') should be true")
		failures += 1

	# RESULT
	print("\n=================================================================")
	if failures == 0:
		print("🏆 VERTICAL SLICE: ALL TESTS PASSED")
	else:
		print("❌ VERTICAL SLICE: " + str(failures) + " FAILURE(S)")
	print("=================================================================\n")

	registry.free()
	loader.free()
	if collection.get_parent(): collection.free()
	if director.get_parent(): director.free()
	if builder.get_parent(): builder.free()
	quit(failures)
