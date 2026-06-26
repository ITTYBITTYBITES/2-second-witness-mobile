extends CanvasLayer

signal play_universe_requested(universe_id: String)
signal return_requested

@onready var grid = $PanelContainer/MarginContainer/VBoxContainer/GridContainer
@onready var btn_return = $PanelContainer/MarginContainer/VBoxContainer/Header/BtnReturn

var monetization_gate_scene = preload("res://scenes/ui/screens/MonetizationGate.tscn")
var active_gate = null

var universe_meta = {
	"history": {
		"title": "History", "desc": "Explore civilizations and human decision making.",
		"completion": "18%", "traits": "Pattern Recognition, Memory, Reasoning"
	},
	"science_lab": {
		"title": "Science Lab", "desc": "Empirical deduction and probabilistic estimation.",
		"completion": "32%", "traits": "Hypothesis Testing, Abstraction, Calculation"
	},
	"creative_arts": {
		"title": "Creative Arts", "desc": "Divergent thinking and compositional harmony.",
		"completion": "45%", "traits": "Divergence, Aesthetic Judgment, Intuition"
	},
	"frontier": {
		"title": "Frontier", "desc": "Deep space navigation and high-stakes trade-offs.",
		"completion": "12%", "traits": "Spatial Reasoning, Risk Assessment, Navigation"
	},
	"society_mind": {
		"title": "Society & Mind", "desc": "Behavioral dynamics and societal evolution.",
		"completion": "27%", "traits": "Social Dynamics, Empathy, Systemic Thinking"
	},
	"tech_ops": {
		"title": "Technology", "desc": "Cybernetic protocols and algorithmic efficiency.",
		"completion": "61%", "traits": "Algorithmic Speed, Precision, Code Parse"
	},
	"life_sciences": {
		"title": "Life Sciences", "desc": "Cellular mechanics and ecological equilibrium.",
		"completion": "24%", "traits": "Taxonomy, Biological Scaling, Equilibria"
	}
}

func _ready():
	print("WEEKLY SCREEN READY")
	print("Size: ", $PanelContainer.size)
	for child in get_children():
		print("Child: ", child.name)
		
	if AdManager: AdManager.show_banner()
	print("[2 SECOND WITNESS] Weekly Discovery Screen active.")
	btn_return.pressed.connect(func(): return_requested.emit())
	_populate_grid()

func _populate_grid():
	var controller = SamplingController if SamplingController else get_tree().root.get_node_or_null("SamplingController")
	var profile = PlayerProfile if PlayerProfile else get_tree().root.get_node_or_null("PlayerProfile")
	if not controller or not profile: return
	
	var all_universes = [
		"history", "science_lab", "creative_arts", 
		"frontier", "society_mind", "tech_ops", "life_sciences"
	]
	
	var renderer = UniverseRenderer.new()
	
	for child in grid.get_children():
		child.queue_free()
	
	for uni in all_universes:
		var is_featured = controller.featured_universes.has(uni)
		var is_owned = profile.unlocked_universes.has(uni) or uni == "history"
		var can_play = is_featured or is_owned
		
		var def = renderer.universe_definitions.get(uni, renderer.universe_definitions["science_lab"])
		var meta = universe_meta.get(uni, universe_meta["science_lab"])
		
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(340, 220)
		
		var status_text = "(OWNED)" if is_owned else ("(FEATURED)" if is_featured else "[LOCKED - $2.99]")
		btn.text = meta["title"] + " " + status_text + "\n\n" + meta["desc"] + "\n\nCompletion: " + meta["completion"] + "\nTraits: " + meta["traits"]
		btn.add_theme_font_size_override("font_size", 16)
		
		var style = StyleBoxFlat.new()
		style.bg_color = def["palette"]["bg"]
		if not can_play:
			style.bg_color = style.bg_color.darkened(0.5)
			
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
	print("CARD CLICKED:", universe_id)
	if AudioManager: AudioManager.play_sfx("ui_click")
	if can_play:
		play_universe_requested.emit(universe_id)
	else:
		_show_monetization_gate(universe_id)

func _show_monetization_gate(universe_id: String):
	if active_gate: active_gate.queue_free()
	active_gate = monetization_gate_scene.instantiate()
	active_gate.name = "MonetizationGate"
	if active_gate.has_method("setup_universe_unlock"):
		active_gate.setup_universe_unlock(universe_id)
	elif active_gate.has_method("setup"):
		active_gate.setup(universe_id)
		
	var modal_mgr = ModalWindowManager if ModalWindowManager else get_tree().root.get_node_or_null("ModalWindowManager")
	if modal_mgr:
		modal_mgr.push_modal(active_gate, true, "WeeklyFeaturedScreen")
	else:
		add_child(active_gate)
	
	active_gate.purchase_completed.connect(func():
		var profile = PlayerProfile if PlayerProfile else get_node_or_null("/root/PlayerProfile")
		if profile and not profile.unlocked_universes.has(universe_id):
			profile.unlocked_universes.append(universe_id)
			profile.save_profile()
		_populate_grid()
	)

func hide_screen():
	if AdManager: AdManager.hide_banner()
	queue_free()
