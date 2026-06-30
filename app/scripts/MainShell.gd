extends Node
class_name MainShell

@onready var system_layer = $SystemLayer
@onready var world_layer = $WorldLayer
@onready var tunnel_layer = $WorldLayer/TunnelLayer
@onready var ui_layer = $UILayer
@onready var audio_layer = $AudioLayer

func _enter_tree():
	if StructuredLogger and StructuredLogger.has_method("log_event_trace"):
		StructuredLogger.log_event_trace(self, "_enter_tree", "MainShell cold boot scene mounting.")

func _ready():
	if StructuredLogger and StructuredLogger.has_method("log_event_trace"):
		StructuredLogger.log_event_trace(self, "_ready", "MainShell ready. Invoking boot sequence.")
	print("========================================")
	print("[KERNEL] MainShell Initialized. Executing Boot Sequence...")
	print("========================================")
	
	world_layer.process_mode = Node.PROCESS_MODE_DISABLED
	ui_layer.process_mode = Node.PROCESS_MODE_DISABLED
	get_viewport().physics_object_picking = true
	
	_apply_display_cutout_safe_area()
	
	var boot_loader = BootLoader.new()
	boot_loader.name = "BootLoader"
	system_layer.add_child(boot_loader)

func _apply_display_cutout_safe_area():
	if DisplayServer.has_method("get_display_safe_area"):
		var safe_area = DisplayServer.get_display_safe_area()
		print("[ANDROID PLATFORM] Inspected display safe area: ", safe_area)
		var hud_root = get_node_or_null("UILayer/HUDRoot")
		if hud_root and hud_root is Control:
			hud_root.position.x = max(hud_root.position.x, safe_area.position.x)
			hud_root.position.y = max(hud_root.position.y, safe_area.position.y)

func _notification(what):
	if what == Node.NOTIFICATION_WM_WINDOW_FOCUS_IN or what == Node.NOTIFICATION_APPLICATION_RESUMED:
		print("[ANDROID LIFECYCLE] App brought to foreground / resumed. Restoring audio stems and 3D stream buffers.")
		if world_layer: world_layer.process_mode = Node.PROCESS_MODE_INHERIT
	elif what == Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT or what == Node.NOTIFICATION_APPLICATION_PAUSED:
		print("[ANDROID LIFECYCLE] App moved to background / paused. Pausing simulation to preserve Android battery budget.")
		if world_layer: world_layer.process_mode = Node.PROCESS_MODE_DISABLED

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
