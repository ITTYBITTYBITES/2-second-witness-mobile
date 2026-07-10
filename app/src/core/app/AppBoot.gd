extends Node
## AppBoot - Clean startup flow orchestrator
## Phases: Preload configs -> Init systems -> Load saves -> Ready

@warning_ignore("unused_signal")
signal boot_step_started(step: String)
@warning_ignore("unused_signal")
signal boot_step_completed(step: String, duration_ms: int)
signal boot_completed()
signal boot_failed(reason: String)

enum BootStep {
	INIT_CONFIG,
	INIT_THEME,
	INIT_SETTINGS,
	INIT_SAVE,
	INIT_CONTENT,
	INIT_AUDIO,
	INIT_NAV,
	FINALIZE
}

var _is_booting: bool = false
var _boot_start_time: int = 0

func start_boot() -> void:
	if _is_booting:
		return
	_is_booting = true
	_boot_start_time = Time.get_ticks_msec()
	print("[AppBoot] Starting boot sequence")

	# Keep the dependency order explicit. Settings reads SaveService and the
	# theme reads SettingsService; starting either one too early produces a
	# cascade of null/default errors on a cold Android launch.
	_run_step("config", BootStep.INIT_CONFIG, _boot_config)
	_run_step("save", BootStep.INIT_SAVE, _boot_save)
	_run_step("settings", BootStep.INIT_SETTINGS, _boot_settings)
	_run_step("theme", BootStep.INIT_THEME, _boot_theme)
	_run_step("content", BootStep.INIT_CONTENT, _boot_content)
	_run_step("audio", BootStep.INIT_AUDIO, _boot_audio)
	_run_step("navigation", BootStep.INIT_NAV, _boot_nav)
	_run_step("finalize", BootStep.FINALIZE, _boot_finalize)

	var total := Time.get_ticks_msec() - _boot_start_time
	print("[AppBoot] Boot completed in %d ms" % total)
	_is_booting = false
	boot_completed.emit()
	EventBus.publish_app_initialized()

func _run_step(step_name: String, _step: BootStep, callable: Callable) -> void:
	var start := Time.get_ticks_msec()
	boot_step_started.emit(step_name)
	print("[AppBoot] Step: %s" % step_name)
	AppState.set_loading(true, "Loading %s..." % step_name.capitalize())

	var success: bool = true
	var err: String = ""

	# Use try-like pcall via callable
	var result = callable.call()
	if result is Dictionary and result.has("error"):
		success = false
		err = str(result["error"])

	var duration := Time.get_ticks_msec() - start
	boot_step_completed.emit(step_name, duration)

	if not success:
		var error_code := "BOOT_%s_FAILED" % step_name.to_upper()
		var context := {"step": step_name}
		ErrorHandler.handle(error_code, err, context, ErrorHandler.Severity.WARNING)
		boot_failed.emit("[%s] %s" % [error_code, err])
		print("[AppBoot] Step %s FAILED - %s" % [step_name, err])
	else:
		print("[AppBoot] Step %s OK (%d ms)" % [step_name, duration])

func _boot_config() -> Dictionary:
	if ConfigService:
		ConfigService.initialize()
	return {}

func _boot_theme() -> Dictionary:
	if ThemeService:
		ThemeService.initialize()
	return {}

func _boot_settings() -> Dictionary:
	if SettingsService:
		SettingsService.initialize()
	return {}

func _boot_save() -> Dictionary:
	if SaveService:
		SaveService.initialize()
	if ProfileService:
		ProfileService.initialize()
	return {}

func _boot_content() -> Dictionary:
	if ContentService:
		ContentService.initialize()
	# Do not let placeholder experience discovery block mobile startup.
	# The playable app boots from ChallengeRegistry, not ExperienceRegistry.
	if ChallengeRegistry:
		ChallengeRegistry.initialize()
	return {}

func _boot_audio() -> Dictionary:
	if AudioService:
		AudioService.initialize()
	return {}

func _boot_nav() -> Dictionary:
	if NavigationService:
		NavigationService.initialize()
	return {}

func _boot_finalize() -> Dictionary:
	AppState.set_loading(false)
	return {}
