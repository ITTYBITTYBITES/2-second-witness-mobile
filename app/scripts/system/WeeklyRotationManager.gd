extends Node
class_name WeeklyRotationManagerNode

signal rotation_refreshed(active_universes: Array[String], current_seed: int)

# Full Universe Library (7 available universes in repository)
const FULL_UNIVERSE_LIBRARY: Array[String] = [
	"science_lab",
	"history",
	"tech_ops",
	"life_sciences",
	"society_mind",
	"creative_arts",
	"frontier"
]

const ACTIVE_SUBSET_SIZE: int = 6

var current_week_seed: int = 0
var active_universes: Array[String] = []
var _last_checked_week_id: int = -1

func _ready():
	if BootTracer: BootTracer.log_init("WeeklyRotationManager")
	print("[WEEKLY ROTATION] Online. Governing deterministic weekly content subset.")
	refresh_weekly_rotation(false)

func get_active_universes() -> Array[String]:
	_check_cycle_boundary()
	return active_universes

func is_universe_active(u_id: String) -> bool:
	_check_cycle_boundary()
	return active_universes.has(u_id)

func get_current_seed() -> int:
	_check_cycle_boundary()
	return current_week_seed

func get_full_universe_library() -> Array:
	var reg = Engine.get_main_loop().root.get_node_or_null("ContentRegistry")
	if reg and reg.has_method("get_all_universes"):
		var u_list = reg.get_all_universes()
		if not u_list.is_empty():
			return u_list
	return FULL_UNIVERSE_LIBRARY.duplicate()

func refresh_weekly_rotation(force_refresh: bool = false):
	var week_id = _compute_current_week_id()
	if week_id == _last_checked_week_id and not force_refresh and not active_universes.is_empty():
		return
		
	_last_checked_week_id = week_id
	current_week_seed = week_id * 77777 + 2026
	
	print("[WEEKLY ROTATION] Cycle boundary reached or initialized. Computing active subset for Week ID: ", week_id, " (Seed: ", current_week_seed, ")")
	
	var pool = get_full_universe_library()
	
	# Deterministic selection without mutating global RNG
	var rng = RandomNumberGenerator.new()
	rng.seed = current_week_seed
	
	# Fisher-Yates shuffle using deterministic RNG
	for i in range(pool.size() - 1, 0, -1):
		var j = rng.randi() % (i + 1)
		var tmp = pool[i]
		pool[i] = pool[j]
		pool[j] = tmp
		
	active_universes.clear()
	for i in range(min(ACTIVE_SUBSET_SIZE, pool.size())):
		active_universes.append(pool[i])
		
	print("[WEEKLY ROTATION] Active 6 Universes Locked for Week: ", active_universes)
	rotation_refreshed.emit(active_universes, current_week_seed)

func _check_cycle_boundary():
	var cur_week_id = _compute_current_week_id()
	if cur_week_id != _last_checked_week_id:
		refresh_weekly_rotation(true)

func _compute_current_week_id() -> int:
	# Compute exact 7-day weekly epoch cycle ID (604800 seconds per week)
	var now_sec = int(Time.get_unix_time_from_system())
	return int(float(now_sec) / 604800.0)
