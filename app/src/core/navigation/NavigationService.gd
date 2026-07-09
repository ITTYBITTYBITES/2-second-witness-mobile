extends Node
## NavigationService - Central navigation orchestrator
## Updated for ITTYBITTYBITES publisher identity + first-run flow

signal route_changed(route: String, params: Dictionary)
signal route_change_requested(route: String, params: Dictionary)
signal history_updated(history: Array)
signal deep_link_received(route: String, params: Dictionary)

var current_route: String = "publisher_splash"
var current_params: Dictionary = {}
var history: Array[Dictionary] = []
const MAX_HISTORY := 50

var _initialized: bool = false

const SPLASH_ROUTES := ["publisher_splash", "title_splash", "splash"]
const FIRST_RUN_ROUTES := ["privacy", "tutorial", "observation", "memory_question", "result"]

func _ready() -> void:
	if EventBus:
		if not EventBus.navigation_requested.is_connected(_on_navigation_requested):
			EventBus.navigation_requested.connect(_on_navigation_requested)
	print("[NavigationService] Ready")

func initialize() -> void:
	if _initialized:
		return
	_initialized = true
	current_route = "publisher_splash"
	current_params = {}
	history.clear()
	print("[NavigationService] Initialized - start publisher_splash")
	await get_tree().process_frame

func navigate_to(route: String, params: Dictionary = {}) -> bool:
	if not _is_valid(route):
		if ErrorHandler:
			ErrorHandler.handle("NAV_INVALID_ROUTE", "Route not found: %s" % route, {"route": route})
		return false
	
	# Do not push splash or first-run to history to keep back simple, unless going to main tabs
	var should_push = true
	if current_route in SPLASH_ROUTES:
		should_push = false
	if current_route in FIRST_RUN_ROUTES and route in FIRST_RUN_ROUTES:
		should_push = false # linear first-run flow, no history bloat
	
	if should_push and current_route != route:
		_push_history(current_route, current_params)
	
	route_change_requested.emit(route, params)
	current_route = route
	current_params = params
	
	print("[NavigationService] -> %s %s" % [route, str(params)])
	route_changed.emit(route, params)
	if EventBus:
		EventBus.navigation_changed.emit(route, params)
	
	_update_app_state_phase(route)
	
	if AnalyticsService:
		AnalyticsService.log_screen_view(route, params)
	
	return true

func go_back() -> bool:
	if history.is_empty():
		if current_route != "home" and current_route not in SPLASH_ROUTES and current_route not in FIRST_RUN_ROUTES:
			return navigate_to("home")
		# If in first-run, don't go back to splash
		if current_route in FIRST_RUN_ROUTES:
			return false
		return false
	
	var prev: Dictionary = history.pop_back()
	history_updated.emit(history.duplicate())
	var route: String = prev.get("route", "home")
	var params: Dictionary = prev.get("params", {})
	
	current_route = route
	current_params = params
	route_changed.emit(route, params)
	if EventBus:
		EventBus.navigation_changed.emit(route, params)
	_update_app_state_phase(route)
	print("[NavigationService] Back -> %s" % route)
	return true

func replace(route: String, params: Dictionary = {}) -> bool:
	if not _is_valid(route):
		return false
	current_route = route
	current_params = params
	route_changed.emit(route, params)
	if EventBus:
		EventBus.navigation_changed.emit(route, params)
	_update_app_state_phase(route)
	print("[NavigationService] Replace -> %s" % route)
	return true

func can_go_back() -> bool:
	return not history.is_empty()

func clear_history() -> void:
	history.clear()
	history_updated.emit(history)

func _push_history(route: String, params: Dictionary) -> void:
	history.append({"route": route, "params": params, "timestamp": Time.get_ticks_msec()})
	if history.size() > MAX_HISTORY:
		history.pop_front()
	history_updated.emit(history.duplicate())

func _is_valid(route: String) -> bool:
	var script = load("res://src/core/navigation/AppRoutes.gd")
	return script.is_valid_route(route)

func _on_navigation_requested(route: String, params: Dictionary) -> void:
	navigate_to(route, params)

func _update_app_state_phase(route: String) -> void:
	if not AppState:
		return
	match route:
		"publisher_splash", "title_splash", "splash":
			AppState.set_phase(AppState.AppPhase.SPLASH)
		"home":
			AppState.set_phase(AppState.AppPhase.HOME)
		"experiences":
			AppState.set_phase(AppState.AppPhase.EXPERIENCES)
		"profile":
			AppState.set_phase(AppState.AppPhase.PROFILE)
		"settings", "about":
			AppState.set_phase(AppState.AppPhase.SETTINGS)
		"privacy", "tutorial":
			AppState.set_phase(AppState.AppPhase.SPLASH)
		"observation", "memory_question", "result", "experience_play":
			AppState.set_phase(AppState.AppPhase.EXPERIENCE_PLAYING)

func get_current() -> Dictionary:
	return {"route": current_route, "params": current_params}
