extends Control
## SectionHeader - Title + optional action button

@export var title_text: String = "Section" : set = set_title
@export var subtitle_text: String = "" : set = set_subtitle
@export var show_action: bool = false
@export var action_text: String = "See all"

signal action_pressed()

@onready var title_label: Label = $VBox/TitleRow/Title
@onready var subtitle_label: Label = $VBox/Subtitle
@onready var action_button: Button = $VBox/TitleRow/ActionButton

func _ready() -> void:
	# Might not have nodes if not in scene, handle via code build
	_ensure_ui()
	_apply_theme()
	if ThemeService:
		ThemeService.theme_changed.connect(_on_theme_changed)

func _ensure_ui() -> void:
	if has_node("VBox"):
		return
	# Build programmatically if .tscn not present
	var vbox := VBoxContainer.new()
	vbox.name = "VBox"
	add_child(vbox)
	
	var title_row := HBoxContainer.new()
	title_row.name = "TitleRow"
	vbox.add_child(title_row)
	
	var title := Label.new()
	title.name = "Title"
	title.text = title_text
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title)
	
	var action := Button.new()
	action.name = "ActionButton"
	action.text = action_text
	action.visible = show_action
	title_row.add_child(action)
	
	var sub := Label.new()
	sub.name = "Subtitle"
	sub.text = subtitle_text
	sub.visible = subtitle_text != ""
	vbox.add_child(sub)

func _apply_theme() -> void:
	if not has_node("VBox/TitleRow/Title"):
		return
	if not ThemeService:
		return
	var tokens := ThemeService.tokens
	$VBox/TitleRow/Title.add_theme_color_override("font_color", tokens.get("text_primary", Color.WHITE))
	$VBox/TitleRow/Title.add_theme_font_size_override("font_size", 20)
	$VBox/Subtitle.add_theme_color_override("font_color", tokens.get("text_secondary", Color.GRAY))
	$VBox/Subtitle.add_theme_font_size_override("font_size", 14)

func set_title(t: String) -> void:
	title_text = t
	if has_node("VBox/TitleRow/Title"):
		$VBox/TitleRow/Title.text = t

func set_subtitle(t: String) -> void:
	subtitle_text = t
	if has_node("VBox/Subtitle"):
		$VBox/Subtitle.text = t
		$VBox/Subtitle.visible = t != ""

func _on_theme_changed(_name: String, _tokens: Dictionary) -> void:
	_apply_theme()

func _on_ActionButton_pressed() -> void:
	action_pressed.emit()
