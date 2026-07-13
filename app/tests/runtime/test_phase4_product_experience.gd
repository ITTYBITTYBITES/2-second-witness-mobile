extends SceneTree

var failures: Array[String] = []
var passes: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if condition:
		passes += 1
		print("[PHASE4 PASS] %s" % message)
	else:
		failures.append(message)
		push_error("[PHASE4 FAIL] %s" % message)

func _wait_frames(count: int = 2) -> void:
	for _index: int in range(count):
		await process_frame

func _run() -> void:
	var save: Node = root.get_node("SaveService")
	var profile: Node = root.get_node("ProfileService")
	var settings: Node = root.get_node("SettingsService")
	var analytics: Node = root.get_node("AnalyticsService")
	var theme: Node = root.get_node("ThemeService")
	var accessibility: Node = root.get_node("AccessibilityService")
	var fixture_registry: Node = root.get_node("ChallengeRegistry")
	var family_registry: Node = root.get_node("ChallengeFamilyRegistry")
	var progress: Node = root.get_node("PlayerProgressService")
	var recommendations: Node = root.get_node("RecommendationService")
	var programs: Node = root.get_node("ProgramService")
	var achievements: Node = root.get_node("AchievementService")
	var results: Node = root.get_node("ResultService")
	var runtime: Node = root.get_node("ChallengeSessionService")
	var navigation: Node = root.get_node("NavigationService")

	save.call("initialize")
	profile.call("initialize")
	settings.call("initialize")
	analytics.call("initialize")
	accessibility.call("initialize")
	theme.call("initialize")
	fixture_registry.call("initialize")
	family_registry.call("initialize")
	progress.call("initialize")
	recommendations.call("initialize")
	programs.call("initialize")
	achievements.call("initialize")
	results.call("initialize")
	runtime.call("initialize")
	navigation.call("initialize")
	await _wait_frames()

	var player_state: Dictionary = progress.call("get_player_state")
	var catalog: Array[Dictionary] = recommendations.call("get_available_challenge_types", player_state)
	_check(catalog.size() >= 2, "Phase 4 catalog preserves the original production Challenge Types")
	for item: Dictionary in catalog:
		_check(item.get("gameplay_focus", []) is Array, "Catalog exposes family-owned gameplay focus")
		_check(float(item.get("recommendation_weight", 0.0)) > 0.0, "Catalog exposes family-owned recommendation weight")
		_check(item.has("favorite"), "Catalog exposes favorite state without a family-specific UI branch")

	var definitions: Array[Dictionary] = programs.call("get_definitions")
	_check(definitions.size() >= 6, "The original six curated Programs remain available")
	var required_programs: Array[String] = [
		"Daily Witness", "Observation Bootcamp", "Rapid Recall",
		"Mixed Rotation", "Favorites Run", "Weekend Challenge"
	]
	var program_titles: Array[String] = []
	for definition: Dictionary in definitions:
		program_titles.append(str(definition.get("title", "")))
		_check(int(definition.get("round_count", 0)) > 0, "Program declares a finite round count")
		_check(not str(definition.get("selection_policy", "")).is_empty(), "Program declares a selection policy")
	for title: String in required_programs:
		_check(program_titles.has(title), "Program catalog includes %s" % title)

	var favorite_family_id: String = str(catalog[0].get("family_id", ""))
	_check(progress.call("set_family_favorite", favorite_family_id, true), "Challenge Type can be marked as a favorite")
	_check((progress.call("get_favorite_family_ids") as Array).has(favorite_family_id), "Favorite state persists through PlayerProgressService")
	var persisted_after_favorite: Dictionary = save.call("load_profile")
	_check((persisted_after_favorite.get("favorite_challenge_types", []) as Array).has(favorite_family_id), "Favorite state persists through SaveService")
	player_state = progress.call("get_player_state")
	var favorite_recommendation: Dictionary = programs.call("recommend_for_program", "challenge_favorites", player_state)
	_check(favorite_recommendation.get("family_id", "") == favorite_family_id, "Favorites Run selects a favorite Challenge Type")
	_check((profile.get("profile").get("achievements", []) as Array).has("curator"), "Favoriting unlocks the Curator achievement")

	# Skip tutorial gates so the test isolates Program selection and runtime context.
	var tutorial_versions: Dictionary = {}
	for family_id: String in family_registry.call("get_visible_family_ids"):
		var family: ChallengeFamily = family_registry.call("get_family", family_id)
		tutorial_versions[family_id] = family.tutorial_version
	var preferences: Dictionary = profile.get("profile").get("preferences", {})
	preferences["family_tutorial_versions"] = tutorial_versions
	profile.get("profile")["preferences"] = preferences

	_check(runtime.call("start_program_session", "daily_witness", "program"), "Program launches through ChallengeSessionService")
	var snapshot: Dictionary = runtime.call("get_active_session_snapshot")
	_check(snapshot.get("program_id", "") == "daily_witness", "Runtime session carries generic Program context")
	_check(snapshot.get("source", "") == "program", "Runtime records Program launch source")
	_submit_correct(runtime)
	var first_result: ChallengeResult = runtime.call("get_active_result")
	var first_program_data: Dictionary = first_result.metadata.get("program_progress", {})
	_check(int(first_program_data.get("round", 0)) == 1 and not bool(first_program_data.get("run_completed", true)), "First Program round updates run progress")
	runtime.call("return_home")

	player_state = progress.call("get_player_state")
	var continue_recommendation: Dictionary = recommendations.call("recommend_continue", player_state)
	_check(continue_recommendation.get("program_id", "") == "daily_witness", "Continue prioritizes an unfinished Program")
	_check(runtime.call("start_continue_session", "continue"), "Continue resumes unfinished Program through runtime")
	_check((runtime.call("get_active_session_snapshot") as Dictionary).get("program_id", "") == "daily_witness", "Resumed session preserves Program context")
	_submit_correct(runtime)
	runtime.call("return_home")

	_check(runtime.call("start_continue_session", "continue"), "Continue launches the final Program round")
	_submit_correct(runtime)
	var final_result: ChallengeResult = runtime.call("get_active_result")
	var final_data: Dictionary = final_result.metadata.get("program_progress", {})
	_check(bool(final_data.get("run_completed", false)), "Finite Program run completes at its declared round count")
	_check(int(programs.call("get_completed_run_count")) == 1, "Program completion is recorded once")
	_check(str(profile.get("profile").get("active_program_id", "")) == "", "Completed Program clears resume state")
	_check((final_result.recommendation as Dictionary).get("program_complete", false), "Completed Program produces a finish-run recommendation")
	_check(runtime.call("continue_recommended"), "Finish Run returns through the standard runtime lifecycle")
	_check(str(navigation.get("current_route")) == "home", "Finished Program returns Home")
	_check((profile.get("profile").get("achievements", []) as Array).has("first_journey"), "Completing a Program unlocks First Journey")

	var achievement_titles: Array[String] = []
	for definition: Dictionary in achievements.call("get_definitions"):
		achievement_titles.append(str(definition.get("title", "")))
	for title: String in ["Versatile Witness", "Curator", "First Journey", "All Angles"]:
		_check(achievement_titles.has(title), "Expanded achievement catalog includes %s" % title)

	await _verify_screens(programs, progress)

	print("[PHASE4 SUMMARY] %d passed, %d failed" % [passes, failures.size()])
	for failure: String in failures:
		print("[PHASE4 FAILURE] %s" % failure)
	quit(0 if failures.is_empty() else 1)

func _submit_correct(runtime: Node) -> void:
	var instance: ChallengeInstance = runtime.call("get_active_instance")
	runtime.call("submit_response", instance.correct_answer, 750)

func _verify_screens(programs: Node, progress: Node) -> void:
	var programs_scene: PackedScene = load("res://src/ui/screens/ProgramsScreen.tscn")
	var programs_screen: Control = programs_scene.instantiate() as Control
	root.add_child(programs_screen)
	await _wait_frames()
	var program_list: VBoxContainer = programs_screen.get_node("MainMargin/Scroll/Content/ProgramList") as VBoxContainer
	_check(program_list.get_child_count() == programs.call("get_definitions").size(), "Programs screen renders the data-driven catalog")
	_check(programs_screen.has_node("MainMargin/Scroll/Content/Header/Subtitle"), "Programs explains curated runtime selection")

	var home_scene: PackedScene = load("res://src/ui/screens/HomeScreen.tscn")
	var home: Control = home_scene.instantiate() as Control
	root.add_child(home)
	await _wait_frames()
	_check(home.has_node("MainMargin/Scroll/Content/ProgramsCard/Margin/VBox/ProgramsButton"), "Home provides Programs access")
	_check(not (home.get_node("MainMargin/Scroll/Content/ProgramsCard/Margin/VBox/ProgramsButton") as Button).disabled, "Home Programs access is active")

	var profile_scene: PackedScene = load("res://src/ui/screens/ProfileScreen.tscn")
	var profile_screen: Control = profile_scene.instantiate() as Control
	root.add_child(profile_screen)
	await _wait_frames()
	for path: String in [
		"Margin/Scroll/VBox/RecentlyPlayed",
		"Margin/Scroll/VBox/FavoritesList",
		"Margin/Scroll/VBox/ProgramSummary",
		"Margin/Scroll/VBox/CollectionsCard"
	]:
		_check(profile_screen.has_node(path), "Profile includes %s" % path.get_file())
	var collection_copy: Label = profile_screen.get_node("Margin/Scroll/VBox/CollectionsCard/Margin/VBox/Copy") as Label
	_check(collection_copy.text.contains("Challenge Types discovered") and collection_copy.text.contains("Curated runs completed"), "Collections present meaningful tracked goals")
	_check((progress.call("get_recent_family_summaries", 5) as Array).size() > 0, "Recently Played derives from Challenge History")

	var routes_script: Script = load("res://src/core/navigation/AppRoutes.gd")
	_check(bool(routes_script.call("is_valid_route", "programs")), "Programs route is registered")

	programs_screen.queue_free()
	home.queue_free()
	profile_screen.queue_free()
	await _wait_frames()
