extends Node
class_name CognitiveController

# The Perceptual Transfer Function (Derived from Protocol 5)
const COGNITIVE_KNEE_DENSITY = 1.35
const BASELINE_DENSITY = 1.0

# Smoothing / PID-lite mechanics
var target_density: float = BASELINE_DENSITY
var current_density: float = BASELINE_DENSITY

func _ready():
	print("[COGNITIVE CONTROLLER] Online. Enforcing perceptual ceiling.")
	# We hook into the ChunkSpawner directly
	call_deferred("_attach_to_spawner")

func _attach_to_spawner():
	# In production, we wire this to ChunkSpawner so it scales the buffer
	pass

func evaluate_perceptual_envelope(hardware_health_ok: bool):
	# 1. State Estimation (Forward Model)
	# If hardware is struggling, we aggressively drop toward baseline
	if not hardware_health_ok:
		target_density = max(BASELINE_DENSITY, current_density - 0.15)
		print("[COGNITIVE CONTROLLER] Hardware pressure detected. Relaxing perceptual load.")
		return
	
	# 2. The Predictive Clamp (The Hard Ceiling)
	# If hardware is fine, we probe upward, but NEVER past the knee.
	if current_density < COGNITIVE_KNEE_DENSITY:
		target_density = min(COGNITIVE_KNEE_DENSITY, current_density + 0.05)
	
	# 3. Stabilization
	# If we are already at the knee, we do nothing. Unused GPU budget is intentionally sacrificed.
	if current_density >= COGNITIVE_KNEE_DENSITY:
		target_density = COGNITIVE_KNEE_DENSITY
		# print("[COGNITIVE CONTROLLER] Holding at Cognitive Knee. Rejecting surplus hardware budget.")

func _process(delta):
	# Smoothly interpolate density so visual transitions are not jarring
	if abs(current_density - target_density) > 0.01:
		current_density = lerp(current_density, target_density, delta * 2.0)
		# Update visual systems here...
