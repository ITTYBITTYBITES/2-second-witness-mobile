extends Control
## PublisherSplashScreen - ITTYBITTYBITES presents
## First screen in first-run flow, premium gallery feeling

@onready var bg_rect: TextureRect = $Background
@onready var title_label: Label = $Center/VBox/Title
@onready var subtitle_label: Label = $Center/VBox/Subtitle
@onready var detail_label: Label = $Center/VBox/Detail

var _elapsed: float = 0.0
const DISPLAY_DURATION := 2.5

func _ready() -> void:
	_apply_theme()
	_load_splash_asset()
	_animate_in()
	print("[PublisherSplash] Ready - ITTYBITTYBITES presents")

func _load_splash_asset() -> void:
	# Try to load generated premium asset
	var path = "res://assets/splash/ittybittybites_splash.png"
	if ResourceLoader.exists(path):
		var tex = load(path) as Texture2D
		if tex and has_node("Background"):
			$Background.texture = tex
			print("[PublisherSplash] Loaded premium asset")
	elif FileAccess.file_exists("res://assets/splash/ittybittybites_splash.png"):
		var img = Image.load_from_file("res://assets/splash/ittybittybites_splash.png")
		if img:
			var tex = ImageTexture.create_from_image(img)
			if has_node("Background"):
				$Background.texture = tex

func _apply_theme() -> void:
	if not ThemeService:
		return
	var tokens = ThemeService.tokens
	if tokens.is_empty():
		return
	# Background handled by texture, but ensure panel color fallback
	if has_node("Background"):
		$Background.modulate = Color.WHITE

func _animate_in() -> void:
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.6).set_ease(Tween.EASE_OUT)
	
	# Subtle scale for premium feel if not reduced motion
	if AccessibilityService and not AccessibilityService.is_reduced_motion_enabled():
		if has_node("Center"):
			$Center.scale = Vector2(0.96, 0.96)
			var tween2 = create_tween()
			tween2.tween_property($Center, "scale", Vector2.ONE, 1.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= DISPLAY_DURATION:
		_navigate_next()
		set_process(false)

func _navigate_next() -> void:
	# Fade out
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.finished.connect(func():
		if NavigationService:
			NavigationService.navigate_to("title_splash")
		else:
			print("[PublisherSplash] NavigationService not available")
	)

func on_navigated_to(_params: Dictionary) -> void:
	_elapsed = 0.0
	modulate.a = 0.0
	set_process(true)
	_animate_in()
	if AnalyticsService:
		AnalyticsService.log_screen_view("publisher_splash")

func _input(event: InputEvent) -> void:
	# Allow tap to skip after 0.5s
	if event is InputEventScreenTouch and event.pressed:
		if _elapsed > 0.5:
			_navigate_next()
			set_process(false)
