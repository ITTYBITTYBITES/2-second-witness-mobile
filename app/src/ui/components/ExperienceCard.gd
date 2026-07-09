extends Control
## ExperienceCard - Displays experience info, polished placeholder
## FIXED: Robust to both TSCN instantiation and programmatic Control+script usage

signal experience_selected(exp_id: String)
signal info_requested(exp_id: String)

@export var experience_id: String = ""
var manifest: Dictionary = {}

var card_root: PanelContainer = null
var title_label: Label = null
var desc_label: Label = null
var meta_label: Label = null
var icon_panel: PanelContainer = null
var play_button: Button = null

var _built: bool = false

func _ready() -> void:
	if manifest.is_empty() and experience_id != "" and ExperienceRegistry:
		manifest = ExperienceRegistry.get_manifest(experience_id)
	_attempt_find_nodes()
	if not _built and (card_root == null):
		_build_ui()
	_apply_theme()
	_refresh_ui()

func _attempt_find_nodes() -> void:
	title_label = _find_label([
		"Card/Margin/VBox/Title",
		"Margin/VBox/Title",
		"VBox/Title",
		"Title"
	])
	desc_label = _find_label([
		"Card/Margin/VBox/Description",
		"Margin/VBox/Description",
		"Description"
	])
	meta_label = _find_label([
		"Card/Margin/VBox/MetaRow/Meta",
		"Margin/VBox/MetaRow/Meta",
		"MetaRow/Meta",
		"Meta"
	])
	icon_panel = get_node_or_null("Card/Margin/VBox/TopRow/IconWrapper") as PanelContainer
	if icon_panel == null:
		icon_panel = get_node_or_null("Margin/VBox/TopRow/IconWrapper") as PanelContainer
	play_button = get_node_or_null("Card/Margin/VBox/PlayButton") as Button
	if play_button == null:
		play_button = get_node_or_null("Margin/VBox/PlayButton") as Button
	if play_button == null:
		play_button = get_node_or_null("PlayButton") as Button
	if has_node("Card"):
		card_root = get_node_or_null("Card") as PanelContainer
	_ensure_wired()

func _find_label(paths: Array) -> Label:
	for p in paths:
		var n = get_node_or_null(p)
		if n is Label:
			return n as Label
	return null

func set_experience(exp_manifest: Dictionary) -> void:
	manifest = exp_manifest
	experience_id = exp_manifest.get("id", "")
	if is_inside_tree():
		_refresh_ui()

func _ensure_wired() -> void:
	if play_button:
		if not play_button.pressed.is_connected(_on_play_pressed):
			play_button.pressed.connect(_on_play_pressed)
	if card_root:
		if not card_root.gui_input.is_connected(_on_card_input):
			card_root.gui_input.connect(_on_card_input)

func _build_ui() -> void:
	if _built:
		return
	_built = true
	if card_root and is_instance_valid(card_root):
		return
	custom_minimum_size = Vector2(0, 180)
	var card = PanelContainer.new()
	card.name = "Card"
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(card)
	card_root = card
	var margin = MarginContainer.new()
	margin.name = "Margin"
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	card.add_child(margin)
	var vbox = VBoxContainer.new()
	vbox.name = "VBox"
	margin.add_child(vbox)
	var top_row = HBoxContainer.new()
	top_row.name = "TopRow"
	vbox.add_child(top_row)
	var icon_wrap = PanelContainer.new()
	icon_wrap.name = "IconWrapper"
	icon_wrap.custom_minimum_size = Vector2(48,48)
	top_row.add_child(icon_wrap)
	icon_panel = icon_wrap
	var title = Label.new()
	title.name = "Title"
	title.text = "Experience"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(title)
	title_label = title
	var meta_row = HBoxContainer.new()
	meta_row.name = "MetaRow"
	vbox.add_child(meta_row)
	var meta = Label.new()
	meta.name = "Meta"
	meta.text = "• 2 sec • Memory"
	vbox.add_child(meta)
	meta_label = meta
	var desc = Label.new()
	desc.name = "Description"
	desc.text = "Observe quickly"
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(desc)
	desc_label = desc
	var play = Button.new()
	play.name = "PlayButton"
	play.text = "Play"
	vbox.add_child(play)
	play_button = play
	_ensure_wired()

func _apply_theme() -> void:
	if not ThemeService:
		return
	var tokens = ThemeService.tokens
	if tokens.is_empty():
		return
	if card_root:
		var style = StyleBoxFlat.new()
		style.bg_color = tokens.get("surface", Color("#1E1E26"))
		style.corner_radius_top_left = tokens.get("radius_lg", 20)
		style.corner_radius_top_right = tokens.get("radius_lg", 20)
		style.corner_radius_bottom_left = tokens.get("radius_lg", 20)
		style.corner_radius_bottom_right = tokens.get("radius_lg", 20)
		style.content_margin_left = 2
		style.content_margin_right = 2
		style.content_margin_top = 2
		style.content_margin_bottom = 2
		style.border_color = tokens.get("border", Color.GRAY)
		style.border_width_left = 1
		style.border_width_right = 1
		style.border_width_top = 1
		style.border_width_bottom = 1
		card_root.add_theme_stylebox_override("panel", style)
	if title_label:
		title_label.add_theme_color_override("font_color", tokens.get("text_primary", Color.WHITE))
		title_label.add_theme_font_size_override("font_size", 18)
	if desc_label:
		desc_label.add_theme_color_override("font_color", tokens.get("text_secondary", Color.GRAY))
		desc_label.add_theme_font_size_override("font_size", 13)
	if meta_label:
		meta_label.add_theme_color_override("font_color", tokens.get("text_tertiary", Color.GRAY))
		meta_label.add_theme_font_size_override("font_size", 11)

func _refresh_ui() -> void:
	if manifest.is_empty():
		return
	if not _built and card_root == null:
		_build_ui()
	var title_fallback := "Experience"
	if experience_id != "":
		title_fallback = experience_id.capitalize()
	var title = manifest.get("title", title_fallback)
	var short_desc = manifest.get("short_description", manifest.get("description", ""))
	var category = manifest.get("category", "observation")
	var duration = manifest.get("estimated_duration_sec", 10)
	var tags = manifest.get("tags", [])
	var color_str = manifest.get("preview_color", "#7C5CFF")
	var coming_soon = manifest.get("coming_soon", false)
	var runtime = manifest.get("runtime", {})
	var is_locked = false
	if not runtime.is_empty():
		is_locked = runtime.get("is_locked", false)
	else:
		is_locked = manifest.get("is_locked", false)
	var is_unlocked = true
	if not runtime.is_empty():
		is_unlocked = runtime.get("is_unlocked", true)
	else:
		is_unlocked = not is_locked
	if title_label:
		title_label.text = title
	if desc_label:
		desc_label.text = short_desc
	if meta_label:
		var meta_parts: Array[String] = []
		meta_parts.append(category.capitalize())
		meta_parts.append("%ds" % duration)
		if tags.size() > 0:
			meta_parts.append(str(tags[0]).capitalize())
		meta_label.text = " • ".join(meta_parts)
	if play_button:
		if coming_soon:
			play_button.text = "Coming Soon"
			play_button.disabled = true
		elif is_locked or not is_unlocked:
			play_button.text = "Locked"
			play_button.disabled = true
		else:
			play_button.text = "Play • %ds" % duration
			play_button.disabled = false
	if icon_panel:
		var style = StyleBoxFlat.new()
		var col = Color(color_str) if color_str != "" else Color("#7C5CFF")
		style.bg_color = col
		style.corner_radius_top_left = 12
		style.corner_radius_top_right = 12
		style.corner_radius_bottom_left = 12
		style.corner_radius_bottom_right = 12
		icon_panel.add_theme_stylebox_override("panel", style)

func _on_play_pressed() -> void:
	if manifest.is_empty():
		return
	var runtime = manifest.get("runtime", {})
	if runtime.get("is_coming_soon", false) or manifest.get("coming_soon", false):
		return
	if not (runtime.get("is_unlocked", true)):
		if manifest.get("is_locked", false):
			return
	if AccessibilityService:
		if AccessibilityService.is_haptics_enabled():
			AccessibilityService.vibrate(30)
	if AudioService:
		AudioService.play_ui("ui_click")
	experience_selected.emit(experience_id if experience_id != "" else manifest.get("id",""))

func _on_card_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		pass
