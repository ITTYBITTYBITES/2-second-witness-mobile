extends PanelContainer
## ExperienceCard - Premium featured challenge card
## HomeScreen redesign - matches mockup

signal experience_selected(exp_id: String)
signal info_requested(exp_id: String)

@export var experience_id: String = ""
var manifest: Dictionary = {}

var card_root: PanelContainer = null
var thumbnail_rect: TextureRect = null
var title_label: Label = null
var category_label: Label = null
var duration_label: Label = null
var desc_label: Label = null
var play_button: Button = null

func _ready() -> void:
	_find_nodes()
	_apply_theme()
	_refresh_ui()
	if play_button and not play_button.pressed.is_connected(_on_play_pressed):
		play_button.pressed.connect(_on_play_pressed)

func _find_nodes() -> void:
	card_root = self
	thumbnail_rect = get_node_or_null("Margin/HBox/Thumbnail") as TextureRect
	title_label = get_node_or_null("Margin/HBox/RightVBox/TopRow/Title") as Label
	var cat_badge = get_node_or_null("Margin/HBox/RightVBox/TopRow/CategoryBadge/BadgeLabel") as Label
	category_label = cat_badge
	duration_label = get_node_or_null("Margin/HBox/RightVBox/TopRow/DurationBadge/DurationLabel") as Label
	desc_label = get_node_or_null("Margin/HBox/RightVBox/Description") as Label
	play_button = get_node_or_null("Margin/HBox/RightVBox/BottomRow/PlayButton") as Button

func set_experience(exp_manifest: Dictionary) -> void:
	manifest = exp_manifest
	experience_id = exp_manifest.get("id", "")
	if is_inside_tree():
		_refresh_ui()

func _apply_theme() -> void:
	if not ThemeService:
		return
	var tokens = ThemeService.tokens
	if tokens.is_empty():
		return
	
	# Card background
	if card_root:
		var style := StyleBoxFlat.new()
		style.bg_color = tokens.get("surface", Color("#1E1E26"))
		var r = tokens.get("radius_lg", 20)
		style.corner_radius_top_left = r
		style.corner_radius_top_right = r
		style.corner_radius_bottom_left = r
		style.corner_radius_bottom_right = r
		style.border_color = tokens.get("border", Color("#2E2E3A"))
		style.border_width_left = 1
		style.border_width_right = 1
		style.border_width_top = 1
		style.border_width_bottom = 1
		card_root.add_theme_stylebox_override("panel", style)

	# Title
	if title_label:
		ThemeService.apply_label_style(title_label, "label", "text_primary")
		title_label.text = "EXPERIENCE"
	
	# Category badge
	var cat_panel := get_node_or_null("Margin/HBox/RightVBox/TopRow/CategoryBadge") as PanelContainer
	if cat_panel:
		var cs := StyleBoxFlat.new()
		cs.bg_color = Color(tokens.get("primary", Color("#6A3DFF")), 0.18)
		cs.corner_radius_top_left = 8
		cs.corner_radius_top_right = 8
		cs.corner_radius_bottom_left = 8
		cs.corner_radius_bottom_right = 8
		cs.content_margin_left = 0
		cs.content_margin_right = 0
		cs.content_margin_top = 0
		cs.content_margin_bottom = 0
		cat_panel.add_theme_stylebox_override("panel", cs)
	if category_label:
		category_label.add_theme_color_override("font_color", tokens.get("primary_variant", Color("#8A68FF")))
		category_label.add_theme_font_size_override("font_size", 11)

	# Duration badge
	var dur_panel := get_node_or_null("Margin/HBox/RightVBox/TopRow/DurationBadge") as PanelContainer
	if dur_panel:
		var ds := StyleBoxFlat.new()
		ds.bg_color = tokens.get("background_tertiary", Color("#24242C"))
		ds.corner_radius_top_left = 8
		ds.corner_radius_top_right = 8
		ds.corner_radius_bottom_left = 8
		ds.corner_radius_bottom_right = 8
		dur_panel.add_theme_stylebox_override("panel", ds)
	if duration_label:
		ThemeService.apply_label_style(duration_label, "label_small", "text_secondary")

	# Description
	if desc_label:
		ThemeService.apply_label_style(desc_label, "body_small", "text_secondary")

	# Play button - secondary style
	if play_button:
		var btn_bg := StyleBoxFlat.new()
		btn_bg.bg_color = Color(tokens.get("primary", Color("#6A3DFF")), 0.22)
		btn_bg.corner_radius_top_left = 12
		btn_bg.corner_radius_top_right = 12
		btn_bg.corner_radius_bottom_left = 12
		btn_bg.corner_radius_bottom_right = 12
		btn_bg.content_margin_left = 16
		btn_bg.content_margin_right = 16
		btn_bg.content_margin_top = 8
		btn_bg.content_margin_bottom = 8
		play_button.add_theme_stylebox_override("normal", btn_bg)
		play_button.add_theme_stylebox_override("hover", btn_bg)
		play_button.add_theme_stylebox_override("pressed", btn_bg)
		play_button.add_theme_color_override("font_color", tokens.get("text_primary", Color.WHITE))
		play_button.add_theme_font_size_override("font_size", ThemeService.get_font_size("label"))
		play_button.text = "PLAY  →"

	# Thumbnail rounding - via shader? Just clip - Godot 4 TextureRect no corner radius natively, acceptable

func _refresh_ui() -> void:
	if manifest.is_empty():
		return
	_find_nodes()

	var title_fallback := "Experience"
	if experience_id != "":
		title_fallback = experience_id.capitalize()
	var title = manifest.get("title", title_fallback)
	# User-facing: Challenge terminology – show real challenge title
	if title_label:
		title_label.text = title.to_upper()

	var category = str(manifest.get("category", "observation")).to_upper()
	if category_label:
		category_label.text = category

	var duration = int(manifest.get("estimated_duration_sec", 10))
	if duration_label:
		duration_label.text = "%ds" % duration

	if desc_label:
		# Use short, punchy copy matching the mockup
		desc_label.text = "Count the details. Beat the clock."

	# Thumbnail
	if thumbnail_rect:
		var img_path: String = str(manifest.get("image_path", ""))
		var tex: Texture2D = null
		# UI-only premium preview override for challenge_01 to match mockup
		# Gameplay image (ObservationChallengeScreen) remains manifest.image_path
		var premium_preview := "res://assets/gameplay/featured_desk_scene_landscape.png"
		if experience_id == "challenge_01" and ResourceLoader.exists(premium_preview):
			tex = load(premium_preview)
		elif img_path != "" and ResourceLoader.exists(img_path):
			tex = load(img_path) as Texture2D
		
		if tex:
			thumbnail_rect.texture = tex

	# Play button text
	if play_button:
		var coming_soon = manifest.get("coming_soon", false)
		var is_locked = manifest.get("is_locked", false)
		if coming_soon:
			play_button.text = "SOON"
			play_button.disabled = true
		elif is_locked:
			play_button.text = "LOCKED"
			play_button.disabled = true
		else:
			play_button.text = "PLAY  →"
			play_button.disabled = false

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
