extends SceneTree

var failures: Array[String] = []
var passes: int = 0
var metrics: Dictionary = {}

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if condition:
		passes += 1
		print("[PHASE35 PASS] %s" % message)
	else:
		failures.append(message)
		push_error("[PHASE35 FAIL] %s" % message)

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
	var achievements: Node = root.get_node("AchievementService")

	var init_started: int = Time.get_ticks_usec()
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
	achievements.call("initialize")
	metrics["service_init_ms"] = _elapsed_ms(init_started)
	_check(float(metrics["service_init_ms"]) < 1000.0, "Cold service initialization stays below the local 1000 ms budget")

	_verify_boot_and_orientation()
	_verify_responsive_math()
	_verify_accessibility(settings, theme, accessibility, progress, family_registry)
	await _verify_device_layout_matrix()
	_verify_performance(progress, recommendations)

	print("[PHASE35 METRICS] %s" % JSON.stringify(metrics))
	print("[PHASE35 SUMMARY] %d passed, %d failed" % [passes, failures.size()])
	for failure: String in failures:
		print("[PHASE35 FAILURE] %s" % failure)
	quit(0 if failures.is_empty() else 1)

func _verify_boot_and_orientation() -> void:
	_check(
		str(ProjectSettings.get_setting("application/boot_splash/image", "")) == "res://assets/splash/ittybittybites_splash.png",
		"The first engine-drawn frame uses sponsor artwork instead of the app icon"
	)
	_check(int(ProjectSettings.get_setting("application/boot_splash/stretch_mode", -1)) == 4, "Sponsor boot artwork uses full-screen cover mode")
	_check(int(ProjectSettings.get_setting("display/window/handheld/orientation", -1)) == 1, "Project orientation is locked to portrait")
	var publisher_scene: PackedScene = load("res://src/ui/screens/PublisherSplashScreen.tscn")
	var publisher: Control = publisher_scene.instantiate() as Control
	root.add_child(publisher)
	_check(publisher.has_node("SponsorArtwork"), "Sponsor screen owns the matching full-screen artwork")
	_check(not publisher.get_node("Center").visible, "No duplicate sponsor text overlays the artwork")
	publisher.queue_free()

func _verify_responsive_math() -> void:
	_check(is_equal_approx(ResponsiveLayout.horizontal_gutter(360.0), 20.0), "Compact phones retain a 20 px content gutter")
	_check(is_equal_approx(ResponsiveLayout.horizontal_gutter(1080.0), 60.0), "Standard portrait layout centers a 960 px content column")
	_check(is_equal_approx(ResponsiveLayout.horizontal_gutter(1600.0), 320.0), "Tablets and unfolded displays cap content width")
	var insets: Dictionary = ResponsiveLayout.scale_safe_area_insets(
		Rect2i(0, 100, 1080, 2200),
		Vector2i(1080, 2400),
		Vector2(1080, 1920)
	)
	_check(int(insets.get("top", -1)) == 80 and int(insets.get("bottom", -1)) == 80, "Physical safe-area insets scale into logical viewport coordinates")
	var side_insets: Dictionary = ResponsiveLayout.scale_safe_area_insets(
		Rect2i(80, 0, 2240, 1800),
		Vector2i(2400, 1800),
		Vector2(1600, 1200)
	)
	_check(int(side_insets.get("left", -1)) == 53 and int(side_insets.get("right", -1)) == 53, "Side cutouts scale symmetrically for wide and foldable profiles")

func _verify_accessibility(
	settings: Node,
	theme: Node,
	accessibility: Node,
	progress: Node,
	family_registry: Node
) -> void:
	settings.call("set_value", "font_scale", 1.4)
	_check(int(theme.call("get_font_size", "body")) == 25, "Text Size scales shared typography to 140 percent")
	settings.call("set_value", "high_contrast", true)
	var background: Color = theme.call("get_color", "background", Color.BLACK)
	var primary_text: Color = theme.call("get_color", "text_primary", Color.WHITE)
	var secondary_text: Color = theme.call("get_color", "text_secondary", Color.WHITE)
	_check(_contrast_ratio(primary_text, background) >= 7.0, "High Contrast primary text exceeds a 7:1 ratio")
	_check(_contrast_ratio(secondary_text, background) >= 7.0, "High Contrast secondary text exceeds a 7:1 ratio")
	settings.call("set_value", "reduced_motion", true)
	_check(not bool(accessibility.call("should_animate")), "Reduced Motion disables nonessential animation")
	_check(is_zero_approx(float(accessibility.call("get_animation_duration", 0.5))), "Reduced Motion resolves animation duration to zero")
	settings.call("set_value", "reading_comfort_mode", true)
	settings.call("set_value", "color_assist_mode", true)
	var player_state: Dictionary = progress.call("get_player_state")
	_check(bool((player_state.get("preferences", {}) as Dictionary).get("reading_comfort_mode", false)), "Reading Comfort Mode reaches family policies")
	_check(bool((player_state.get("preferences", {}) as Dictionary).get("color_assist_mode", false)), "Color Assistance reaches family policies")
	var scene_module: ChallengeFamilyModule = family_registry.call("get_module", "scene_investigation")
	var template: ChallengeTemplate = scene_module.get_template(scene_module.get_default_template_id())
	var difficulty: Dictionary = scene_module.get_difficulty_policy().resolve_difficulty(player_state, scene_module.get_family(), template)
	_check(bool((difficulty.get("axes", {}) as Dictionary).get("color_assist_mode", false)), "Scene Investigation enables color-independent question selection")
	var no_color_questions: bool = true
	for sample_seed: int in range(80):
		var exposure: float = scene_module.get_exposure_policy().resolve_exposure(template, difficulty, player_state)
		var instance: ChallengeInstance = scene_module.get_generator().generate(template, difficulty, exposure, 350000 + sample_seed)
		if str(instance.metadata.get("question_type", "")) == "attribute":
			no_color_questions = false
			break
	_check(no_color_questions, "Color Assistance removes color-dependent questions across sampled scenes")

func _verify_device_layout_matrix() -> void:
	var profiles: Array[Dictionary] = [
		{"name": "compact_phone", "size": Vector2i(360, 640)},
		{"name": "modern_phone", "size": Vector2i(412, 915)},
		{"name": "small_tablet", "size": Vector2i(600, 960)},
		{"name": "large_tablet", "size": Vector2i(800, 1280)},
		{"name": "unfolded_portrait", "size": Vector2i(884, 1104)}
	]
	var scenes: Array[String] = [
		"HomeScreen", "ExperiencesScreen", "ProfileScreen", "ProgramsScreen",
		"AchievementsScreen", "SettingsScreen", "AboutScreen"
	]
	var matrix_started: int = Time.get_ticks_usec()
	for profile: Dictionary in profiles:
		for screen_name: String in scenes:
			var profile_size: Vector2i = profile.get("size", Vector2i(360, 640))
			var viewport := SubViewport.new()
			viewport.size = profile_size
			viewport.disable_3d = true
			viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
			root.add_child(viewport)
			var scene: PackedScene = load("res://src/ui/screens/%s.tscn" % screen_name)
			var screen: Control = scene.instantiate() as Control
			viewport.add_child(screen)
			screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			await _wait_frames(2)
			ResponsiveLayout.enforce_touch_targets(screen)
			await process_frame
			var touch_failures: Array[String] = ResponsiveLayout.collect_touch_target_failures(screen)
			_check(touch_failures.is_empty(), "%s has 48 px touch targets on %s" % [screen_name, profile.get("name", "device")])
			var margin: MarginContainer = screen.get_node_or_null("MainMargin") as MarginContainer
			if margin == null:
				margin = screen.get_node_or_null("Margin") as MarginContainer
			_check(margin != null and margin.size.x <= float(profile_size.x) + 0.5, "%s stays within horizontal bounds on %s" % [screen_name, profile.get("name", "device")])
			viewport.queue_free()
			await process_frame
	metrics["layout_matrix_ms"] = _elapsed_ms(matrix_started)
	_check(float(metrics["layout_matrix_ms"]) < 3000.0, "Thirty-five responsive screen constructions stay below the local 3000 ms matrix budget")

func _verify_performance(progress: Node, recommendations: Node) -> void:
	var player_state: Dictionary = progress.call("get_player_state")
	var snapshot_started: int = Time.get_ticks_usec()
	for _index: int in range(500):
		recommendations.call("get_home_snapshot", player_state)
	metrics["home_snapshot_500_ms"] = _elapsed_ms(snapshot_started)
	metrics["home_snapshot_average_ms"] = float(metrics["home_snapshot_500_ms"]) / 500.0
	_check(float(metrics["home_snapshot_average_ms"]) < 2.0, "Home snapshot construction averages below 2 ms")

	var home_scene: PackedScene = load("res://src/ui/screens/HomeScreen.tscn")
	var construction_started: int = Time.get_ticks_usec()
	for _index: int in range(50):
		var home: Control = home_scene.instantiate() as Control
		home.free()
	metrics["home_scene_50_ms"] = _elapsed_ms(construction_started)
	metrics["home_scene_average_ms"] = float(metrics["home_scene_50_ms"]) / 50.0
	_check(float(metrics["home_scene_average_ms"]) < 10.0, "Packed Home scene instantiation averages below 10 ms")
	metrics["static_memory_mb"] = snappedf(float(Performance.get_monitor(Performance.MEMORY_STATIC)) / 1048576.0, 0.1)
	_check(float(metrics["static_memory_mb"]) < 384.0, "Local static memory remains below the 384 MB review ceiling")

func _elapsed_ms(started_at_usec: int) -> float:
	return snappedf(float(Time.get_ticks_usec() - started_at_usec) / 1000.0, 0.01)

func _contrast_ratio(foreground: Color, background: Color) -> float:
	var light: float = _relative_luminance(foreground)
	var dark: float = _relative_luminance(background)
	if dark > light:
		var swap: float = light
		light = dark
		dark = swap
	return (light + 0.05) / (dark + 0.05)

func _relative_luminance(color: Color) -> float:
	return 0.2126 * _linear_channel(color.r) + 0.7152 * _linear_channel(color.g) + 0.0722 * _linear_channel(color.b)

func _linear_channel(value: float) -> float:
	return value / 12.92 if value <= 0.04045 else pow((value + 0.055) / 1.055, 2.4)
