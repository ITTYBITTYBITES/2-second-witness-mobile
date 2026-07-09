extends Control
## AppShell - Root application container
## Manages layers, first-run flow, splash system, main navigation
## Premium ITTYBITTYBITES + Two Second Witness identity

@onready var content_container: Control = $ContentLayer/ContentContainer
@onready var nav_bar: Control = $NavigationLayer/MainNavigation
@onready var top_bar: Control = $TopBarLayer/TopBar
@onready var loading_overlay: Control = $OverlayLayer/LoadingOverlay
@onready var error_banner: Control = $OverlayLayer/ErrorBanner
@onready var background_layer: Control = $BackgroundLayer

var _current_screen: Control = null
var _screen_cache: Dictionary = {}
var _boot_flow: Node

const SCREEN_SCENES := {
	"publisher_splash": "res://src/ui/screens/PublisherSplashScreen.tscn",
	"title_splash":    "res://src/ui/screens/TitleSplashScreen.tscn",
	"splash":          "res://src/ui/screens/TitleSplashScreen.tscn",
	"observation":     "res://src/ui/screens/ObservationChallengeScreen.tscn",
	"memory_question": "res://src/ui/screens/MemoryQuestionScreen.tscn",
	"result":          "res://src/ui/screens/ResultScreen.tscn",
	"about":           "res://src/ui/screens/AboutScreen.tscn",
	"home":            "res://src/ui/screens/HomeScreen.tscn",
	"experiences":     "res://src/ui/screens/ExperiencesScreen.tscn",
	"profile":         "res://src/ui/screens/ProfileScreen.tscn",
	"settings":        "res://src/ui/screens/SettingsScreen.tscn"
}

func _ready() -> void:
	print("[AppShell] Starting - New Vision with ITTYBITTYBITES identity")
	_ensure_boot_flow()

	if AppState:
		if not AppState.phase_changed.is_connected(_on_phase_changed):
			AppState.phase_changed.connect(_on_phase_changed)
		if not AppState.loading_changed.is_connected(_on_loading_changed):
			AppState.loading_changed.connect(_on_loading_changed)
	if NavigationService:
		if not NavigationService.route_changed.is_connected(_on_route_changed):
			NavigationService.route_changed.connect(_on_route_changed)
	if ErrorHandler:
		if not ErrorHandler.user_message_requested.is_connected(_on_user_message):
			ErrorHandler.user_message_requested.connect(_on_user_message)
	if ThemeService:
		if not ThemeService.theme_changed.is_connected(_on_theme_changed):
			ThemeService.theme_changed.connect(_on_theme_changed)

	_apply_theme()

	if top_bar:
		if top_bar.has_signal("back_pressed") and not top_bar.back_pressed.is_connected(_on_topbar_back):
			top_bar.back_pressed.connect(_on_topbar_back)
		var has_profile_signal := top_bar.has_signal("profile_pressed")
		if has_profile_signal and not top_bar.profile_pressed.is_connected(_on_topbar_profile):
			top_bar.profile_pressed.connect(_on_topbar_profile)
		var has_settings_signal := top_bar.has_signal("settings_pressed")
		if has_settings_signal and not top_bar.settings_pressed.is_connected(_on_topbar_settings):
			top_bar.settings_pressed.connect(_on_topbar_settings)

	if nav_bar and nav_bar.has_signal("tab_selected"):
		if not nav_bar.tab_selected.is_connected(_on_nav_tab_selected):
			nav_bar.tab_selected.connect(_on_nav_tab_selected)

	# Display the publisher splash immediately while systems initialize in the
	# background, so the user sees branding within the first frame or two.
	if NavigationService:
		NavigationService.replace("publisher_splash")

	if _boot_flow:
		_boot_flow.boot_completed.connect(_on_boot_completed)
		_boot_flow.boot_failed.connect(_on_boot_failed)
		_boot_flow.start_boot()
	else:
		call_deferred("_on_boot_completed")

func _ensure_boot_flow() -> void:
	var boot_script = load("res://src/core/app/AppBoot.gd")
	if boot_script:
		_boot_flow = boot_script.new()
		_boot_flow.name = "AppBoot"
		add_child(_boot_flow)

func _on_boot_completed() -> void:
	print("[AppShell] Boot completed")
	AppState.set_loading(false)
	# The publisher splash is displayed immediately in _ready; once boot finishes
	# the splash's own timer advances us to the title/loading screen. If for some
	# reason we're not on a splash route (e.g. deep link), load that screen.
	if NavigationService:
		var current = NavigationService.current_route
		if current != "publisher_splash" and current != "title_splash" and current != "splash":
			_load_screen(current)
	# Notify the active splash screen that boot has completed (if it is already up).
	if _current_screen and _current_screen.has_method("notify_boot_completed"):
		_current_screen.notify_boot_completed()

func _on_boot_failed(reason: String) -> void:
	print("[AppShell] Boot failed: %s" % reason)
	_show_error("Boot failed: %s" % reason)
	AppState.set_loading(false)
	if NavigationService:
		NavigationService.navigate_to("publisher_splash")

func _on_route_changed(route: String, params: Dictionary) -> void:
	print("[AppShell] Route change to %s" % route)
	_load_screen(route, params)
	_update_chrome(route)

func _load_screen(route: String, params: Dictionary = {}) -> void:
	if _current_screen:
		_current_screen.visible = false

	if _screen_cache.has(route):
		_current_screen = _screen_cache[route]
		_current_screen.visible = true
		if _current_screen.has_method("on_navigated_to"):
			_current_screen.call("on_navigated_to", params)
	else:
		var scene_path: String = SCREEN_SCENES.get(route, "")
		if scene_path == "":
			scene_path = "res://src/ui/screens/%sScreen.tscn" % _capitalize_first(route)

		var screen_instance: Control = null

		if ResourceLoader.exists(scene_path):
			var scene: PackedScene = load(scene_path)
			if scene:
				screen_instance = scene.instantiate() as Control
		else:
			screen_instance = _create_placeholder_screen(route)

		if screen_instance:
			screen_instance.name = "%sScreenInstance" % route.capitalize()
			screen_instance.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			screen_instance.size_flags_vertical = Control.SIZE_EXPAND_FILL
			if content_container:
				content_container.add_child(screen_instance)
			else:
				add_child(screen_instance)
			_screen_cache[route] = screen_instance
			_current_screen = screen_instance
			if screen_instance.has_method("on_navigated_to"):
				screen_instance.call("on_navigated_to", params)
		else:
			print("[AppShell] Failed to load screen for route %s" % route)
			if ErrorHandler:
				ErrorHandler.handle("SCREEN_LOAD_FAILED", "Failed to load %s" % route, {"route": route})

func _create_placeholder_screen(route: String) -> Control:
	var placeholder_script = load("res://src/ui/screens/PlaceholderScreen.gd")
	var ctrl := Control.new()
	if placeholder_script:
		ctrl.set_script(placeholder_script)
		ctrl.set("route_name", route)
	else:
		var label := Label.new()
		label.text = "Screen: %s (Placeholder)" % route
		ctrl.add_child(label)
	return ctrl

func _update_chrome(route: String) -> void:
	var is_tab := true
	var routes_script = load("res://src/core/navigation/AppRoutes.gd")
	if routes_script:
		is_tab = routes_script.is_tab_route(route)

	# Hide chrome for the launch splash/loading sequence. Gameplay screens show
	# top bar (for exit/back) but hide the bottom tab bar so players cannot
	# wander off mid-challenge.
	var is_splash := route in ["publisher_splash", "title_splash", "splash"]
	var is_gameplay := route in ["observation", "memory_question", "result"]

	if nav_bar:
		nav_bar.visible = is_tab and not is_splash and not is_gameplay
		if nav_bar.has_method("set_current_route"):
			nav_bar.set_current_route(route)

	if top_bar:
		top_bar.visible = not is_splash
		if top_bar.has_method("set_show_back"):
			var show_back := not is_tab and not is_splash
			if route == "about":
				show_back = true
			top_bar.set_show_back(show_back)
		var title_map := {
			"publisher_splash": "",
			"title_splash": "",
			"splash": "",
			"observation": "Observe",
			"memory_question": "Recall",
			"result": "Result",
			"home": "Two Second Witness",
			"experiences": "Experiences",
			"profile": "Profile",
			"settings": "Settings",
			"about": "About"
		}
		if top_bar.has_method("set_title"):
			top_bar.set_title(title_map.get(route, route.capitalize()))

func _on_phase_changed(new_phase, old_phase) -> void:
	print("[AppShell] Phase %s -> %s" % [str(old_phase), str(new_phase)])
	if NavigationService:
		_update_chrome(NavigationService.current_route)
	else:
		_update_chrome("home")

func _on_loading_changed(is_loading: bool, message: String) -> void:
	if loading_overlay:
		loading_overlay.visible = is_loading
		if loading_overlay.has_node("Center/VBox/Message"):
			loading_overlay.get_node("Center/VBox/Message").text = message if message != "" else "Loading..."

func _on_user_message(message: String, _severity: int) -> void:
	_show_error(message)

func _show_error(message: String) -> void:
	if error_banner:
		error_banner.visible = true
		if error_banner.has_node("Margin/Label"):
			error_banner.get_node("Margin/Label").text = message
	get_tree().create_timer(4.0).timeout.connect(_hide_error_banner)

func _hide_error_banner() -> void:
	if is_instance_valid(error_banner):
		error_banner.visible = false

func _apply_theme() -> void:
	if not ThemeService:
		return
	var tokens = ThemeService.tokens
	var bg: Color = tokens.get("background", Color("#0F0F12"))
	if background_layer:
		var style := StyleBoxFlat.new()
		style.bg_color = bg
		background_layer.add_theme_stylebox_override("panel", style)

func _on_theme_changed(_theme_name: String, _tokens: Dictionary) -> void:
	_apply_theme()

func _on_topbar_back() -> void:
	if NavigationService:
		if NavigationService.can_go_back():
			NavigationService.go_back()
		else:
			NavigationService.navigate_to("home")

func _on_topbar_profile() -> void:
	if NavigationService:
		NavigationService.navigate_to("profile")

func _on_topbar_settings() -> void:
	if NavigationService:
		NavigationService.navigate_to("settings")

func _on_nav_tab_selected(route: String) -> void:
	if NavigationService and NavigationService.current_route != route:
		NavigationService.navigate_to(route)

func _capitalize_first(s: String) -> String:
	if s.is_empty():
		return s
	return s[0].to_upper() + s.substr(1)
