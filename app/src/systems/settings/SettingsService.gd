extends Node
## SettingsService - User preferences persistence
## Independent, observable, typed getters

signal setting_changed(key: String, value: Variant)
signal settings_loaded(settings: Dictionary)
signal settings_saved(settings: Dictionary)
signal settings_reset()

var _settings: Dictionary = {}
var _initialized: bool = false

const DEFAULT_SETTINGS := {
	"version": 2,
	# Audio
	"volume_master": 1.0,
	"volume_bgm": 0.7,
	"volume_sfx": 0.9,
	"volume_ui": 0.8,
	"mute_master": false,
	"mute_bgm": false,
	"mute_sfx": false,
	"mute_ui": false,
	"haptics_enabled": true,
	# Visual
	"theme_mode": "dark", # dark / light / system
	"reduced_motion": false,
	"screen_shake_enabled": true,
	"font_scale": 1.0, # 0.8 - 1.3
	"high_contrast": false,
	# Gameplay
	"show_tutorials": true,
	"auto_play_next": false,
	"confirm_exit": true,
	# Privacy
	"analytics_enabled": true,
	"crash_reporting": true,
	# Accessibility
	"accessibility_font_scaling": 1.0,
	"accessibility_reduce_motion": false,
	"accessibility_screen_reader_hints": false,
	# System
	"language": "en",
	"first_launch_completed": false,
	"privacy_acknowledged": false
}

func _ready() -> void:
	print("[SettingsService] Ready")

func initialize() -> void:
	if _initialized:
		return

	var loaded := SaveService.load_settings() if SaveService else {}
	if loaded.is_empty():
		_settings = DEFAULT_SETTINGS.duplicate(true)
		print("[SettingsService] Using defaults")
	else:
		_settings = _merge_defaults(loaded)
		print("[SettingsService] Loaded %d settings" % _settings.size())

	_initialized = true
	settings_loaded.emit(_settings)

	# Apply immediate settings
	_apply_settings()

func _merge_defaults(loaded: Dictionary) -> Dictionary:
	var merged := DEFAULT_SETTINGS.duplicate(true)
	for k in loaded.keys():
		merged[k] = loaded[k]
	# Handle version upgrades
	if not merged.has("version") or merged["version"] < DEFAULT_SETTINGS["version"]:
		merged["version"] = DEFAULT_SETTINGS["version"]
	return merged

func _apply_settings() -> void:
	# Push to systems that need initial values
	pass

func get_value(key: String, default: Variant = null) -> Variant:
	if _settings.has(key):
		return _settings[key]
	if DEFAULT_SETTINGS.has(key):
		return DEFAULT_SETTINGS[key]
	return default

func set_value(key: String, value: Variant) -> bool:
	var old = _settings.get(key, null)
	if old == value:
		return true

	_settings[key] = value
	_save()
	setting_changed.emit(key, value)
	EventBus.setting_changed.emit(key, value)

	# Analytics for settings change (non-sensitive)
	if AnalyticsService and not key.begins_with("volume"):
		AnalyticsService.log_event("setting_changed", {"key": key})

	print("[SettingsService] %s = %s" % [key, str(value)])
	return true

func _save() -> bool:
	if not SaveService:
		return false
	var ok := SaveService.save_settings(_settings)
	if ok:
		settings_saved.emit(_settings)
	return ok

func get_all() -> Dictionary:
	return _settings.duplicate(true)

func reset_to_defaults() -> void:
	_settings = DEFAULT_SETTINGS.duplicate(true)
	_save()
	settings_reset.emit()
	print("[SettingsService] Reset to defaults")
	for k in _settings.keys():
		setting_changed.emit(k, _settings[k])

func is_haptics_enabled() -> bool:
	return get_value("haptics_enabled", true)

func is_reduced_motion() -> bool:
	return get_value("reduced_motion", false) or get_value("accessibility_reduce_motion", false)

func get_font_scale() -> float:
	return clamp(get_value("font_scale", 1.0), 0.8, 1.4)

func get_theme_mode() -> String:
	return get_value("theme_mode", "dark")
