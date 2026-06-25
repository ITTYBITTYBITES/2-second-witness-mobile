extends CanvasLayer

signal world_selected(universe_id: String, world_id: String)
signal return_requested

@onready var grid = $PanelContainer/MarginContainer/VBoxContainer/GridContainer
@onready var btn_return = $PanelContainer/MarginContainer/VBoxContainer/Header/BtnReturn
@onready var title_label = $PanelContainer/MarginContainer/VBoxContainer/Header/Title

var active_universe_id: String = "science_lab"

func setup(universe_id: String):
	active_universe_id = universe_id
	title_label.text = universe_id.capitalize().replace("_", " ") + " - WORLDS"
	_populate_grid()

func _ready():
	print("WORLD SELECT SCREEN READY")
	print("Size: ", $PanelContainer.size)
	AdManager.show_banner()
	btn_return.pressed.connect(func(): return_requested.emit())

func _populate_grid():
	var registry = get_node_or_null("/root/ContentRegistry")
	var profile = get_node_or_null("/root/PlayerProfile")
	if not registry or not profile: return
	
	var worlds = registry.get_all_worlds_in_universe(active_universe_id)
	if worlds.is_empty():
		# Fallback default worlds if ContentRegistry has not crawled custom JSON yet
		if active_universe_id == "science_lab": worlds = ["cognitive_bias", "neural_mapping", "ai"]
		elif active_universe_id == "life_sciences": worlds = ["genetics", "cellular_biology", "virology"]
		elif active_universe_id == "tech_ops": worlds = ["cyber_matrix", "subliminal_code", "protocols"]
		else: worlds = ["foundations", "advanced_concepts", "synthesis"]
		
	for child in grid.get_children():
		child.queue_free()
		
	for w_id in worlds:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(280, 160)
		btn.mouse_filter = Control.MOUSE_FILTER_STOP
		
		var pretty_name = w_id.capitalize().replace("_", " ")
		var world_key = active_universe_id + "_" + w_id
		var mastery_count = profile.world_affinity.get(world_key, 0)
		
		btn.text = pretty_name + "\n[ MASTERY: " + str(mastery_count) + " ]"
		btn.add_theme_font_size_override("font_size", 20)
		
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.05, 0.1, 0.15, 0.9)
		style.border_width_bottom = 4
		style.border_color = Color(0.298, 0.788, 0.941)
		style.corner_radius_top_left = 12
		style.corner_radius_top_right = 12
		style.corner_radius_bottom_left = 12
		style.corner_radius_bottom_right = 12
		
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style.duplicate())
		btn.add_theme_stylebox_override("pressed", style.duplicate())
		btn.add_theme_color_override("font_color", Color(0.85, 0.95, 1.0))
		
		btn.pressed.connect(func():
			print("WORLD CARD CLICKED:", w_id)
			AudioManager.play_sfx("ui_click")
			world_selected.emit(active_universe_id, w_id)
		)
		grid.add_child(btn)

func hide_screen():
	AdManager.hide_banner()
	queue_free()
