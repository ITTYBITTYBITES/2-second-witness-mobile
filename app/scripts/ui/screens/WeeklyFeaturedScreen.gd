extends CanvasLayer

signal play_universe_requested(universe_id: String)
signal return_requested

@onready var grid = $PanelContainer/MarginContainer/VBoxContainer/GridContainer
@onready var btn_return = $PanelContainer/MarginContainer/VBoxContainer/Header/BtnReturn

func _ready():
	print("[2 SECOND WITNESS] Weekly Discovery Screen active.")
	btn_return.pressed.connect(func(): return_requested.emit())
	_populate_grid()

func _populate_grid():
	var controller = get_node_or_null("/root/SamplingController")
	if not controller: return
	
	# The Weekly Featured Screen pulls directly from the active weekly pool.
	# We display the 6 unique universes currently in rotation.
	
	# For the sake of the UX mockup, we use the 6 hardcoded universes.
	# In production, this reads `controller.featured_universes`.
	var featured = [
		"science_lab", "tech_ops", "life_sciences", 
		"society_mind", "creative_arts", "frontier"
	]
	
	var renderer = UniverseRenderer.new()
	
	for uni in featured:
		var def = renderer.universe_definitions.get(uni, renderer.universe_definitions["science_lab"])
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(250, 150)
		btn.text = uni.capitalize().replace("_", " ")
		btn.add_theme_font_size_override("font_size", 24)
		
		var style = StyleBoxFlat.new()
		style.bg_color = def["palette"]["bg"]
		style.border_width_bottom = 4
		style.border_color = def["palette"]["primary"]
		style.corner_radius_top_left = 12
		style.corner_radius_top_right = 12
		style.corner_radius_bottom_left = 12
		style.corner_radius_bottom_right = 12
		
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)
		btn.add_theme_color_override("font_color", def["palette"]["primary"])
		
		btn.pressed.connect(func(): play_universe_requested.emit(uni))
		grid.add_child(btn)

func hide_screen():
	queue_free()
