extends CanvasLayer

signal return_requested

@onready var lifetime_label = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/Header/LifetimeLabel
@onready var welcome_label = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/Header/WelcomeLabel
@onready var traits_container = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/TraitsContainer
@onready var insights_container = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/InsightsContainer
@onready var rec_container = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/RecContainer
@onready var nav_container = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/NavigationContainer

var btn_leave

func _ready():
	print("PROFILE SCREEN READY")
	StyleInjector.apply_menu_style(self)
	print("Visible: ", visible)
	print("Size: ", $PanelContainer.size)
	print("Children: ", get_child_count())
	
	var nav = get_node_or_null("/root/NavigationRouter")
	var uni = nav.active_universe_selection if nav else "history"
	_apply_universe_manifest(uni)
	
	$PanelContainer.mouse_filter = Control.MOUSE_FILTER_PASS
	$VoidBG.mouse_filter = Control.MOUSE_FILTER_STOP
	
	$VoidBG.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed:
			print("[MEMORY MIRROR] Background clicked. Exiting mirror.")
			if AudioManager: AudioManager.play_sfx("ui_click")
			if AdManager: AdManager.hide_banner()
			return_requested.emit()
	)
	
	if AdManager: AdManager.show_banner()
	print("[2 SECOND WITNESS] Player Profile Screen initializing.")
	_populate_data()

func _apply_universe_manifest(universe_id: String):
	var vim = VisualIdentityManager if VisualIdentityManager else get_tree().root.get_node_or_null("VisualIdentityManager")
	if vim and vim.has_method("apply_screen_identity"):
		vim.apply_screen_identity(self, universe_id, "", true)
	else:
		var bg = get_node_or_null("VoidBG")
		if bg and bg is ColorRect: bg.color = Color(0.04, 0.07, 0.12, 0.15)

func _populate_data():
	var profile = get_node_or_null("/root/PlayerProfile")
	var lifetime = profile.lifetime_sessions if profile else 0
	
	if lifetime_label: lifetime_label.text = "LIFETIME SESSIONS: " + str(lifetime)
	
	for child in traits_container.get_children(): child.queue_free()
	for child in insights_container.get_children(): child.queue_free()
	for child in rec_container.get_children(): child.queue_free()
	for child in nav_container.get_children(): child.queue_free()
	
	if lifetime == 0:
		if welcome_label: welcome_label.text = "Your player profile develops as you complete scenarios. Complete your first world to begin generating observations."
		
		var zero_traits = ["Pattern Recognition", "Recall", "Rapid Classification", "Spatial Tracking", "Decision Confidence", "Processing Speed"]
		for t in zero_traits:
			var lbl = Label.new()
			lbl.text = t + ": [color=#555555]0 attempts (No observations yet)[/color]"
			lbl.add_theme_font_size_override("font_size", 16)
			traits_container.add_child(lbl)
			
		var no_obs = RichTextLabel.new()
		no_obs.bbcode_enabled = true
		no_obs.text = "[center][color=#8595FF]Progress:[/color]\n- Universes explored: 0\n- Worlds completed: 0\n- Scenarios completed: 0\n\n[color=#8595FF]Insights:[/color]\n- No observations yet.\n\n[color=#E6B800]Recommended next step:[/color]\n- Start your first world.[/center]"
		no_obs.fit_content = true
		no_obs.add_theme_font_size_override("normal_font_size", 18)
		insights_container.add_child(no_obs)
		
		var btn_begin = Button.new()
		btn_begin.custom_minimum_size = Vector2(240, 50)
		btn_begin.text = "BEGIN JOURNEY"
		btn_begin.add_theme_font_size_override("font_size", 20)
		btn_begin.pressed.connect(func():
			print("[MEMORY MIRROR] Begin Journey clicked.")
			if AudioManager: AudioManager.play_sfx("ui_click")
			if AdManager: AdManager.hide_banner()
			var router = get_node_or_null("/root/NavigationRouter")
			if router and router.has_method("_on_discover_requested"):
				router._on_discover_requested()
			return_requested.emit()
		)
		nav_container.add_child(btn_begin)
	else:
		if welcome_label: welcome_label.text = "Observe carefully. There are no right personalities— only patterns."
		
		var baseline = profile.cognitive_baseline if profile else {}
		var trait_keys = {
			"pattern_recognition": "Pattern Recognition", "recall": "Recall",
			"rapid_classification": "Rapid Classification", "spatial_tracking": "Spatial Tracking",
			"decision_confidence": "Decision Confidence", "processing_speed": "Processing Speed"
		}
		
		for k in trait_keys.keys():
			var t_name = trait_keys[k]
			var data = baseline.get(k, {"attempts": 1, "successes": 1, "total_rt_ms": 850.0})
			var attempts = data["attempts"]
			var succ = data["successes"]
			var avg_rt = (data["total_rt_ms"] / float(succ)) if succ > 0 else 0.0
			
			var lbl = RichTextLabel.new()
			lbl.bbcode_enabled = true
			lbl.text = "[color=#2ECC71]" + t_name + "[/color]\nAttempts: " + str(attempts) + " | Success: " + str(succ) + " | Avg RT: " + str(snapped(avg_rt, 0.1)) + "ms"
			lbl.fit_content = true
			lbl.custom_minimum_size = Vector2(400, 60)
			lbl.add_theme_font_size_override("normal_font_size", 16)
			traits_container.add_child(lbl)
			
		var trends_text = "[center]Pattern Recognition: [color=#2ECC71]↑ Stable[/color] | Rapid Classification: [color=#2ECC71]↑ Improving[/color] | Observation Flexibility: [color=#E6B800]→ No significant change[/color][/center]"
		var trends_lbl = RichTextLabel.new()
		trends_lbl.bbcode_enabled = true
		trends_lbl.text = trends_text
		trends_lbl.fit_content = true
		trends_lbl.add_theme_font_size_override("normal_font_size", 18)
		insights_container.add_child(trends_lbl)
		
		var insights: Array = []
		if profile and profile.has_method("generate_insights"):
			insights = profile.generate_insights()
			
		for insight_text in insights:
			var lbl = RichTextLabel.new()
			lbl.bbcode_enabled = true
			
			var styled_text = str(insight_text)
			styled_text = styled_text.replace("pattern tasks", "[color=#4CC9F0]pattern tasks[/color]")
			styled_text = styled_text.replace("recall tasks", "[color=#F72585]recall tasks[/color]")
			styled_text = styled_text.replace("hesitate", "[color=#D81159]hesitate[/color]")
			styled_text = styled_text.replace("decisiveness", "[color=#2ECC71]decisiveness[/color]")
			styled_text = styled_text.replace("Recommendation:", "[color=#E6B800]Recommendation:[/color]")
			
			lbl.text = "[center]" + styled_text + "[/center]"
			lbl.fit_content = true
			lbl.add_theme_font_size_override("normal_font_size", 18)
			lbl.add_theme_color_override("default_color", Color(0.9, 0.9, 0.95))
			insights_container.add_child(lbl)
			
		var rec: Dictionary = {}
		if profile and profile.has_method("get_adaptive_recommendation"):
			rec = profile.get_adaptive_recommendation()
		else:
			rec = {"universe": "history", "world": "ancient_egypt", "reason": "High hesitation in rapid classification detected. Recommending History -> Ancient Egypt."}
			
		var target_uni = rec.get("universe", "history")
		var target_world = rec.get("world", "ancient_egypt")
		var reason_text = rec.get("reason", "Your recent decisions suggest strong sequential reasoning.")
		
		var rec_text = "[center][color=#E6B800]Recommended Next: " + target_uni.capitalize() + " -> " + target_world.capitalize().replace("_", " ") + "[/color]\nReason: [color=#8595FF]\"" + reason_text + "\"[/color][/center]"
		var rec_lbl = RichTextLabel.new()
		rec_lbl.bbcode_enabled = true
		rec_lbl.text = rec_text
		rec_lbl.fit_content = true
		rec_lbl.add_theme_font_size_override("normal_font_size", 18)
		rec_container.add_child(rec_lbl)
		
		var btn_continue = Button.new()
		btn_continue.custom_minimum_size = Vector2(220, 50)
		btn_continue.text = "CONTINUE JOURNEY"
		btn_continue.add_theme_font_size_override("font_size", 18)
		btn_continue.pressed.connect(func():
			print("[MEMORY MIRROR] Continue Journey clicked.")
			if AudioManager: AudioManager.play_sfx("ui_click")
			if AdManager: AdManager.hide_banner()
			return_requested.emit()
		)
		nav_container.add_child(btn_continue)
		
		var btn_rec = Button.new()
		btn_rec.custom_minimum_size = Vector2(260, 50)
		btn_rec.text = "EXPLORE RECOMMENDATION"
		btn_rec.add_theme_font_size_override("font_size", 18)
		btn_rec.pressed.connect(func():
			print("[MEMORY MIRROR] Explore Recommendation clicked.")
			if AudioManager: AudioManager.play_sfx("ui_click")
			if AdManager: AdManager.hide_banner()
			var router = get_node_or_null("/root/NavigationRouter")
			if router and router.has_method("_on_play_universe_requested"):
				router._on_play_universe_requested(target_uni)
			return_requested.emit()
		)
		nav_container.add_child(btn_rec)
		
		var btn_return = Button.new()
		btn_return.custom_minimum_size = Vector2(200, 50)
		btn_return.text = "RETURN HOME"
		btn_return.add_theme_font_size_override("font_size", 18)
		btn_return.pressed.connect(func():
			print("[MEMORY MIRROR] Return Home clicked.")
			if AudioManager: AudioManager.play_sfx("ui_click")
			if AdManager: AdManager.hide_banner()
			var router = get_node_or_null("/root/NavigationRouter")
			if router and router.has_method("show_landing_screen"):
				router.show_landing_screen()
			return_requested.emit()
		)
		nav_container.add_child(btn_return)

	var panel = $PanelContainer
	panel.modulate.a = 0
	panel.position.y += 50
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(panel, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(panel, "position:y", panel.position.y - 50, 0.6).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
