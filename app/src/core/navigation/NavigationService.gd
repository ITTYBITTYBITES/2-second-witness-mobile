extends Node
## NavigationService - Central navigation orchestrator
## Decoupled from UI, manages route stack, params, history

signal route_changed(route: String, params: Dictionary)
signal route_change_requested(route: String, params: Dictionary)
signal history_updated(history: Array)
signal deep_link_received(route: String, params: Dictionary)

var current_route: String = "splash"
var current_params: Dictionary = {}
var history: Array[Dictionary] = []
const MAX_HISTORY := 50

var _initialized: bool = false

func _ready() -> void:
	EventBus.navigation_requested.connect(_on_navigation_requested)
	print("[NavigationService] Ready")

func initialize() -> void:
	if _initialized:
		return
	_initialized = true
	current_route = "splash"
	current_params = {}
	history.clear()
	print("[NavigationService] Initialized")
	await get_tree().process_frame

func navigate_to(route: String, params: Dictionary = {}) -> bool:
	if not _is_valid(route):
		ErrorHandler.handle("NAV_INVALID_ROUTE", "Route not found: %s" % route, {"route": route})
		return false
	
	# Push current to history if not splash and different
	if current_route != route and current_route != "splash":
		_push_history(current_route, current_params)
	
	route_change_requested.emit(route, params)
	
	current_route = route
	current_params = params
	
	print("[NavigationService] -> %s %s" % [route, str(params)])
	route_changed.emit(route, params)
	EventBus.navigation_changed.emit(route, params)
	
	# Update AppState phase mapping
	_update_app_state_phase(route)
	
	# Analytics
	if AnalyticsService:
		AnalyticsService.log_screen_view(route, params)
	
	return true

func go_back() -> bool:
	if history.is_empty():
		# Default back to home if not already there
		if current_route != "home":
			return navigate_to("home")
		return false
	
	var prev: Dictionary = history.pop_back()
	history_updated.emit(history.duplicate())
	var route: String = prev.get("route", "home")
	var params: Dictionary = prev.get("params", {})
	
	current_route = route
	current_params = params
	route_changed.emit(route, params)
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
	# Use AppRoutes if available, else allowlist
	var script = load("res://src/core/navigation/AppRoutes.gd")
	return script.is_valid_route(route)

func _on_navigation_requested(route: String, params: Dictionary) -> void:
	navigate_to(route, params)

func _update_app_state_phase(route: String) -> void:
	if not AppState:
		return
	match route:
		"home":
			AppState.set_phase(AppState.AppPhase.HOME)
		"experiences":
			AppState.set_phase(AppState.AppPhase.EXPERIENCES)
		"profile":
			AppState.set_phase(AppState.AppPhase.PROFILE)
		"settings":
			AppState.set_phase(AppState.AppPhase.SETTINGS)
		"splash":
			AppState.set_phase(AppState.AppPhase.SPLASH)
		"experience_play":
			AppState.set_phase(AppState.AppPhase.EXPERIENCE_PLAYING)

func get_current() -> Dictionary:
	return {"route": current_route, "params": current_params}
