extends Control
## TitleSplashScreen - Two Second Witness loading screen
## Shows title, tagline, and a simple loading indicator for ~1-2 seconds.
## On first launch only, a centered Privacy & Terms modal is presented over this
## screen. After Accept, acknowledgment is stored and we go directly to the Main
## Menu (home). The first gameplay challenge is launched from the Main Menu.

const MIN_DISPLAY_TIME := 1.4          # approx 1-2 seconds total
const MAX_BOOT_WAIT_TIME := 8.0       # watchdog so we never get stuck
const PRIVACY_POLICY_URL := "https://ittybittybites.github.io/two-second-witness/privacy"

const PrivacyDialogScene := preload("res://src/ui/dialogs/PrivacyTermsDialog.tscn")

@onready var title_label: Label = $Center/Margin/VBox/Title
@onready var tagline_label: Label = $Center/Margin/VBox/Tagline
@onready var spinner_label: Label = $Center/Margin/VBox/Loader/Spinner
@onready var status_label: Label = $Center/Margin/VBox/Loader/Status
@onready var footer_label: Label = $Footer
@onready var dialog_layer: Control = $PrivacyDialogLayer

var _elapsed: float = 0.0
var _boot_completed: bool = false
var _is_navigating: bool = false
var _privacy_dialog: Control = null
var _spinner_pulse_tween: Tween = null
var _spinner_rotate_tween: Tween = null

func _ready() -> void:
	_elapsed = 0.0
	_is_navigating = false
	_apply_theme()
	_animate_in()
	_connect_boot()

func _connect_boot() -> void:
	var boot_node := _find_boot_node()
	if boot_node:
		var has_step_started := boot_node.has_signal("boot_step_started")
		if has_step_started and not boot_node.boot_step_started.is_connected(_on_boot_step_started):
			boot_node.boot_step_started.connect(_on_boot_step_started)

		var has_step_completed := boot_node.has_signal("boot_step_completed")
		if has_step_completed and not boot_node.boot_step_completed.is_connected(_on_boot_step_completed):
			boot_node.boot_step_completed.connect(_on_boot_step_completed)

		var has_boot_completed := boot_node.has_signal("boot_completed")
		if has_boot_completed and not boot_node.boot_completed.is_connected(_on_boot_completed):
			boot_node.boot_completed.connect(_on_boot_completed)

		var boot_already_done := false
		if AppState and AppState.is_initialized:
			boot_already_done = true
		var is_booting = boot_node.get("_is_booting")
		if is_booting == false:
			boot_already_done = true
		if boot_already_done:
			_boot_completed = true
			if status_label:
				status_label.text = "Ready"
	else:
		_boot_completed = true

func _find_boot_node() -> Node:
	if has_node("/root/AppShell/AppBoot"):
		return get_node("/root/AppShell/AppBoot")
	var root := get_tree().root
	if root.has_node("AppShell/AppBoot"):
		return root.get_node("AppShell/AppBoot")
	return null

func _apply_theme() -> void:
	if $Background:
		$Background.color = Color(0.055, 0.055, 0.07, 1.0)
	if not ThemeService:
		return
	var tokens := ThemeService.tokens
	if title_label:
		title_label.add_theme_color_override("font_color", tokens.get("text_primary", Color.WHITE))
		title_label.add_theme_font_size_override("font_size", 34)
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if tagline_label:
		tagline_label.add_theme_color_override("font_color", tokens.get("text_secondary", Color.GRAY))
		tagline_label.add_theme_font_size_override("font_size", 15)
		tagline_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if spinner_label:
		spinner_label.add_theme_color_override("font_color", tokens.get("primary", Color("#7C5CFF")))
		spinner_label.add_theme_font_size_override("font_size", 28)
		spinner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if status_label:
		status_label.add_theme_color_override("font_color", tokens.get("text_tertiary", Color.GRAY))
		status_label.add_theme_font_size_override("font_size", 12)
		status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if footer_label:
		footer_label.add_theme_color_override("font_color", tokens.get("text_tertiary", Color.GRAY))
		footer_label.add_theme_font_size_override("font_size", 10)
		footer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _animate_in() -> void:
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.4).set_ease(Tween.EASE_OUT)
	_spin_spinner()

func _spin_spinner() -> void:
	if not spinner_label:
		return
	if AccessibilityService and AccessibilityService.is_reduced_motion_enabled():
		spinner_label.text = "• • •"
		spinner_label.rotation = 0.0
		return
	spinner_label.text = "◍"
	if _spinner_pulse_tween and _spinner_pulse_tween.is_valid():
		_spinner_pulse_tween.kill()
	if _spinner_rotate_tween and _spinner_rotate_tween.is_valid():
		_spinner_rotate_tween.kill()
	spinner_label.rotation = 0.0
	spinner_label.modulate.a = 1.0
	_spinner_pulse_tween = create_tween().set_loops()
	var pulse_down := _spinner_pulse_tween.tween_property(spinner_label, "modulate:a", 0.45, 0.6)
	pulse_down.set_ease(Tween.EASE_IN_OUT)
	var pulse_up := _spinner_pulse_tween.tween_property(spinner_label, "modulate:a", 1.0, 0.6)
	pulse_up.set_ease(Tween.EASE_IN_OUT)

	_spinner_rotate_tween = create_tween().set_loops()
	var spin := _spinner_rotate_tween.tween_property(spinner_label, "rotation", TAU, 2.0)
	spin.set_ease(Tween.EASE_IN_OUT)

func _process(delta: float) -> void:
	_elapsed += delta
	if not _boot_completed and _elapsed >= MAX_BOOT_WAIT_TIME:
		_boot_completed = true
		if status_label:
			status_label.text = "Continuing"
	if _boot_completed and _elapsed >= MIN_DISPLAY_TIME and not _is_navigating:
		_on_ready_to_proceed()
		set_process(false)

func _on_boot_step_started(_step: String) -> void:
	if status_label:
		status_label.text = "Loading..."

func _on_boot_step_completed(_step: String, _duration_ms: int) -> void:
	pass

func _on_boot_completed() -> void:
	_boot_completed = true
	if status_label:
		status_label.text = "Ready"

func _on_ready_to_proceed() -> void:
	if _is_navigating:
		return
	if _needs_privacy_acknowledgment():
		_show_privacy_dialog()
	else:
		_navigate_home()

func _needs_privacy_acknowledgment() -> bool:
	if ProfileService:
		var prefs: Dictionary = ProfileService.profile.get("preferences", {})
		if prefs.get("privacy_acknowledged", false):
			return false
		if prefs.get("onboarding_completed", false):
			return false
	if SettingsService and SettingsService.get_value("privacy_acknowledged", false):
		return false
	return true

func _show_privacy_dialog() -> void:
	if dialog_layer.visible:
		return
	if _privacy_dialog == null:
		_privacy_dialog = PrivacyDialogScene.instantiate() as Control
		dialog_layer.add_child(_privacy_dialog)
		if _privacy_dialog.has_signal("accepted"):
			_privacy_dialog.accepted.connect(_on_privacy_accepted)
		if _privacy_dialog.has_signal("view_policy"):
			_privacy_dialog.view_policy.connect(_on_view_privacy_policy)
	dialog_layer.visible = true
	_privacy_dialog.visible = true
	# Stop the spinner and update status - user must make a choice.
	if spinner_label:
		spinner_label.visible = false
	if _spinner_pulse_tween and _spinner_pulse_tween.is_valid():
		_spinner_pulse_tween.pause()
	if _spinner_rotate_tween and _spinner_rotate_tween.is_valid():
		_spinner_rotate_tween.pause()
	if status_label:
		status_label.text = ""
	print("[TitleSplash] Presenting Privacy & Terms modal (first launch)")

func _on_privacy_accepted() -> void:
	# Persist acknowledgment in both Profile preferences and Settings.
	if ProfileService:
		var prefs: Dictionary = ProfileService.profile.get("preferences", {})
		prefs["privacy_acknowledged"] = true
		prefs["onboarding_completed"] = true
		ProfileService.profile["preferences"] = prefs
		ProfileService.save()
	if SettingsService:
		SettingsService.set_value("privacy_acknowledged", true)
		SettingsService.set_value("first_launch_completed", true)
	if AnalyticsService:
		AnalyticsService.log_event("privacy_acknowledged")
	# Dismiss dialog then continue to Main Menu.
	if dialog_layer:
		dialog_layer.visible = false
	if _privacy_dialog:
		_privacy_dialog.visible = false
	_navigate_home()

func _on_view_privacy_policy() -> void:
	# Open placeholder URL while keeping the first-launch acceptance modal in place.
	if OS.shell_open(PRIVACY_POLICY_URL) != OK:
		print("[TitleSplash] Unable to open privacy policy URL: %s" % PRIVACY_POLICY_URL)

func _navigate_home() -> void:
	if _is_navigating:
		return
	_is_navigating = true
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4).set_ease(Tween.EASE_IN)
	tween.finished.connect(func():
		if NavigationService:
			NavigationService.navigate_to("home")
	)

func _input(event: InputEvent) -> void:
	# Block tap-to-skip while privacy dialog is showing.
	if dialog_layer and dialog_layer.visible:
		return
	if event is InputEventScreenTouch and event.pressed:
		if _elapsed > 0.4 and _boot_completed:
			_on_ready_to_proceed()
			set_process(false)

func on_navigated_to(_params: Dictionary) -> void:
	_elapsed = 0.0
	_is_navigating = false
	# Reset boot completion check for subsequent navigations
	if AppState and AppState.is_initialized:
		_boot_completed = true
	else:
		_boot_completed = false
		var boot_node := _find_boot_node()
		if boot_node:
			var is_booting = boot_node.get("_is_booting")
			if is_booting == false:
				_boot_completed = true
	_connect_boot()
	modulate.a = 0.0
	dialog_layer.visible = false
	if spinner_label:
		spinner_label.visible = true
		_spin_spinner()
	set_process(true)
	_animate_in()
	if AnalyticsService:
		AnalyticsService.log_screen_view("title_splash")
