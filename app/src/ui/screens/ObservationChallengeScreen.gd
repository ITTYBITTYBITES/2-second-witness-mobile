extends Control
## ObservationChallengeScreen - Reusable two-second observation view.

@onready var background: ColorRect = $Background
@onready var timer_bar: ProgressBar = $Margin/VBox/TimerBar
@onready var image_container: PanelContainer = $Margin/VBox/ImageContainer
@onready var image_rect: TextureRect = $Margin/VBox/ImageContainer/ObservationImage
@onready var countdown_label: Label = $Margin/VBox/CountdownLabel
@onready var instruction_label: Label = $Margin/VBox/InstructionLabel
@onready var hint_label: Label = $Margin/VBox/Hint

var _elapsed := 0.0
var _duration := 2.0
var _challenge_id := "challenge_01"
var _challenge_data: Dictionary = {}
var _transitioning := false

const FALLBACK_CHALLENGE := {
	"id": "challenge_01",
	"title": "Study Desk",
	"image_path": "res://assets/gameplay/observation_challenge_01.png",
	"question": "How many writing tools were in the green mug?",
	"options": ["3", "4", "5", "6"],
	"correct": "5",
	"detail": "There were 5 writing tools in the green mug."
}

func _ready() -> void:
	set_process(false)
	_apply_theme()
	if ThemeService and not ThemeService.theme_changed.is_connected(_on_theme_changed):
		ThemeService.theme_changed.connect(_on_theme_changed)

func _apply_theme() -> void:
	if not ThemeService:
		return
	var tokens := ThemeService.tokens
	background.color = tokens.get("background", Color("#0F0F12"))
	ThemeService.apply_label_style(instruction_label, "body", "text_primary")
	ThemeService.apply_label_style(countdown_label, "headline", "primary_text")
	ThemeService.apply_label_style(hint_label, "body_small", "text_secondary")
	var timer_background := StyleBoxFlat.new()
	timer_background.bg_color = tokens.get("surface_elevated", Color("#2A2A36"))
	timer_background.set_corner_radius_all(4)
	var timer_fill := StyleBoxFlat.new()
	timer_fill.bg_color = tokens.get("primary_text", Color("#A78FFF"))
	timer_fill.set_corner_radius_all(4)
	timer_bar.add_theme_stylebox_override("background", timer_background)
	timer_bar.add_theme_stylebox_override("fill", timer_fill)
	var image_style := StyleBoxFlat.new()
	image_style.bg_color = tokens.get("surface", Color("#1E1E26"))
	image_style.border_color = tokens.get("border", Color("#2E2E3A"))
	image_style.set_border_width_all(1)
	image_style.set_corner_radius_all(int(tokens.get("radius_md", 12)))
	image_container.add_theme_stylebox_override("panel", image_style)

func _load_challenge() -> bool:
	if _challenge_data.is_empty() and AppState:
		var transient = AppState.get_transient("current_challenge", {})
		if transient is Dictionary and not transient.is_empty():
			_challenge_data = transient
	if _challenge_data.is_empty() and ChallengeRegistry:
		_challenge_data = ChallengeRegistry.get_challenge(_challenge_id)
	if _challenge_data.is_empty():
		_challenge_data = FALLBACK_CHALLENGE.duplicate(true)

	_challenge_id = str(_challenge_data.get("id", _challenge_id))
	var image_path := str(_challenge_data.get("image_path", FALLBACK_CHALLENGE["image_path"]))
	if not ResourceLoader.exists(image_path):
		_show_asset_error(image_path)
		return false
	var texture := load(image_path) as Texture2D
	if not texture:
		_show_asset_error(image_path)
		return false
	image_rect.texture = texture
	hint_label.text = str(_challenge_data.get("title", "Focus your attention"))
	return true

func _show_asset_error(image_path: String) -> void:
	set_process(false)
	image_rect.texture = null
	instruction_label.text = "Challenge unavailable"
	hint_label.text = "Return to Play and choose another challenge."
	countdown_label.text = ""
	if ErrorHandler:
		ErrorHandler.handle("CHALLENGE_IMAGE_MISSING", "Missing challenge image", {"path": image_path})
		ErrorHandler.user_message_requested.emit("This challenge could not be loaded.", ErrorHandler.Severity.ERROR)

func _start_observation() -> void:
	_elapsed = 0.0
	_duration = 2.0
	_transitioning = false
	modulate.a = 1.0
	instruction_label.text = "Observe carefully — 2 seconds"
	countdown_label.text = "2.0s"
	timer_bar.max_value = _duration
	timer_bar.value = _duration
	set_process(true)
	if AccessibilityService:
		AccessibilityService.vibrate(50)
	if AnalyticsService:
		AnalyticsService.log_event("observation_started", {"challenge_id": _challenge_id})

func _process(delta: float) -> void:
	if _transitioning:
		return
	_elapsed += delta
	var remaining := maxf(_duration - _elapsed, 0.0)
	countdown_label.text = "%.1fs" % remaining
	timer_bar.value = remaining
	if _elapsed >= _duration:
		set_process(false)
		_transition_to_question()

func _transition_to_question() -> void:
	if _transitioning:
		return
	_transitioning = true
	if AccessibilityService and AccessibilityService.is_reduced_motion_enabled():
		_open_question()
		return
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.finished.connect(_open_question)

func _open_question() -> void:
	if AppState:
		AppState.set_transient("current_challenge_id", _challenge_id)
		AppState.set_transient("current_challenge", _challenge_data)
	if NavigationService:
		NavigationService.navigate_to("memory_question", {
			"challenge_id": _challenge_id,
			"challenge_data": _challenge_data
		})

func on_navigated_to(params: Dictionary) -> void:
	var fallback_id := "challenge_01"
	if AppState:
		fallback_id = str(AppState.get_transient("current_challenge_id", fallback_id))
	_challenge_id = str(params.get("challenge_id", fallback_id))
	if params.has("challenge_data") and params.get("challenge_data") is Dictionary:
		_challenge_data = params.get("challenge_data")
	else:
		_challenge_data = {}
	modulate.a = 1.0
	if _load_challenge():
		_start_observation()

func _on_theme_changed(_theme: String, _tokens: Dictionary) -> void:
	_apply_theme()
