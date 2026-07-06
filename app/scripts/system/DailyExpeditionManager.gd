extends Node

# ---------------------------------------------------------
# DAILY EXPEDITION MANAGER
# ---------------------------------------------------------
# Deterministic daily world selection using calendar date as seed.
# Fully offline, device-independent, no server dependency.
#
# Each day selects 5 worlds from published universes using a
# seeded shuffle. Same date = same expedition on every device.
# ---------------------------------------------------------

signal expedition_generated(worlds: Array)
signal expedition_progress_updated(completed: int, total: int)

const EXPEDITION_SIZE := 5

var current_day_seed: int = 0
var current_expedition: Array = []  # Array of {universe_id, world_id}
var completed_worlds_today: Dictionary = {}  # key: "u/w" -> true
var expeditions_completed: int = 0
var daily_streak: int = 0
var last_completion_date: String = ""

func _ready():
	if BootTracer: BootTracer.log_init("DailyExpeditionManager")
	print("[DAILY EXPEDITION] Online. Computing today's expedition.")
	_load_expedition_state()
	_generate_if_needed()

func _compute_day_id() -> int:
	var d = Time.get_date_dict_from_system()
	return d["year"] * 10000 + d["month"] * 100 + d["day"]

func _compute_day_string() -> String:
	var d = Time.get_date_dict_from_system()
	return "%04d-%02d-%02d" % [d["year"], d["month"], d["day"]]

func _generate_if_needed():
	var today_id = _compute_day_id()
	if today_id == current_day_seed and not current_expedition.is_empty():
		return  # Already generated for today

	current_day_seed = today_id
	var today_str = _compute_day_string()

	# Check if the day changed — reset completion
	if today_str != last_completion_date:
		completed_worlds_today.clear()

	# Build pool from ALL universes with content (not just playable — scaffolded have content too)
	var pool: Array = []
	var reg = ContentRegistry if ContentRegistry else Engine.get_main_loop().root.get_node_or_null("ContentRegistry")
	if not reg:
		print("[DAILY EXPEDITION] No ContentRegistry — empty expedition.")
		return

	for u_id in reg.get_all_universes():
		for w_id in reg.get_all_worlds_in_universe(u_id):
			var count = reg.get_all_scenarios_in_world(u_id, w_id).size()
			if count > 0:
				pool.append({"universe_id": u_id, "world_id": w_id})

	if pool.is_empty():
		print("[DAILY EXPEDITION] No worlds with content found.")
		return

	# Deterministic shuffle using day seed
	var rng = RandomNumberGenerator.new()
	rng.seed = today_id * 99991 + 7
	for i in range(pool.size() - 1, 0, -1):
		var j = rng.randi() % (i + 1)
		var tmp = pool[i]
		pool[i] = pool[j]
		pool[j] = tmp

	# Select EXPEDITION_SIZE worlds, preferring cross-universe diversity
	current_expedition.clear()
	var used_universes: Dictionary = {}
	for entry in pool:
		var u = str(entry["universe_id"])
		# Prefer worlds from different universes, but allow repeats if pool is small
		if used_universes.has(u) and used_universes.size() < len(pool):
			# Already have one from this universe, skip (unless pool is small)
			if current_expedition.size() < min(EXPEDITION_SIZE, pool.size()) and pool.size() > EXPEDITION_SIZE:
				continue
		current_expedition.append(entry)
		used_universes[u] = true
		if current_expedition.size() >= EXPEDITION_SIZE:
			break

	# If we still don't have enough (small pool), fill from remaining
	if current_expedition.size() < min(EXPEDITION_SIZE, pool.size()):
		for entry in pool:
			if current_expedition.size() >= min(EXPEDITION_SIZE, pool.size()):
				break
			if not current_expedition.has(entry):
				current_expedition.append(entry)

	print("[DAILY EXPEDITION] Expedition for ", today_str, " (", current_expedition.size(), " worlds):")
	for e in current_expedition:
		print("  - ", e["universe_id"], "/", e["world_id"])
	expedition_generated.emit(current_expedition)
	_save_expedition_state()

func get_expedition() -> Array:
	return current_expedition.duplicate(true)

func get_progress() -> Dictionary:
	return {
		"completed": completed_worlds_today.size(),
		"total": current_expedition.size(),
		"streak": daily_streak,
		"total_completed": expeditions_completed,
		"date": _compute_day_string()
	}

func mark_world_completed(universe_id: String, world_id: String):
	var key = universe_id + "/" + world_id
	if not completed_worlds_today.has(key):
		completed_worlds_today[key] = true
		print("[DAILY EXPEDITION] World completed: ", key, " (", completed_worlds_today.size(), "/", current_expedition.size(), ")")

		if completed_worlds_today.size() >= current_expedition.size():
			_complete_expedition()

		expedition_progress_updated.emit(completed_worlds_today.size(), current_expedition.size())
		_save_expedition_state()

func is_world_in_expedition(universe_id: String, world_id: String) -> bool:
	for e in current_expedition:
		if str(e["universe_id"]) == universe_id and str(e["world_id"]) == world_id:
			return true
	return false

func _complete_expedition():
	var today = _compute_day_string()
	if last_completion_date != today:
		# Check streak continuity (must have completed yesterday)
		var d = Time.get_date_dict_from_system()
		d["day"] -= 1
		var yesterday = Time.get_unix_time_from_system() - 86400
		var yd = Time.get_datetime_dict_from_unix_time(int(yesterday))
		var y_str = "%04d-%02d-%02d" % [yd["year"], yd["month"], yd["day"]]
		if last_completion_date == y_str:
			daily_streak += 1
		else:
			daily_streak = 1
		last_completion_date = today

	expeditions_completed += 1
	print("[DAILY EXPEDITION] Expedition COMPLETE! Streak: ", daily_streak, ", Total: ", expeditions_completed)

func _save_expedition_state():
	var save_path = "user://daily_expedition.json"
	var data = {
		"day_seed": current_day_seed,
		"expedition": current_expedition,
		"completed": completed_worlds_today.keys(),
		"expeditions_completed": expeditions_completed,
		"daily_streak": daily_streak,
		"last_completion_date": last_completion_date
	}
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))

func _load_expedition_state():
	var save_path = "user://daily_expedition.json"
	if not FileAccess.file_exists(save_path):
		return
	var file = FileAccess.open(save_path, FileAccess.READ)
	if not file:
		return
	var json = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return
	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		return
	current_day_seed = int(data.get("day_seed", 0))
	current_expedition = data.get("expedition", []) if data.get("expedition", []) is Array else []
	var comp_keys = data.get("completed", []) if data.get("completed", []) is Array else []
	for k in comp_keys:
		completed_worlds_today[str(k)] = true
	expeditions_completed = int(data.get("expeditions_completed", 0))
	daily_streak = int(data.get("daily_streak", 0))
	last_completion_date = str(data.get("last_completion_date", ""))
