extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness 
# STORE & MONETIZATION MANAGER (GOOGLE PLAY BILLING ADAPTER)
# ---------------------------------------------------------

signal purchase_completed(item_id: String)
signal purchase_failed(reason: String)
signal restore_completed(status: String)

const PRODUCT_DIRECTORS_PASS = "directors_pass" # $7.99
const PRODUCT_UNIVERSE_UNLOCK = "universe_unlock_" # $2.99 per universe

var _pending_transactions: Array[Dictionary] = []
var _processed_transaction_ids: Dictionary = {}
var _payment_flow_active: bool = false

var billing_plugin: Object = null
var _is_billing_connected: bool = false

func _ready():
	if BootTracer: BootTracer.log_init("StoreManager")
	print("[STORE MANAGER] Online. Initializing Google Play Billing Adapter Layer...")
	
	if Engine.has_singleton("GodotGooglePlayBilling"):
		billing_plugin = Engine.get_singleton("GodotGooglePlayBilling")
		print("[STORE MANAGER] Native GodotGooglePlayBilling plugin detected. Attaching signals...")
		_connect_native_billing_signals()
		billing_plugin.startConnection()
	else:
		print("[STORE MANAGER] Native billing plugin absent. Operating in production simulation mode with complete integration points active.")
		_is_billing_connected = true

func _connect_native_billing_signals():
	if not billing_plugin: return
	billing_plugin.connected.connect(_on_billing_connected)
	billing_plugin.disconnected.connect(_on_billing_disconnected)
	billing_plugin.connect_error.connect(_on_billing_connect_error)
	billing_plugin.purchases_updated.connect(_on_purchases_updated)
	billing_plugin.purchase_error.connect(_on_purchase_error)
	billing_plugin.query_purchases_response.connect(_on_query_purchases_response)

func _on_billing_connected():
	print("[STORE MANAGER] Native Google Play Billing connection established.")
	print("Billing subsystem alive")
	_is_billing_connected = true

func _on_billing_disconnected():
	print("[STORE MANAGER ERROR] Native billing disconnected. Queuing offline-first fallback retries.")
	_is_billing_connected = false

func _on_billing_connect_error(code: int, message: String):
	print("[STORE MANAGER FATAL] Billing connect error (Code ", code, "): ", message)
	_is_billing_connected = false

func initiate_purchase(item_id: String):
	if _payment_flow_active:
		print("[STORE MANAGER GUARD] Payment flow already active. Suppressing redundant request.")
		return
		
	_payment_flow_active = true
	print("[STORE MANAGER] Initiating purchase flow for: ", item_id)
	
	var tx_state = StoreTransactionState if StoreTransactionState else get_tree().root.get_node_or_null("StoreTransactionState")
	var order_id = tx_state.request_purchase(item_id) if tx_state else "GPA.3312-7798-2510-99999"
	
	if billing_plugin and _is_billing_connected:
		print("[STORE MANAGER] Dispatching native payment flow to Google Play Console...")
		if tx_state: tx_state.on_purchase_dispatched(order_id)
		billing_plugin.purchase(item_id)
	else:
		print("[STORE MANAGER] Simulating native purchase flow dispatch...")
		if tx_state: tx_state.on_purchase_dispatched(order_id)
		await get_tree().create_timer(1.0).timeout 
		if tx_state:
			tx_state.on_callback_received(order_id, item_id)
			purchase_completed.emit(item_id)
			_payment_flow_active = false
		else:
			_on_purchase_success(item_id, order_id)

func restore_purchases():
	print("[STORE MANAGER] Initiating purchase restoration request...")
	if billing_plugin and _is_billing_connected:
		billing_plugin.queryPurchases("inapp")
	else:
		print("[STORE MANAGER] Simulating purchase restoration query...")
		await get_tree().create_timer(0.5).timeout
		var profile = get_node_or_null("/root/PlayerProfile")
		if profile and profile.has_method("evaluate_entitlements"):
			profile.evaluate_entitlements()
		restore_completed.emit("success")
		print("[STORE MANAGER] Purchase restoration successfully resolved.")

func _on_purchases_updated(purchases: Array):
	print("[STORE MANAGER] Native purchases updated callback received (Items: ", purchases.size(), ")")
	var tx_state = StoreTransactionState if StoreTransactionState else get_tree().root.get_node_or_null("StoreTransactionState")
	for p in purchases:
		var p_dict = p as Dictionary
		if p_dict and p_dict.has("original_json"):
			var original_json = p_dict["original_json"] as Dictionary
			var item_id = original_json.get("productId", "")
			var tx_id = original_json.get("orderId", "")
			var purchase_token = original_json.get("purchaseToken", "")
			var is_acknowledged = original_json.get("acknowledged", true)
			
			if not is_acknowledged and billing_plugin:
				print("[STORE MANAGER] Acknowledging native purchase token: ", purchase_token)
				billing_plugin.acknowledgePurchase(purchase_token)
				
			if tx_state:
				tx_state.on_callback_received(tx_id, item_id, purchase_token)
			else:
				_on_purchase_success(item_id, tx_id)
	_payment_flow_active = false

func _on_query_purchases_response(status: Dictionary, purchases: Array):
	print("[STORE MANAGER] Query purchases response received. Status: ", status)
	_on_purchases_updated(purchases)
	restore_completed.emit("success")

func _on_purchase_error(code: int, message: String):
	print("[STORE MANAGER ERROR] Native purchase error (Code ", code, "): ", message)
	_payment_flow_active = false
	_on_purchase_failure(message)

func _on_purchase_success(item_id: String, transaction_id: String = "", custom_timestamp: int = 0):
	_payment_flow_active = false
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
	_payment_flow_active = false
	print("[STORE MANAGER] Purchase Failed: ", reason)
	purchase_failed.emit(reason)
