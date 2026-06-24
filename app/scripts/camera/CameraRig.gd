extends Node3D

# Camera is strictly isolated.
# NEVER reads gameplay state directly.
# ONLY responds to NavigationEngine events.
# Physically independent of ChunkManager.

@onready var motion_controller = $MotionController
@onready var shake_system = $ShakeSystem
@onready var transition_animator = $TransitionAnimator
@onready var camera = $Camera3D

func _ready():
	print("[CAMERA RIG] Initialized. Awaiting Navigation triggers.")
	NavigationEngine.transition_sequence_started.connect(_on_transition_started)

func _on_transition_started():
	print("[CAMERA RIG] Transition Sequence requested. Activating Animator and fov pull.")
	# Ex: tween FOV, add minor shake, prep for scene fade
