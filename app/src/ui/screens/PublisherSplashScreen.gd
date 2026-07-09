extends Control
## PublisherSplashScreen - ITTYBITTYBITES publisher splash
## Simple text-only on black, 1-2 seconds, fade to black (we already start on black).
## Premium editorial feel, minimal.

@onready var title_label: Label = $VBox/Margin/Inner/Title
@onready var subtitle_label: Label = $VBox/Margin/Inner/Subtitle

var _elapsed: float = 0.0
const DISPLAY_DURATION := 1.5  # 1-2 seconds, premium feel without dragging
var _is_navigating: bool = false
var _can_advance: bool = false

func _ready() -> void:
	_elapsed = 0.0
	_is_navigating = false
	_can_advance = false
	set_process(true)
	_apply_theme()
	_animate_in()
	# If boot already finished (fast devices / warm start) advance as soon as
	# DISPLAY_DURATION elapses; otherwise wait for AppShell to notify us.
	if AppState and AppState.is_initialized:
		_can_advance = true
	print("[PublisherSplash] Ready")

func notify_boot_completed() -> void:
	# Called by AppShell when background boot finishes.
	_can_advance = true

func _apply_theme() -> void:
	# Black canvas - we own the background directly.
	if $Background:
		$Background.color = Color(0.055, 0.055, 0.07, 1.0)
	if not ThemeService:
		return
	var tokens := ThemeService.tokens
	if title_label:
		title_label.add_theme_color_override("font_color", Color.WHITE)
		title_label.add_theme_font_size_override("font_size", 28)
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if subtitle_label:
		subtitle_label.add_theme_color_override("font_color", tokens.get("text_secondary", Color.GRAY))
		subtitle_label.add_theme_font_size_override("font_size", 14)
		subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _animate_in() -> void:
	modulate.a = 0.0
	$VBox.modulate.a = 0.0
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate:a", 1.0, 0.3).set_ease(Tween.EASE_OUT)
	var center_fade := tween.parallel().tween_property($VBox, "modulate:a", 1.0, 0.5)
	center_fade.set_ease(Tween.EASE_OUT).set_delay(0.1)

func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= DISPLAY_DURATION and _can_advance:
		_navigate_next()
		set_process(false)

func _input(event: InputEvent) -> void:
	# Allow tap-to-skip after a small grace period. Skip only moves to the next
	# splash if boot is already done; otherwise it just shortens the wait and
	# the next screen will hold for boot completion.
	if event is InputEventScreenTouch and event.pressed:
		if _elapsed > 0.3:
			_can_advance = true
			_navigate_next()
			set_process(false)

func _navigate_next() -> void:
	if _is_navigating:
		return
	_is_navigating = true
	# Fade to black (we're already on near-black, so just fade text out cleanly)
	var tween := create_tween()
	tween.tween_property($VBox, "modulate:a", 0.0, 0.35).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, 0.35).set_ease(Tween.EASE_IN)
	tween.finished.connect(func():
		if NavigationService:
			NavigationService.navigate_to("title_splash")
	)

func on_navigated_to(_params: Dictionary) -> void:
	_elapsed = 0.0
	_is_navigating = false
	modulate.a = 0.0
	$VBox.modulate.a = 0.0
	set_process(true)
	_animate_in()
	# Screen-view analytics are centralized in NavigationService.navigate_to.
