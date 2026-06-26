extends CanvasLayer

signal return_requested

@onready var lifetime_label = $PanelContainer/MarginContainer/VBoxContainer/Header/LifetimeLabel
@onready var insights_container = $PanelContainer/MarginContainer/VBoxContainer/InsightsContainer

var btn_leave

func _ready():
	print("PROFILE SCREEN READY")
	print("Visible: ", visible)
	print("Size: ", $PanelContainer.size)
	print("Children: ", get_child_count())
	
	$PanelContainer.mouse_filter = Control.MOUSE_FILTER_PASS
	$VoidBG.mouse_filter = Control.MOUSE_FILTER_STOP
	
	$VoidBG.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed:
			print("[COGNITIVE MIRROR] Background clicked. Exiting mirror.")
			if AudioManager: AudioManager.play_sfx("ui_click")
			if AdManager: AdManager.hide_banner()
			return_requested.emit()
	)
	
	if AdManager: AdManager.show_banner()
	print("[2 SECOND WITNESS] Player Profile Screen initializing.")
	_populate_data()

func _populate_data():
	var profile = PlayerProfile if PlayerProfile else get_tree().root.get_node_or_null("PlayerProfile")
	if not profile: return
	
	if lifetime_label: lifetime_label.text = "LIFETIME SESSIONS: " + str(profile.lifetime_sessions)
	
	for child in insights_container.get_children():
		child.queue_free()
		
	var header_lbl = RichTextLabel.new()
	header_lbl.bbcode_enabled = true
	header_lbl.text = "[center][color=#2ECC71]★ TODAY'S OBSERVATIONS & TRENDS[/color][/center]"
	header_lbl.fit_content = true
	header_lbl.add_theme_font_size_override("normal_font_size", 24)
	insights_container.add_child(header_lbl)
	
	var trends_text = "[center]Working Memory: [color=#2ECC71]↑ Stable[/color] | Rapid Classification: [color=#2ECC71]↑ Improving[/color] | Cognitive Flexibility: [color=#E6B800]→ No significant change[/color][/center]"
	var trends_lbl = RichTextLabel.new()
	trends_lbl.bbcode_enabled = true
	trends_lbl.text = trends_text
	trends_lbl.fit_content = true
	trends_lbl.add_theme_font_size_override("normal_font_size", 18)
	insights_container.add_child(trends_lbl)
	
	var rec = profile.get_adaptive_recommendation() if profile.has_method("get_adaptive_recommendation") else {"target_universe": "frontier", "reason": "Your recent decisions suggest strong spatial reasoning."}
	var rec_text = "\n[center][color=#E6B800]Suggested Exploration: " + rec.get("target_universe", "frontier").capitalize() + "[/color]\nReason: [color=#8595FF]\"" + rec.get("reason", "Your recent decisions suggest strong spatial reasoning.") + "\"[/color][/center]\n"
	var rec_lbl = RichTextLabel.new()
	rec_lbl.bbcode_enabled = true
	rec_lbl.text = rec_text
	rec_lbl.fit_content = true
	rec_lbl.add_theme_font_size_override("normal_font_size", 18)
	insights_container.add_child(rec_lbl)
	
	var insights = profile.generate_insights() if profile.has_method("generate_insights") else []
	for insight_text in insights:
		var lbl = RichTextLabel.new()
		lbl.bbcode_enabled = true
		
		var styled_text = insight_text
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

	var hbox = HBoxContainer.new()
	hbox.alignment = HBoxContainer.ALIGN_CENTER
	hbox.add_theme_constant_override("separation", 30)
	
	var btn_continue = Button.new()
	btn_continue.custom_minimum_size = Vector2(220, 50)
	btn_continue.text = "CONTINUE JOURNEY"
	btn_continue.add_theme_font_size_override("font_size", 18)
	btn_continue.pressed.connect(func():
		print("[COGNITIVE MIRROR] Continue Journey clicked.")
		if AudioManager: AudioManager.play_sfx("ui_click")
		if AdManager: AdManager.hide_banner()
		return_requested.emit()
	)
	hbox.add_child(btn_continue)
	
	var btn_rec = Button.new()
	btn_rec.custom_minimum_size = Vector2(260, 50)
	btn_rec.text = "EXPLORE RECOMMENDATION"
	btn_rec.add_theme_font_size_override("font_size", 18)
	btn_rec.pressed.connect(func():
		print("[COGNITIVE MIRROR] Explore Recommendation clicked.")
		if AudioManager: AudioManager.play_sfx("ui_click")
		if AdManager: AdManager.hide_banner()
		var router = NavigationRouter if NavigationRouter else get_tree().root.get_node_or_null("NavigationRouter")
		if router and router.has_method("_on_play_universe_requested"):
			router._on_play_universe_requested(rec.get("target_universe", "frontier"))
		return_requested.emit()
	)
	hbox.add_child(btn_rec)
	
	var btn_return = Button.new()
	btn_return.custom_minimum_size = Vector2(200, 50)
	btn_return.text = "RETURN HOME"
	btn_return.add_theme_font_size_override("font_size", 18)
	btn_return.pressed.connect(func():
		print("[COGNITIVE MIRROR] Return Home clicked.")
		if AudioManager: AudioManager.play_sfx("ui_click")
		if AdManager: AdManager.hide_banner()
		var router = NavigationRouter if NavigationRouter else get_tree().root.get_node_or_null("NavigationRouter")
		if router and router.has_method("show_landing_screen"):
			router.show_landing_screen()
		return_requested.emit()
	)
	hbox.add_child(btn_return)
	
	insights_container.add_child(hbox)

	var panel = $PanelContainer
	panel.modulate.a = 0
	panel.position.y += 50
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(panel, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(panel, "position:y", panel.position.y - 50, 0.6).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
