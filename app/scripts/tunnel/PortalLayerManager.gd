extends Node3D

var active_speed_multiplier: float = 1.0

func _ready():
	# Spawn the very first Iris in front of the camera to start the loop
	var initial_iris = preload("res://scripts/portals/ScenarioNode.gd").new()
	initial_iris.position = Vector3(0, 0, -20)
	
	# Set portal to AVAILABLE (state 2) so it accepts clicks
	initial_iris.setup(2, {"universe": "science_lab", "world": "cognitive_bias", "chunk_id": "start"})
	add_child(initial_iris)

func apply_theme(theme_data: Dictionary):
	var tunnel = theme_data.get("tunnel", {})
	active_speed_multiplier = tunnel.get("speed_multiplier", 1.0)
	
	print("[TIER 3 - PORTALS] Interaction layer synchronized. Interactive elements allowed: ", tunnel.get("interactive_elements", false))

func spawn_artifact(_content_id: String, _type: String):
	# Driven exclusively by external gameplay/content systems
	pass

func _process(_delta):
	# Artifacts must move identically to the Geometry pool to prevent desync in physical space
	var _forward_motion = active_speed_multiplier * _delta * 10.0
	
	for child in get_children():
		# Move interactive children forward
		# child.position.z += forward_motion
		pass
