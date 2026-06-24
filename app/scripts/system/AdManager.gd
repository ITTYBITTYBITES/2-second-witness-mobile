extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# ADVERTISEMENT CONTROLLER
# ---------------------------------------------------------

signal ad_finished

var ad_frequency: int = 3 # Show an ad every 3 scenario loops
var _loops_since_last_ad: int = 0

func _ready():
	print("[AD MANAGER] Online. Hooking into Navigation Loop.")
	NavigationEngine.navigation_event.connect(_on_loop_completed)

func _on_loop_completed(payload: Dictionary):
	_loops_since_last_ad += 1

func check_and_show_ad() -> bool:
	var profile = get_node_or_null("/root/PlayerProfile")
	
	if profile and profile.has_directors_pass:
		return false
		
	if _loops_since_last_ad >= ad_frequency:
		
		# 1. Check if the Arcade Operator wants to step in (The Grace Mechanic)
		if GoodwillManager.evaluate_random_grace():
			_loops_since_last_ad = 0
			# Wait for the Operator Intervention UI to finish before returning control
			await get_tree().create_timer(3.0).timeout 
			return true
			
		# 2. Check if the player already has tokens from a previous Operator visit
		if GoodwillManager.consume_ad_skip():
			print("[AD MANAGER] Override Token used. Bypassing Ad.")
			_loops_since_last_ad = 0
			return false
			
		# 3. Otherwise, show the Ad
		print("[AD MANAGER] Triggering Interstitial Ad...")
		_show_dummy_ad()
		_loops_since_last_ad = 0
		return true
		
	return false

func _show_dummy_ad():
	var ad_layer = CanvasLayer.new()
	ad_layer.layer = 110
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.9)
	ad_layer.add_child(bg)
	var lbl = Label.new()
	lbl.text = "[ INCOMING TRANSMISSION INTERCEPTED ]\n[ ESTABLISHING AD LINK ]"
	lbl.add_theme_font_size_override("font_size", 32)
	lbl.set_anchors_preset(Control.PRESET_CENTER)
	ad_layer.add_child(lbl)
	get_tree().root.add_child(ad_layer)
	
	await get_tree().create_timer(3.0).timeout
	
	ad_layer.queue_free()
	print("[AD MANAGER] Ad completed. Returning to game.")
	ad_finished.emit()
