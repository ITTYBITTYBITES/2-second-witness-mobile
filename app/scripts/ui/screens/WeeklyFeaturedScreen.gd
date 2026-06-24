extends CanvasLayer

signal play_universe_requested(universe_id: String)
signal return_requested

@onready var grid = $PanelContainer/MarginContainer/VBoxContainer/GridContainer
@onready var btn_return = $PanelContainer/MarginContainer/VBoxContainer/Header/BtnReturn

var monetization_gate_scene = preload("res://scenes/ui/screens/MonetizationGate.tscn")
var active_gate = null

func _ready():
	print("[2 SECOND WITNESS] Weekly Discovery Screen active.")
	btn_return.pressed.connect(func(): return_requested.emit())
	_populate_grid()

func _populate_grid():
	var controller = get_node_or_null("/root/SamplingController")
	var profile = get_node_or_null("/root/PlayerProfile")
	if not controller or not profile: return
	
	var all_universes = [
		"science_lab", "tech_ops", "life_sciences", 
		"society_mind", "creative_arts", "frontier"
	]
	
	var renderer = UniverseRenderer.new()
	
	for child in grid.get_children():
		child.queue_free()
	
	for uni in all_universes:
		var is_featured = controller.featured_universes.has(uni)
		var is_owned = profile.unlocked_universes.has(uni)
		var can_play = is_featured or is_owned
		
		var def = renderer.universe_definitions.get(uni, renderer.universe_definitions["science_lab"])
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(250, 150)
		
		var title = uni.capitalize().replace("_", " ")
		if is_owned:
			btn.text = title + "\n(OWNED)"
		elif is_featured:
			btn.text = title + "\n(FEATURED)"
		else:
			btn.text = title + "\n[LOCKED]"
			
		btn.add_theme_font_size_override("font_size", 20)
		
		var style = StyleBoxFlat.new()
		style.bg_color = def["palette"]["bg"]
		if not can_play:
			style.bg_color = style.bg_color.darkened(0.5) # Dim locked universes
			
		style.border_width_bottom = 4
		style.border_color = def["palette"]["primary"] if can_play else Color(0.3, 0.3, 0.3)
		style.corner_radius_top_left = 12
		style.corner_radius_top_right = 12
		style.corner_radius_bottom_left = 12
		style.corner_radius_bottom_right = 12
		
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)
		btn.add_theme_color_override("font_color", def["palette"]["primary"] if can_play else Color(0.5, 0.5, 0.5))
		
		btn.pressed.connect(func(): _on_universe_clicked(uni, can_play))
		grid.add_child(btn)

func _on_universe_clicked(universe_id: String, can_play: bool):
	AudioManager.play_sfx("ui_click")
	if can_play:
		play_universe_requested.emit(universe_id)
	else:
		_show_monetization_gate(universe_id)

func _show_monetization_gate(universe_id: String):
	if active_gate: active_gate.queue_free()
	active_gate = monetization_gate_scene.instantiate()
	active_gate.setup(universe_id)
	add_child(active_gate)
	
	active_gate.purchase_completed.connect(func():
		var profile = get_node_or_null("/root/PlayerProfile")
		if profile and not profile.unlocked_universes.has(universe_id):
			profile.unlocked_universes.append(universe_id)
			profile.save_profile()
		_populate_grid() # Refresh grid to show as OWNED
	)

func hide_screen():
	queue_free()
