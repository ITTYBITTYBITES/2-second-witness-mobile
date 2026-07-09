extends Node
## ErrorHandler - Centralized error handling and recovery
## Provides safe boundaries, logging, and user-friendly feedback

enum Severity { INFO, WARNING, ERROR, CRITICAL }

signal error_logged(entry: Dictionary)
signal user_message_requested(message: String, severity: Severity)

var _error_history: Array[Dictionary] = []
const MAX_HISTORY := 100
var _crash_count_today: int = 0

func _ready() -> void:
	print("[ErrorHandler] Initialized")
	EventBus.error_occurred.connect(_on_error_occurred)

func _on_error_occurred(code: String, message: String, context: Dictionary) -> void:
	handle(code, message, context, Severity.ERROR)

func handle(
	code: String,
	message: String,
	context: Dictionary = {},
	severity: Severity = Severity.ERROR
) -> void:
	var entry := {
		"code": code,
		"message": message,
		"context": context,
		"severity": severity,
		"timestamp": Time.get_datetime_string_from_system(),
		"ticks": Time.get_ticks_msec(),
		"phase": str(AppState.current_phase) if AppState else "unknown"
	}
	_error_history.append(entry)
	if _error_history.size() > MAX_HISTORY:
		_error_history.pop_front()

	error_logged.emit(entry)

	match severity:
		Severity.CRITICAL:
			push_error("[CRITICAL] %s: %s %s" % [code, message, str(context)])
			user_message_requested.emit("A critical error occurred. Restarting safely...", severity)
			_attempt_safe_recovery()
		Severity.ERROR:
			push_error("[ERROR] %s: %s %s" % [code, message, str(context)])
		Severity.WARNING:
			push_warning("[WARN] %s: %s" % [code, message])
		_:
			print("[INFO] %s: %s" % [code, message])

	# Also forward to Analytics if available
	if AnalyticsService:
		AnalyticsService.log_error(code, message, context, severity)

func handle_exception(code: String, context: Dictionary = {}) -> void:
	handle(code, "Exception caught", context, Severity.ERROR)

func get_history() -> Array[Dictionary]:
	return _error_history.duplicate()

func clear_history() -> void:
	_error_history.clear()

func _attempt_safe_recovery() -> void:
	print("[ErrorHandler] Attempting safe recovery")
	AppState.set_loading(false)
	NavigationService.navigate_to("home")
