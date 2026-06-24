extends Node
class_name GoodwillManager

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# THE ARCADE OPERATOR'S GRACE
# ---------------------------------------------------------

signal grace_event_triggered(message: String)

var ad_skips_inventory: int = 0
var total_ads_watched_lifetime: int = 0
var last_grace_timestamp: int = 0

func _ready():
	print("[GOODWILL MANAGER] Online. Watching the floor.")
	_load_goodwill_state()

func record_ad_watched():
	total_ads_watched_lifetime += 1
	_evaluate_grace_condition()

func consume_ad_skip() -> bool:
	if ad_skips_inventory > 0:
		ad_skips_inventory -= 1
		print("[GOODWILL MANAGER] Ad skip consumed. Remaining: ", ad_skips_inventory)
		_save_goodwill_state()
		return true
	return false

func _evaluate_grace_condition():
	var current_time = Time.get_unix_time_from_system()
	
	# Prevent spamming grace events (e.g., minimum 7 days between events)
	if current_time - last_grace_timestamp < 604800:
		return
		
	# The Trigger: If a free player has diligently watched a lot of ads, reward them.
	# We use a slight randomized threshold so it doesn't feel like a predictable "loyalty card".
	# It should feel like the operator just walked by and noticed them.
	var threshold = 15 + (randi() % 10) 
	
	if total_ads_watched_lifetime >= threshold:
		print("[GOODWILL MANAGER] Loyalty detected. Dispensing Grace.")
		_trigger_grace_event()

func _trigger_grace_event():
	# Reset counter and update timestamp
	total_ads_watched_lifetime = 0
	last_grace_timestamp = Time.get_unix_time_from_system()
	
	# Grant 3 Free Ad Skips
	ad_skips_inventory += 3
	_save_goodwill_state()
	
	# The message delivered to the UI
	var message = "SYSTEM ANOMALY. OPERATOR INTERVENTION.\n\nThank you for your time in the stream.\n[ 3 Override Tokens Granted ]"
	grace_event_triggered.emit(message)

func _load_goodwill_state():
	# In production: Read from secure profile save
	pass

func _save_goodwill_state():
	# In production: Write to disk
	pass
