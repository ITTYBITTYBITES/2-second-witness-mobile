extends Node
## EventBus - Decoupled messaging
## Global signal bus to keep systems independent.

signal app_initialized()
signal navigation_requested(route: String, params: Dictionary)
signal navigation_changed(route: String, params: Dictionary)
signal setting_changed(key: String, value: Variant)
signal theme_changed(theme_name: String)
signal audio_requested(bus: String, sound_id: String, params: Dictionary)
signal profile_updated(profile_data: Dictionary)
signal experience_unlocked(exp_id: String)
signal experience_completed(exp_id: String, result: Dictionary)
signal error_occurred(code: String, message: String, context: Dictionary)
signal accessibility_changed(settings: Dictionary)

var _event_log: Array[Dictionary] = []
const MAX_LOG_SIZE := 200

func _ready() -> void:
	print("[EventBus] Initialized")

func emit_routed(signal_name: String, args: Array = []) -> void:
	_log_event(signal_name, args)

func _log_event(name: String, args: Array) -> void:
	var entry := {
		"name": name,
		"args": args,
		"timestamp": Time.get_ticks_msec()
	}
	_event_log.append(entry)
	if _event_log.size() > MAX_LOG_SIZE:
		_event_log.pop_front()

func get_recent_events(count: int = 20) -> Array:
	return _event_log.slice(-count)

func publish_navigation(route: String, params: Dictionary = {}) -> void:
	_log_event("navigation_requested", [route, params])
	navigation_requested.emit(route, params)

func publish_error(code: String, message: String, context: Dictionary = {}) -> void:
	_log_event("error_occurred", [code, message, context])
	error_occurred.emit(code, message, context)
	print("[EventBus][Error] %s: %s %s" % [code, message, str(context)])
