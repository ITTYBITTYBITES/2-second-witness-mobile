extends Node
## AudioService - Centralized audio management
## Supports BGM, SFX, UI sounds, per-bus volume, mute states
## Designed to be extendable with AudioStreamPlayers pooled

signal volume_changed(bus: String, volume_db: float, linear: float)
signal bus_muted(bus: String, muted: bool)
signal sound_played(sound_id: String, bus: String)

enum Bus { MASTER, BGM, SFX, UI }

const BUS_NAMES := {
	Bus.MASTER: "Master",
	Bus.BGM: "BGM",
	Bus.SFX: "SFX",
	Bus.UI: "UI"
}

var _bgm_player: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []
var _ui_player: AudioStreamPlayer
var _initialized: bool = false

var _volumes: Dictionary = {
	"Master": 1.0,
	"BGM": 0.8,
	"SFX": 0.9,
	"UI": 0.8
}

var _muted: Dictionary = {
	"Master": false,
	"BGM": false,
	"SFX": false,
	"UI": false
}

func _ready() -> void:
	print("[AudioService] Ready")
	EventBus.audio_requested.connect(_on_audio_requested)

func initialize() -> void:
	if _initialized:
		return

	# Create audio buses if not present (gl_compatibility still supports buses)
	_ensure_buses()

	# Create players
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = BUS_NAMES[Bus.BGM]
	_bgm_player.name = "BGMPlayer"
	add_child(_bgm_player)

	_ui_player = AudioStreamPlayer.new()
	_ui_player.bus = BUS_NAMES[Bus.UI]
	_ui_player.name = "UIPlayer"
	add_child(_ui_player)

	# SFX pool of 6 players
	for i in range(6):
		var p := AudioStreamPlayer.new()
		p.bus = BUS_NAMES[Bus.SFX]
		p.name = "SFXPool_%d" % i
		add_child(p)
		_sfx_pool.append(p)

	# Load settings
	if SettingsService:
		_volumes["Master"] = SettingsService.get_value("volume_master", 1.0)
		_volumes["BGM"] = SettingsService.get_value("volume_bgm", 0.8)
		_volumes["SFX"] = SettingsService.get_value("volume_sfx", 0.9)
		_volumes["UI"] = SettingsService.get_value("volume_ui", 0.8)
		_muted["Master"] = SettingsService.get_value("mute_master", false)
		_muted["BGM"] = SettingsService.get_value("mute_bgm", false)
		_muted["SFX"] = SettingsService.get_value("mute_sfx", false)
		_muted["UI"] = SettingsService.get_value("mute_ui", false)

	_apply_all_volumes()

	_initialized = true
	print("[AudioService] Initialized - Buses: %s" % str(BUS_NAMES))

func _ensure_buses() -> void:
	# Create custom buses via AudioServer if not exist
	var needed := ["BGM", "SFX", "UI"]
	for n in needed:
		var idx := AudioServer.get_bus_index(n)
		if idx == -1:
			AudioServer.add_bus()
			var new_idx := AudioServer.bus_count - 1
			AudioServer.set_bus_name(new_idx, n)
			AudioServer.set_bus_send(new_idx, "Master")
			print("[AudioService] Created bus %s at %d" % [n, new_idx])

func play_ui(sound_id: String, volume_linear: float = 1.0) -> void:
	play_sound(sound_id, Bus.UI, volume_linear)

func play_sfx(sound_id: String, volume_linear: float = 1.0) -> void:
	play_sound(sound_id, Bus.SFX, volume_linear)

func play_bgm(sound_id: String, loop: bool = true, _fade_duration: float = 0.5) -> void:
	play_sound(sound_id, Bus.BGM, 1.0, loop)

func play_sound(
	sound_id: String,
	bus: Bus = Bus.SFX,
	volume_linear: float = 1.0,
	_loop: bool = false
) -> void:
	# In foundation phase, we support placeholder beeps and Tone generation
	# Real implementation would load AudioStream from ContentService

	var bus_name: String = BUS_NAMES[bus]
	if _muted.get(bus_name, false) or _muted.get("Master", false):
		return

	# Generate placeholder procedural audio if no file (foundation placeholder)
	var stream: AudioStream = _get_stream_for_id(sound_id)
	if not stream:
		# Silently skip if no asset yet, but log for analytics
		print("[AudioService] Sound '%s' not found (placeholder)" % sound_id)
		return

	match bus:
		Bus.BGM:
			_bgm_player.stream = stream
			_bgm_player.volume_db = linear_to_db(volume_linear * _volumes[bus_name])
			_bgm_player.play()
		Bus.UI:
			_ui_player.stream = stream
			_ui_player.volume_db = linear_to_db(volume_linear * _volumes[bus_name])
			_ui_player.play()
		_:
			# Find free player in pool
			var player: AudioStreamPlayer = _get_free_sfx_player()
			if player:
				player.stream = stream
				player.volume_db = linear_to_db(volume_linear * _volumes[bus_name])
				player.play()

	sound_played.emit(sound_id, bus_name)

func _get_free_sfx_player() -> AudioStreamPlayer:
	for p in _sfx_pool:
		if not p.playing:
			return p
	# If all busy, return first (steal)
	return _sfx_pool[0] if _sfx_pool.size() > 0 else null

func _get_stream_for_id(sound_id: String) -> AudioStream:
	# Try load from content
	# res://assets/audio/ fallback
	var paths := [
		"res://assets/audio/%s.wav" % sound_id,
		"res://assets/audio/%s.ogg" % sound_id,
		"res://src/experiences/%s/audio/%s.wav" % [sound_id, sound_id]
	]
	for p in paths:
		if ResourceLoader.exists(p):
			return load(p)
	return null

func set_volume(bus: Bus, linear: float) -> void:
	var bus_name: String = BUS_NAMES[bus]
	_volumes[bus_name] = clamp(linear, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), linear_to_db(_volumes[bus_name]))
	volume_changed.emit(bus_name, linear_to_db(_volumes[bus_name]), _volumes[bus_name])
	if SettingsService:
		SettingsService.set_value("volume_%s" % bus_name.to_lower(), _volumes[bus_name])
	print("[AudioService] Volume %s = %.2f" % [bus_name, linear])

func get_volume(bus: Bus) -> float:
	return _volumes.get(BUS_NAMES[bus], 1.0)

func set_muted(bus: Bus, muted: bool) -> void:
	var bus_name: String = BUS_NAMES[bus]
	_muted[bus_name] = muted
	AudioServer.set_bus_mute(AudioServer.get_bus_index(bus_name), muted)
	bus_muted.emit(bus_name, muted)
	if SettingsService:
		SettingsService.set_value("mute_%s" % bus_name.to_lower(), muted)

func is_muted(bus: Bus) -> bool:
	return _muted.get(BUS_NAMES[bus], false)

func _apply_all_volumes() -> void:
	for b in BUS_NAMES.values():
		var idx := AudioServer.get_bus_index(b)
		if idx != -1:
			AudioServer.set_bus_volume_db(idx, linear_to_db(_volumes.get(b, 1.0)))
			AudioServer.set_bus_mute(idx, _muted.get(b, false))

func stop_bgm(_fade_duration: float = 0.3) -> void:
	if _bgm_player and _bgm_player.playing:
		_bgm_player.stop()

func _on_audio_requested(bus: String, sound_id: String, params: Dictionary) -> void:
	var b: Bus = Bus.SFX
	match bus.to_lower():
		"bgm": b = Bus.BGM
		"ui": b = Bus.UI
		"sfx": b = Bus.SFX
		"master": b = Bus.MASTER
	play_sound(sound_id, b, params.get("volume", 1.0))
