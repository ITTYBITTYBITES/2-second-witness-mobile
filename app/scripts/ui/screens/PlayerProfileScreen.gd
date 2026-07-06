extends CanvasLayer

# ---------------------------------------------------------
# MIRROR — 3-Tier Player Reflection Screen
# ---------------------------------------------------------
# Tier 1 (FOCUS): Daily Expedition status, streak, primary action
# Tier 2 (PROGRESS): Worlds, universes, mechanics — compact tiles
# Tier 3 (DETAILS): Accuracy, reaction times, historical — collapsed
# ---------------------------------------------------------

signal return_requested
signal recommendation_requested(universe_id: String, world_id: String)

@onready var identity_label = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/Header/IdentityLabel
@onready var focus_section = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/FocusSection
@onready var progress_grid = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/ProgressSection/ProgressGrid
@onready var details_section = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/DetailsSection
@onready var details_toggle = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/DetailsToggle
@onready var nav_container = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/NavContainer

func _ready():
	var registry = ContentRegistry if ContentRegistry else get_tree().root.get_node_or_null("ContentRegistry")
	var uni = ""
	var nav = get_node_or_null("/root/NavigationRouter")
	if nav and "active_universe_selection" in nav:
		uni = str(nav.active_universe_selection)
	_apply_universe_manifest(uni)

	$PanelContainer.mouse_filter = Control.MOUSE_FILTER_PASS
	$VoidBG.mouse_filter = Control.MOUSE_FILTER_STOP
	$VoidBG.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed:
			_request_close()
	)

	details_toggle.toggled.connect(func(pressed):
		details_section.visible = pressed
		details_toggle.text = "Hide Advanced Stats" if pressed else "Advanced Stats"
	)

	_mount_close_button()
	_populate_data()

# =========================================================
# POPULATION
# =========================================================

func _populate_data():
	var profile = get_node_or_null("/root/PlayerProfile")
	var narrator = get_node_or_null("/root/MirrorNarrator")
	var exp_mgr = DailyExpeditionManager if DailyExpeditionManager else get_tree().root.get_node_or_null("DailyExpeditionManager")

	# --- TIER 1: FOCUS ---
	_build_focus(profile, narrator, exp_mgr)

	# --- TIER 2: PROGRESS ---
	_build_progress(profile, narrator)

	# --- TIER 3: DETAILS ---
	_build_details(profile, narrator)

	# --- NAVIGATION ---
	_build_navigation(profile, narrator, exp_mgr)

	# Entrance animation
	var panel = $PanelContainer
	panel.modulate.a = 0
	panel.position.y += 30
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(panel, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(panel, "position:y", panel.position.y - 30, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

# =========================================================
# TIER 1: FOCUS — Daily Expedition + Streak + Action
# =========================================================

func _build_focus(profile, narrator, exp_mgr):
	for child in focus_section.get_children():
		child.queue_free()

	var level = profile.current_level if profile else 1
	var title = profile.player_title if profile else "Observer"

	# Identity line
	if identity_label:
		identity_label.text = title.to_upper() + " • LEVEL " + str(level)

	if exp_mgr:
		var exp = exp_mgr.get_expedition()
		var prog = exp_mgr.get_progress()
		var completed = int(prog.get("completed", 0))
		var total = int(prog.get("total", exp.size()))
		var streak = int(prog.get("streak", 0))

		# Expedition status card
		var card = _create_focus_card(
			"DAILY EXPEDITION",
			str(completed) + " / " + str(total) + " worlds complete",
			"Streak: " + str(streak) + " days"
		)
		focus_section.add_child(card)

		# Primary action button
		if completed < total:
			var btn = Button.new()
			btn.custom_minimum_size = Vector2(320, 56)
			btn.text = "CONTINUE EXPEDITION"
			btn.add_theme_font_size_override("font_size", 20)
			_style_primary_button(btn)
			btn.pressed.connect(func():
				if AudioManager: AudioManager.play_sfx("ui_click")
				return_requested.emit()
			)
			focus_section.add_child(btn)
		else:
			var done_lbl = Label.new()
			done_lbl.text = "Today's expedition complete!"
			done_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			done_lbl.add_theme_font_size_override("font_size", 18)
			done_lbl.add_theme_color_override("font_color", Color(0.3, 0.8, 0.4))
			focus_section.add_child(done_lbl)
	else:
		# No expedition system — show journey status
		var lifetime = profile.lifetime_sessions if profile else 0
		if lifetime <= 1:
			var welcome = Label.new()
			welcome.text = "Your reflection is still forming.\nComplete observations to reveal patterns."
			welcome.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			welcome.add_theme_font_size_override("font_size", 18)
			welcome.add_theme_color_override("font_color", Color(0.85, 0.95, 1, 0.8))
			focus_section.add_child(welcome)
		else:
			var streak = profile.current_streak if profile else 1
			var card = _create_focus_card(
				"YOUR JOURNEY",
				str(lifetime) + " sessions observed",
				"Streak: " + str(streak) + " days"
			)
			focus_section.add_child(card)

# =========================================================
# TIER 2: PROGRESS — Compact tiles
# =========================================================

func _build_progress(profile, narrator):
	for child in progress_grid.get_children():
		child.queue_free()

	var reg = ContentRegistry if ContentRegistry else get_tree().root.get_node_or_null("ContentRegistry")
	var lifetime = profile.lifetime_sessions if profile else 0

	# Count explored worlds and universes
	var worlds_explored = 0
	var universes_explored = 0
	if reg:
		for u_id in reg.get_all_universes():
			var has_any = false
			for w_id in reg.get_all_worlds_in_universe(u_id):
				if reg.get_all_scenarios_in_world(u_id, w_id).size() > 0:
					has_any = true
			if has_any:
				universes_explored += 1

	# Mechanics mastered (traits with >5 successes)
	var mechanics_count = 0
	if profile and "cognitive_baseline" in profile:
		for trait in profile.cognitive_baseline:
			if int(profile.cognitive_baseline[trait].get("successes", 0)) >= 5:
				mechanics_count += 1

	# Expeditions completed
	var expeditions = 0
	var exp_mgr = DailyExpeditionManager if DailyExpeditionManager else get_tree().root.get_node_or_null("DailyExpeditionManager")
	if exp_mgr:
		expeditions = exp_mgr.expeditions_completed

	# Add tiles
	_add_progress_tile("Worlds Available", str(_count_playable_worlds(reg)))
	_add_progress_tile("Universes", str(universes_explored))
	_add_progress_tile("Mechanics Practiced", str(mechanics_count))
	_add_progress_tile("Expeditions", str(expeditions))

# =========================================================
# TIER 3: DETAILS — Collapsed by default
# =========================================================

func _build_details(profile, narrator):
	for child in details_section.get_children():
		child.queue_free()

	if not profile or profile.lifetime_sessions <= 1:
		var lbl = Label.new()
		lbl.text = "Complete more observations to unlock detailed metrics."
		lbl.add_theme_font_size_override("font_size", 14)
		lbl.add_theme_color_override("font_color", Color(0.5, 0.55, 0.6))
		details_section.add_child(lbl)
		return

	# Cognitive traits with details
	if narrator:
		var cards = narrator.get_strength_cards(profile)
		_build_strength_group("STRENGTH", cards.get("strength", []), Color("#2ECC71"))
		_build_strength_group("IMPROVING", cards.get("improving", []), Color("#4CC9F0"))
		_build_strength_group("NEEDS PRACTICE", cards.get("needs_practice", []), Color("#E6B800"))

	# Session summary
	if narrator:
		var summary = narrator.get_last_session_summary(profile)
		if summary and not summary.is_empty():
			var lbl = Label.new()
			lbl.text = "RECENT SESSION"
			lbl.add_theme_font_size_override("font_size", 13)
			lbl.add_theme_color_override("font_color", Color(0.6, 0.65, 0.72))
			details_section.add_child(lbl)
			for s in summary:
				var line = Label.new()
				line.text = "  • " + str(s)
				line.add_theme_font_size_override("font_size", 14)
				line.add_theme_color_override("font_color", Color(0.7, 0.75, 0.8))
				details_section.add_child(line)

	# Raw stats
	var xp = profile.experience if profile else 0
	var sessions = profile.lifetime_sessions if profile else 0
	var streak = profile.current_streak if profile else 0
	var raw_lbl = Label.new()
	raw_lbl.text = "\nXP: " + str(xp) + " | Sessions: " + str(sessions) + " | Streak: " + str(streak) + " days"
	raw_lbl.add_theme_font_size_override("font_size", 13)
	raw_lbl.add_theme_color_override("font_color", Color(0.5, 0.55, 0.6))
	raw_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	details_section.add_child(raw_lbl)

# =========================================================
# NAVIGATION
# =========================================================

func _build_navigation(profile, narrator, exp_mgr):
	for child in nav_container.get_children():
		child.queue_free()

	var btn_home = Button.new()
	btn_home.custom_minimum_size = Vector2(200, 50)
	btn_home.text = "RETURN HOME"
	btn_home.add_theme_font_size_override("font_size", 16)
	btn_home.pressed.connect(_request_close)
	nav_container.add_child(btn_home)

# =========================================================
# HELPERS
# =========================================================

func _create_focus_card(title_text: String, main_text: String, sub_text: String) -> PanelContainer:
	var card = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.1, 0.16, 0.8)
	style.border_width_bottom = 3
	style.border_color = Color(0.3, 0.78, 0.94, 0.6)
	style.set_corner_radius_all(12)
	card.add_theme_stylebox_override("panel", style)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)

	var title_lbl = Label.new()
	title_lbl.text = title_text
	title_lbl.add_theme_font_size_override("font_size", 13)
	title_lbl.add_theme_color_override("font_color", Color(0.5, 0.55, 0.6))
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title_lbl)

	var main_lbl = Label.new()
	main_lbl.text = main_text
	main_lbl.add_theme_font_size_override("font_size", 22)
	main_lbl.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
	main_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(main_lbl)

	if sub_text != "":
		var sub_lbl = Label.new()
		sub_lbl.text = sub_text
		sub_lbl.add_theme_font_size_override("font_size", 14)
		sub_lbl.add_theme_color_override("font_color", Color(0.6, 0.65, 0.72))
		sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(sub_lbl)

	card.add_child(vbox)
	return card

func _add_progress_tile(label_text: String, value_text: String):
	var tile = PanelContainer.new()
	tile.custom_minimum_size = Vector2(220, 60)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.08, 0.13, 0.7)
	style.set_corner_radius_all(10)
	tile.add_theme_stylebox_override("panel", style)

	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER

	var val_lbl = Label.new()
	val_lbl.text = value_text
	val_lbl.add_theme_font_size_override("font_size", 20)
	val_lbl.add_theme_color_override("font_color", Color(0.3, 0.78, 0.94))
	hbox.add_child(val_lbl)

	var sep = Label.new()
	sep.text = "  "
	hbox.add_child(sep)

	var lbl = Label.new()
	lbl.text = label_text
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.add_theme_color_override("font_color", Color(0.6, 0.65, 0.72))
	hbox.add_child(lbl)

	tile.add_child(hbox)
	progress_grid.add_child(tile)

func _build_strength_group(header_title: String, items: Array, header_color: Color):
	if items.is_empty():
		return
	var header = Label.new()
	header.text = header_title
	header.add_theme_font_size_override("font_size", 14)
	header.add_theme_color_override("font_color", header_color)
	details_section.add_child(header)

	for item in items:
		var lbl = Label.new()
		lbl.text = "  " + str(item.get("title", "?")) + " " + str(item.get("stars", "")) + "  (" + str(item.get("success_rate", "?")) + " success, " + str(item.get("avg_rt", "?")) + "ms avg)"
		lbl.add_theme_font_size_override("font_size", 13)
		lbl.add_theme_color_override("font_color", Color(0.7, 0.75, 0.8))
		details_section.add_child(lbl)

func _count_playable_worlds(reg) -> int:
	if not reg:
		return 0
	var count = 0
	for u_id in reg.get_all_universes():
		for w_id in reg.get_all_worlds_in_universe(u_id):
			if reg.get_all_scenarios_in_world(u_id, w_id).size() > 0:
				count += 1
	return count

func _style_primary_button(btn: Button):
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.18, 0.28, 0.9)
	style.border_width_bottom = 4
	style.border_color = Color(0.3, 0.78, 0.94, 1)
	style.set_corner_radius_all(12)
	btn.add_theme_stylebox_override("normal", style)
	var hover = style.duplicate()
	hover.bg_color = Color(0.06, 0.24, 0.36, 0.95)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", style.duplicate())
	btn.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))

func _escape_bbcode(value: Variant) -> String:
	var text = str(value)
	text = text.replace("[", "__BB_LB__")
	text = text.replace("]", "__BB_RB__")
	text = text.replace("__BB_LB__", "[lb]")
	return text.replace("__BB_RB__", "[rb]")

func _request_close():
	if AudioManager: AudioManager.play_sfx("ui_click")
	return_requested.emit()

func _apply_universe_manifest(universe_id: String):
	var vim = VisualIdentityManager if VisualIdentityManager else get_tree().root.get_node_or_null("VisualIdentityManager")
	if vim and vim.has_method("apply_screen_identity"):
		vim.apply_screen_identity(self, universe_id, "", false)
	else:
		var bg = get_node_or_null("VoidBG")
		if bg and bg is ColorRect:
			bg.color = Color(0.04, 0.07, 0.12, 0.15)

func _mount_close_button():
	if get_node_or_null("CloseMirrorButton"):
		return
	var btn_close = Button.new()
	btn_close.name = "CloseMirrorButton"
	btn_close.text = "×"
	btn_close.tooltip_text = "Close Mirror"
	btn_close.custom_minimum_size = Vector2(44, 44)
	btn_close.size = btn_close.custom_minimum_size
	btn_close.mouse_filter = Control.MOUSE_FILTER_STOP
	btn_close.z_index = 200
	btn_close.add_theme_font_size_override("font_size", 26)
	btn_close.add_theme_color_override("font_color", Color(1.0, 0.92, 0.98))
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.04, 0.08, 0.92)
	style.border_color = Color("#F72585")
	style.set_border_width_all(2)
	style.set_corner_radius_all(22)
	var hover = style.duplicate()
	hover.bg_color = Color(0.16, 0.05, 0.12, 0.96)
	var pressed = style.duplicate()
	pressed.bg_color = Color("#F72585")
	btn_close.add_theme_stylebox_override("normal", style)
	btn_close.add_theme_stylebox_override("hover", hover)
	btn_close.add_theme_stylebox_override("pressed", pressed)
	btn_close.pressed.connect(_request_close)
	add_child(btn_close)
	if get_viewport() and not get_viewport().size_changed.is_connected(_position_close_button):
		get_viewport().size_changed.connect(_position_close_button)
	call_deferred("_position_close_button")

func _position_close_button():
	var btn_close = get_node_or_null("CloseMirrorButton")
	var panel = get_node_or_null("PanelContainer")
	if not btn_close or not panel:
		return
	var btn_size = btn_close.custom_minimum_size
	btn_close.size = btn_size
	btn_close.position = panel.global_position + Vector2(max(12.0, panel.size.x - btn_size.x - 14.0), 14.0)

func hide_screen():
	queue_free()
