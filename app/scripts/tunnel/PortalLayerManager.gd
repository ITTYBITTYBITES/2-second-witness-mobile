extends Node3D

var active_speed_multiplier: float = 1.0
var active_universe_id: String = "science_lab"

func _ready():
	# We no longer spawn the generic "initial_iris" here.
	# The LandingScreen / Router manages when the Cockpit Lens spawns.
	pass

func apply_theme(theme_data: Dictionary, universe_id: String = "science_lab"):
	active_universe_id = universe_id
	var tunnel = theme_data.get("tunnel", {})
	active_speed_multiplier = tunnel.get("speed_multiplier", 1.0)
	
	print("[TIER 3 - PORTALS] Interaction layer synchronized. Lens Identity updated to: ", universe_id)

func _process(_delta):
	var _forward_motion = active_speed_multiplier * _delta * 10.0
	for child in get_children():
		pass

func spawn_lens_portal(chunk_id: String):
	# The Iris is no longer a generic ring. It is the Cockpit Lens for the specific universe.
	var renderer = UniverseRenderer.new()
	var def = renderer.universe_definitions.get(active_universe_id, renderer.universe_definitions["science_lab"])
	
	print("[COCKPIT] Spawning world lens: ", def["lens_profile"])
	
	var lens = preload("res://scripts/portals/ScenarioNode.gd").new()
	lens.position = Vector3(0, 0, -20)
	
	# Pass the specific lens_profile so the ScenarioNode mounts the correct 3D .obj
	lens.setup(2, {"universe": active_universe_id, "world": "cognitive_bias", "chunk_id": chunk_id, "lens_profile": def["lens_profile"]})
	add_child(lens)
