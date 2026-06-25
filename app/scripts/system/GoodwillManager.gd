extends Node

const SAVE_PATH = "user://grace.save"
const SAVE_SCHEMA_VERSION = 1

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

func evaluate_boot_grace():
	var current_time = Time.get_unix_time_from_system()
	if current_time - last_grace_timestamp < 259200:
		return
		
	if randf() > 0.95:
		print("[GOODWILL MANAGER] Random Grace Triggered on Boot! Dispensing tokens.")
		_trigger_grace_event()

func _trigger_grace_event():
	last_grace_timestamp = int(Time.get_unix_time_from_system())
	ad_skips_inventory += 3
	_save_goodwill_state()
	
	var grace_scene = preload("res://scenes/ui/screens/OperatorIntervention.tscn")
	var grace = grace_scene.instantiate()
	get_tree().root.add_child(grace)

func _load_goodwill_state():
	if not FileAccess.file_exists(SAVE_PATH): return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			var data = json.get_data()
			if typeof(data) == TYPE_DICTIONARY and data.get("schema_version", 0) == SAVE_SCHEMA_VERSION:
				ad_skips_inventory = data.get("ad_skips_inventory", 0)
				last_grace_timestamp = data.get("last_grace_timestamp", 0)
		file.close()

func _save_goodwill_state():
	var save_dict = {
		"schema_version": SAVE_SCHEMA_VERSION,
		"ad_skips_inventory": ad_skips_inventory,
		"last_grace_timestamp": last_grace_timestamp
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_dict, "\t"))
		file.close()
