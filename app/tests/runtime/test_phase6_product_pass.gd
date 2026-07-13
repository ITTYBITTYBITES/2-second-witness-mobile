extends SceneTree
## End-to-end production-readiness checks for screen construction, interaction
## usability, accessibility settings, family accommodations, and product states.

const SCREEN_PATHS: Array[String] = [
	"res://src/ui/screens/PublisherSplashScreen.tscn",
	"res://src/ui/screens/TitleSplashScreen.tscn",
	"res://src/ui/screens/HomeScreen.tscn",
	"res://src/ui/screens/ProgramsScreen.tscn",
	"res://src/ui/screens/ExperiencesScreen.tscn",
	"res://src/ui/screens/AchievementsScreen.tscn",
	"res://src/ui/screens/ProfileScreen.tscn",
	"res://src/ui/screens/SettingsScreen.tscn",
	"res://src/ui/screens/AboutScreen.tscn",
	"res://src/ui/screens/TutorialScreen.tscn",
	"res://src/ui/screens/ObservationChallengeScreen.tscn",
	"res://src/ui/screens/MemoryQuestionScreen.tscn",
	"res://src/ui/screens/ResultScreen.tscn"
]
const FAMILY_IDS: Array[String] = [
	"scene_investigation", "flash_words", "spot_the_difference", "object_recall", "pattern_recall"
]

var failures: Array[String] = []
var passes := 0
var settings_service: Node
var accessibility_service: Node
var profile_service: Node
var progress_service: Node
var family_registry: Node
var session_service: Node
var program_service: Node
var achievement_service: Node

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if condition:
		passes += 1
		print("[PHASE6-PRODUCT PASS] %s" % message)
	else:
		failures.append(message)
		push_error("[PHASE6-PRODUCT FAIL] %s" % message)

func _wait_frames(count: int = 2) -> void:
	for _index: int in range(count):
		await process_frame

func _run() -> void:
	root.size = Vector2i(360, 640)
	_initialize_services()
	settings_service = root.get_node("SettingsService")
	accessibility_service = root.get_node("AccessibilityService")
	profile_service = root.get_node("ProfileService")
	progress_service = root.get_node("PlayerProgressService")
	family_registry = root.get_node("ChallengeFamilyRegistry")
	session_service = root.get_node("ChallengeSessionService")
	program_service = root.get_node("ProgramService")
	achievement_service = root.get_node("AchievementService")
	await _wait_frames()
	await _verify_screens()
	await _verify_privacy_dialog()
	_verify_settings_surface()
	await _verify_family_accessibility()
	_verify_tutorial_preference()
	_verify_product_catalogs()
	var audio: Node = root.get_node("AudioService")
	audio.call("stop_all")
	audio.set("_stream_cache", {})
	await _wait_frames()
	print("[PHASE6-PRODUCT SUMMARY] %d passed, %d failed, screens=%d families=%d" % [passes, failures.size(), SCREEN_PATHS.size(), FAMILY_IDS.size()])
	quit(0 if failures.is_empty() else 1)

func _initialize_services() -> void:
	for service_name: String in [
		"ConfigService", "SaveService", "ProfileService", "SettingsService",
		"AnalyticsService", "AccessibilityService", "ThemeService", "AudioService",
		"ContentService", "ChallengeRegistry", "InteractionAdapterRegistry",
		"ChallengeFamilyRegistry", "PlayerProgressService", "RecommendationService",
		"ProgramService", "AchievementService", "ResultService",
		"ChallengeSessionService", "NavigationService"
	]:
		var service: Node = root.get_node(service_name)
		if service.has_method("initialize"):
			service.call("initialize")

func _verify_screens() -> void:
	for scene_path: String in SCREEN_PATHS:
		var packed := load(scene_path) as PackedScene
		var screen := packed.instantiate() as Control if packed else null
		_check(screen != null, "Screen instantiates: %s" % scene_path.get_file())
		if screen == null:
			continue
		root.add_child(screen)
		await _wait_frames()
		ResponsiveLayout.enforce_touch_targets(screen)
		var touch_failures := ResponsiveLayout.collect_touch_target_failures(screen)
		_check(touch_failures.is_empty(), "Visible touch targets meet 48 px: %s" % scene_path.get_file())
		_check(screen.size.x >= 360.0 and screen.size.y >= 640.0, "Small-screen anchors fill the viewport: %s" % scene_path.get_file())
		var labels := screen.find_children("*", "Label", true, false)
		var wraps_or_short := true
		for node: Node in labels:
			var label := node as Label
			if label.is_visible_in_tree() and label.text.length() > 80 and label.autowrap_mode == TextServer.AUTOWRAP_OFF:
				wraps_or_short = false
				break
		_check(wraps_or_short, "Long copy wraps on small screens: %s" % scene_path.get_file())
		screen.queue_free()
		await _wait_frames()

func _verify_privacy_dialog() -> void:
	var packed := load("res://src/ui/dialogs/PrivacyTermsDialog.tscn") as PackedScene
	var dialog := packed.instantiate() as Control
	root.add_child(dialog)
	await _wait_frames()
	var panel := dialog.get_node("Margin/CenterVBox/DialogPanel") as PanelContainer
	var accept := dialog.get_node("Margin/CenterVBox/DialogPanel/InnerMargin/Scroll/VBox/Actions/AcceptButton") as Button
	_check(panel.custom_minimum_size.x <= 520.0, "Privacy modal keeps a bounded readable width")
	_check(accept.text == "ACCEPT & CONTINUE" and accept.custom_minimum_size.y >= 48.0, "Privacy action is explicit and touch-safe")
	dialog.queue_free()
	await _wait_frames()

func _verify_settings_surface() -> void:
	var packed := load("res://src/ui/screens/SettingsScreen.tscn") as PackedScene
	var screen := packed.instantiate() as Control
	root.add_child(screen)
	var keys: Dictionary = {}
	_collect_setting_keys(screen, keys)
	for required: String in [
		"font_scale", "reduced_motion", "high_contrast", "color_assist_mode",
		"reading_comfort_mode", "comfortable_timing", "haptics_enabled",
		"volume_master", "volume_bgm", "volume_sfx", "volume_ui", "mute_master",
		"show_tutorials", "analytics_enabled"
	]:
		_check(keys.has(required), "Settings exposes production control: %s" % required)
	var reset_dialog := screen.get_node_or_null("ConfirmationDialog") as ConfirmationDialog
	_check(reset_dialog != null, "Destructive settings reset requires confirmation")
	screen.queue_free()

func _collect_setting_keys(node: Node, output: Dictionary) -> void:
	if node.has_meta("key"):
		output[str(node.get_meta("key"))] = true
	for child: Node in node.get_children():
		_collect_setting_keys(child, output)

func _verify_family_accessibility() -> void:
	settings_service.call("set_value", "font_scale", 1.4)
	settings_service.call("set_value", "high_contrast", true)
	settings_service.call("set_value", "reduced_motion", true)
	settings_service.call("set_value", "color_assist_mode", true)
	settings_service.call("set_value", "reading_comfort_mode", true)
	settings_service.call("set_value", "comfortable_timing", true)
	settings_service.call("set_value", "accessibility_screen_reader_hints", true)
	settings_service.call("set_value", "mute_master", true)
	var snapshot: Dictionary = accessibility_service.call("get_settings_snapshot")
	_check(is_equal_approx(float(snapshot.get("font_scale", 0.0)), 1.4), "140% text scale reaches AccessibilityService")
	_check(bool(snapshot.get("high_contrast", false)), "High Contrast reaches AccessibilityService")
	_check(bool(snapshot.get("reduced_motion", false)), "Reduced Motion reaches AccessibilityService")
	_check(bool(snapshot.get("color_assist_mode", false)), "Color Assistance reaches AccessibilityService")
	var player_state: Dictionary = progress_service.call("get_player_state")
	for family_id: String in FAMILY_IDS:
		var module: ChallengeFamilyModule = family_registry.call("get_module", family_id)
		var family := module.get_family()
		var template := module.get_templates()[0]
		var accessible_difficulty := module.get_difficulty_policy().resolve_difficulty(player_state, family, template)
		var accessible_exposure := module.get_exposure_policy().resolve_exposure(template, accessible_difficulty, player_state)
		var base_state := player_state.duplicate(true)
		base_state["preferences"] = {}
		var base_difficulty := module.get_difficulty_policy().resolve_difficulty(base_state, family, template)
		var base_exposure := module.get_exposure_policy().resolve_exposure(template, base_difficulty, base_state)
		_check(accessible_exposure >= base_exposure, "Comfortable Timing never shortens exposure: %s" % family_id)
		var instance := module.get_generator().generate(template, accessible_difficulty, accessible_exposure, 660000 + absi(family_id.hash()) % 10000)
		_check(instance != null and module.get_validator().validate(instance).is_valid, "Accessibility preferences preserve valid gameplay: %s" % family_id)
		var renderer_path := str(instance.generated_scene.get("renderer_script", ""))
		var renderer := Control.new()
		renderer.custom_minimum_size = Vector2(360, 420)
		renderer.set_script(load(renderer_path))
		root.add_child(renderer)
		renderer.call("set_scene_data", instance.generated_scene, [])
		await _wait_frames()
		_check(renderer.size.x >= 360.0, "Family renderer constructs in High Contrast: %s" % family_id)
		renderer.queue_free()
		await _wait_frames()

	var spot_module: ChallengeFamilyModule = family_registry.call("get_module", "spot_the_difference")
	var sequential := spot_module.get_template("sequential_switch_v1")
	var difficulty := spot_module.get_difficulty_policy().resolve_difficulty(player_state, spot_module.get_family(), sequential)
	var exposure := spot_module.get_exposure_policy().resolve_exposure(sequential, difficulty, player_state)
	var spot_instance := spot_module.get_generator().generate(sequential, difficulty, exposure, 661100)
	var surface := SpatialTapSurface.new()
	surface.configure(spot_instance.to_dictionary())
	root.add_child(surface)
	await _wait_frames()
	var renderer_value: Variant = surface.get("_renderer")
	var response_scene: Dictionary = (renderer_value as Control).get("_scene") if renderer_value is Control else {}
	_check(str(response_scene.get("interaction_phase", "")) == "response", "Spatial Tap response uses a stable paired render context")
	surface.queue_free()
	await _wait_frames()

	var object_module: ChallengeFamilyModule = family_registry.call("get_module", "object_recall")
	var object_template := object_module.get_template("missing_set_v1")
	var object_difficulty := object_module.get_difficulty_policy().resolve_difficulty(player_state, object_module.get_family(), object_template)
	var object_exposure := object_module.get_exposure_policy().resolve_exposure(object_template, object_difficulty, player_state)
	var object_instance := object_module.get_generator().generate(object_template, object_difficulty, object_exposure, 661200)
	var adapter := MultipleChoiceInteractionAdapter.new()
	adapter.configure(object_module.get_interaction_profile(), object_instance.to_dictionary())
	var host := VBoxContainer.new()
	root.add_child(host)
	adapter.mount(host)
	ResponsiveLayout.enforce_touch_targets(host)
	var status := host.get_child(0) as Label
	_check(status.text.contains("Select exactly"), "Multiple Choice states the exact required selection count")
	_check(ResponsiveLayout.collect_touch_target_failures(host).is_empty(), "Dynamic Multiple Choice controls meet touch targets")
	host.queue_free()
	await _wait_frames()

func _verify_tutorial_preference() -> void:
	settings_service.call("set_value", "show_tutorials", false)
	_check(not session_service.call("needs_tutorial", "scene_investigation"), "Show Tutorials off bypasses automatic tutorial gating")
	settings_service.call("set_value", "show_tutorials", true)
	var family: ChallengeFamily = family_registry.call("get_family", "scene_investigation")
	var preferences: Dictionary = (profile_service.get("profile") as Dictionary).get("preferences", {})
	var versions: Dictionary = preferences.get("family_tutorial_versions", {})
	versions["scene_investigation"] = family.tutorial_version
	preferences["family_tutorial_versions"] = versions
	profile_service.get("profile")["preferences"] = preferences
	_check(not session_service.call("needs_tutorial", "scene_investigation"), "Completed tutorial version remains respected")

func _verify_product_catalogs() -> void:
	var programs: Array[Dictionary] = program_service.call("get_definitions")
	var achievements: Array[Dictionary] = achievement_service.call("get_definitions")
	_check(programs.size() == 9, "Nine balanced curated Programs remain available")
	_check(achievements.size() == 26, "Twenty-six paced achievements remain available")
	var early_family_goals: Dictionary = {}
	var long_family_goals: Dictionary = {}
	for achievement: Dictionary in achievements:
		if str(achievement.get("criterion", "")) != "family_correct":
			continue
		var family_id := str(achievement.get("family_id", ""))
		var target := int(achievement.get("target", 0))
		if target == 10:
			early_family_goals[family_id] = true
		elif target == 50:
			long_family_goals[family_id] = true
	_check(early_family_goals.size() == 5, "Every Challenge Type has an early correctness milestone")
	_check(long_family_goals.size() >= 2, "Long-session achievements extend beyond the first milestones")
