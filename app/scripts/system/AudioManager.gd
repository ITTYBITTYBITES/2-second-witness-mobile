extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# AUDIO MANAGEMENT LAYER
# ---------------------------------------------------------

var _ambient_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_pool_size: int = 5
var _sfx_index: int = 0

var audio_assets = {
	"ambient_science_lab": "res://assets/audio/ambience_science_lab.wav",
	"ui_click": "res://assets/audio/ui_click.wav",
	"ui_error": "res://assets/audio/ui_error.wav",
	"slingshot": "res://assets/audio/slingshot_drop.wav",
	"iris_heartbeat": "res://assets/audio/iris_heartbeat.wav"
}

func _ready():
	print("[AUDIO MANAGER] Online. Initializing Audio Buses.")
	
	# Setup Ambient Channel
	_ambient_player = AudioStreamPlayer.new()
	_ambient_player.bus = "Ambient"
	_ambient_player.volume_db = -10.0
	add_child(_ambient_player)
	
	# Setup SFX Pooling (to handle overlapping sounds without clipping)
	for i in range(_sfx_pool_size):
		var p = AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_sfx_players.append(p)
		
	# Hook into Global Events
	NavigationEngine.transition_sequence_started.connect(_on_transition)

func play_sfx(sound_id: String, volume_offset: float = 0.0, pitch_scale: float = 1.0):
	if not audio_assets.has(sound_id): return
	
	var stream = load(audio_assets[sound_id])
	if not stream: return
	
	var player = _sfx_players[_sfx_index]
	player.stream = stream
	player.volume_db = volume_offset
	player.pitch_scale = pitch_scale
	player.play()
	
	_sfx_index = (_sfx_index + 1) % _sfx_pool_size

func play_ambient(universe_id: String):
	var ambient_id = "ambient_" + universe_id
	if not audio_assets.has(ambient_id):
		ambient_id = "ambient_science_lab" # Fallback
		
	var stream = load(audio_assets[ambient_id])
	if stream and _ambient_player.stream != stream:
		_ambient_player.stream = stream
		_ambient_player.play()
		
		# Fade in
		_ambient_player.volume_db = -40.0
		var tween = get_tree().create_tween()
		tween.tween_property(_ambient_player, "volume_db", -10.0, 2.0)

func stop_ambient():
	var tween = get_tree().create_tween()
	tween.tween_property(_ambient_player, "volume_db", -40.0, 1.0)
	tween.tween_callback(_ambient_player.stop)

func _on_transition():
	# Play the heavy suction plunge
	play_sfx("ui_click", 5.0, 0.5) 
