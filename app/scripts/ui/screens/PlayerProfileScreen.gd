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
	var narrator = get_node_or_null("/root/MirrorNarrator")
	var lifetime = profile.lifetime_sessions if profile else 0
	
	if lifetime_label: lifetime_label.text = "LIFETIME SESSIONS: " + str(lifetime)
	
	for child in traits_container.get_children(): child.queue_free()
	for child in insights_container.get_children(): child.queue_free()
	for child in rec_container.get_children(): child.queue_free()
	for child in nav_container.get_children(): child.queue_free()
	
	if lifetime <= 1 or not narrator:
		if lifetime_label: lifetime_label.text = "OBSERVATION JOURNEY INITIATED"
		if welcome_label: welcome_label.text = "Your reflection is still forming. Complete observation sessions to reveal patterns."
		var summary = narrator.get_last_session_summary(profile) if narrator else ["Your observation journey is just beginning."]
		for s in summary:
			var lbl = Label.new()
			lbl.text = "• " + s
			lbl.add_theme_font_size_override("font_size", 16)
			traits_container.add_child(lbl)
			
		var btn_begin = Button.new()
		btn_begin.custom_minimum_size = Vector2(260, 50)
		btn_begin.text = "BEGIN OBSERVATION"
		btn_begin.add_theme_font_size_override("font_size", 20)
		btn_begin.pressed.connect(func():
			if AudioManager: AudioManager.play_sfx("ui_click")
			if AdManager: AdManager.hide_banner()
			var router = get_node_or_null("/root/NavigationRouter")
			if router and router.has_method("_on_discover_requested"):
				router._on_discover_requested()
			return_requested.emit()
		)
		nav_container.add_child(btn_begin)
		
		var btn_return_home = Button.new()
		btn_return_home.custom_minimum_size = Vector2(200, 50)
		btn_return_home.text = "RETURN HOME"
		btn_return_home.add_theme_font_size_override("font_size", 16)
		btn_return_home.pressed.connect(func():
			if AudioManager: AudioManager.play_sfx("ui_click")
			if AdManager: AdManager.hide_banner()
			var router = get_node_or_null("/root/NavigationRouter")
			if router and router.has_method("show_landing_screen"):
				router.show_landing_screen()
			return_requested.emit()
		)
		nav_container.add_child(btn_return_home)
		return

	# Stage 2: Who Am I Becoming? (Hero Section)
	var journey = narrator.get_journey_narration(profile)
	if lifetime_label:
		lifetime_label.text = "LEVEL %d | XP %d | SESSIONS: %d | STREAK: %d DAYS" % [journey["level"], journey["xp"], journey["sessions"], journey["streak"]]
	if welcome_label:
		welcome_label.text = journey["confidence_title"].to_upper() + "\n" + journey["confidence_narration"] + "\n\n" + journey["style_narration"]
		welcome_label.add_theme_color_override("font_color", Color("#2ECC71"))

	# Stage 1: Since Your Last Session
	var summary_lines = narrator.get_last_session_summary(profile)
	var sum_text = "[center][color=#4CC9F0]SINCE YOUR LAST SESSION:[/color]\n"
	for s in summary_lines:
		sum_text += "• " + str(s).escape_bbcode() + "\n"
	sum_text += "[/center]"
	var sum_lbl = RichTextLabel.new()
	sum_lbl.bbcode_enabled = true
	sum_lbl.text = sum_text
	sum_lbl.fit_content = true
	sum_lbl.add_theme_font_size_override("normal_font_size", 18)
	traits_container.add_child(sum_lbl)

	# Surprise Narration
	var surprise = narrator.get_surprise_narration(profile)
	if surprise != "":
		var sur_lbl = RichTextLabel.new()
		sur_lbl.bbcode_enabled = true
		sur_lbl.text = "[center][color=#F72585]" + str(surprise).escape_bbcode() + "[/color][/center]"
		sur_lbl.fit_content = true
		sur_lbl.add_theme_font_size_override("normal_font_size", 18)
		traits_container.add_child(sur_lbl)

	# Stage 3: What The Mirror Sees (Visual Strength Groupings & Expandable Details)
	var cards = narrator.get_strength_cards(profile)
	_build_strength_group("STRENGTH", cards["strength"], Color("#2ECC71"))
	_build_strength_group("IMPROVING", cards["improving"], Color("#4CC9F0"))
	_build_strength_group("NEEDS PRACTICE", cards["needs_practice"], Color("#E6B800"))

	# Stage 4: Insights (Coaching Guidance)
	var insights = narrator.get_insights(profile)
	for insight_text in insights:
		var lbl = RichTextLabel.new()
		lbl.bbcode_enabled = true
		var styled = "[center][color=#99AAFF]" + str(insight_text).escape_bbcode() + "[/color][/center]"
		lbl.text = styled
		lbl.fit_content = true
		lbl.add_theme_font_size_override("normal_font_size", 18)
		insights_container.add_child(lbl)

	# Stage 5: Continue Your Journey
	var rec = narrator.get_next_recommendation(profile)
	var rec_title = str(rec["display_title"]).to_upper().escape_bbcode()
	var rec_reason = str(rec["narrative_reason"]).escape_bbcode()
	var rec_text = "[center][color=#E6B800]CONTINUE YOUR JOURNEY: " + rec_title + "[/color]\n\"" + rec_reason + "\"[/center]"
	var rec_lbl = RichTextLabel.new()
	rec_lbl.bbcode_enabled = true
	rec_lbl.text = rec_text
	rec_lbl.fit_content = true
	rec_lbl.add_theme_font_size_override("normal_font_size", 18)
	rec_container.add_child(rec_lbl)

	var btn_cta = Button.new()
	btn_cta.custom_minimum_size = Vector2(300, 60)
	btn_cta.text = rec["cta_text"]
	btn_cta.add_theme_font_size_override("font_size", 20)
	btn_cta.pressed.connect(func():
		if AudioManager: AudioManager.play_sfx("ui_click")
		if AdManager: AdManager.hide_banner()
		var orch = get_tree().root.get_node_or_null("ExperienceOrchestrator")
		if orch and orch.has_method("request_world_selection"):
			orch.request_world_selection(rec["universe"], rec["world"])
		return_requested.emit()
	)
	nav_container.add_child(btn_cta)

	var btn_return = Button.new()
	btn_return.custom_minimum_size = Vector2(200, 50)
	btn_return.text = "RETURN HOME"
	btn_return.add_theme_font_size_override("font_size", 16)
	btn_return.pressed.connect(func():
		if AudioManager: AudioManager.play_sfx("ui_click")
		if AdManager: AdManager.hide_banner()
		var router = get_node_or_null("/root/NavigationRouter")
		if router and router.has_method("show_landing_screen"):
			router.show_landing_screen()
		return_requested.emit()
	)
	nav_container.add_child(btn_return)

func _build_strength_group(header_title: String, items: Array, header_color: Color):
	if items.is_empty(): return
	var header = RichTextLabel.new()
	header.bbcode_enabled = true
	header.text = "[center][color=#" + header_color.to_html(false) + "]" + str(header_title).escape_bbcode() + "[/color][/center]"
	header.fit_content = true
	header.add_theme_font_size_override("normal_font_size", 18)
	traits_container.add_child(header)
	
	for item in items:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(380, 50)
		btn.text = item["title"] + "  " + item["stars"] + "   [Tap for Details]"
		btn.add_theme_font_size_override("font_size", 16)
		traits_container.add_child(btn)
		
		var details = RichTextLabel.new()
		details.bbcode_enabled = true
		var details_text = "Attempts: " + str(item["attempts"]) + " | Success Rate: " + str(item["success_rate"]) + " | Avg RT: " + str(item["avg_rt"]) + "\n" + str(item["trend"])
		details.text = "[center][color=#AAAAAA]" + details_text.escape_bbcode() + "[/color][/center]"
		details.fit_content = true
		details.visible = false
		traits_container.add_child(details)
		
		btn.pressed.connect(func():
			if AudioManager: AudioManager.play_sfx("ui_click")
			details.visible = not details.visible
		)

	var panel = $PanelContainer
	panel.modulate.a = 0
	panel.position.y += 50
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(panel, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(panel, "position:y", panel.position.y - 50, 0.6).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
