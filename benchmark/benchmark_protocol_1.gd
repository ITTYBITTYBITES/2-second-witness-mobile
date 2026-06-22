extends Node3D

@onready var chunk_pool = $ChunkPool
@onready var stream_controller = $StreamController
@onready var health_monitor = $SystemHealthMonitor

var _test_densities = [1.0, 1.25, 1.50, 1.75, 2.00, 2.50]
var active_test_density: float = 1.0

func _ready():
	# STEP 2.1: Deterministic Execution (for positioning, not density picking)
	randomize()
	active_test_density = _test_densities[randi() % _test_densities.size()]
	
	# Re-lock spatial seed so layout is identical per run, regardless of density multiplier
	seed(12345)
	
	# Pass reference to StreamController
	stream_controller.chunk_pool = chunk_pool
	
	# Preallocate chunks based on randomized density multiplier
	var base_chunks = 5
	var test_chunks = int(base_chunks * active_test_density)
	chunk_pool.reset_pool(test_chunks)
	
	# Seed initial buffer sequentially
	for i in range(test_chunks):
		chunk_pool.spawn_at_offset(i * -50.0)
	
	# Start flow
	stream_controller.set_flow_speed(1.0) 
	
	# Inform health monitor
	health_monitor.push_context(health_monitor.ExecContext.CHUNK_STREAMING, true)
	
	print("===========================================")
	print("[BLIND TEST] Protocol 5 Active. Density randomized.")
	print("[BLIND TEST] Focus on the Iris. Score clarity after 60s.")
	print("===========================================")

func reveal_density():
	# Called externally AFTER annotation is recorded
	print("\n[REVEAL] The true density multiplier for this run was: ", active_test_density, "x\n")
