extends SceneTree

var failures: Array[String] = []
var passes: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if condition:
		passes += 1
		print("[PHASE3 PASS] %s" % message)
	else:
		failures.append(message)
		push_error("[PHASE3 FAIL] %s" % message)

func _wait_frames(count: int = 2) -> void:
	for _index: int in range(count):
		await process_frame

func _run() -> void:
	var save: Node = root.get_node("SaveService")
	var profile: Node = root.get_node("ProfileService")
	var settings: Node = root.get_node("SettingsService")
	var theme: Node = root.get_node("ThemeService")
	var accessibility: Node = root.get_node("AccessibilityService")
	var fixture_registry: Node = root.get_node("ChallengeRegistry")
	var family_registry: Node = root.get_node("ChallengeFamilyRegistry")
	var progress: Node = root.get_node("PlayerProgressService")
	var recommendations: Node = root.get_node("RecommendationService")
	var achievements: Node = root.get_node("AchievementService")
	var result_service: Node = root.get_node("ResultService")
	var runtime: Node = root.get_node("ChallengeSessionService")
	var navigation: Node = root.get_node("NavigationService")

	save.call("initialize")
	profile.call("initialize")
	settings.call("initialize")
	theme.call("initialize")
	accessibility.call("initialize")
	fixture_registry.call("initialize")
	family_registry.call("initialize")
	progress.call("initialize")
	recommendations.call("initialize")
	achievements.call("initialize")
	result_service.call("initialize")
	runtime.call("initialize")
	navigation.call("initialize")
	await _wait_frames(2)

	var player_state: Dictionary = progress.call("get_player_state")
	var available: Array[Dictionary] = recommendations.call("get_available_challenge_types", player_state)
	_check(available.size() >= 2, "Challenge Library preserves the original player-visible Challenge Types")
	var available_ids: Array[String] = []
	for item: Dictionary in available:
		available_ids.append(str(item.get("family_id", "")))
		_check(not str(item.get("title", "")).is_empty(), "Library data includes a Challenge Type name")
		_check(not str(item.get("description", "")).is_empty(), "Library data includes a short description")
		_check(ResourceLoader.exists(str(item.get("preview_image", ""))), "Library artwork resolves")
		_check(int(item.get("required_level", 0)) >= 1, "Library data includes a Witness Level requirement")
		_check(item.get("progress", {}) is Dictionary, "Library data includes progress and Mastery")
		_check(item.get("tutorial_profile", {}) is Dictionary, "Library data includes tutorial replay metadata")

	var first_recommendation: Dictionary = recommendations.call("recommend_start", player_state)
	_check(available_ids.has(str(first_recommendation.get("family_id", ""))), "Play Now recommendation comes from the available catalog")
	_check(not str(first_recommendation.get("template_id", "")).is_empty(), "Play Now recommendation resolves a template")
	var first_family: String = str(first_recommendation.get("family_id", ""))
	var witness: Dictionary = profile.get("profile").get("witness_progress", {})
	var families: Dictionary = witness.get("families", {})
	families[first_family] = {"plays": 1, "mastery": 10.0}
	witness["families"] = families
	witness["last_played_family_id"] = first_family
	profile.get("profile")["witness_progress"] = witness
	player_state = progress.call("get_player_state")
	var second_recommendation: Dictionary = recommendations.call("recommend_start", player_state)
	_check(str(second_recommendation.get("family_id", "")) != first_family, "Recommendation introduces an unplayed Challenge Type")
	var featured_a: Dictionary = recommendations.call("recommend_featured", player_state)
	var featured_b: Dictionary = recommendations.call("recommend_featured", player_state)
	_check(featured_a == featured_b, "Featured Challenge Type is deterministic for the current day")

	witness.erase("last_played_family_id")
	witness.erase("last_played_template_id")
	profile.get("profile")["witness_progress"] = witness
	var fallback: Dictionary = recommendations.call("recommend_continue", progress.call("get_player_state"))
	_check(bool(fallback.get("is_fallback", false)), "Continue falls back gracefully when no recent Challenge Type exists")
	var recent_item: Dictionary = available[1]
	witness["last_played_family_id"] = recent_item.get("family_id", "")
	witness["last_played_template_id"] = recent_item.get("default_template_id", "")
	profile.get("profile")["witness_progress"] = witness
	var continued: Dictionary = recommendations.call("recommend_continue", progress.call("get_player_state"))
	_check(not bool(continued.get("is_fallback", true)), "Continue recognizes recent play")
	_check(continued.get("family_id", "") == recent_item.get("family_id", ""), "Continue resumes the most recently played Challenge Type")
	_check(continued.get("template_id", "") == recent_item.get("default_template_id", ""), "Continue resumes the recent template")

	var initial_statuses: Array[Dictionary] = achievements.call("get_statuses")
	var required_titles: Array[String] = [
		"First Witness", "Keen Eye", "Perfect Memory", "Sharp Shooter", "Word Watcher",
		"Scene Specialist", "Consistency", "Comeback", "Marathon", "Flawless Finish"
	]
	_check(initial_statuses.size() >= 10, "Achievement catalog preserves the original ten data-driven definitions")
	var actual_titles: Array[String] = []
	for status: Dictionary in initial_statuses:
		actual_titles.append(str(status.get("title", "")))
	for required_title: String in required_titles:
		_check(actual_titles.has(required_title), "Achievement catalog includes %s" % required_title)
	_check(achievements.call("get_featured_statuses", 3).size() == 3, "Home can request achievements in progress")

	_verify_ui_scenes(available)
	await _wait_frames(3)

	# Build progress satisfying every achievement criterion without relying on UI names.
	families.clear()
	for definition: Dictionary in achievements.call("get_definitions"):
		var family_id: String = str(definition.get("family_id", ""))
		if family_id.is_empty():
			continue
		if not families.has(family_id):
			families[family_id] = {
				"plays": 25,
				"correct": 0,
				"mastery": 0.0,
				"best_streak": 10,
				"history": []
			}
		var family_progress: Dictionary = families[family_id]
		match str(definition.get("criterion", "")):
			"family_correct":
				family_progress["correct"] = maxi(
					int(family_progress.get("correct", 0)),
					int(definition.get("target", 1))
				)
			"family_mastery":
				family_progress["mastery"] = maxf(
					float(family_progress.get("mastery", 0.0)),
					float(definition.get("target", 1.0))
				)
		families[family_id] = family_progress
	if families.size() < 2:
		for family_id: String in available_ids:
			if not families.has(family_id):
				families[family_id] = {"plays": 25, "correct": 10, "mastery": 50.0, "best_streak": 10, "history": []}
	var comeback_family_id: String = str(families.keys()[0])
	var comeback_progress: Dictionary = families[comeback_family_id]
	comeback_progress["history"] = [
		{"outcome": "incorrect", "timestamp": "2026-07-12T10:00:00", "template_id": "round_a"},
		{"outcome": "correct", "timestamp": "2026-07-12T10:01:00", "template_id": "round_b"}
	]
	families[comeback_family_id] = comeback_progress
	witness["families"] = families
	profile.get("profile")["witness_progress"] = witness
	profile.get("profile")["stats"] = {
		"observations_made": 50,
		"correct_observations": 40,
		"fastest_reaction_ms": 850,
		"streak_current": 4,
		"streak_best": 10
	}
	var result := ChallengeResult.new()
	result.outcome = "correct"
	result.reaction_ms = 900
	result.family_id = comeback_family_id
	var newly_unlocked: Array[String] = achievements.call("evaluate_after_result", result)
	_check(newly_unlocked.size() >= 10, "Original achievement criteria evaluate from Witness Progress")
	var unlocked_count: int = int(achievements.call("get_unlocked_count"))
	_check(unlocked_count >= 10, "Original achievements unlock")
	_check((achievements.call("evaluate_after_result", result) as Array).is_empty(), "Achievements unlock exactly once")
	var persisted: Dictionary = save.call("load_profile")
	_check((persisted.get("achievements", []) as Array).size() == unlocked_count, "Achievement unlocks persist through SaveService")

	var record: Dictionary = progress.call("get_observation_record")
	_check(int(record.get("total_plays", 0)) == 50, "Observation Record reports completed rounds")
	_check(is_equal_approx(float(record.get("accuracy", 0.0)), 0.8), "Observation Record reports overall accuracy")
	_check(int(record.get("fastest_response_ms", -1)) == 850, "Observation Record reports fastest response")
	_check((progress.call("get_recent_history", 8) as Array).size() == 2, "Challenge History flattens recent family history")

	var versions: Dictionary = {}
	for family_id: String in available_ids:
		var family: ChallengeFamily = family_registry.call("get_family", family_id)
		versions[family_id] = family.tutorial_version
	var preferences: Dictionary = profile.get("profile").get("preferences", {})
	preferences["family_tutorial_versions"] = versions
	profile.get("profile")["preferences"] = preferences
	witness["last_played_family_id"] = recent_item.get("family_id", "")
	witness["last_played_template_id"] = recent_item.get("default_template_id", "")
	profile.get("profile")["witness_progress"] = witness
	_check(runtime.call("start_continue_session", "continue"), "Continue launches through ChallengeSessionService")
	var snapshot: Dictionary = runtime.call("get_active_session_snapshot")
	_check(snapshot.get("source", "") == "continue", "Runtime records Continue launch source")
	_check(snapshot.get("family_id", "") == recent_item.get("family_id", ""), "Runtime session uses the recent Challenge Type")
	runtime.call("return_home")

	settings.call("set_value", "reading_comfort_mode", true)
	_check(bool(settings.call("get_value", "reading_comfort_mode", false)), "Reading Comfort Mode persists as a setting")

	print("[PHASE3 SUMMARY] %d passed, %d failed" % [passes, failures.size()])
	for failure: String in failures:
		print("[PHASE3 FAILURE] %s" % failure)
	quit(0 if failures.is_empty() else 1)

func _verify_ui_scenes(available: Array[Dictionary]) -> void:
	var home_scene: PackedScene = load("res://src/ui/screens/HomeScreen.tscn")
	var home: Control = home_scene.instantiate() as Control
	root.add_child(home)
	_check(home.has_node("MainMargin/Scroll/Content/PlayNowButton"), "Home presents Play Now")
	_check(home.has_node("MainMargin/Scroll/Content/PrimaryLinks/ContinueButton"), "Home presents Continue")
	_check(home.has_node("MainMargin/Scroll/Content/PrimaryLinks/LibraryButton"), "Home presents Challenge Library")
	_check(home.has_node("MainMargin/Scroll/Content/QuickActions/ProfileButton"), "Home presents Profile quick access")
	_check(home.has_node("MainMargin/Scroll/Content/AchievementsButton"), "Home presents Achievements quick access")
	_check(home.has_node("MainMargin/Scroll/Content/QuickActions/SettingsButton"), "Home presents Settings quick access")
	_check(home.has_node("MainMargin/Scroll/Content/ProgramsCard"), "Home preserves the Programs surface")
	_check(home.get_node("MainMargin/Scroll/Content/FeaturedHost").get_child_count() == 1, "Home renders the daily featured Challenge Type")

	var library_scene: PackedScene = load("res://src/ui/screens/ExperiencesScreen.tscn")
	var library: Control = library_scene.instantiate() as Control
	root.add_child(library)
	var list: VBoxContainer = library.get_node("MainMargin/Scroll/Content/ChallengeList") as VBoxContainer
	_check(list.get_child_count() == available.size(), "Challenge Library renders one card per available type")
	if list.get_child_count() > 0:
		var card: Control = list.get_child(0) as Control
		_check(card.has_node("Margin/VBox/Artwork"), "Library card displays artwork")
		_check(card.has_node("Margin/VBox/RequirementLabel"), "Library card displays Witness Level requirement")
		_check(card.has_node("Margin/VBox/MasteryBar"), "Library card displays Mastery")
		_check(card.has_node("Margin/VBox/MetricsRow/StreakLabel"), "Library card displays best streak")
		_check(card.has_node("Margin/VBox/BottomRow/TutorialButton"), "Library card provides tutorial replay")

	var profile_scene: PackedScene = load("res://src/ui/screens/ProfileScreen.tscn")
	var profile_screen: Control = profile_scene.instantiate() as Control
	root.add_child(profile_screen)
	_check(profile_screen.has_node("Margin/Scroll/VBox/StatsGrid"), "Profile presents the Observation Record")
	_check(profile_screen.has_node("Margin/Scroll/VBox/ExperienceProgress"), "Profile presents Family Mastery")
	_check(profile_screen.has_node("Margin/Scroll/VBox/HistoryList"), "Profile presents Challenge History")
	_check(profile_screen.has_node("Margin/Scroll/VBox/AchievementCard"), "Profile presents achievement summary")
	_check(profile_screen.has_node("Margin/Scroll/VBox/CollectionsCard"), "Profile is future-ready for Collections")

	var achievements_scene: PackedScene = load("res://src/ui/screens/AchievementsScreen.tscn")
	var achievements_screen: Control = achievements_scene.instantiate() as Control
	root.add_child(achievements_screen)
	var achievement_service: Node = root.get_node("AchievementService")
	_check(achievements_screen.get_node("Margin/Scroll/Content/AchievementList").get_child_count() == (achievement_service.call("get_statuses") as Array).size(), "Achievements screen renders the data-driven catalog")

	var settings_scene: PackedScene = load("res://src/ui/screens/SettingsScreen.tscn")
	var settings_screen: Control = settings_scene.instantiate() as Control
	root.add_child(settings_screen)
	var settings_text: String = _collect_text(settings_screen)
	for expected: String in ["Audio", "Music", "Haptics", "Reading Comfort Mode", "Text Size", "Reduced Motion", "High Contrast", "Privacy", "Credits", "About"]:
		_check(settings_text.contains(expected), "Settings presents %s" % expected)

	var routes_script: Script = load("res://src/core/navigation/AppRoutes.gd")
	_check(bool(routes_script.call("is_valid_route", "achievements")), "Achievements is a valid app route")

	home.queue_free()
	library.queue_free()
	profile_screen.queue_free()
	achievements_screen.queue_free()
	settings_screen.queue_free()

func _collect_text(node: Node) -> String:
	var output: String = ""
	if node is Label:
		output += (node as Label).text + "\n"
	elif node is Button:
		output += (node as Button).text + "\n"
	for child: Node in node.get_children():
		output += _collect_text(child)
	return output
