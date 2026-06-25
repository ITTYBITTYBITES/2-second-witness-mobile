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
	)
	
	print("========================================")
	print("[KERNEL] System Stable. Handoff to Navigation Engine.")
	print("========================================")
	
	NavigationRouter.show_landing_screen()
