extends Node3D

@onready var shader_field = $Tier1_ShaderField/ShaderRect
@onready var geometry_pool = $Tier2_InstancedGeometry
@onready var portal_layer = $Tier3_PortalLayer

func _ready():
	print("TunnelController initialized. Hybrid Architecture Active.")
	ThemeManager.theme_applied.connect(_on_theme_applied)
	NavigationEngine.transition_sequence_started.connect(_on_transition_started)

func _on_theme_applied(theme_data: Dictionary):
	print("[TUNNEL CORE] Orchestrating Layer Synchronization...")
	shader_field.apply_theme(theme_data)
	geometry_pool.apply_theme(theme_data)
	portal_layer.apply_theme(theme_data)

func _on_transition_started():
	print("[TUNNEL CORE] Transition Sequence: Slowing tunnel speed, fading non-selected portals...")
	# Logic to interpolate speed_multiplier to a crawl (e.g. 0.1x)
	# Logic to dispatch portal expansion

