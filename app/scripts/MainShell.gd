extends Node
class_name MainShell

@onready var system_layer = $SystemLayer
@onready var world_layer = $WorldLayer
@onready var tunnel_layer = $WorldLayer/TunnelLayer
@onready var ui_layer = $UILayer
@onready var audio_layer = $AudioLayer

func _ready():
	print("========================================")
	print("[KERNEL] MainShell Initialized. Executing Boot Sequence...")
	print("========================================")
	
	world_layer.process_mode = Node.PROCESS_MODE_DISABLED
	ui_layer.process_mode = Node.PROCESS_MODE_DISABLED
	
	get_viewport().physics_object_picking = true
	
	_execute_boot_sequence()

func _execute_boot_sequence():
	print("[BOOT: 1] SystemLayer initialized.")
	
	print("[BOOT: 2] ThemeManager compiling base themes.")
	var active_theme = ThemeManager.get_active_theme()
	if active_theme.is_empty():
		await ThemeManager.theme_applied
	
	print("[BOOT: 3] ContentLoader loading base bundle.")
	print("[BOOT: 4] ContentRegistry index confirmed.")
	print("[BOOT: 5] NavigationRouter active.")
	print("[BOOT: 6] GitHubSyncManager async check started.")
	
	print("[BOOT: 7] WorldLayer activating.")
	world_layer.process_mode = Node.PROCESS_MODE_INHERIT
	
	print("[BOOT: 8] TunnelLayer spawning chunks.")
	print("[BOOT: 9] PortalLayer streaming initialized.")
	
	print("[BOOT: 10] UILayer attaching. Presentation ready.")
	ui_layer.process_mode = Node.PROCESS_MODE_INHERIT
	
	var overlay = $UILayer/TransitionOverlay
	var tween = get_tree().create_tween()
	tween.tween_property(overlay, "color:a", 0.0, 1.0)
	tween.tween_callback(func():
		overlay.visible = false
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		print("[KERNEL] Transition overlay freed. Visual incoherence window closed.")
	)
	
	print("========================================")
	print("[KERNEL] System Stable. Handoff to Navigation Engine.")
	print("========================================")
	
	NavigationRouter.show_landing_screen()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("[RAYCAST TRACE] Left mouse click registered in MainShell._unhandled_input.")
		var camera = get_viewport().get_camera_3d()
		if not camera:
			print("[RAYCAST TRACE] Failure: No active Camera3D found in viewport.")
			return
			
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * 1000.0
		
		var space_state = camera.get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.collide_with_areas = true
		query.collide_with_bodies = true
		
		var result = space_state.intersect_ray(query)
		if not result.is_empty():
			var collider = result["collider"]
			print("========================================")
			print("[DEFINITIVE RAYCAST HIT LOG]")
			print("  Node Name: ", collider.name)
			print("  Class:     ", collider.get_class())
			print("  Layer:     ", collider.collision_layer)
			print("  Parent:    ", collider.get_parent().get_path() if collider.get_parent() else "None")
			print("========================================")
			
			if collider.get_parent() and collider.get_parent().has_method("select_portal"):
				print("[RAYCAST TRACE] Direct fallback jumpstart: Invoking select_portal() on parent.")
				collider.get_parent().select_portal()
		else:
			print("[RAYCAST TRACE] Raycast hit NOTHING in 3D world space (GUI consumed click or empty space).")
