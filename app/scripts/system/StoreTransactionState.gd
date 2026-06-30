extends Node
class_name StoreTransactionState

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness (Liquid Memory V2)
# STORE TRANSACTION STATE MACHINE & ENTITLEMENT RECONCILIATION
# ---------------------------------------------------------

enum TxState {
	IDLE,
	REQUESTING_PURCHASE,
	PURCHASE_PENDING_GOOGLE,
	PURCHASE_RECEIVED_CALLBACK,
	VALIDATING,
	GRANTING_ENTITLEMENT
}

const STATE_PATH = "user://store_state.json"

var current_state: int = TxState.IDLE
var pending_transactions: Dictionary = {} 
var processed_orders: Dictionary = {}

func _ready():
	print("[TRANSACTION STATE] Online. Initializing event-driven commerce state machine...")
	_load_and_reconcile_state()

func request_purchase(product_id: String) -> String:
	var order_id = "GPA.3312-7798-2510-" + str(Time.get_ticks_usec()).substr(0, 5)
	print("[TRANSACTION STATE] Explicit state transition: IDLE -> REQUESTING_PURCHASE for product: ", product_id)
	_transition_state(order_id, product_id, TxState.REQUESTING_PURCHASE)
	return order_id

func on_purchase_dispatched(order_id: String):
	if pending_transactions.has(order_id):
		print("[TRANSACTION STATE] State transition: REQUESTING_PURCHASE -> PURCHASE_PENDING_GOOGLE for Order: ", order_id)
		_transition_state(order_id, pending_transactions[order_id]["product_id"], TxState.PURCHASE_PENDING_GOOGLE)

func on_callback_received(order_id: String, product_id: String, purchase_token: String = ""):
	print("[TRANSACTION STATE] State transition: PURCHASE_PENDING_GOOGLE -> PURCHASE_RECEIVED_CALLBACK for Order: ", order_id)
	_transition_state(order_id, product_id, TxState.PURCHASE_RECEIVED_CALLBACK)
	
	print("[TRANSACTION STATE] State transition: PURCHASE_RECEIVED_CALLBACK -> VALIDATING...")
	_transition_state(order_id, product_id, TxState.VALIDATING)
	
	if processed_orders.has(order_id):
		print("[TRANSACTION STATE GUARD] Duplicate callback received for previously processed Order: ", order_id, ". Suppressing double entitlement grant.")
		_transition_state(order_id, product_id, TxState.IDLE)
		return
		
	print("[TRANSACTION STATE] State transition: VALIDATING -> GRANTING_ENTITLEMENT...")
	_transition_state(order_id, product_id, TxState.GRANTING_ENTITLEMENT)
	
	processed_orders[order_id] = true
	var profile = get_node_or_null("/root/PlayerProfile")
	if profile and profile.has_method("record_purchase_receipt"):
		profile.record_purchase_receipt({
			"item_id": product_id,
			"transaction_id": order_id,
			"timestamp": int(Time.get_unix_time_from_system()),
			"acknowledged": true
		})
	elif profile:
		if product_id == "directors_pass": profile.has_directors_pass = true
		elif product_id.begins_with("universe_unlock_"):
			var uni = product_id.replace("universe_unlock_", "")
			if not profile.unlocked_universes.has(uni): profile.unlocked_universes.append(uni)
		profile.save_profile()
		
	print("[TRANSACTION STATE] Entitlement granted successfully. State transition: GRANTING_ENTITLEMENT -> IDLE.")
	_transition_state(order_id, product_id, TxState.IDLE)

func _transition_state(order_id: String, product_id: String, state: int):
	current_state = state
	if state == TxState.IDLE:
		if pending_transactions.has(order_id): pending_transactions.erase(order_id)
	else:
		pending_transactions[order_id] = {
			"product_id": product_id,
			"state": state,
			"timestamp": int(Time.get_unix_time_from_system())
		}
	_save_state()

func _load_and_reconcile_state():
	if FileAccess.file_exists(STATE_PATH):
		var file = FileAccess.open(STATE_PATH, FileAccess.READ)
		if file:
			var json = JSON.new()
			if json.parse(file.get_as_text()) == OK:
				var data = json.get_data()
				if typeof(data) == TYPE_DICTIONARY:
					pending_transactions = data.get("pending_transactions", {})
					processed_orders = data.get("processed_orders", {})
			file.close()
			
	print("[TRANSACTION STATE] Reconciling pending transactions on boot (Pending: ", pending_transactions.size(), ")...")
	for order_id in pending_transactions.keys():
		var tx = pending_transactions[order_id]
		print("[TRANSACTION STATE RECOVERY] Recovering interrupted transaction: ", order_id, " (State: ", tx["state"], ")")
		if tx["state"] >= TxState.PURCHASE_PENDING_GOOGLE:
			on_callback_received(order_id, tx["product_id"])

func _save_state():
	var save_dict = {
		"pending_transactions": pending_transactions,
		"processed_orders": processed_orders
	}
	var file = FileAccess.open(STATE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_dict, "\t"))
		file.close()
