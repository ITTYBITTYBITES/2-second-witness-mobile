extends PortalBase

var mesh_instance: MeshInstance3D
var area: Area3D

func _ready():
	super._ready()
	
	mesh_instance = get_node_or_null("MeshInstance3D")
	
	# Mount the final Crystalline Iris Geometry
	if mesh_instance == null:
		mesh_instance = MeshInstance3D.new()
		
		var uni = destination_data.get("universe", "science_lab")
		var world_id = destination_data.get("world", "")
		var lens_profile = destination_data.get("lens_profile", "particle_accelerator_tier_0")
		var complexity = destination_data.get("complexity", 1)
		
		var asset_registry = AssetManifestRegistry
		var mesh_res = null
		
		if world_id != "":
			var world_bundle = asset_registry.get_world_bundle(uni, world_id, {"complexity": complexity})
			if world_bundle.has("hash"):
				var cached_bundle = WorldAssetCompiler.get_bundle(world_bundle["hash"])
				if cached_bundle.has("meshes") and cached_bundle["meshes"].has("iris_accent"):
					mesh_res = cached_bundle["meshes"]["iris_accent"]
					
		if mesh_res == null:
			var manifest = asset_registry.get_manifest(uni)
			var resolved_mesh_path = asset_registry.resolve_asset(manifest, lens_profile)
			mesh_res = load(resolved_mesh_path)
			
		mesh_instance.mesh = mesh_res
		
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
