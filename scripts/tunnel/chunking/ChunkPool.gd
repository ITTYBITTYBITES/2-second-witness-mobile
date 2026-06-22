extends Node

var pooled_chunks = []

func reset_pool(max_chunks: int):
	print("[CHUNK POOL] Flushing and allocating ", max_chunks, " MultiMesh chunks.")
	# Destroys old chunks, creates blank Node3Ds with MultiMeshInstance3D children
	for child in get_children():
		child.queue_free()
	pooled_chunks.clear()

	# Replace debug boxes with Science Lab structural rings
	var structure_mat = load("res://assets/materials/lab_structure.tres")
	var node_mat = load("res://assets/materials/lab_data_node.tres")
	
	for i in range(max_chunks):
		var chunk = Node3D.new()
		chunk.name = "Chunk_" + str(i)
		
		# Inner Hexagonal Structural Ring (Torus)
		var main_ring = MeshInstance3D.new()
		var torus = TorusMesh.new()
		torus.inner_radius = 18.0
		torus.outer_radius = 20.0
		torus.rings = 32 # Higher res for rings
		torus.radial_segments = 6 # Make it hexagonal radially
		main_ring.mesh = torus
		main_ring.material_override = structure_mat
		main_ring.rotation_degrees.x = 90 # Orient to fly *through* it
		chunk.add_child(main_ring)
		
		# MultiMesh for floating data nodes inside the ring
		var multi = MultiMeshInstance3D.new()
		var mm = MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		var sphere = SphereMesh.new()
		sphere.radius = 0.2
		sphere.height = 0.4
		sphere.radial_segments = 8
		sphere.rings = 4
		mm.mesh = sphere
		mm.instance_count = 15
		
		# Scatter the data nodes along the inner perimeter
		for j in range(15):
			var pos = Transform3D()
			# Random point in a ring shape
			var angle = randf() * TAU
			var radius = randf_range(8.0, 16.0)
			var z_drift = randf_range(-10.0, 10.0)
			pos = pos.translated(Vector3(cos(angle) * radius, sin(angle) * radius, z_drift))
			mm.set_instance_transform(j, pos)
			
		multi.multimesh = mm
		multi.material_override = node_mat
		chunk.add_child(multi)
		
		# Hide it initially
		chunk.visible = false 
		add_child(chunk)
		pooled_chunks.append(chunk)

func spawn_at_offset(_z_offset: float):
	# Request chunk from pool, move to z_offset
	for chunk in pooled_chunks:
		if not chunk.visible:
			chunk.position.z = _z_offset
			chunk.visible = true
			print("[CHUNK POOL] Activated chunk at Z: ", _z_offset)
			return

func recycle_chunk(_chunk_node: Node3D):
	_chunk_node.visible = false
	print("[CHUNK POOL] Recycled chunk behind camera.")
