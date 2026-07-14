extends Control
class_name FlashWordsSceneView
## Family typography renderer for observation sequences and result comparison.

var _scene_data: Dictionary = {}
var _elapsed: float = 0.0
var _last_index: int = -2
var _word_card: PanelContainer
var _word_label: Label
var _detail_label: Label
var _position_label: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not resized.is_connected(queue_redraw):
		resized.connect(queue_redraw)
	_build_ui()
	_apply_scene()
	queue_redraw()

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
	_word_card = PanelContainer.new()
	_word_card.name = "FlashWordCard"
	_word_card.custom_minimum_size = Vector2(0, 176)
	_word_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color(0.10, 0.07, 0.18, 0.92)
	card_style.border_color = Color("#8A68FF")
	card_style.border_width_left = 2
	card_style.border_width_right = 2
	card_style.border_width_top = 2
	card_style.border_width_bottom = 2
	card_style.corner_radius_top_left = 28
	card_style.corner_radius_top_right = 28
	card_style.corner_radius_bottom_left = 28
	card_style.corner_radius_bottom_right = 28
	card_style.content_margin_left = 18
	card_style.content_margin_right = 18
	card_style.content_margin_top = 18
	card_style.content_margin_bottom = 18
	_word_card.add_theme_stylebox_override("panel", card_style)
	stack.add_child(_word_card)
	_word_label = Label.new()
	_word_label.custom_minimum_size = Vector2(0, 132)
	_word_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_word_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_word_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_word_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	_word_label.add_theme_color_override("font_color", Color("#F5F3FA"))
	_word_label.add_theme_color_override("font_shadow_color", Color(0.54, 0.41, 1.0, 0.75))
	_word_label.add_theme_constant_override("shadow_offset_x", 0)
	_word_label.add_theme_constant_override("shadow_offset_y", 3)
	_word_card.add_child(_word_label)
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

func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	draw_rect(rect, Color("#100D18"), true)
	var band_color := Color(0.42, 0.24, 1.0, 0.16)
	draw_circle(Vector2(size.x * 0.18, size.y * 0.20), maxf(size.x, size.y) * 0.24, band_color)
	draw_circle(Vector2(size.x * 0.86, size.y * 0.78), maxf(size.x, size.y) * 0.30, Color(1.0, 0.72, 0.30, 0.10))
	for i in range(5):
		var y := size.y * (0.18 + float(i) * 0.15)
		draw_line(Vector2(size.x * 0.08, y), Vector2(size.x * 0.92, y + size.y * 0.04), Color(0.74, 0.68, 1.0, 0.05), 2.0)

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
		# Animate the reveal: a soft scale-in on the word card.
		if _word_card and not (AccessibilityService and not AccessibilityService.should_animate()):
			_word_card.scale = Vector2(0.85, 0.85)
			_word_card.modulate = Color(1, 1, 1, 0)
			var tween := _word_card.create_tween()
			tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			tween.tween_property(_word_card, "modulate:a", 1.0, 0.25).set_ease(Tween.EASE_OUT)
			tween.parallel().tween_property(_word_card, "scale", Vector2.ONE, 0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
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
		if _word_card:
			_word_card.scale = Vector2(0.985, 0.985)
			if not (AccessibilityService and not AccessibilityService.should_animate()):
				var tween := _word_card.create_tween()
				tween.tween_property(_word_card, "scale", Vector2.ONE, 0.10).set_ease(Tween.EASE_OUT)
		if AudioService:
			AudioService.play_sfx("flash_pulse", 0.45)
