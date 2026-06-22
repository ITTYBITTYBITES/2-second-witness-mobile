extends Node3D

@onready var chunk_pool = $ChunkPool
@onready var stream_controller = $StreamController
@onready var health_monitor = $SystemHealthMonitor

var _test_densities = [1.0, 1.25, 1.50, 1.75, 2.00, 2.50]
var active_test_density: float = 1.0

# Protocol 7 Execution Tracking
var target_loops = 5
var current_loops = 0

func _ready():
	randomize()
	active_test_density = _test_densities[randi() % _test_densities.size()]
	
	seed(12345)
	
	stream_controller.chunk_pool = chunk_pool
	
	var base_chunks = 5
	var test_chunks = int(base_chunks * active_test_density)
	chunk_pool.reset_pool(test_chunks)
	
	for i in range(test_chunks):
		chunk_pool.spawn_at_offset(i * -50.0)
	
	stream_controller.set_flow_speed(1.0) 
	health_monitor.push_context(health_monitor.ExecContext.CHUNK_STREAMING, true)
	
	print("===========================================")
	print("[BLIND TEST] Protocol 7 Active. Density randomized.")
	print("===========================================")
	
	# Hook into SessionTracker or NavigationRouter to track loop completion
	NavigationEngine.navigation_event.connect(_on_loop_completed)

func _on_loop_completed(payload: Dictionary):
	current_loops += 1
	if current_loops >= target_loops:
		print("PROTOCOL_7_COMPLETE")
		# Give logcat a second to flush the buffer before adb kills the process
		await get_tree().create_timer(1.0).timeout 
