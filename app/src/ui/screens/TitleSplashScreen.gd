extends Control
## TitleSplashScreen - Two Second Witness loading screen
## Image-only splash, no text overlay. Shows privacy modal on first launch over the image,
## then goes directly to Home. Robust against boot stalls.

const MIN_DISPLAY_TIME := 1.2
const MAX_BOOT_WAIT_TIME := 6.0
const PRIVACY_POLICY_URL := "https://ittybittybites.github.io/privacy-policy/"

const PrivacyDialogScene := preload("res://src/ui/dialogs/PrivacyTermsDialog.tscn")

@onready var splash_image: TextureRect = $SplashImage
@onready var dialog_layer: Control = $PrivacyDialogLayer
@onready var loading_status: Label = $LoadingStatus

var _elapsed: float = 0.0
var _boot_completed: bool = false
var _is_navigating: bool = false
var _privacy_dialog: Control = null

func _ready() -> void:
	_elapsed = 0.0
	_is_navigating = false
	_load_splash_image()
	_animate_in()
	_connect_boot()
	if ThemeService:
		ThemeService.apply_label_style(loading_status, "caption", "text_secondary")
	print("[TitleSplash] Ready")

func _load_splash_image() -> void:
	if splash_image:
		var path := "res://assets/splash/two_second_witness_splash.png"
		if ResourceLoader.exists(path):
			splash_image.texture = load(path)
			splash_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			splash_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			splash_image.modulate.a = 1.0
		else:
			splash_image.visible = false
	if has_node("Background") and $Background:
		$Background.color = Color(0.055, 0.055, 0.07, 1.0)

func _connect_boot() -> void:
	var boot_node := _find_boot_node()
	if boot_node:
		if boot_node.has_signal("boot_step_started") and not boot_node.boot_step_started.is_connected(_on_boot_step_started):
			boot_node.boot_step_started.connect(_on_boot_step_started)
		if boot_node.has_signal("boot_step_completed") and not boot_node.boot_step_completed.is_connected(_on_boot_step_completed):
			boot_node.boot_step_completed.connect(_on_boot_step_completed)
		if boot_node.has_signal("boot_completed") and not boot_node.boot_completed.is_connected(_on_boot_completed):
			boot_node.boot_completed.connect(_on_boot_completed)

		var boot_already_done := false
		if AppState and AppState.is_initialized:
			boot_already_done = true
		var is_booting = boot_node.get("_is_booting")
		if is_booting == false:
			boot_already_done = true
		if boot_already_done:
			_boot_completed = true
	else:
		# No boot node found (e.g., running standalone) - don't block
		_boot_completed = true

func _find_boot_node() -> Node:
	if has_node("/root/AppShell/AppBoot"):
		return get_node("/root/AppShell/AppBoot")
	var root := get_tree().root
	if root and root.has_node("AppShell/AppBoot"):
		return root.get_node("AppShell/AppBoot")
	# Also try direct child search
	if get_tree().root:
		for child in get_tree().root.get_children():
			if child.name == "AppShell" and child.has_node("AppBoot"):
				return child.get_node("AppBoot")
	return null

func _animate_in() -> void:
	if AccessibilityService and AccessibilityService.is_reduced_motion_enabled():
		modulate.a = 1.0
		return
	modulate.a = 0.0
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate:a", 1.0, 0.32).set_ease(Tween.EASE_OUT)

func _process(delta: float) -> void:
	_elapsed += delta
	if not _boot_completed and _elapsed >= MAX_BOOT_WAIT_TIME:
		_boot_completed = true
		print("[TitleSplash] Boot watchdog triggered - forcing continue")
	if _boot_completed and _elapsed >= MIN_DISPLAY_TIME and not _is_navigating:
		# Don't auto-proceed while privacy dialog is visible
		if dialog_layer and dialog_layer.visible:
			return
		_on_ready_to_proceed()
		set_process(false)

func _on_boot_step_started(step: String) -> void:
	if loading_status:
		loading_status.text = "Preparing %s…" % step.capitalize()

func _on_boot_step_completed(_step: String, _duration_ms: int) -> void:
	if loading_status:
		loading_status.text = "Preparing your experience…"

func _on_boot_completed() -> void:
	_boot_completed = true
	print("[TitleSplash] Boot completed")

func _on_ready_to_proceed() -> void:
	if _is_navigating:
		return
	if dialog_layer and dialog_layer.visible:
		return
	if _needs_privacy_acknowledgment():
		_show_privacy_dialog()
	else:
		_navigate_home()

func _needs_privacy_acknowledgment() -> bool:
	# Robust check - if services missing, don't block launch
	var has_profile_ack := false
	var has_settings_ack := false
	if ProfileService and ProfileService.profile is Dictionary:
		var prefs: Dictionary = ProfileService.profile.get("preferences", {})
		if prefs.get("privacy_acknowledged", false):
			has_profile_ack = true
	if SettingsService:
		if SettingsService.get_value("privacy_acknowledged", false):
			has_settings_ack = true
	# If either says acknowledged, we're good
	if has_profile_ack or has_settings_ack:
		return false
	# If neither service is available, don't block
	if not ProfileService and not SettingsService:
		return false
	# Otherwise need acknowledgment (first launch)
	# Extra safety: if profile is empty (not yet loaded), check settings only
	return true

func _show_privacy_dialog() -> void:
	if dialog_layer and dialog_layer.visible:
		return
	print("[TitleSplash] Showing Privacy & Data modal")
	if _privacy_dialog == null:
		_privacy_dialog = PrivacyDialogScene.instantiate() as Control
		if dialog_layer:
			dialog_layer.add_child(_privacy_dialog)
		else:
			add_child(_privacy_dialog)
		if _privacy_dialog.has_signal("accepted"):
			_privacy_dialog.accepted.connect(_on_privacy_accepted)
		if _privacy_dialog.has_signal("view_policy"):
			_privacy_dialog.view_policy.connect(_on_view_privacy_policy)
	if dialog_layer:
		dialog_layer.visible = true
		dialog_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
		dialog_layer.offset_left = 0
		dialog_layer.offset_right = 0
		dialog_layer.offset_top = 0
		dialog_layer.offset_bottom = 0
		dialog_layer.mouse_filter = Control.MOUSE_FILTER_STOP
		dialog_layer.z_index = 100
		dialog_layer.move_to_front()
	if _privacy_dialog:
		_privacy_dialog.set_anchors_preset(Control.PRESET_FULL_RECT)
		_privacy_dialog.mouse_filter = Control.MOUSE_FILTER_STOP
		_privacy_dialog.z_index = 101
		_privacy_dialog.move_to_front()
		_privacy_dialog.visible = true
	# Pause splash processing - user must act
	set_process(false)

func _on_privacy_accepted() -> void:
	print("[TitleSplash] Privacy accepted")
	if ProfileService:
		var prefs: Dictionary = ProfileService.profile.get("preferences", {})
		prefs["privacy_acknowledged"] = true
		# Also mark onboarding as completed so we don't route to tutorial
		prefs["onboarding_completed"] = true
		ProfileService.profile["preferences"] = prefs
		ProfileService.save()
	if SettingsService:
		SettingsService.set_value("privacy_acknowledged", true)
		SettingsService.set_value("first_launch_completed", true)
	if AnalyticsService:
		AnalyticsService.log_event("privacy_acknowledged")
	if dialog_layer:
		dialog_layer.visible = false
	if _privacy_dialog:
		_privacy_dialog.visible = false
	# Directly go to home - no tutorial step per simplified flow
	_navigate_home()

func _on_view_privacy_policy() -> void:
	var policy_url := PRIVACY_POLICY_URL
	if ConfigService:
		policy_url = str(ConfigService.get_value("privacy_policy_url", policy_url))
	if OS.shell_open(policy_url) != OK:
		print("[TitleSplash] Unable to open privacy policy URL: %s" % policy_url)
		if _privacy_dialog and _privacy_dialog.has_method("show_policy_error"):
			_privacy_dialog.call("show_policy_error")

func _navigate_home() -> void:
	if _is_navigating:
		return
	_is_navigating = true
	print("[TitleSplash] Navigating to Home")
	if AccessibilityService and AccessibilityService.is_reduced_motion_enabled():
		if NavigationService:
			NavigationService.navigate_to("home")
		return
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate:a", 0.0, 0.35).set_ease(Tween.EASE_IN)
	tween.finished.connect(func():
		if NavigationService:
			NavigationService.navigate_to("home")
	)

func is_privacy_visible() -> bool:
	return dialog_layer != null and dialog_layer.visible

func _input(event: InputEvent) -> void:
	# Block skip while privacy dialog is visible
	if dialog_layer and dialog_layer.visible:
		return
	var should_advance := false
	if event is InputEventScreenTouch and event.pressed:
		if _elapsed > 0.3 and _boot_completed:
			should_advance = true
	if event is InputEventKey and event.pressed:
		if _elapsed > 0.3 and _boot_completed:
			should_advance = true
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _elapsed > 0.3 and _boot_completed:
			should_advance = true
	if should_advance and not _is_navigating:
		_on_ready_to_proceed()

func on_navigated_to(_params: Dictionary) -> void:
	_elapsed = 0.0
	_is_navigating = false
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
	if dialog_layer:
		dialog_layer.visible = false
	if _privacy_dialog:
		_privacy_dialog.visible = false
	set_process(true)
	_animate_in()
