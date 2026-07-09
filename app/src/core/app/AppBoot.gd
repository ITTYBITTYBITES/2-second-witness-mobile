extends Node
## AppBoot - Clean startup flow orchestrator
## Phases: Preload configs -> Init systems -> Load saves -> Ready

signal boot_step_started(step: String)
signal boot_step_completed(step: String, duration_ms: int)
signal boot_completed()
signal boot_failed(reason: String)

enum BootStep { INIT_CONFIG, INIT_THEME, INIT_SETTINGS, INIT_SAVE, INIT_CONTENT, INIT_AUDIO, INIT_NAV, FINALIZE }

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
	await _run_step("config", BootStep.INIT_CONFIG, _boot_config)
	await _run_step("save", BootStep.INIT_SAVE, _boot_save)
	await _run_step("settings", BootStep.INIT_SETTINGS, _boot_settings)
	await _run_step("theme", BootStep.INIT_THEME, _boot_theme)
	await _run_step("content", BootStep.INIT_CONTENT, _boot_content)
	await _run_step("audio", BootStep.INIT_AUDIO, _boot_audio)
	await _run_step("navigation", BootStep.INIT_NAV, _boot_nav)
	await _run_step("finalize", BootStep.FINALIZE, _boot_finalize)
	
	var total := Time.get_ticks_msec() - _boot_start_time
	print("[AppBoot] Boot completed in %d ms" % total)
	_is_booting = false
	boot_completed.emit()
	EventBus.app_initialized.emit()

func _run_step(name: String, step: BootStep, callable: Callable) -> void:
	var start := Time.get_ticks_msec()
	boot_step_started.emit(name)
	print("[AppBoot] Step: %s" % name)
	AppState.set_loading(true, "Loading %s..." % name.capitalize())
	
	var success: bool = true
	var err: String = ""
	
	# Use try-like pcall via callable
	var result = await callable.call()
	if result is Dictionary and result.has("error"):
		success = false
		err = result["error"]
	
	var duration := Time.get_ticks_msec() - start
	boot_step_completed.emit(name, duration)
	
	if not success:
		ErrorHandler.handle("BOOT_%s_FAILED" % name.to_upper(), err, {"step": name}, ErrorHandler.Severity.WARNING)
	else:
		print("[AppBoot] Step %s OK (%d ms)" % [name, duration])

func _boot_config() -> Dictionary:
	if ConfigService:
		await ConfigService.initialize()
	return {}

func _boot_theme() -> Dictionary:
	if ThemeService:
		await ThemeService.initialize()
	return {}

func _boot_settings() -> Dictionary:
	if SettingsService:
		await SettingsService.initialize()
	return {}

func _boot_save() -> Dictionary:
	if SaveService:
		await SaveService.initialize()
	if ProfileService:
		await ProfileService.initialize()
	return {}

func _boot_content() -> Dictionary:
	if ContentService:
		await ContentService.initialize()
	# Do not let placeholder experience discovery block mobile startup.
	# The playable app boots from ChallengeRegistry, not ExperienceRegistry.
	if ChallengeRegistry:
		await ChallengeRegistry.initialize()
	return {}

func _boot_audio() -> Dictionary:
	if AudioService:
		await AudioService.initialize()
	return {}

func _boot_nav() -> Dictionary:
	if NavigationService:
		await NavigationService.initialize()
	return {}

func _boot_finalize() -> Dictionary:
	AppState.set_loading(false)
	return {}
