extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# STORE & MONETIZATION MANAGER (EVENT LOGGING BASE)
# ---------------------------------------------------------

signal purchase_completed(item_id: String)
signal purchase_failed(reason: String)

const PRODUCT_DIRECTORS_PASS = "directors_pass" # $7.99
const PRODUCT_UNIVERSE_UNLOCK = "universe_unlock_" # $2.99 per universe

func _ready():
	BootTracer.log_init("StoreManager")
	print("[STORE MANAGER] Online. Mocking App Store APIs.")

func initiate_purchase(item_id: String):
	print("[STORE MANAGER] Initiating purchase flow for: ", item_id)
	await get_tree().create_timer(1.0).timeout
	_on_purchase_success(item_id)

func _on_purchase_success(item_id: String, transaction_id: String = "", custom_timestamp: int = 0):
	print("[STORE MANAGER] Purchase Event Logged: ", item_id, " (Tx: ", transaction_id, ")")
	
	var profile = get_node_or_null("/root/PlayerProfile")
	if profile and profile.has_method("record_purchase_receipt"):
		var tx = transaction_id if transaction_id != "" else str(Time.get_ticks_usec())
		var ts = custom_timestamp if custom_timestamp != 0 else int(Time.get_unix_time_from_system())
		profile.record_purchase_receipt({
			"item_id": item_id,
			"transaction_id": tx,
			"timestamp": ts,
			"acknowledged": true
		})
	elif profile:
		# Fallback legacy direct write if method not bound
		if item_id == PRODUCT_DIRECTORS_PASS:
			profile.has_directors_pass = true
		elif item_id.begins_with(PRODUCT_UNIVERSE_UNLOCK):
			var uni = item_id.replace(PRODUCT_UNIVERSE_UNLOCK, "")
			if not profile.unlocked_universes.has(uni):
				profile.unlocked_universes.append(uni)
		profile.save_profile()
		
	purchase_completed.emit(item_id)

func _on_purchase_failure(reason: String):
	print("[STORE MANAGER] Purchase Failed: ", reason)
	purchase_failed.emit(reason)
