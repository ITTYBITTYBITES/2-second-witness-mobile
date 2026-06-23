extends CanvasLayer

@onready var affinity_label = $Panel/VBoxContainer/AffinityLabel
@onready var lifetime_label = $Panel/VBoxContainer/LifetimeLabel
@onready var streak_label = $Panel/VBoxContainer/StreakLabel

func _ready():
	print("[2 SECOND WITNESS] Player Profile Screen initializing.")
	_populate_data()

func _populate_data():
	# This is where the product hook lives: learning about themselves.
	var profile = get_node("/root/PlayerProfile")
	if profile:
		lifetime_label.text = "Lifetime Sessions: " + str(profile.lifetime_sessions)
		affinity_label.text = "Dominant Universe: " + profile.most_played_universe.capitalize()
		streak_label.text = "Current Streak: Active"
