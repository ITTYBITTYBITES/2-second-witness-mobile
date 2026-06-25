extends Node

var pooled_chunks = []
var active_universe = "science_lab"

func reset_pool(max_chunks: int, universe_id: String = "science_lab"):
	active_universe = universe_id
	print("[CHUNK POOL] Flushing and allocating ", max_chunks, " MultiMesh chunks for ", universe_id)
	
	for child in get_children():
		child.queue_free()
	pooled_chunks.clear()

	var structure_mat = load("res://assets/materials/lab_structure.tres")
	var node_mat = load("res://assets/materials/lab_data_node.tres")
	
	var asset_registry = AssetManifestRegistry.new()
	var manifest = asset_registry.get_manifest(universe_id)
	
	var resolved_mesh_path = asset_registry.resolve_asset(manifest, "rib_mesh")
	var rib_mesh = load(resolved_mesh_path)
		
	# Update Material Colors based on Universe
	var renderer = UniverseRenderer.new()
	var def = renderer.universe_definitions.get(universe_id, renderer.universe_definitions["science_lab"])
	var u_mat = structure_mat.duplicate()
	u_mat.albedo_color = def["palette"]["bg"]
	u_mat.emission = def["palette"]["primary"]
	
	for i in range(max_chunks):
		var chunk = Node3D.new()
		chunk.name = "Chunk_" + str(i)
		
		var main_ring = MeshInstance3D.new()
		main_ring.mesh = rib_mesh
		main_ring.material_override = u_mat
		main_ring.rotation_degrees.x = 90
		chunk.add_child(main_ring)
		
		# MultiMesh for floating data nodes inside the ring
		var multi = MultiMeshInstance3D.new()
		var mm = MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		var node_mesh = load("res://assets/meshes/data_node.obj")
		if not node_mesh: node_mesh = SphereMesh.new()
		mm.mesh = node_mesh
		mm.instance_count = 15
		
		for j in range(15):
			var pos = Transform3D()
			var angle = randf() * TAU
			var radius = randf_range(8.0, 16.0)
			var z_drift = randf_range(-10.0, 10.0)
			pos = pos.translated(Vector3(cos(angle) * radius, sin(angle) * radius, z_drift))
			mm.set_instance_transform(j, pos)
			
		multi.multimesh = mm
		multi.material_override = node_mat
		chunk.add_child(multi)
		
		chunk.visible = true 
		chunk.position.y = -1000.0
		add_child(chunk)
		pooled_chunks.append(chunk)

func spawn_at_offset(_z_offset: float):
	for chunk in pooled_chunks:
		if chunk.position.y == -1000.0: 
			chunk.position.y = 0.0
			chunk.position.z = _z_offset
			return

func recycle_chunk(_chunk_node: Node3D):
	_chunk_node.position.y = -1000.0
