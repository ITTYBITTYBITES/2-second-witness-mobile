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
	"tutorial":        "res://src/ui/screens/TutorialScreen.tscn",
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

	_apply_safe_area()
	_apply_theme()
	_setup_loading_overlay()
	_setup_error_banner()

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
		if _current_screen.has_method("_apply_theme"):
			_current_screen.call("_apply_theme")
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
		# Root tabs own their page headings and bottom navigation. Reserve the
		# compact app bar for contextual/back navigation only.
		top_bar.visible = not is_splash and not is_tab
		if top_bar.has_method("set_show_actions"):
			top_bar.set_show_actions(false)
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

	# Visibility must be finalized before offsets are calculated.
	_apply_safe_area()

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
		if error_banner.has_node("Margin/HBox/Label"):
			error_banner.get_node("Margin/HBox/Label").text = message
		elif error_banner.has_node("Margin/Label"):
			error_banner.get_node("Margin/Label").text = message
	# Auto-hide after 4s, but user can dismiss early
	if _error_hide_timer:
		_error_hide_timer.timeout.disconnect(_hide_error_banner)
		_error_hide_timer.queue_free()
	_error_hide_timer = get_tree().create_timer(4.0)
	_error_hide_timer.timeout.connect(_hide_error_banner)

var _error_hide_timer: SceneTreeTimer = null

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
	# Error banner styling
	if error_banner:
		var err_style := StyleBoxFlat.new()
		err_style.bg_color = tokens.get("error_container", tokens.get("error", Color.RED))
		err_style.corner_radius_bottom_left = 8
		err_style.corner_radius_bottom_right = 8
		error_banner.add_theme_stylebox_override("panel", err_style)
		var label_path := "Margin/HBox/Label"
		if error_banner.has_node(label_path):
			var lbl: Label = error_banner.get_node(label_path)
			lbl.add_theme_color_override("font_color", tokens.get("text_primary", Color.WHITE))
			ThemeService.apply_typography(lbl, "body_small")

func _on_theme_changed(_theme_name: String, _tokens: Dictionary) -> void:
	_apply_safe_area()
	_apply_theme()
	_setup_loading_overlay()
	_setup_error_banner()
	if _current_screen and _current_screen.has_method("_apply_theme"):
		_current_screen.call("_apply_theme")

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

func _apply_safe_area() -> void:
	if not ThemeService:
		return
	var area: Rect2i = DisplayServer.get_display_safe_area()
	var window_size: Vector2i = DisplayServer.window_get_size()
	if area.size.x <= 0 or area.size.y <= 0:
		area = Rect2i(Vector2i.ZERO, window_size)
	var viewport_size := get_viewport_rect().size
	var scale_x := viewport_size.x / float(maxi(window_size.x, 1))
	var scale_y := viewport_size.y / float(maxi(window_size.y, 1))
	var raw_top := maxi(area.position.y, 0)
	var raw_bottom := maxi(0, window_size.y - (area.position.y + area.size.y))
	var raw_left := maxi(area.position.x, 0)
	var raw_right := maxi(0, window_size.x - (area.position.x + area.size.x))
	var top := int(round(raw_top * scale_y))
	var bottom := int(round(raw_bottom * scale_y))
	var left := int(round(raw_left * scale_x))
	var right := int(round(raw_right * scale_x))
	if OS.get_name() in ["Android", "iOS"]:
		top = maxi(top, 24)
		bottom = maxi(bottom, 16)
	else:
		top = maxi(top, 8)
		bottom = maxi(bottom, 8)

	var current_route := NavigationService.current_route if NavigationService else "home"
	var is_splash: bool = current_route in ["publisher_splash", "title_splash", "splash"]

	var top_bar_layer := get_node_or_null("TopBarLayer")
	if top_bar_layer:
		top_bar_layer.offset_top = top
		top_bar_layer.offset_bottom = top + 56
		top_bar_layer.offset_left = left
		top_bar_layer.offset_right = -right
	var nav_layer := get_node_or_null("NavigationLayer")
	if nav_layer:
		nav_layer.offset_top = -bottom - 76
		nav_layer.offset_bottom = -bottom
		nav_layer.offset_left = left
		nav_layer.offset_right = -right

	if content_container:
		# Splash art stays full bleed; its privacy modal applies its own safe
		# margins. App content uses logical safe-area insets plus visible chrome.
		content_container.offset_top = 0 if is_splash else top + (56 if top_bar and top_bar.visible else 0)
		content_container.offset_bottom = 0 if is_splash else -bottom - (76 if nav_bar and nav_bar.visible else 0)
		content_container.offset_left = 0 if is_splash else left
		content_container.offset_right = 0 if is_splash else -right

	if error_banner:
		error_banner.offset_top = top
		error_banner.offset_left = left
		error_banner.offset_right = -right

	ThemeService.tokens["safe_area_top"] = top
	ThemeService.tokens["safe_area_bottom"] = bottom

func _setup_loading_overlay() -> void:
	if not loading_overlay or not ThemeService:
		return
	var tokens = ThemeService.tokens
	# Style background
	var style := StyleBoxFlat.new()
	style.bg_color = Color(tokens.get("background", Color.BLACK), 0.85)
	loading_overlay.add_theme_stylebox_override("panel", style)

	# Find message label
	var msg_label: Label = null
	if loading_overlay.has_node("Center/VBox/Message"):
		msg_label = loading_overlay.get_node("Center/VBox/Message")
		ThemeService.apply_label_style(msg_label, "body", "text_primary")
		msg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Replace / enhance spinner
	var spinner_parent: VBoxContainer = null
	if loading_overlay.has_node("Center/VBox"):
		spinner_parent = loading_overlay.get_node("Center/VBox")
	var spinner_label: Label = null
	if spinner_parent and spinner_parent.get_child_count() > 0:
		var first = spinner_parent.get_child(0)
		if first is Label:
			spinner_label = first
	if spinner_label:
		# Text remains legible with fallback fonts and does not introduce a
		# perpetual-motion accessibility exception.
		spinner_label.text = "Preparing"
		ThemeService.apply_typography(spinner_label, "label")
		spinner_label.add_theme_color_override("font_color", tokens.get("primary_text", Color.WHITE))
		spinner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _setup_error_banner() -> void:
	if not error_banner or not ThemeService:
		return
	# Ensure HBox with label + close button exists
	var margin: MarginContainer = null
	if error_banner.has_node("Margin"):
		margin = error_banner.get_node("Margin")
	if not margin:
		return
	var hbox: HBoxContainer = null
	if margin.has_node("HBox"):
		hbox = margin.get_node("HBox")
	else:
		# Migrate old Label to HBox layout
		var old_label: Label = null
		if margin.has_node("Label"):
			old_label = margin.get_node("Label")
			margin.remove_child(old_label)
		hbox = HBoxContainer.new()
		hbox.name = "HBox"
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		margin.add_child(hbox)
		if old_label:
			old_label.name = "Label"
			old_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			old_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			hbox.add_child(old_label)
		else:
			var lbl := Label.new()
			lbl.name = "Label"
			lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			hbox.add_child(lbl)
		var close_btn := Button.new()
		close_btn.name = "CloseButton"
		close_btn.text = "✕"
		close_btn.custom_minimum_size = Vector2(48, 48)
		close_btn.flat = true
		hbox.add_child(close_btn)
		if not close_btn.pressed.is_connected(_hide_error_banner):
			close_btn.pressed.connect(_hide_error_banner)
	# Style close button
	var close_btn_node = hbox.get_node_or_null("CloseButton")
	if close_btn_node is Button:
		var btn: Button = close_btn_node
		btn.add_theme_font_size_override("font_size", ThemeService.get_font_size("body"))
		btn.add_theme_color_override("font_color", ThemeService.get_color("text_primary"))

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel") or not NavigationService:
		return
	var route := NavigationService.current_route
	if route in ["publisher_splash", "title_splash", "splash"]:
		# The first-launch disclosure is mandatory and system back must not
		# dismiss it or quit behind it.
		if _current_screen and _current_screen.has_method("is_privacy_visible"):
			if bool(_current_screen.call("is_privacy_visible")):
				get_viewport().set_input_as_handled()
				return
		return
	if NavigationService.can_go_back():
		NavigationService.go_back()
		get_viewport().set_input_as_handled()
	elif route != "home":
		NavigationService.navigate_to("home")
		get_viewport().set_input_as_handled()

func _capitalize_first(s: String) -> String:
	if s.is_empty():
		return s
	return s[0].to_upper() + s.substr(1)
