extends Control
## Four-step visual tutorial using the production pattern renderer.

signal completed(family_id: String, tutorial_version: String)
signal skipped(family_id: String, tutorial_version: String)
signal practice_requested(family_id: String, template_id: String)

const FAMILY_ID := "pattern_recall"
const TUTORIAL_VERSION := "1"

var _step: int = 0
var _title: Label
var _description: Label
var _progress: Label
var _next: Button
var _preview: PatternRecallView

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("#0F0F12")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 32)
	margin.add_theme_constant_override("margin_right", 32)
	margin.add_theme_constant_override("margin_top", 56)
	margin.add_theme_constant_override("margin_bottom", 36)
	add_child(margin)
	var stack := VBoxContainer.new()
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 18)
	margin.add_child(stack)
	_progress = Label.new()
	_progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stack.add_child(_progress)
	_title = Label.new()
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stack.add_child(_title)
	_description = Label.new()
	_description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stack.add_child(_description)
	_preview = PatternRecallView.new()
	_preview.custom_minimum_size = Vector2(0, 390)
	_preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.add_child(_preview)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_child(spacer)
	_next = Button.new()
	_next.custom_minimum_size = Vector2(0, 64)
	_next.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_next.pressed.connect(_advance)
	stack.add_child(_next)
	var skip := Button.new()
	skip.text = "Skip Tutorial"
	skip.flat = true
	skip.custom_minimum_size = Vector2(0, 48)
	skip.pressed.connect(_skip)
	stack.add_child(skip)
	_update()

func configure(_family: ChallengeFamily, _profile: TutorialProfile) -> void:
	pass

func reset_tutorial() -> void:
	_step = 0
	if is_inside_tree():
		_update()

func _update() -> void:
	var steps: Array[Array] = [
		["WATCH EACH STEP", "A cell or geometric symbol appears at every pulse. Keep the order, not only the pieces."],
		["FOLLOW THE PATH", "Grid Path shows one step at a time. Pattern Build keeps earlier steps visible as the path grows."],
		["REPEAT IN ORDER", "Tap the matching cells or symbols one by one. Undo is available before you submit."],
		["YOUR TURN", "Practice begins with three clear steps and a comfortable one-second pulse."]
	]
	_title.text = str(steps[_step][0])
	_description.text = str(steps[_step][1])
	_progress.text = "%d / %d" % [_step + 1, steps.size()]
	_next.text = "START PRACTICE" if _step == steps.size() - 1 else "NEXT  →"
	if ThemeService:
		ThemeService.apply_label_style(_title, "display", "text_primary")
		ThemeService.apply_label_style(_description, "body", "text_secondary")
		ThemeService.apply_label_style(_progress, "label_small", "primary_variant")
		ThemeService.apply_typography(_next, "button")
	var reveal := _step in [1, 2]
	_preview.set_scene_data(_demo_scene(reveal, _step == 1), ["A1", "A2", "B2"] if reveal else [])

func _demo_scene(reveal: bool, cumulative: bool) -> Dictionary:
	return {
		"mode": "build" if cumulative else "grid",
		"presentation_style": "cumulative_build" if cumulative else "single_step",
		"grid_size": 3,
		"tokens": ["A1","A2","A3","B1","B2","B3","C1","C2","C3"],
		"sequence": ["A1", "A2", "B2"],
		"interval": 1.0,
		"final_hold": 0.4,
		"reveal_mode": reveal
	}

func _advance() -> void:
	if _step >= 3:
		completed.emit(FAMILY_ID, TUTORIAL_VERSION)
		practice_requested.emit(FAMILY_ID, "grid_path_v1")
		return
	_step += 1
	_update()

func _skip() -> void:
	skipped.emit(FAMILY_ID, TUTORIAL_VERSION)
	practice_requested.emit(FAMILY_ID, "grid_path_v1")
