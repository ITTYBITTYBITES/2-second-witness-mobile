extends Control
## AppShell - Root application container
## Manages layers: Background, Content, Navigation, Overlays, Boot

@onready var content_container: Control = $ContentLayer/ContentContainer
@onready var nav_bar: Control = $NavigationLayer/MainNavigation
@onready var top_bar: Control = $TopBarLayer/TopBar
@onready var loading_overlay: Control = $OverlayLayer/LoadingOverlay
@onready var error_banner: Control = $OverlayLayer/ErrorBanner
@onready var background_layer: Control = $BackgroundLayer

var _current_screen: Control = null
var _screen_cache: Dictionary = {} # route -> Control
var _boot_flow: Node

const SCREEN_SCENES := {
	"splash": "res://src/ui/screens/SplashScreen.tscn",
	"home": "res://src/ui/screens/HomeScreen.tscn",
	"experiences": "res://src/ui/screens/ExperiencesScreen.tscn",
	"profile": "res://src/ui/screens/ProfileScreen.tscn",
	"settings": "res://src/ui/screens/SettingsScreen.tscn"
}

func _ready() -> void:
	print("[AppShell] Starting")
	_ensure_boot_flow()
	
	# Connect services
	if AppState:
		AppState.phase_changed.connect(_on_phase_changed)
		AppState.loading_changed.connect(_on_loading_changed)
	if NavigationService:
		NavigationService.route_changed.connect(_on_route_changed)
	if ErrorHandler:
		ErrorHandler.user_message_requested.connect(_on_user_message)
	
	# Theme background
	if ThemeService:
		ThemeService.theme_changed.connect(_on_theme_changed)
	
	_apply_theme()
	
	# Start boot sequence
	if _boot_flow:
		_boot_flow.boot_completed.connect(_on_boot_completed)
		_boot_flow.boot_failed.connect(_on_boot_failed)
		_boot_flow.start_boot()
	else:
		# Fallback if boot flow not set
		call_deferred("_on_boot_completed")

func _ensure_boot_flow() -> void:
	# Create AppBoot instance if not exists as child
	var boot_script = load("res://src/core/app/AppBoot.gd")
	if boot_script:
		_boot_flow = boot_script.new()
		_boot_flow.name = "AppBoot"
		add_child(_boot_flow)

func _on_boot_completed() -> void:
	print("[AppShell] Boot completed, navigating to home")
	AppState.set_loading(false)
	
	# Determine initial route
	if NavigationService.current_route == "splash":
		NavigationService.navigate_to("home")
	else:
		# Ensure screen loaded for current route
		_load_screen(NavigationService.current_route)

func _on_boot_failed(reason: String) -> void:
	print("[AppShell] Boot failed: %s" % reason)
	_show_error("Boot failed: %s" % reason)
	AppState.set_loading(false)
	NavigationService.navigate_to("home")

func _on_route_changed(route: String, params: Dictionary) -> void:
	print("[AppShell] Route change to %s" % route)
	_load_screen(route, params)
	_update_chrome(route)

func _load_screen(route: String, params: Dictionary = {}) -> void:
	# Remove current
	if _current_screen:
		_current_screen.visible = false
		# Optionally free non-tab screens to save memory
		# For foundation we keep cache but hide
	
	if _screen_cache.has(route):
		_current_screen = _screen_cache[route]
		_current_screen.visible = true
		if _current_screen.has_method("on_navigated_to"):
			_current_screen.call("on_navigated_to", params)
	else:
		var scene_path: String = SCREEN_SCENES.get(route, "")
		if scene_path == "":
			# Try generic
			scene_path = "res://src/ui/screens/%s.tscn" % _capitalize_first(route) + "Screen"
		
		var screen_instance: Control = null
		
		if ResourceLoader.exists(scene_path):
			var scene: PackedScene = load(scene_path)
			if scene:
				screen_instance = scene.instantiate() as Control
		else:
			# Create placeholder screen
			screen_instance = _create_placeholder_screen(route)
		
		if screen_instance:
			screen_instance.name = "%sScreenInstance" % route.capitalize()
			screen_instance.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			screen_instance.size_flags_vertical = Control.SIZE_EXPAND_FILL
			content_container.add_child(screen_instance)
			_screen_cache[route] = screen_instance
			_current_screen = screen_instance
			
			if screen_instance.has_method("on_navigated_to"):
				screen_instance.call("on_navigated_to", params)
		else:
			print("[AppShell] Failed to load screen for route %s" % route)
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
	# Show/hide nav bar based on route
	var is_tab := true
	# Check via AppRoutes
	var routes_script = load("res://src/core/navigation/AppRoutes.gd")
	if routes_script:
		is_tab = routes_script.is_tab_route(route)
	
	if nav_bar:
		nav_bar.visible = is_tab and route != "splash"
		if nav_bar.has_method("set_current_route"):
			nav_bar.set_current_route(route)
	
	if top_bar:
		top_bar.visible = route != "splash"
		if top_bar.has_method("set_show_back"):
			top_bar.set_show_back(not is_tab)
		var title_map := {
			"home": "2 Second Witness",
			"experiences": "Experiences",
			"profile": "Profile",
			"settings": "Settings",
			"splash": ""
		}
		if top_bar.has_method("set_title"):
			top_bar.set_title(title_map.get(route, route.capitalize()))

func _on_phase_changed(new_phase, old_phase) -> void:
	print("[AppShell] Phase %s -> %s" % [str(old_phase), str(new_phase)])
	_update_chrome(NavigationService.current_route if NavigationService else "home")

func _on_loading_changed(is_loading: bool, message: String) -> void:
	if loading_overlay:
		loading_overlay.visible = is_loading
		if loading_overlay.has_node("Center/VBox/Message"):
			loading_overlay.get_node("Center/VBox/Message").text = message if message != "" else "Loading..."

func _on_user_message(message: String, severity: int) -> void:
	_show_error(message)

func _show_error(message: String) -> void:
	if error_banner:
		error_banner.visible = true
		if error_banner.has_node("Margin/Label"):
			error_banner.get_node("Margin/Label").text = message
		# Auto-hide after 4 seconds
		get_tree().create_timer(4.0).timeout.connect(func(): if error_banner: error_banner.visible = false)

func _apply_theme() -> void:
	if not ThemeService:
		return
	var tokens := ThemeService.tokens
	var bg: Color = tokens.get("background", Color("#0F0F12"))
	if background_layer:
		var style := StyleBoxFlat.new()
		style.bg_color = bg
		background_layer.add_theme_stylebox_override("panel", style)

func _on_theme_changed(_theme_name: String, _tokens: Dictionary) -> void:
	_apply_theme()

func _capitalize_first(s: String) -> String:
	if s.is_empty():
		return s
	return s[0].to_upper() + s.substr(1)
