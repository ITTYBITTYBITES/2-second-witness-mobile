extends Control
## ExperienceCard - Displays experience info, polished placeholder

signal experience_selected(exp_id: String)
signal info_requested(exp_id: String)

@export var experience_id: String = ""
var manifest: Dictionary = {}

@onready var card_root: PanelContainer = $Card
@onready var title_label: Label = $Card/Margin/VBox/Title
@onready var desc_label: Label = $Card/Margin/VBox/Description
@onready var meta_label: Label = $Card/Margin/VBox/MetaRow/Meta
@onready var icon_panel: PanelContainer = $Card/Margin/VBox/TopRow/IconWrapper
@onready var play_button: Button = $Card/Margin/VBox/PlayButton

func _ready() -> void:
	# If manifest not set via set_experience, try to create from ID
	if manifest.is_empty() and experience_id != "" and ExperienceRegistry:
		manifest = ExperienceRegistry.get_manifest(experience_id)
	_ensure_wired()
	_apply_theme()
	_refresh_ui()

func set_experience(exp_manifest: Dictionary) -> void:
	manifest = exp_manifest
	experience_id = exp_manifest.get("id", "")
	_refresh_ui()

func _ensure_wired() -> void:
	if not has_node("Card/Margin/VBox/PlayButton"):
		_build_ui()
	else:
		if play_button:
			if not play_button.pressed.is_connected(_on_play_pressed):
				play_button.pressed.connect(_on_play_pressed)
		if has_node("Card"):
			var card_btn := $Card as PanelContainer
			card_btn.gui_input.connect(_on_card_input)

func _build_ui() -> void:
	# Programmatic UI fallback for foundation
	custom_minimum_size = Vector2(0, 180)
	
	var card := PanelContainer.new()
	card.name = "Card"
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(card)
	
	var margin := MarginContainer.new()
	margin.name = "Margin"
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	card.add_child(margin)
	
	var vbox := VBoxContainer.new()
	vbox.name = "VBox"
	margin.add_child(vbox)
	
	var top_row := HBoxContainer.new()
	top_row.name = "TopRow"
	vbox.add_child(top_row)
	
	var icon_wrap := PanelContainer.new()
	icon_wrap.name = "IconWrapper"
	icon_wrap.custom_minimum_size = Vector2(48,48)
	top_row.add_child(icon_wrap)
	
	var title := Label.new()
	title.name = "Title"
	title.text = "Experience"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(title)
	
	var meta_row := HBoxContainer.new()
	meta_row.name = "MetaRow"
	vbox.add_child(meta_row)
	
	var meta := Label.new()
	meta.name = "Meta"
	meta.text = "• 2 sec • Memory"
	vbox.add_child(meta)
	
	var desc := Label.new()
	desc.name = "Description"
	desc.text = "Observe quickly"
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(desc)
	
	var play := Button.new()
	play.name = "PlayButton"
	play.text = "Play"
	vbox.add_child(play)
	play.pressed.connect(_on_play_pressed)
	
	card.gui_input.connect(_on_card_input)
	
	card_root = card
	title_label = title
	desc_label = desc
	meta_label = meta
	icon_panel = icon_wrap
	play_button = play

func _apply_theme() -> void:
	if not ThemeService:
		return
	var tokens := ThemeService.tokens
	if card_root:
		var style := StyleBoxFlat.new()
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
	
	_ensure_wired()
	
	var title: String = manifest.get("title", experience_id.capitalize())
	var short_desc: String = manifest.get("short_description", manifest.get("description", ""))
	var category: String = manifest.get("category", "observation")
	var duration: int = manifest.get("estimated_duration_sec", 10)
	var tags: Array = manifest.get("tags", [])
	var color_str: String = manifest.get("preview_color", "#7C5CFF")
	var coming_soon: bool = manifest.get("coming_soon", false)
	var runtime: Dictionary = manifest.get("runtime", {})
	var is_locked: bool = runtime.get("is_locked", false) if not runtime.is_empty() else manifest.get("is_locked", false)
	var is_unlocked: bool = runtime.get("is_unlocked", true) if not runtime.is_empty() else true
	
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
	
	if icon_panel and ThemeService:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(color_str) if color_str != "" else Color("#7C5CFF")
		style.corner_radius_top_left = 12
		style.corner_radius_top_right = 12
		style.corner_radius_bottom_left = 12
		style.corner_radius_bottom_right = 12
		icon_panel.add_theme_stylebox_override("panel", style)

func _on_play_pressed() -> void:
	if manifest.is_empty():
		return
	var runtime: Dictionary = manifest.get("runtime", {})
	if runtime.get("is_coming_soon", false) or manifest.get("coming_soon", false):
		return
	if not (runtime.get("is_unlocked", true)):
		return
	
	# Haptics
	if AccessibilityService:
		AccessibilityService.vibrate(30)
	# SFX
	if AudioService:
		AudioService.play_ui("ui_click")
	
	experience_selected.emit(experience_id if experience_id != "" else manifest.get("id",""))

func _on_card_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		# Could show details
		pass
