extends Control
## PublisherSplashScreen - ITTYBITTYBITES publisher splash
## Image-only, no text overlay. Robust auto-advance with boot + fallback.

@onready var splash_image: TextureRect = $SplashImage

var _elapsed: float = 0.0
const DISPLAY_DURATION := 1.6
const MAX_WAIT := 4.0
var _is_navigating: bool = false
var _can_advance: bool = false

func _ready() -> void:
	_elapsed = 0.0
	_is_navigating = false
	_can_advance = false
	set_process(true)
	_load_splash_image()
	_animate_in()
	if AppState and AppState.is_initialized:
		_can_advance = true
	print("[PublisherSplash] Ready - image only")

func _load_splash_image() -> void:
	if splash_image:
		var path := "res://assets/splash/ittybittybites_splash.png"
		if ResourceLoader.exists(path):
			splash_image.texture = load(path)
			splash_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			splash_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			splash_image.modulate.a = 1.0
		else:
			splash_image.visible = false
	if has_node("Background") and $Background:
		$Background.color = Color(0.055, 0.055, 0.07, 1.0)

func notify_boot_completed() -> void:
	_can_advance = true
	print("[PublisherSplash] Boot completed notified")

func _animate_in() -> void:
	modulate.a = 0.0
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate:a", 1.0, 0.28).set_ease(Tween.EASE_OUT)

func _process(delta: float) -> void:
	_elapsed += delta
	if not _is_navigating and _elapsed >= DISPLAY_DURATION:
		if _can_advance or _elapsed >= MAX_WAIT:
			_navigate_next()
			set_process(false)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		if _elapsed > 0.25 and not _is_navigating:
			_can_advance = true
			_navigate_next()
			set_process(false)
	if event is InputEventKey and event.pressed:
		if _elapsed > 0.25 and not _is_navigating:
			_can_advance = true
			_navigate_next()
			set_process(false)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _elapsed > 0.25 and not _is_navigating:
			_can_advance = true
			_navigate_next()
			set_process(false)

func _navigate_next() -> void:
	if _is_navigating:
		return
	_is_navigating = true
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate:a", 0.0, 0.32).set_ease(Tween.EASE_IN)
	tween.finished.connect(func():
		if NavigationService:
			NavigationService.navigate_to("title_splash")
		else:
			print("[PublisherSplash] NavigationService missing, cannot navigate")
	)

func on_navigated_to(_params: Dictionary) -> void:
	_elapsed = 0.0
	_is_navigating = false
	modulate.a = 0.0
	set_process(true)
	_animate_in()
