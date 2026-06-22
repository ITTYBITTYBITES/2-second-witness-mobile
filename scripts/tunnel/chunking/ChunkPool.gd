extends Node

var pooled_chunks = []

func reset_pool(max_chunks: int):
	print("[CHUNK POOL] Flushing and allocating ", max_chunks, " MultiMesh chunks.")
	# Destroys old chunks, creates blank Node3Ds with MultiMeshInstance3D children
	for child in get_children():
		child.queue_free()
	pooled_chunks.clear()

	# Create debug geometric representation
	var debug_mesh = BoxMesh.new()
	var debug_mat = StandardMaterial3D.new()
	debug_mat.albedo_color = Color(0.5, 0.5, 0.5) # Gray boxes
	debug_mesh.material = debug_mat
	debug_mesh.size = Vector3(5, 5, 5)
	
	for i in range(max_chunks):
		var chunk = Node3D.new()
		chunk.name = "Chunk_" + str(i)
		
		# Give it actual multi-mesh placeholder data for visual verification
		var multi = MultiMeshInstance3D.new()
		var mm = MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = debug_mesh
		mm.instance_count = 5 # 5 debug boxes per chunk
		
		# Layout 5 boxes loosely
		for j in range(5):
			var pos = Transform3D()
			pos = pos.translated(Vector3(randf_range(-10, 10), randf_range(-5, 5), randf_range(-20, 20)))
			mm.set_instance_transform(j, pos)
			
		multi.multimesh = mm
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
