extends Node
# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# FEEDBACK MANAGER (GOLD STANDARD PRESENTATION LAYER)
# ---------------------------------------------------------
# Handles all high-level visual and auditory feedback:
# Success Flashes, Failure Shakes, and Transition Effects.
# ---------------------------------------------------------

signal feedback_triggered(type: String)

func _ready():
	if BootTracer: BootTracer.log_init("FeedbackManager")
	print("[FEEDBACK MANAGER] Online. Managing gold-standard presentation layers.")

## Triggers a visual and haptic "Success" event.
func trigger_success():
	print("[FEEDBACK] Triggering SUCCESS presentation.")
	feedback_triggered.emit("success")
	_play_visual_flash(Color(0.2, 1.0, 0.4, 0.3))
	if AudioManager: AudioManager.play_sfx("ui_click")
	_trigger_haptic("light")

## Triggers a visual and haptic "Failure" event.
func trigger_failure():
	print("[FEEDBACK] Triggering FAILURE presentation.")
	feedback_triggered.emit("failure")
	_play_visual_flash(Color(1.0, 0.2, 0.2, 0.3))
	if AudioManager: AudioManager.play_sfx("ui_error")
	_trigger_haptic("heavy")
	_trigger_screen_shake()

func _play_visual_flash(color: Color):
	var overlay = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = color
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var ui_layer = get_tree().root.get_node_or_null("MainShell/UILayer")
	if ui_layer:
		ui_layer.add_child(overlay)
		
		var tween = get_tree().create_tween()
		tween.tween_property(overlay, "modulate:a", 0.0, 0.4)
		tween.finished.connect(func(): overlay.queue_free())

func _trigger_screen_shake():
	var camera = get_viewport().get_camera_3d()
	if camera:
		var shake_intensity = 5.0
		var shake_duration = 0.2
		var elapsed = 0.0
		
		while elapsed < shake_duration:
			var offset = Vector3(randf_range(-1, 1), randf_range(-1, 1), 0) * shake_intensity * 0.01
			camera.h_offset = offset.x
			camera.v_offset = offset.y
			await get_tree().create_timer(0.01).timeout
			elapsed += 0.01
		
		camera.h_offset = 0
		camera.v_offset = 0

func _trigger_haptic(type: String):
	# Godot 4 exposes handheld vibration as Input.vibrate_handheld().
	# Use call() so desktop/editor runs and older platform exports fail safely.
	var duration_ms = 50 if type == "light" else 150
	if Input.has_method("vibrate_handheld"):
		Input.call("vibrate_handheld", duration_ms)
