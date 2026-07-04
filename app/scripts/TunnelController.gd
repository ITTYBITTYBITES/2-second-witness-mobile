extends Node3D

@onready var shader_field = $Tier1_ShaderField/ShaderRect
@onready var geometry_pool = $Tier2_InstancedGeometry
@onready var portal_layer = $Tier3_PortalLayer

var _is_slingshotting: bool = false
var _slingshot_timer: float = 0.0
var _base_animation_tween: Tween = null
var _persistent_flow_time: float = 0.0
var _tunnel_animation_started: bool = false

func _ready():
	print("TunnelController initialized. Hybrid Architecture Active.")
	ThemeManager.theme_applied.connect(_on_theme_applied)
	NavigationEngine.transition_sequence_started.connect(_on_transition_started)
	_initialize_independent_tunnel_animation()

func _initialize_independent_tunnel_animation():
	if not _tunnel_animation_started:
		print("[TUNNEL CORE] Initializing independent global tunnel animation loop.")
		_tunnel_animation_started = true
	if not is_inside_tree(): return
	if _base_animation_tween and _base_animation_tween.is_valid():
		_base_animation_tween.kill()
	_base_animation_tween = create_tween()
	geometry_pool.position.z = 0.0
	_base_animation_tween.tween_property(geometry_pool, "position:z", -2.0, 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_base_animation_tween.tween_property(geometry_pool, "position:z", 0.0, 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_base_animation_tween.tween_callback(_on_tunnel_loop_finished)

func _on_tunnel_loop_finished():
	if not is_inside_tree(): return
	_initialize_independent_tunnel_animation()

func _process(delta):
	_persistent_flow_time += delta
	if _is_slingshotting:
		_slingshot_timer -= delta
		if _slingshot_timer <= 0.0:
			_is_slingshotting = false
			geometry_pool.active_speed_multiplier = 1.0
			if shader_field and shader_field.has_method("reset_to_baseline"):
				shader_field.reset_to_baseline(0.35, true)
			elif shader_field._material:
				shader_field._material.set_shader_parameter("flow_speed", 1.0)
			print("[TUNNEL CORE] Slingshot stabilized. Tunnel baseline restored.")
		else:
			# Damped decay: Lerp from 2.0x down to 1.0x over 3.5 seconds
			var t = _slingshot_timer / 3.5 
			var current_speed = 1.0 + (t * 1.0)
			geometry_pool.active_speed_multiplier = current_speed
			shader_field._material.set_shader_parameter("flow_speed", current_speed)
	else:
		# Enforce static background baseline flow speed to guarantee persistent animated framing
		if geometry_pool.active_speed_multiplier != 1.0:
			geometry_pool.active_speed_multiplier = 1.0
		if shader_field._material and shader_field._material.get_shader_parameter("flow_speed") != 1.0:
			shader_field._material.set_shader_parameter("flow_speed", 1.0)

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
