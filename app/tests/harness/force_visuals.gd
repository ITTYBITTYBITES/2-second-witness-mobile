extends Node

func _ready():
	print("[DEBUG] Forcing Giant Iris and Grid Floor for depth perception.")
	
	# Wait for boot to finish (increased to ensure it clears the boot lock)
	await get_tree().create_timer(3.0).timeout
	
	var world = get_tree().root.get_node_or_null("MainShell/WorldLayer")
	if not world: 
		print("[DEBUG ERROR] WorldLayer not found.")
		return
		
	print("[DEBUG] Injecting visual geometry now...")
	
	# 1. Force Depth Cues (A receding Grid Floor)
	var floor_mesh = PlaneMesh.new()
	floor_mesh.size = Vector2(100, 400)
	var floor_mat = StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.1, 0.1, 0.1)
	floor_mat.emission_enabled = true
	floor_mat.emission = Color(0, 0.5, 1)
	floor_mat.emission_energy_multiplier = 4.0 # Boosted for visibility
	# We use a wireframe/grid trick by scaling a texture or just using raw lines if we could, 
	# but for pure primitive testing, we'll scatter glowing ribs.
	
	for i in range(20):
		var rib = MeshInstance3D.new()
		var box = BoxMesh.new()
		box.size = Vector3(40, 0.5, 0.5)
		rib.mesh = box
		rib.material_override = floor_mat
		rib.position = Vector3(0, -2, -i * 10)
		world.add_child(rib)

	# 2. Force a Giant Cyan Iris
	var iris = MeshInstance3D.new()
	var torus = TorusMesh.new()
	torus.inner_radius = 4.0
	torus.outer_radius = 5.0
	iris.mesh = torus
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.298, 0.788, 0.941)
	mat.emission_enabled = true
	mat.emission = Color(0.298, 0.788, 0.941)
	mat.emission_energy_multiplier = 4.0 # Blinding
	iris.material_override = mat
	
	iris.position = Vector3(0, 0, -15)
	world.add_child(iris)
	
	# Rotate it slowly
	var tween = get_tree().create_tween().set_loops()
	tween.tween_property(iris, "rotation_degrees", Vector3(0, 0, 360), 5.0)

