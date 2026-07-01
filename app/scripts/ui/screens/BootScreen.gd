extends CanvasLayer

# @warning_ignore("unused_signal")
signal boot_completed

@onready var status_label = $VBoxContainer/StatusLabel
@onready var progress_bar = $VBoxContainer/ProgressBar
@onready var logo_label = $VBoxContainer/LogoLabel
@onready var brand_label = $VBoxContainer/BrandLabel
@onready var scan_line = $ColorRect/ScanLine
@onready var failure_panel = $FailurePanel
@onready var btn_retry = $FailurePanel/VBoxContainer/HBoxContainer/BtnRetry
@onready var btn_reset = $FailurePanel/VBoxContainer/HBoxContainer/BtnReset
@onready var btn_exit = $FailurePanel/VBoxContainer/HBoxContainer/BtnExit

var _state_machine: BootStateMachine = null

func _ready():
	print("========================================")
	print("[BRAND SPLASH] ITTY BITTY BITES GAMES")
	print("[BOOT] Boot Screen Active. Masking Engine Initialization.")
	print("========================================")
	if status_label: status_label.text = "Preparing Observation..."
	if progress_bar: progress_bar.value = 10
	
	var bg = get_node_or_null("ColorRect")
	if bg and bg is ColorRect:
		bg.color.a = 0.15 # Ensure persistent animated TunnelLayer remains visible as outermost frame behind boot sequence
	
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
	
	_start_scan_line_animation()
	
	if btn_retry: btn_retry.pressed.connect(_on_retry_pressed)
	if btn_reset: btn_reset.pressed.connect(_on_reset_pressed)
	if btn_exit: btn_exit.pressed.connect(_on_exit_pressed)

func bind_state_machine(sm: BootStateMachine):
	_state_machine = sm
	_state_machine.state_changed.connect(_on_boot_state_changed)

func _on_boot_state_changed(_state: int, progress: float, message: String):
	if status_label: status_label.text = message
	if progress_bar: progress_bar.value = progress

func show_failure_dialog(reason: String):
	if failure_panel:
		failure_panel.visible = true
		var msg = failure_panel.get_node_or_null("VBoxContainer/Message")
		if msg: msg.text = "We encountered a brief interruption while preparing your session: " + reason + ".\n\nChoose an action below to continue."

func _on_retry_pressed():
	if AudioManager: AudioManager.play_sfx("ui_click")
	if failure_panel: failure_panel.visible = false
	if _state_machine and _state_machine.get_parent() and _state_machine.get_parent().has_method("_execute_fast_boot"):
		_state_machine.get_parent()._execute_fast_boot()

func _on_reset_pressed():
	if AudioManager: AudioManager.play_sfx("ui_click")
	print("[BOOT RECOVERY] Resetting local cache...")
	var dir = DirAccess.open("user://live_content/")
	if dir:
		dir.remove("manifest.json")
		print("[BOOT RECOVERY] Local manifest cache cleared.")
	_on_retry_pressed()

func _on_exit_pressed():
	if AudioManager: AudioManager.play_sfx("ui_click")
	get_tree().quit()

func _start_scan_line_animation():
	if not is_instance_valid(scan_line): return
	var viewport_height = get_viewport().get_visible_rect().size.y
	if viewport_height <= 0: viewport_height = 648.0
	scan_line.position.y = 0.0
	var tween = get_tree().create_tween().set_loops()
	tween.tween_property(scan_line, "position:y", viewport_height, 2.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(scan_line, "position:y", 0.0, 0.01) # Explicit non-zero duration reset step

func complete_boot():
	boot_completed.emit()
