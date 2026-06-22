extends PortalBase

@onready var mesh_instance = $MeshInstance3D

func _ready():
	super._ready()
	
	# Fallback visual initialization if spawned via script
	if mesh_instance == null:
		mesh_instance = MeshInstance3D.new()
		var torus = TorusMesh.new()
		torus.inner_radius = 1.0
		torus.outer_radius = 1.2
		mesh_instance.mesh = torus
		
		# Apply the glowing visual material
		mesh_instance.material_override = load("res://assets/materials/portal_glow.tres")
		add_child(mesh_instance)

func _get_portal_type() -> String:
	return "scenario_node"

func _on_theme_applied(theme_data: Dictionary):
	print("[SCENARIO NODE] Updating interactive artifact visual layer.")

func check_monetization_gate() -> bool:
	print("[SCENARIO NODE] Interfacing with legacy Monetization/Reward layer.")
	return true

func _input_event(camera, event, position, normal, shape_idx):
	# A simple click-detection fallback
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		select_portal()
