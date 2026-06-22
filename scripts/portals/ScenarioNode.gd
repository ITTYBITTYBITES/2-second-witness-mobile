extends PortalBase

var mesh_instance: MeshInstance3D
var area: Area3D

func _ready():
	super._ready()
	
	mesh_instance = get_node_or_null("MeshInstance3D")
	
	# Fallback visual initialization if spawned via script
	if mesh_instance == null:
		mesh_instance = MeshInstance3D.new()
		var torus = TorusMesh.new()
		torus.inner_radius = 2.0
		torus.outer_radius = 3.0
		mesh_instance.mesh = torus
		
		# Apply the glowing visual material
		mesh_instance.material_override = load("res://assets/materials/portal_glow.tres")
		add_child(mesh_instance)
		
		# Add Area3D for actual mouse clicking / touch
		area = Area3D.new()
		var collision = CollisionShape3D.new()
		var shape = SphereShape3D.new()
		shape.radius = 4.0
		collision.shape = shape
		area.add_child(collision)
		add_child(area)
		
		area.input_event.connect(_on_input_event)

func _get_portal_type() -> String:
	return "scenario_node"

func _on_theme_applied(_theme_data: Dictionary):
	print("[SCENARIO NODE] Updating interactive artifact visual layer.")

func check_monetization_gate() -> bool:
	return true

func _on_input_event(_camera, event, _position, _normal, _shape_idx):
	# Handle both Mouse Clicks (PC) and Touch Screen taps (Android)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("[IRIS] Mouse Clicked! Initiating transition.")
		select_portal()
	elif event is InputEventScreenTouch and event.pressed:
		print("[IRIS] Screen Touched! Initiating transition.")
		select_portal()
