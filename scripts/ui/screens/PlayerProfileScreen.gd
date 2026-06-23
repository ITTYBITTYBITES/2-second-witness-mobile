extends CanvasLayer

@onready var lifetime_label = $Panel/VBoxContainer/Header/LifetimeLabel
@onready var insights_container = $Panel/VBoxContainer/InsightsContainer

func _ready():
	print("[2 SECOND WITNESS] Player Profile Screen initializing.")
	_populate_data()

func _populate_data():
	var profile = get_node("/root/PlayerProfile")
	if not profile: return
	
	lifetime_label.text = "Lifetime Sessions: " + str(profile.lifetime_sessions)
	
	# Clear placeholder insights
	for child in insights_container.get_children():
		child.queue_free()
		
	# Populate dynamic insights
	var insights = profile.generate_insights()
	for insight_text in insights:
		var lbl = Label.new()
		lbl.text = "• " + insight_text
		lbl.add_theme_font_size_override("font_size", 20)
		lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		insights_container.add_child(lbl)
