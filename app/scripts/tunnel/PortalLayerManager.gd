extends Node3D

var active_speed_multiplier: float = 1.0
var active_universe_id: String = "science_lab"
var active_world_id: String = ""

func _ready():
	pass

func apply_theme(theme_data: Dictionary, universe_id: String = "", world_id: String = ""):
	if universe_id == "": universe_id = theme_data.get("id", "science_lab")
	active_universe_id = universe_id
	active_world_id = world_id
	var tunnel = theme_data.get("tunnel", {})
	active_speed_multiplier = tunnel.get("speed_multiplier", 1.0)
	
	print("[TIER 3 - PORTALS] Interaction layer synchronized. Lens Identity updated to: ", universe_id, " | ", world_id)

func _process(_delta):
	pass

func spawn_lens_portal(chunk_id: String):
	print("STEP 5: PORTAL SPAWN ENTERED")
	var renderer = UniverseRenderer.new()
	var def = renderer.universe_definitions.get(active_universe_id, renderer.universe_definitions["science_lab"])
	
	var lens = preload("res://scripts/portals/ScenarioNode.gd").new()
	lens.position = Vector3(0, 0, -20)
	
	var mastery_engine = LensMorphology
	var mastery_tier = mastery_engine.get_world_mastery(active_universe_id, active_world_id)
	
	var profile = def["lens_profile"] + "_tier_" + str(mastery_tier)
	
	print("[COCKPIT] Spawning world lens: ", profile)
	lens.setup(2, {"universe": active_universe_id, "world": active_world_id, "chunk_id": chunk_id, "lens_profile": profile})
	add_child(lens)
