extends Node3D

@onready var shader_field = $Tier1_ShaderField/ShaderRect
@onready var geometry_pool = $Tier2_InstancedGeometry
@onready var portal_layer = $Tier3_PortalLayer

var _is_slingshotting: bool = false
var _slingshot_timer: float = 0.0

func _ready():
	print("TunnelController initialized. Hybrid Architecture Active.")
	ThemeManager.theme_applied.connect(_on_theme_applied)
	NavigationEngine.transition_sequence_started.connect(_on_transition_started)

func _process(delta):
	if _is_slingshotting:
		_slingshot_timer -= delta
		if _slingshot_timer <= 0.0:
			_is_slingshotting = false
			geometry_pool.active_speed_multiplier = 1.0
			shader_field._material.set_shader_parameter("flow_speed", 1.0)
			
			# Spawning the next recurrence hook at baseline stabilization
			var new_iris = preload("res://scripts/portals/ScenarioNode.gd").new()
			new_iris.position = Vector3(0, 0, -25)
			new_iris.setup(2, {"universe": ThemeManager.active_theme_id if ThemeManager.active_theme_id != "" else "science_lab", "world": "cognitive_bias", "chunk_id": "next"})
			portal_layer.add_child(new_iris)
			
			print("[TUNNEL CORE] Slingshot stabilized. Next Iris spawned.")
		else:
			# Damped decay: Lerp from 2.0x down to 1.0x over 3.5 seconds
			var t = _slingshot_timer / 3.5 
			var current_speed = 1.0 + (t * 1.0)
			geometry_pool.active_speed_multiplier = current_speed
			shader_field._material.set_shader_parameter("flow_speed", current_speed)

func trigger_slingshot():
	print("[TUNNEL CORE] SLINGSHOT INITIATED! 200% Velocity Impulse.")
	_is_slingshotting = true
	_slingshot_timer = 3.5
	geometry_pool.active_speed_multiplier = 2.0
	shader_field._material.set_shader_parameter("flow_speed", 2.0)

func _on_theme_applied(theme_data: Dictionary):
	print("[TUNNEL CORE] Orchestrating Layer Synchronization...")
	shader_field.apply_theme(theme_data)
	geometry_pool.apply_theme(theme_data)
	portal_layer.apply_theme(theme_data)

func _on_transition_started():
	print("[TUNNEL CORE] Transition Sequence: Slowing tunnel speed, fading non-selected portals...")
	SystemHealthMonitor.push_context(SystemHealthMonitor.ExecContext.TRANSITION)
	# Logic to interpolate speed_multiplier to a crawl (e.g. 0.1x)
	# Logic to dispatch portal expansion

