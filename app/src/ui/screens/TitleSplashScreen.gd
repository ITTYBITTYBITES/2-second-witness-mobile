extends Control
## TitleSplashScreen - Two Second Witness title/loading
## Second splash after publisher, premium cognitive aesthetic

@onready var bg_rect: TextureRect = $Background
@onready var progress_bar: ProgressBar = $Center/VBox/ProgressBar
@onready var status_label: Label = $Center/VBox/Status

var _boot_progress: float = 0.0
var _min_display_time: float = 2.0
var _elapsed: float = 0.0
var _boot_completed: bool = false

func _ready() -> void:
	_apply_theme()
	_load_splash_asset()
	_animate_in()
	# Connect boot signals if AppShell boot still running
	var boot_node = _find_boot_node()
	if boot_node:
		if boot_node.has_signal("boot_step_started"):
			boot_node.boot_step_started.connect(_on_boot_step_started)
		if boot_node.has_signal("boot_step_completed"):
			boot_node.boot_step_completed.connect(_on_boot_step_completed)
		if boot_node.has_signal("boot_completed"):
			boot_node.boot_completed.connect(_on_boot_completed)
	else:
		# If no boot node, assume boot done
		_boot_completed = true
		if progress_bar:
			progress_bar.value = 100

func _find_boot_node() -> Node:
	if has_node("/root/AppShell/AppBoot"):
		return get_node("/root/AppShell/AppBoot")
	var root = get_tree().root
	if root.has_node("AppShell/AppBoot"):
		return root.get_node("AppShell/AppBoot")
	return null

func _load_splash_asset() -> void:
	var path = "res://assets/splash/two_second_witness_splash.png"
	if ResourceLoader.exists(path):
		var tex = load(path) as Texture2D
		if tex and bg_rect:
			bg_rect.texture = tex

func _apply_theme() -> void:
	if not ThemeService:
		return
	# Keep dark background fallback

func _animate_in() -> void:
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

func _process(delta: float) -> void:
	_elapsed += delta
	if _boot_completed and _elapsed >= _min_display_time:
		_navigate_next()
		set_process(false)

func _on_boot_step_started(step: String) -> void:
	if status_label:
		status_label.text = "Loading %s..." % step.capitalize()

func _on_boot_step_completed(step: String, duration_ms: int) -> void:
	_boot_progress += 12.5 # 8 steps ~100
	if progress_bar:
		progress_bar.value = min(_boot_progress, 95)

func _on_boot_completed() -> void:
	_boot_completed = true
	if progress_bar:
		progress_bar.value = 100
	if status_label:
		status_label.text = "Ready"

func _navigate_next() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.finished.connect(func():
		# Check if first run
		var is_first_run = true
		if ProfileService:
			is_first_run = not ProfileService.profile.get("preferences", {}).get("onboarding_completed", false)
			if not is_first_run:
				is_first_run = not SettingsService.get_value("first_launch_completed", false) if SettingsService else true
		
		if is_first_run:
			if NavigationService:
				NavigationService.navigate_to("privacy")
		else:
			if NavigationService:
				NavigationService.navigate_to("home")
	)

func on_navigated_to(_params: Dictionary) -> void:
	_elapsed = 0.0
	_boot_progress = 0.0
	_boot_completed = false
	modulate.a = 0.0
	set_process(true)
	_animate_in()
	if AnalyticsService:
		AnalyticsService.log_screen_view("title_splash")
