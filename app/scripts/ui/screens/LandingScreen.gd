extends CanvasLayer

# ---------------------------------------------------------
# ARRIVAL SPACE — Progressive Affordance Reveal
# ---------------------------------------------------------
# First launch: only Expedition Portal is visible.
# After first completion: Mirror fades in, Archive appears.
# After multiple sessions: full environment active.
#
# Design principle: one unambiguous action at time=0.
# ---------------------------------------------------------

signal play_requested
signal profile_requested
signal discover_requested
signal settings_requested

@onready var expedition_portal = $Panel/ArrivalSpace/CenterAnchor/ArrivalVBox/ExpeditionPortal
@onready var expedition_label = $Panel/ArrivalSpace/CenterAnchor/ArrivalVBox/ExpeditionLabel
@onready var archive_node = $Panel/ArrivalSpace/CenterAnchor/ArrivalVBox/SecondaryRow/ArchiveNode
@onready var mirror_node = $Panel/ArrivalSpace/CenterAnchor/ArrivalVBox/SecondaryRow/MirrorNode
@onready var settings_node = $Panel/ArrivalSpace/CenterAnchor/ArrivalVBox/SecondaryRow/SettingsNode
@onready var secondary_row = $Panel/ArrivalSpace/CenterAnchor/ArrivalVBox/SecondaryRow
@onready var subtitle_label = $Panel/ArrivalSpace/SubtitleLabel
@onready var title_label = $Panel/ArrivalSpace/TitleLabel

var _portal_glow_tween: Tween

func _ready():
	_style_expedition_portal()
	_style_archive_node()
	_style_mirror_node()
	_style_settings_node()

	# Wire interactions
	expedition_portal.pressed.connect(_on_expedition_selected)
	expedition_portal.gui_input.connect(_on_portal_gui_input)
	archive_node.pressed.connect(_on_archive_selected)
	mirror_node.pressed.connect(_on_mirror_selected)
	settings_node.pressed.connect(_on_settings_selected)

	# Footer
	var footer = $Panel/FooterContainer
	if footer:
		var btn_privacy = footer.get_node_or_null("BtnPrivacy")
		var btn_version = footer.get_node_or_null("BtnVersion")
		if btn_privacy: btn_privacy.pressed.connect(func():
			print("[PRIVACY] 2 Second Witness gathers observations strictly on device."))
		if btn_version: btn_version.pressed.connect(func():
			print("[VERSION] Version 1.0.0-DEV (Godot 4.6 Engine)"))

	_apply_progressive_reveal()
	_register_with_kernel()
	_start_portal_pulse()

# =========================================================
# PROGRESSIVE AFFORDANCE REVEAL
# The core mechanic: show fewer options to new players.
# =========================================================

func _apply_progressive_reveal():
	var profile = get_node_or_null("/root/PlayerProfile")
	var sessions = profile.lifetime_sessions if profile else 0
	var exp_mgr = DailyExpeditionManager if DailyExpeditionManager else get_tree().root.get_node_or_null("DailyExpeditionManager")

	# === FIRST LAUNCH (sessions <= 1): single affordance ===
	if sessions <= 1:
		# Only expedition portal visible. Everything else hidden.
		secondary_row.visible = false
		secondary_row.modulate.a = 0.0

		# No progress numbers — removes meaningless framing
		if exp_mgr:
			var exp = exp_mgr.get_expedition()
			var prog = exp_mgr.get_progress()
			var completed = int(prog.get("completed", 0))
			var total = int(prog.get("total", exp.size()))

			if completed == 0:
				# Truly first time — no progress shown at all
				expedition_portal.text = "BEGIN YOUR FIRST JOURNEY"
				expedition_label.text = ""
				subtitle_label.text = "You are beginning."
			else:
				# Partial progress but still first session
				expedition_portal.text = "TODAY'S EXPEDITION\n%d / %d worlds" % [completed, total]
				expedition_label.text = "Continue exploring"
				subtitle_label.text = "You have arrived."
		else:
			expedition_portal.text = "BEGIN"
			expedition_label.text = ""
			subtitle_label.text = "You are beginning."

		# Title very dim on first launch
		title_label.modulate.a = 0.3
		return

	# === RETURNING PLAYER (sessions > 1): full environment ===
	secondary_row.visible = true
	secondary_row.modulate.a = 1.0

	# Title brighter for returning players
	title_label.modulate.a = 0.5

	if exp_mgr:
		var exp = exp_mgr.get_expedition()
		var prog = exp_mgr.get_progress()
		var completed = int(prog.get("completed", 0))
		var total = int(prog.get("total", exp.size()))
		var streak = int(prog.get("streak", 0))

		if completed < total:
			expedition_portal.text = "TODAY'S EXPEDITION\n%d / %d worlds" % [completed, total]
			expedition_label.text = "Streak: %d days" % streak
			subtitle_label.text = "You have arrived."
		else:
			expedition_portal.text = "EXPEDITION COMPLETE\n%d / %d worlds" % [completed, total]
			expedition_label.text = "Return tomorrow for a new expedition"
			subtitle_label.text = "You have arrived."
	else:
		expedition_portal.text = "BEGIN"
		expedition_label.text = ""
		subtitle_label.text = "You have arrived."

	# Archive node — shows world count
	var reg = ContentRegistry if ContentRegistry else get_tree().root.get_node_or_null("ContentRegistry")
	var world_count = _count_playable_worlds(reg)
	archive_node.text = "WORLD ARCHIVE\n%d worlds" % world_count

	# Mirror node — shows player title
	var title = profile.player_title if profile else "Observer"
	mirror_node.text = title.to_upper()

# =========================================================
# INTERACTION HANDLERS (routing unchanged)
# =========================================================

func _on_expedition_selected():
	if AudioManager: AudioManager.play_sfx("ui_click")
	var kernel = InteractionKernel if InteractionKernel else get_tree().root.get_node_or_null("InteractionKernel")
	if kernel and not kernel.consume_provenance("ExpeditionPortal", null): return
	if kernel: kernel.commit_intent({"type": "enter_stream"})
	else: play_requested.emit()

func _on_portal_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		var k = InteractionKernel if InteractionKernel else get_tree().root.get_node_or_null("InteractionKernel")
		if k and not k.consume_provenance("ExpeditionPortal", event): return
		if k: k.commit_intent({"type": "enter_stream"})

func _on_archive_selected():
	if AudioManager: AudioManager.play_sfx("ui_click")
	var kernel = InteractionKernel if InteractionKernel else get_tree().root.get_node_or_null("InteractionKernel")
	if kernel and not kernel.consume_provenance("ArchiveNode", null): return
	if kernel: kernel.commit_intent({"type": "scene_shift", "target": "DailyExpeditionScreen"})
	else: discover_requested.emit()

func _on_mirror_selected():
	if AudioManager: AudioManager.play_sfx("ui_click")
	var kernel = InteractionKernel if InteractionKernel else get_tree().root.get_node_or_null("InteractionKernel")
	if kernel and not kernel.consume_provenance("MirrorNode", null): return
	if kernel: kernel.commit_intent({"type": "toggle_utility", "utility_id": "mirror"})
	else: profile_requested.emit()

func _on_settings_selected():
	if AudioManager: AudioManager.play_sfx("ui_click")
	var kernel = InteractionKernel if InteractionKernel else get_tree().root.get_node_or_null("InteractionKernel")
	if kernel and not kernel.consume_provenance("SettingsNode", null): return
	if kernel: kernel.commit_intent({"type": "toggle_utility", "utility_id": "settings"})
	else: settings_requested.emit()

# =========================================================
# STYLING
# =========================================================

func _style_expedition_portal():
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.1, 0.18, 0.85)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 4
	style.border_color = Color(0.2, 0.6, 0.85, 0.8)
	style.set_corner_radius_all(16)
	style.shadow_color = Color(0.15, 0.45, 0.65, 0.25)
	style.shadow_size = 24
	expedition_portal.add_theme_stylebox_override("normal", style)

	var hover = style.duplicate()
	hover.bg_color = Color(0.06, 0.16, 0.26, 0.9)
	hover.border_color = Color(0.3, 0.75, 0.95, 1)
	hover.shadow_size = 32
	expedition_portal.add_theme_stylebox_override("hover", hover)

	var pressed = style.duplicate()
	pressed.bg_color = Color(0.08, 0.22, 0.35, 0.95)
	expedition_portal.add_theme_stylebox_override("pressed", pressed)

func _style_archive_node():
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.06, 0.1, 0.6)
	style.border_width_bottom = 2
	style.border_color = Color(0.25, 0.4, 0.55, 0.4)
	style.set_corner_radius_all(10)
	archive_node.add_theme_stylebox_override("normal", style)

	var hover = style.duplicate()
	hover.bg_color = Color(0.06, 0.1, 0.16, 0.75)
	hover.border_color = Color(0.3, 0.5, 0.65, 0.6)
	archive_node.add_theme_stylebox_override("hover", hover)
	archive_node.add_theme_stylebox_override("pressed", style.duplicate())

func _style_mirror_node():
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.04, 0.1, 0.5)
	style.border_width_bottom = 2
	style.border_color = Color(0.4, 0.3, 0.5, 0.3)
	style.set_corner_radius_all(10)
	mirror_node.add_theme_stylebox_override("normal", style)

	var hover = style.duplicate()
	hover.bg_color = Color(0.1, 0.06, 0.16, 0.65)
	hover.border_color = Color(0.5, 0.4, 0.6, 0.5)
	mirror_node.add_theme_stylebox_override("hover", hover)
	mirror_node.add_theme_stylebox_override("pressed", style.duplicate())

func _style_settings_node():
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.04, 0.06, 0.4)
	style.set_corner_radius_all(8)
	settings_node.add_theme_stylebox_override("normal", style)

	var hover = style.duplicate()
	hover.bg_color = Color(0.05, 0.06, 0.1, 0.6)
	settings_node.add_theme_stylebox_override("hover", hover)
	settings_node.add_theme_stylebox_override("pressed", style.duplicate())

# =========================================================
# ATMOSPHERE
# =========================================================

func _start_portal_pulse():
	if _portal_glow_tween:
		_portal_glow_tween.kill()
	_portal_glow_tween = get_tree().create_tween().set_loops()
	_portal_glow_tween.tween_property(expedition_portal, "modulate:a", 0.88, 2.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_portal_glow_tween.tween_property(expedition_portal, "modulate:a", 1.0, 2.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _register_with_kernel():
	var kernel = InteractionKernel if InteractionKernel else get_tree().root.get_node_or_null("InteractionKernel")
	if kernel and $Panel:
		kernel.register_panel($Panel, "arrival_space", kernel.UIState.MODAL_ACTIVE)

func _count_playable_worlds(reg) -> int:
	if not reg:
		return 0
	var count = 0
	for u_id in reg.get_all_universes():
		for w_id in reg.get_all_worlds_in_universe(u_id):
			if reg.get_all_scenarios_in_world(u_id, w_id).size() > 0:
				count += 1
	return count

# =========================================================
# TRANSITION
# =========================================================

func hide_screen():
	var kernel = InteractionKernel if InteractionKernel else get_tree().root.get_node_or_null("InteractionKernel")
	if kernel and $Panel:
		kernel.begin_transition($Panel, "arrival_space")
	var tween = get_tree().create_tween()
	if tween:
		tween.tween_property($Panel, "modulate:a", 0.0, 0.4)
		tween.tween_callback(func():
			if kernel: kernel.end_transition($Panel, kernel.UIState.HIDDEN, "arrival_space")
		)

func show_screen():
	var kernel = InteractionKernel if InteractionKernel else get_tree().root.get_node_or_null("InteractionKernel")
	if kernel and $Panel:
		kernel.begin_transition($Panel, "arrival_space")
	$Panel.modulate.a = 0.0
	var tween = get_tree().create_tween()
	if tween:
		tween.tween_property($Panel, "modulate:a", 1.0, 0.4)
		tween.tween_callback(func():
			if kernel: kernel.end_transition($Panel, kernel.UIState.MODAL_ACTIVE, "arrival_space")
		)
