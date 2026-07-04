extends CanvasLayer

signal play_universe_requested(universe_id: String)
signal return_requested

@onready var grid = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/GridContainer
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
	if get_viewport() and not get_viewport().size_changed.is_connected(_apply_responsive_layout):
		get_viewport().size_changed.connect(_apply_responsive_layout)
	_apply_responsive_layout()
	_apply_universe_manifest("science_lab")
	_populate_grid()

func _to_color(value: Variant, fallback: Color) -> Color:
	if value is Color:
		return value
	if typeof(value) == TYPE_STRING:
		var text = str(value).strip_edges()
		if text != "":
			return Color(text)
	return fallback

func _apply_universe_manifest(universe_id: String):
	var vim = VisualIdentityManager if VisualIdentityManager else get_tree().root.get_node_or_null("VisualIdentityManager")
	if vim and vim.has_method("apply_screen_identity"):
		vim.apply_screen_identity(self, universe_id, "", false)
	else:
		var bg = get_node_or_null("ColorRect") if get_node_or_null("ColorRect") else get_node_or_null("VoidBG")
		if bg and bg is ColorRect: bg.color = Color(0.04, 0.07, 0.12, 0.15)

func _apply_responsive_layout():
	var panel = get_node_or_null("PanelContainer")
	if panel and panel is Control:
		var viewport_size = get_viewport().get_visible_rect().size if get_viewport() else Vector2(1280, 720)
		var inset_x = clamp(viewport_size.x * 0.035, 24.0, 64.0)
		var inset_y = clamp(viewport_size.y * 0.04, 20.0, 48.0)
		panel.offset_left = inset_x
		panel.offset_top = inset_y
		panel.offset_right = -inset_x
		panel.offset_bottom = -inset_y
	if grid:
		var panel_width = panel.size.x if panel and panel is Control else get_viewport().get_visible_rect().size.x
		var usable_width = max(260.0, panel_width - 80.0)
		grid.columns = clamp(int(usable_width / 296.0), 1, 4)

func _populate_grid():
	_apply_responsive_layout()
	var controller = SamplingController if SamplingController else get_tree().root.get_node_or_null("SamplingController")
	var profile = PlayerProfile if PlayerProfile else get_tree().root.get_node_or_null("PlayerProfile")
	if not controller or not profile: return
	
	var rot_mgr = WeeklyRotationManager if WeeklyRotationManager else get_tree().root.get_node_or_null("WeeklyRotationManager")
	var reg = ContentRegistry if ContentRegistry else get_tree().root.get_node_or_null("ContentRegistry")
	var all_universes = rot_mgr.get_full_universe_library() if (rot_mgr and rot_mgr.has_method("get_full_universe_library")) else (reg.get_all_universes() if (reg and reg.has_method("get_all_universes") and not reg.get_all_universes().is_empty()) else ["history", "science_lab", "creative_arts", "frontier", "society_mind", "tech_ops", "life_sciences"])
	all_universes.sort()
	
	var vim = VisualIdentityManager if VisualIdentityManager else get_tree().root.get_node_or_null("VisualIdentityManager")
	
	for child in grid.get_children():
		child.queue_free()
	
	for uni in all_universes:
		var is_featured = controller.featured_universes.has(uni)
		var is_owned = profile.unlocked_universes.has(uni) or uni == "history"
		var can_play = is_featured or is_owned
		
		var def = vim.get_universe_identity(uni) if vim else {"palette": {"bg": Color("#0B1320"), "primary": Color("#00D4FF")}}
		var palette = def.get("palette", {})
		var bg_color = _to_color(palette.get("bg", Color("#0B1320")), Color("#0B1320"))
		var primary_color = _to_color(palette.get("primary", Color("#00D4FF")), Color("#00D4FF"))
		var meta = universe_meta.get(uni, universe_meta["science_lab"])
		
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(280, 138)
		
		var status_text = "(OWNED)" if is_owned else ("(FEATURED)" if is_featured else "[LOCKED - $2.99]")
		var interp = Engine.get_main_loop().root.get_node_or_null("ProgressionInterpreter") if Engine.get_main_loop() else null
		var prog_ctx = interp.get_universe_progression_context(uni) if (interp and interp.has_method("get_universe_progression_context")) else {}
		var m_str = prog_ctx.get("global_mastery_trend", "GLOBAL MASTERY: " + meta["completion"])
		var c_str = prog_ctx.get("continuity", "TOTAL OBSERVATIONS: 0")
		
		btn.text = meta["title"].to_upper() + " " + status_text + "\n" + meta["desc"] + "\n" + m_str + " | " + c_str
		btn.add_theme_font_size_override("font_size", 14)
		btn.clip_text = true
		
		var style = StyleBoxFlat.new()
		style.bg_color = bg_color
		if not can_play:
			style.bg_color = style.bg_color.darkened(0.5)
		
		style.border_width_bottom = 4
		style.border_color = primary_color if can_play else Color(0.3, 0.3, 0.3)
		style.corner_radius_top_left = 12
		style.corner_radius_top_right = 12
		style.corner_radius_bottom_left = 12
		style.corner_radius_bottom_right = 12
		
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)
		btn.add_theme_color_override("font_color", primary_color if can_play else Color(0.5, 0.5, 0.5))
		
		btn.pressed.connect(func(): _on_universe_clicked(uni, can_play))
		grid.add_child(btn)

func _on_universe_clicked(universe_id: String, can_play: bool):
	print("CARD CLICKED:", universe_id)
	if AudioManager: AudioManager.play_sfx("ui_click")
	if can_play:
		var orch = ExperienceOrchestrator if ExperienceOrchestrator else get_tree().root.get_node_or_null("ExperienceOrchestrator")
		if orch and orch.has_method("request_universe_selection"):
			orch.request_universe_selection(universe_id)
		else:
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
