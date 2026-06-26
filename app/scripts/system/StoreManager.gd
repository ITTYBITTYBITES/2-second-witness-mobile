extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# STORE & MONETIZATION MANAGER (EVENT LOGGING BASE)
# ---------------------------------------------------------

signal purchase_completed(item_id: String)
signal purchase_failed(reason: String)

const PRODUCT_DIRECTORS_PASS = "directors_pass" # $7.99
const PRODUCT_UNIVERSE_UNLOCK = "universe_unlock_" # $2.99 per universe

var _pending_transactions: Array[Dictionary] = []
var _processed_transaction_ids: Dictionary = {}

func _ready():
	if BootTracer: BootTracer.log_init("StoreManager")
	print("[STORE MANAGER] Online. Mocking App Store APIs.")

func initiate_purchase(item_id: String):
	print("[STORE MANAGER] Initiating purchase flow for: ", item_id)
	await get_tree().create_timer(1.0).timeout
	var mock_tx = "GPA.3312-7798-2510-" + str(Time.get_ticks_usec()).substr(0, 5)
	_on_purchase_success(item_id, mock_tx)

func _on_purchase_success(item_id: String, transaction_id: String = "", custom_timestamp: int = 0):
	if transaction_id == "":
		print("[STORE MANAGER REJECTION] Rejected purchase event for '", item_id, "'. Transaction ID is empty. Queuing until valid Tx identity is established.")
		_pending_transactions.append({"item_id": item_id, "custom_timestamp": custom_timestamp})
		return
		
	if _processed_transaction_ids.has(transaction_id):
		print("[STORE MANAGER REJECTION] Suppressed duplicate transaction injection for Tx: ", transaction_id)
		return
		
	_processed_transaction_ids[transaction_id] = true
	print("[STORE MANAGER] Purchase Event Logged: ", item_id, " (Tx: ", transaction_id, ")")
	
	var profile = get_node_or_null("/root/PlayerProfile")
	if profile and profile.has_method("record_purchase_receipt"):
		var ts = custom_timestamp if custom_timestamp != 0 else int(Time.get_unix_time_from_system())
		profile.record_purchase_receipt({
			"item_id": item_id,
			"transaction_id": transaction_id,
			"timestamp": ts,
			"acknowledged": true
		})
	elif profile:
		if item_id == PRODUCT_DIRECTORS_PASS:
			profile.has_directors_pass = true
		elif item_id.begins_with(PRODUCT_UNIVERSE_UNLOCK):
			var uni = item_id.replace(PRODUCT_UNIVERSE_UNLOCK, "")
			if not profile.unlocked_universes.has(uni):
				profile.unlocked_universes.append(uni)
		profile.save_profile()
		
	purchase_completed.emit(item_id)

func resolve_pending_transaction(transaction_id: String):
	if not _pending_transactions.is_empty():
		var tx = _pending_transactions.pop_front()
		print("[STORE MANAGER] Resolving queued purchase event '", tx["item_id"], "' with assigned Tx: ", transaction_id)
		_on_purchase_success(tx["item_id"], transaction_id, tx["custom_timestamp"])

func _on_purchase_failure(reason: String):
	print("[STORE MANAGER] Purchase Failed: ", reason)
	purchase_failed.emit(reason)
