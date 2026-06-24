extends CanvasLayer

signal boot_completed

@onready var status_label = $VBoxContainer/StatusLabel
@onready var progress_bar = $VBoxContainer/ProgressBar
@onready var logo_label = $VBoxContainer/LogoLabel

func _ready():
	print("[BOOT] Boot Screen Active. Masking Engine Initialization.")
	status_label.text = "INITIALIZING CORTEX..."
	progress_bar.value = 10
	
	# The "Mood Ring" Splash Screen
	# Randomize the color of the 2 SECOND WITNESS logo every boot to create the illusion of a shifting entity.
	var moods = [
		Color("#00D4FF"), # Cyan (Analytical)
		Color("#2ECC71"), # Green (Organic)
		Color("#F72585"), # Magenta (Creative)
		Color("#FFBC42"), # Orange (Frontier)
		Color("#D81159")  # Crimson (Hostile)
	]
	var today_mood = moods[randi() % moods.size()]
	
	logo_label.add_theme_color_override("font_color", today_mood)
	progress_bar.modulate = today_mood
	
	await get_tree().process_frame
	
	if GitHubSyncManager:
		status_label.text = "SYNCHRONIZING MANIFEST..."
		progress_bar.value = 40
		GitHubSyncManager.sync_cycle()
		var sync_status = await GitHubSyncManager.sync_completed
		if sync_status == "success":
			status_label.text = "PATCH APPLIED."
		else:
			status_label.text = "OFFLINE MODE ACTIVE."
	else:
		status_label.text = "SYNC MANAGER OFFLINE."
	
	progress_bar.value = 80
	
	if ContentLoader:
		status_label.text = "INDEXING NEURAL PATHWAYS..."
		await get_tree().create_timer(0.5).timeout
		
	progress_bar.value = 100
	status_label.text = "SYSTEM READY."
	
	await get_tree().create_timer(0.5).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func():
		boot_completed.emit()
		queue_free()
	)
