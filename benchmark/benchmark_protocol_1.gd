extends Node3D

@onready var chunk_pool = $ChunkPool
@onready var stream_controller = $StreamController
@onready var health_monitor = $SystemHealthMonitor

func _ready():
	# STEP 2.1: Deterministic Execution
	seed(12345)
	print("[BENCHMARK] Seed fixed to 12345.")
	
	# Pass reference to StreamController so it can iterate the pool
	stream_controller.chunk_pool = chunk_pool
	
	# Preallocate chunks
	chunk_pool.reset_pool(5)
	
	# Seed initial buffer sequentially
	chunk_pool.spawn_at_offset(0.0)
	chunk_pool.spawn_at_offset(-50.0)
	chunk_pool.spawn_at_offset(-100.0)
	chunk_pool.spawn_at_offset(-150.0)
	chunk_pool.spawn_at_offset(-200.0)
	
	# Start flow
	stream_controller.set_flow_speed(0.0) # PROTOCOL 3: TEST B (Frozen Geometry)
	
	# Inform health monitor
	health_monitor.push_context(health_monitor.ExecContext.CHUNK_STREAMING, true)
	print("[BENCHMARK] Protocol 3 Active. Frozen Geometry Movement.")
