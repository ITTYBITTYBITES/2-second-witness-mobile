extends CanvasLayer

@onready var lifetime_label = $PanelContainer/MarginContainer/VBoxContainer/Header/LifetimeLabel
@onready var insights_container = $PanelContainer/MarginContainer/VBoxContainer/InsightsContainer

func _ready():
	AdManager.show_banner()
	print("[2 SECOND WITNESS] Player Profile Screen initializing.")
	_populate_data()

func _populate_data():
	var profile = get_node_or_null("/root/PlayerProfile")
	if not profile: return
	
	lifetime_label.text = "LIFETIME SESSIONS: " + str(profile.lifetime_sessions)
	
	for child in insights_container.get_children():
	AdManager.hide_banner()
		child.queue_free()
		
	var insights = profile.generate_insights()
	for insight_text in insights:
		var lbl = RichTextLabel.new()
		lbl.bbcode_enabled = true
		
		var styled_text = insight_text
		styled_text = styled_text.replace("pattern tasks", "[color=#4CC9F0]pattern tasks[/color]")
		styled_text = styled_text.replace("recall tasks", "[color=#F72585]recall tasks[/color]")
		styled_text = styled_text.replace("hesitate", "[color=#D81159]hesitate[/color]")
		styled_text = styled_text.replace("decisiveness", "[color=#2ECC71]decisiveness[/color]")
		
		lbl.text = "[center]" + styled_text + "[/center]"
		lbl.fit_content = true
		lbl.add_theme_font_size_override("normal_font_size", 20)
		lbl.add_theme_color_override("default_color", Color(0.9, 0.9, 0.95))
		
		insights_container.add_child(lbl)

	var panel = $PanelContainer
	panel.modulate.a = 0
	panel.position.y += 50
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(panel, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(panel, "position:y", panel.position.y - 50, 0.6).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
