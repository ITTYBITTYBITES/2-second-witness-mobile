extends Control
class_name FlashWordsSceneView
## Family typography renderer for observation sequences and result comparison.

var _scene_data: Dictionary = {}
var _elapsed: float = 0.0
var _last_index: int = -2
var _word_label: Label
var _detail_label: Label
var _position_label: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()
	_apply_scene()

func set_scene_data(scene_data: Dictionary, _highlight_ids: Array = []) -> void:
	_scene_data = scene_data.duplicate(true)
	_elapsed = 0.0
	_last_index = -2
	if is_inside_tree():
		_build_ui()
		_apply_scene()

func _build_ui() -> void:
	if _word_label:
		return
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)
	var stack := VBoxContainer.new()
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 18)
	margin.add_child(stack)
	_word_label = Label.new()
	_word_label.custom_minimum_size = Vector2(0, 160)
	_word_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_word_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_word_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_word_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	_word_label.add_theme_color_override("font_color", Color("#F5F3FA"))
	stack.add_child(_word_label)
	_detail_label = Label.new()
	_detail_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_label.add_theme_color_override("font_color", Color("#B8B8CC"))
	_detail_label.add_theme_font_size_override("font_size", 22)
	stack.add_child(_detail_label)
	_position_label = Label.new()
	_position_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_position_label.add_theme_color_override("font_color", Color("#8A68FF"))
	_position_label.add_theme_font_size_override("font_size", 18)
	stack.add_child(_position_label)

func _apply_scene() -> void:
	if not _word_label:
		return
	var reading_comfort := bool(_scene_data.get("reading_comfort_mode", false))
	_word_label.add_theme_font_size_override("font_size", 124 if reading_comfort else 104)
	if bool(_scene_data.get("reveal_mode", false)):
		set_process(false)
		_word_label.text = str(_scene_data.get("correct_display", ""))
		_detail_label.text = "You selected: %s\nCorrect: %s\nDifference: %s" % [
			_scene_data.get("player_display", "—"),
			_scene_data.get("correct_display", "—"),
			_scene_data.get("difference", "Exact match")
		]
		_position_label.text = "REVEAL"
		# ResultScreen owns the single outcome cue so family reveals do not layer
		# a second success/failure sound over it.
		return
	_detail_label.text = ""
	_position_label.text = ""
	set_process(true)
	_update_sequence()

func _process(delta: float) -> void:
	_elapsed += delta
	_update_sequence()

func _update_sequence() -> void:
	if not _word_label or bool(_scene_data.get("reveal_mode", false)):
		return
	var words_value: Variant = _scene_data.get("words", [])
	if not (words_value is Array):
		_word_label.text = ""
		return
	var words: Array = words_value
	var display := maxf(float(_scene_data.get("display_duration", 1.0)), 0.05)
	var interval := maxf(float(_scene_data.get("inter_word_interval", 0.0)), 0.0)
	var span := display + interval
	var index := int(floor(_elapsed / span))
	var local_time := fmod(_elapsed, span)
	if index >= words.size():
		_word_label.text = ""
		_position_label.text = ""
		return
	var showing_word := local_time <= display
	_word_label.text = str(words[index]) if showing_word else ""
	_position_label.text = "%d / %d" % [index + 1, words.size()] if words.size() > 1 else ""
	if showing_word and index != _last_index:
		_last_index = index
		if AudioService:
			AudioService.play_sfx("flash_pulse", 0.45)
