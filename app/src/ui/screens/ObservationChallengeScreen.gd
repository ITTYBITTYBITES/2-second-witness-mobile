extends Control
## ObservationChallengeScreen - Reusable 2-second observation challenge screen

@onready var timer_bar: ProgressBar = $Margin/VBox/TimerBar
@onready var image_rect: TextureRect = $Margin/VBox/ImageContainer/ObservationImage
@onready var countdown_label: Label = $Margin/VBox/CountdownLabel
@onready var instruction_label: Label = $Margin/VBox/InstructionLabel
@onready var hint_label: Label = $Margin/VBox/Hint

var _elapsed: float = 0.0
var _duration: float = 2.0
var _challenge_id: String = "challenge_01"
var _challenge_data: Dictionary = {}

const FALLBACK_CHALLENGE := {
	"id": "challenge_01",
	"title": "Study Desk",
	"image_path": "res://assets/gameplay/observation_challenge_01.png",
	"question": "How many colored pencils were in the green mug?",
	"options": ["3", "4", "5", "6"],
	"correct": "5",
	"detail": "There were 5 writing tools in the green mug."
}

func _ready() -> void:
	_apply_theme()
	_load_challenge()
	_start_observation()

func _apply_theme() -> void:
	if ThemeService:
		var tokens = ThemeService.tokens
		if instruction_label:
			ThemeService.apply_label_style(instruction_label, "body", "text_primary")
			instruction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if countdown_label:
			ThemeService.apply_label_style(countdown_label, "headline", "primary")
			countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if hint_label:
			ThemeService.apply_label_style(hint_label, "body_small", "text_secondary")
			hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _load_challenge() -> void:
	if _challenge_data.is_empty() and AppState:
		var transient = AppState.get_transient("current_challenge", {})
		if transient is Dictionary and not transient.is_empty():
			_challenge_data = transient

	if _challenge_data.is_empty() and ChallengeRegistry:
		_challenge_data = ChallengeRegistry.get_challenge(_challenge_id)

	if _challenge_data.is_empty():
		_challenge_data = FALLBACK_CHALLENGE.duplicate(true)

	_challenge_id = str(_challenge_data.get("id", _challenge_id))
	var image_path: String = str(_challenge_data.get("image_path", FALLBACK_CHALLENGE["image_path"]))

	if ResourceLoader.exists(image_path):
		var tex = load(image_path) as Texture2D
		if tex and image_rect:
			image_rect.texture = tex
			print("[Observation] Loaded challenge image %s" % image_path)
	else:
		print("[Observation] Challenge image not found: %s" % image_path)
		if image_rect:
			image_rect.texture = null

	if hint_label:
		hint_label.text = str(_challenge_data.get("title", "Focus your attention"))

func _start_observation() -> void:
	_elapsed = 0.0
	_duration = 2.0
	set_process(true)
	if instruction_label:
		instruction_label.text = "Observe carefully — 2 seconds"
	if countdown_label:
		countdown_label.text = "2.0s"
	if timer_bar:
		timer_bar.max_value = _duration
		timer_bar.value = _duration

	if AccessibilityService:
		AccessibilityService.vibrate(50)

	print("[Observation] Challenge started - %s" % _challenge_id)

func _process(delta: float) -> void:
	_elapsed += delta
	var remaining = max(_duration - _elapsed, 0.0)

	if countdown_label:
		countdown_label.text = "%.1fs" % remaining
	if timer_bar:
		timer_bar.value = remaining

	if _elapsed >= _duration:
		set_process(false)
		_transition_to_question()

func _transition_to_question() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.finished.connect(func():
		if AppState:
			AppState.set_transient("current_challenge_id", _challenge_id)
			AppState.set_transient("current_challenge", _challenge_data)
		if NavigationService:
			NavigationService.navigate_to("memory_question", {
				"challenge_id": _challenge_id,
				"challenge_data": _challenge_data
			})
	)

func on_navigated_to(params: Dictionary) -> void:
	var fallback_id := "challenge_01"
	if AppState:
		fallback_id = AppState.get_transient("current_challenge_id", fallback_id)
	_challenge_id = str(params.get("challenge_id", fallback_id))
	if params.has("challenge_data") and params.get("challenge_data") is Dictionary:
		_challenge_data = params.get("challenge_data")
	else:
		_challenge_data = {}

	modulate.a = 1.0
	_load_challenge()
	_start_observation()

	if AnalyticsService:
		AnalyticsService.log_event("observation_started", {"challenge_id": _challenge_id})
