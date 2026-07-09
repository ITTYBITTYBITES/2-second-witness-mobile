extends Control
## SplashScreen - Clean startup, brand, boot progress

@onready var title_label: Label = $Center/VBox/Title
@onready var subtitle_label: Label = $Center/VBox/Subtitle
@onready var progress_bar: ProgressBar = $Center/VBox/ProgressBar
@onready var status_label: Label = $Center/VBox/Status

var _boot_steps_completed: int = 0
var _total_boot_steps: int = 8

func _ready() -> void:
	_ensure_ui()
	_apply_theme()
	
	if has_node("/root/AppBoot") or get_node_or_null("../../AppBoot"):
		# Connect boot signals if available
		var boot_node: Node = _find_boot_node()
		if boot_node:
			if boot_node.has_signal("boot_step_started"):
				boot_node.boot_step_started.connect(_on_boot_step_started)
			if boot_node.has_signal("boot_step_completed"):
				boot_node.boot_step_completed.connect(_on_boot_step_completed)
			if boot_node.has_signal("boot_completed"):
				boot_node.boot_completed.connect(_on_boot_completed)
	
	# Animate title
	_animate_in()

func _find_boot_node() -> Node:
	# Try common paths
	var candidates := [
		"/root/AppShell/AppBoot",
		"../../AppBoot",
		"../AppBoot",
	]
	for p in candidates:
		if has_node(p):
			return get_node(p)
	# Search child of AppShell
	var root := get_tree().root
	if root.has_node("AppShell/AppBoot"):
		return root.get_node("AppShell/AppBoot")
	# Fallback scan
	var app_shell := _find_app_shell()
	if app_shell and app_shell.has_node("AppBoot"):
		return app_shell.get_node("AppBoot")
	return null

func _find_app_shell() -> Node:
	var root := get_tree().root
	if root.has_node("AppShell"):
		return root.get_node("AppShell")
	return null

func _ensure_ui() -> void:
	if has_node("Center/VBox/Title"):
		return
	
	var center := CenterContainer.new()
	center.name = "Center"
	center.anchor_right = 1.0
	center.anchor_bottom = 1.0
	add_child(center)
	
	var vbox := VBoxContainer.new()
	vbox.name = "VBox"
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 16)
	center.add_child(vbox)
	
	var icon_label := Label.new()
	icon_label.name = "Icon"
	icon_label.text = "◉"
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.add_theme_font_size_override("font_size", 64)
	vbox.add_child(icon_label)
	
	var title := Label.new()
	title.name = "Title"
	title.text = "2 SECOND\nWITNESS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	vbox.add_child(title)
	
	var subtitle := Label.new()
	subtitle.name = "Subtitle"
	subtitle.text = "Observe. Remember. React."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(subtitle)
	
	var progress := ProgressBar.new()
	progress.name = "ProgressBar"
	progress.custom_minimum_size = Vector2(200, 8)
	progress.show_percentage = false
	progress.max_value = 100
	progress.value = 0
	vbox.add_child(progress)
	
	var status := Label.new()
	status.name = "Status"
	status.text = "Initializing..."
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.add_theme_font_size_override("font_size", 11)
	vbox.add_child(status)
	
	title_label = title
	subtitle_label = subtitle
	progress_bar = progress
	status_label = status

func _apply_theme() -> void:
	if not ThemeService:
		return
	var tokens = ThemeService.tokens
	if title_label:
		title_label.add_theme_color_override("font_color", tokens.get("primary", Color("#7C5CFF")))
	if subtitle_label:
		subtitle_label.add_theme_color_override("font_color", tokens.get("text_secondary", Color.GRAY))
	if status_label:
		status_label.add_theme_color_override("font_color", tokens.get("text_tertiary", Color.GRAY))

func _animate_in() -> void:
	if AccessibilityService and AccessibilityService.is_reduced_motion_enabled():
		return
	# Simple fade-in via modulate
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5).set_ease(Tween.EASE_OUT)

func _on_boot_step_started(step: String) -> void:
	if status_label:
		status_label.text = "Loading %s..." % step.capitalize()

func _on_boot_step_completed(step: String, duration_ms: int) -> void:
	_boot_steps_completed += 1
	var pct: float = float(_boot_steps_completed) / float(_total_boot_steps) * 100.0
	if progress_bar:
		progress_bar.value = pct
	print("[SplashScreen] Boot step %s done %d ms (%d/%d)" % [step, duration_ms, _boot_steps_completed, _total_boot_steps])

func _on_boot_completed() -> void:
	if status_label:
		status_label.text = "Ready!"
	if progress_bar:
		progress_bar.value = 100
	
	# Short delay then navigate
	await get_tree().create_timer(0.4).timeout
	
	if NavigationService:
		NavigationService.navigate_to("home")
	else:
		print("[SplashScreen] No NavigationService, staying")

func on_navigated_to(_params: Dictionary) -> void:
	_boot_steps_completed = 0
	if progress_bar:
		progress_bar.value = 0
	if status_label:
		status_label.text = "Initializing..."
	_animate_in()
