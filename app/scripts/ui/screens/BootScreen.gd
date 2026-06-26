extends CanvasLayer

signal boot_completed

@onready var status_label = $VBoxContainer/StatusLabel
@onready var progress_bar = $VBoxContainer/ProgressBar
@onready var logo_label = $VBoxContainer/LogoLabel
@onready var brand_label = $VBoxContainer/BrandLabel
@onready var logo_image = $VBoxContainer/LogoImage

func _ready():
	print("========================================")
	print("[BRAND SPLASH] ITTY BITTY BITES GAMES")
	print("[BOOT] Boot Screen Active. Masking Engine Initialization.")
	print("========================================")
	status_label.text = "INITIALIZING CORTEX..."
	progress_bar.value = 10
	
	var moods = [
		Color("#00D4FF"), # Cyan (Analytical)
		Color("#2ECC71"), # Green (Organic)
		Color("#F72585"), # Magenta (Creative)
		Color("#FFBC42"), # Orange (Frontier)
		Color("#D81159")  # Crimson (Hostile)
	]
	var today_mood = moods[randi() % moods.size()]
	
	if logo_label: logo_label.add_theme_color_override("font_color", today_mood)
	if progress_bar: progress_bar.modulate = today_mood
	
	await get_tree().process_frame
	
	var sync_mgr = GitHubSyncManager if GitHubSyncManager else get_tree().root.get_node_or_null("GitHubSyncManager")
	if sync_mgr:
		status_label.text = "SYNCHRONIZING MANIFEST..."
		progress_bar.value = 40
		sync_mgr.sync_cycle()
		var sync_status = await sync_mgr.sync_completed
		if sync_status == "success":
			status_label.text = "PATCH APPLIED."
		else:
			status_label.text = "OFFLINE MODE ACTIVE."
	else:
		status_label.text = "SYNC MANAGER OFFLINE."
	
	progress_bar.value = 80
	
	var loader = ContentLoader if ContentLoader else get_tree().root.get_node_or_null("ContentLoader")
	if loader:
		status_label.text = "INDEXING NEURAL PATHWAYS..."
		await get_tree().create_timer(0.5).timeout
		
	progress_bar.value = 100
	status_label.text = "SYSTEM READY."
	
	var goodwill = GoodwillManager if GoodwillManager else get_tree().root.get_node_or_null("GoodwillManager")
	if goodwill: goodwill.evaluate_boot_grace()
	
	await get_tree().create_timer(0.5).timeout
	var tween = get_tree().create_tween()
	if tween:
		tween.tween_property(self, "modulate:a", 0.0, 0.5)
		tween.tween_callback(func():
			boot_completed.emit()
			queue_free()
		)
