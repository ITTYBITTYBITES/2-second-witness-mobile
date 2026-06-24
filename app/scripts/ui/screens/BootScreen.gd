extends CanvasLayer

signal boot_completed

@onready var status_label = $VBoxContainer/StatusLabel
@onready var progress_bar = $VBoxContainer/ProgressBar

func _ready():
	# 1. Lock the World
	print("[BOOT] Boot Screen Active. Masking Engine Initialization.")
	status_label.text = "INITIALIZING CORTEX..."
	progress_bar.value = 10
	
	# Wait one frame for UI to render
	await get_tree().process_frame
	
	# 2. Trigger the GitHub Sync Manager
	if GitHubSyncManager:
		status_label.text = "SYNCHRONIZING MANIFEST..."
		progress_bar.value = 40
		GitHubSyncManager.sync_cycle()
		
		# Wait for the sync to finish (either success or failure)
		var sync_status = await GitHubSyncManager.sync_completed
		if sync_status == "success":
			status_label.text = "PATCH APPLIED."
		else:
			status_label.text = "OFFLINE MODE ACTIVE."
	else:
		status_label.text = "SYNC MANAGER OFFLINE."
	
	progress_bar.value = 80
	
	# 3. Trigger Content Loader (Now that we know we have the latest files)
	if ContentLoader:
		status_label.text = "INDEXING NEURAL PATHWAYS..."
		# Assuming ContentLoader parses instantly, but we add a visual delay for UX pacing
		await get_tree().create_timer(0.5).timeout
		
	progress_bar.value = 100
	status_label.text = "SYSTEM READY."
	
	# 4. Handoff to MainShell
	await get_tree().create_timer(0.5).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func():
		boot_completed.emit()
		queue_free()
	)
