extends Control
## ObservationChallengeScreen - 2-second observation challenge
## Shows detailed scene for exactly 2 seconds, then transitions to memory question

@onready var timer_bar: ProgressBar = $Margin/VBox/TimerBar
@onready var image_rect: TextureRect = $Margin/VBox/ImageContainer/ObservationImage
@onready var countdown_label: Label = $Margin/VBox/CountdownLabel
@onready var instruction_label: Label = $Margin/VBox/InstructionLabel

var _elapsed: float = 0.0
var _duration: float = 2.0
var _challenge_id: String = "challenge_01"
var _challenge_data: Dictionary = {}

const CHALLENGE_DEFINITIONS := {
	"challenge_01": {
		"image_path": "res://assets/gameplay/observation_challenge_01.png",
		"question": "How many colored pencils were in the green mug?",
		"options": ["3", "4", "5", "6"],
		"correct": "5",
		"detail": "There were 5 pencils: red, blue, green, yellow, and a pen"
	}
}

func _ready() -> void:
	_apply_theme()
	_load_challenge()
	_start_observation()

func _apply_theme() -> void:
	if ThemeService:
		var tokens = ThemeService.tokens
		if has_node("Margin/VBox/InstructionLabel"):
			$Margin/VBox/InstructionLabel.add_theme_color_override("font_color", tokens.get("text_primary", Color.WHITE))
		if has_node("Margin/VBox/CountdownLabel"):
			$Margin/VBox/CountdownLabel.add_theme_color_override("font_color", tokens.get("primary", Color("#7C5CFF")))

func _load_challenge() -> void:
	# Load challenge based on id or first available
	_challenge_data = CHALLENGE_DEFINITIONS.get(_challenge_id, {})
	var image_path = _challenge_data.get("image_path", "res://assets/gameplay/observation_challenge_01.png")
	
	if ResourceLoader.exists(image_path):
		var tex = load(image_path) as Texture2D
		if tex and image_rect:
			image_rect.texture = tex
			print("[Observation] Loaded challenge image %s" % image_path)
	elif FileAccess.file_exists(image_path):
		var img = Image.load_from_file(image_path)
		if img:
			var tex = ImageTexture.create_from_image(img)
			if image_rect:
				image_rect.texture = tex
	else:
		print("[Observation] Challenge image not found: %s" % image_path)
		# Fallback placeholder
		if image_rect:
			image_rect.texture = null

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
	
	# Haptics
	if AccessibilityService:
		AccessibilityService.vibrate(50)
	
	print("[Observation] Challenge started - 2 second timer")

func _process(delta: float) -> void:
	_elapsed += delta
	var remaining = _duration - _elapsed
	if remaining < 0:
		remaining = 0
	
	if countdown_label:
		countdown_label.text = "%.1fs" % remaining
	if timer_bar:
		timer_bar.value = remaining
	
	if _elapsed >= _duration:
		set_process(false)
		_transition_to_question()

func _transition_to_question() -> void:
	# Fade out
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.finished.connect(func():
		# Store challenge data for next screen
		if AppState:
			AppState.set_transient("current_challenge", _challenge_data)
			AppState.set_transient("observation_time_ms", int(_duration * 1000))
		if NavigationService:
			NavigationService.navigate_to("memory_question", {"challenge_id": _challenge_id})
	)

func on_navigated_to(params: Dictionary) -> void:
	_challenge_id = params.get("challenge_id", "challenge_01")
	if params.has("challenge_data"):
		_challenge_data = params.get("challenge_data")
	else:
		_challenge_data = CHALLENGE_DEFINITIONS.get(_challenge_id, {})
	
	modulate.a = 1.0
	_load_challenge()
	_start_observation()
	
	if AnalyticsService:
		AnalyticsService.log_event("observation_started", {"challenge_id": _challenge_id})
