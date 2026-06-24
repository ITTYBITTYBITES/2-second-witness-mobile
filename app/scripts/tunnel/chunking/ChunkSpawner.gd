extends Node

var active_density: float = 1.0

func seed_initial_buffer(density: float):
	active_density = density
	print("[CHUNK SPAWNER] Seeding initial buffer: 3 chunks ahead, 1 visible, 1 behind.")
	SystemHealthMonitor.push_context(SystemHealthMonitor.ExecContext.CHUNK_STREAMING)
	
	# Pulls from pool and positions them sequentially along Z
	var pool = get_parent().get_node("ChunkPool")
	pool.spawn_at_offset(0.0)
	pool.spawn_at_offset(-50.0)
	pool.spawn_at_offset(-100.0)
	pool.spawn_at_offset(-150.0)
	
	SystemHealthMonitor.pop_context(SystemHealthMonitor.ExecContext.CHUNK_STREAMING)
	SystemHealthMonitor.queue_telemetry_dump("Initial Chunk Seed")
