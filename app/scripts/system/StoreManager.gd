extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# STORE & MONETIZATION MANAGER
# ---------------------------------------------------------

signal purchase_completed(item_id: String)
signal purchase_failed(reason: String)

# Legacy Product Mapping
const PRODUCT_DIRECTORS_PASS = "directors_pass" # $7.99
const PRODUCT_UNIVERSE_UNLOCK = "universe_unlock_" # $2.99 per universe

func _ready():
	BootTracer.log_init("StoreManager")
	print("[STORE MANAGER] Online. Mocking App Store APIs.")

func initiate_purchase(item_id: String):
	print("[STORE MANAGER] Initiating purchase flow for: ", item_id)
	
	# Simulate network delay for store popup
	await get_tree().create_timer(1.0).timeout
	
	# In production: Await GodotBilling or GooglePlayBilling API callback here.
	_on_purchase_success(item_id)

func _on_purchase_success(item_id: String):
	print("[STORE MANAGER] Purchase Successful: ", item_id)
	
	var profile = get_node_or_null("/root/PlayerProfile")
	if profile:
		if item_id == PRODUCT_DIRECTORS_PASS:
			profile.has_directors_pass = true
		elif item_id.begins_with(PRODUCT_UNIVERSE_UNLOCK):
			var uni = item_id.replace(PRODUCT_UNIVERSE_UNLOCK, "")
			if not profile.unlocked_universes.has(uni):
				profile.unlocked_universes.append(uni)
				
		profile.save_profile()
		
	purchase_completed.emit(item_id)
