extends Node
class_name GoodwillManager

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# THE ARCADE OPERATOR'S GRACE
# ---------------------------------------------------------

var ad_skips_inventory: int = 0
var last_grace_timestamp: int = 0

func _ready():
	print("[GOODWILL MANAGER] Online. Watching the floor.")
	_load_goodwill_state()

func consume_ad_skip() -> bool:
	if ad_skips_inventory > 0:
		ad_skips_inventory -= 1
		print("[GOODWILL MANAGER] Ad skip consumed. Remaining: ", ad_skips_inventory)
		_save_goodwill_state()
		return true
	return false

func evaluate_random_grace() -> bool:
	var current_time = Time.get_unix_time_from_system()
	
	# Prevent it from happening constantly. Must be at least 3 days since the last time.
	if current_time - last_grace_timestamp < 259200:
		return false
		
	# Purely random chance when they die (e.g., ~2% chance to trigger instead of an ad)
	# This ensures it is NEVER predictable. They can never "farm" it.
	if randf() > 0.98:
		print("[GOODWILL MANAGER] Random Grace Triggered! Dispensing tokens.")
		_trigger_grace_event()
		return true
		
	return false

func _trigger_grace_event():
	last_grace_timestamp = Time.get_unix_time_from_system()
	
	# Grant the 3 Override Tokens
	ad_skips_inventory += 3
	_save_goodwill_state()
	
	# Throw the immersive UI modal over the screen
	var grace_scene = preload("res://scenes/ui/screens/OperatorIntervention.tscn")
	var grace = grace_scene.instantiate()
	get_tree().root.add_child(grace)

func _load_goodwill_state():
	pass

func _save_goodwill_state():
	pass
