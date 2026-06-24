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
	
	# Disable processing on visual/interaction layers until boot sequence completes
	world_layer.process_mode = Node.PROCESS_MODE_DISABLED
	ui_layer.process_mode = Node.PROCESS_MODE_DISABLED
	
	_execute_boot_sequence()

func _execute_boot_sequence():
	# 1. SystemLayer initializes (Implicitly handled by Godot's Autoloads first, but we log the handover)
	print("[BOOT: 1] SystemLayer initialized.")
	
	# 2. ThemeManager loads base theme
	print("[BOOT: 2] ThemeManager compiling base themes.")
	# Default theme loading is already requested in ThemeManager._ready() deferred, we await the signal to confirm
	var active_theme = ThemeManager.get_active_theme()
	if active_theme.is_empty():
		await ThemeManager.theme_applied
	
	# 3 & 4. ContentLoader and ContentRegistry (Handled inside their ready states, ensuring baseline exists)
	print("[BOOT: 3] ContentLoader loading base bundle.")
	print("[BOOT: 4] ContentRegistry index confirmed.")
	
	# 5. NavigationRouter becomes active
	print("[BOOT: 5] NavigationRouter active.")
	
	# 6. GitHubSyncManager runs (Async, non-blocking)
	print("[BOOT: 6] GitHubSyncManager async check started.")
	GitHubSyncManager.sync_cycle()
	
	# 7. WorldLayer activates
	print("[BOOT: 7] WorldLayer activating.")
	world_layer.process_mode = Node.PROCESS_MODE_INHERIT
	
	# 8 & 9. TunnelLayer spawns chunks & PortalLayer begins streaming
	print("[BOOT: 8] TunnelLayer spawning chunks.")
	print("[BOOT: 9] PortalLayer streaming initialized.")
	# (Triggered inherently by the ThemeManager signal flowing into ChunkManager)
	
	# 10. UILayer attaches last
	print("[BOOT: 10] UILayer attaching. Presentation ready.")
	ui_layer.process_mode = Node.PROCESS_MODE_INHERIT
	
	# Fade out the transition overlay smoothly (Simulated here)
	var tween = get_tree().create_tween()
	tween.tween_property($UILayer/TransitionOverlay, "color:a", 0.0, 1.0)
	
	print("========================================")
	print("[KERNEL] System Stable. Handoff to Navigation Engine.")
	print("========================================")
