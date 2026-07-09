extends Control
## ExperiencesScreen - Grid/list of experiences, modular

@onready var scroll: ScrollContainer = $Margin/Scroll
@onready var list_vbox: VBoxContainer = $Margin/Scroll/VBox

var _current_filter: String = "all"
var _highlight_id: String = ""

func _ready() -> void:
	_ensure_ui()
	_apply_theme()
	_refresh_list()
	
	if ThemeService:
		ThemeService.theme_changed.connect(_on_theme_changed)
	if ExperienceRegistry:
		ExperienceRegistry.registry_updated.connect(_on_registry_updated)

func _ensure_ui() -> void:
	if has_node("Margin/Scroll/VBox"):
		_wire_filters()
		return
	
	var margin := MarginContainer.new()
	margin.name = "Margin"
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 80)
	margin.add_theme_constant_override("margin_bottom", 90)
	add_child(margin)
	
	var scroll_c := ScrollContainer.new()
	scroll_c.name = "Scroll"
	margin.add_child(scroll_c)
	
	var vbox := VBoxContainer.new()
	vbox.name = "VBox"
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 16)
	scroll_c.add_child(vbox)
	
	var header := _create_header()
	vbox.add_child(header)
	
	var filter_row := _create_filter_row()
	vbox.add_child(filter_row)
	
	scroll = scroll_c
	list_vbox = vbox

func _create_header() -> Control:
	var vbox := VBoxContainer.new()
	
	var title := Label.new()
	title.text = "Experiences"
	title.add_theme_font_size_override("font_size", 28)
	vbox.add_child(title)
	
	var sub := Label.new()
	sub.text = "Short, replayable tests • New modules added without app update"
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD
	sub.add_theme_font_size_override("font_size", 13)
	sub.add_theme_color_override("font_color", Color(0.6,0.6,0.7,1))
	vbox.add_child(sub)
	
	return vbox

func _create_filter_row() -> Control:
	var hbox := HBoxContainer.new()
	hbox.name = "FilterRow"
	hbox.add_theme_constant_override("separation", 8)
	
	var filters := ["all", "memory", "observation", "reaction"]
	for f in filters:
		var btn := Button.new()
		btn.text = f.capitalize()
		btn.toggle_mode = true
		btn.set_meta("filter", f)
		btn.pressed.connect(_on_filter_pressed.bind(f, btn))
		if f == "all":
			btn.button_pressed = true
		hbox.add_child(btn)
	
	return hbox

func _wire_filters() -> void:
	if has_node("Margin/Scroll/VBox/FilterRow"):
		var row := $Margin/Scroll/VBox/FilterRow
		for child in row.get_children():
			if child is Button:
				var f: String = child.get_meta("filter") if child.has_meta("filter") else child.text.to_lower()
				if not child.pressed.is_connected(_on_filter_pressed):
					child.pressed.connect(_on_filter_pressed.bind(f, child))

func _apply_theme() -> void:
	if not ThemeService:
		return
	# Can theme buttons etc.

func _refresh_list() -> void:
	if not has_node("Margin/Scroll/VBox"):
		return
	var vbox: VBoxContainer = $Margin/Scroll/VBox
	
	# Remove old experience cards
	for child in vbox.get_children():
		if child.name.begins_with("Exp_") or child.name.begins_with("ExperienceCard_"):
			vbox.remove_child(child)
			child.queue_free()
	
	if not ExperienceRegistry:
		# Placeholder if registry not ready
		var placeholder := _create_coming_soon_card()
		placeholder.name = "Exp_Placeholder"
		vbox.add_child(placeholder)
		return
	
	var all: Array = ExperienceRegistry.get_all_experiences()
	
	var filtered: Array = []
	if _current_filter == "all":
		filtered = all
	else:
		for exp in all:
			var category: String = exp.get("category", "")
			var tags: Array = exp.get("tags", [])
			if category == _current_filter or tags.has(_current_filter):
				filtered.append(exp)
	
	for exp in filtered:
		var exp_id: String = exp.get("id", "")
		var card := _create_experience_card(exp)
		card.name = "Exp_%s" % exp_id
		vbox.add_child(card)
		if exp_id == _highlight_id:
			# Visual highlight
			if card.has_node("Card"):
				var panel: PanelContainer = card.get_node("Card")
				# Could add pulse
				pass
	
	if filtered.is_empty():
		var empty := Label.new()
		empty.text = "No experiences in this category yet. More coming soon!"
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(empty)

func _create_experience_card(manifest: Dictionary) -> Control:
	var card: Control = null
	var tscn_path = "res://src/ui/components/ExperienceCard.tscn"
	if ResourceLoader.exists(tscn_path):
		var scene = load(tscn_path) as PackedScene
		if scene:
			card = scene.instantiate() as Control
	if card == null:
		var script = load("res://src/ui/components/ExperienceCard.gd")
		card = Control.new()
		if script:
			card.set_script(script)
	card.custom_minimum_size = Vector2(0, 200)
	if card.has_method("set_experience"):
		card.call("set_experience", manifest)
	if card.has_signal("experience_selected"):
		if not card.experience_selected.is_connected(_on_experience_selected):
			card.experience_selected.connect(_on_experience_selected)
	return card

func _create_coming_soon_card() -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 120)
	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_left", 16)
	m.add_theme_constant_override("margin_right", 16)
	m.add_theme_constant_override("margin_top", 16)
	m.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(m)
	var lbl := Label.new()
	lbl.text = "Loading experiences..."
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	m.add_child(lbl)
	return panel

func on_navigated_to(params: Dictionary) -> void:
	_highlight_id = params.get("highlight", "")
	var auto_play: String = params.get("auto_play", "")
	
	_refresh_list()
	
	if auto_play != "":
		# Simulate playing
		call_deferred("_play_experience", auto_play)
	
	if AnalyticsService:
		AnalyticsService.log_screen_view("experiences", params)

func _play_experience(exp_id: String) -> void:
	print("[ExperiencesScreen] Play %s" % exp_id)
	
	if ProfileService:
		ProfileService.record_experience_play(exp_id, {"score": randi() % 100, "correct": true, "reaction_ms": 1200 + randi() % 800})
	
	# For foundation, show coming soon dialog for non-flashword
	var manifest: Dictionary = {}
	if ExperienceRegistry:
		manifest = ExperienceRegistry.get_manifest(exp_id)
	
	if exp_id == "flashword":
		# Placeholder for Phase 2 - show flashword preview
		_show_flashword_preview()
	else:
		_show_coming_soon(exp_id, manifest)

func _show_flashword_preview() -> void:
	# Simple preview dialog
	var dialog_text := "Flashword - Observation + Memory\n\n2-second glance → recall → quick decision.\n\nFoundation preview: Full gameplay in Phase 2."
	
	# For now just error banner style
	if get_tree().root.has_node("AppShell"):
		pass
	print("[ExperiencesScreen] Flashword preview shown")

func _show_coming_soon(exp_id: String, manifest: Dictionary) -> void:
	var title: String = manifest.get("title", exp_id)
	print("[ExperiencesScreen] %s coming soon" % title)
	if ErrorHandler:
		ErrorHandler.handle("EXP_COMING_SOON", "%s is coming soon! Stay tuned." % title, {"exp_id": exp_id}, ErrorHandler.Severity.INFO)
	# Could show modal

func _on_experience_selected(exp_id: String) -> void:
	_play_experience(exp_id)

func _on_filter_pressed(filter: String, button: Button) -> void:
	_current_filter = filter
	# Update button states
	if has_node("Margin/Scroll/VBox/FilterRow"):
		var row := $Margin/Scroll/VBox/FilterRow
		for child in row.get_children():
			if child is Button and child != button:
				child.button_pressed = false
		button.button_pressed = true
	
	_refresh_list()
	
	if AccessibilityService:
		AccessibilityService.vibrate(20)
	if AnalyticsService:
		AnalyticsService.log_event("experience_filter_changed", {"filter": filter})

func _on_theme_changed(_theme: String, _tokens: Dictionary) -> void:
	_apply_theme()

func _on_registry_updated(_exps: Array) -> void:
	_refresh_list()
