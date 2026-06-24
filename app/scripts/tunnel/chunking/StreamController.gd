extends Node

var flow_speed: float = 10.0 # Multiplied by delta later
var cull_threshold_z: float = 50.0 # Once behind camera by this much, recycle
var spawn_threshold_z: float = -150.0 # When furthest chunk reaches this, spawn new

var chunk_pool = null

func set_flow_speed(multiplier: float):
	flow_speed = multiplier * 10.0

func _process(delta):
	if chunk_pool == null: return
	
	var movement = flow_speed * delta
	var max_z = 0.0
	
	for chunk in chunk_pool.pooled_chunks:
		if chunk.visible:
			chunk.position.z += movement
			if chunk.position.z > cull_threshold_z:
				chunk_pool.recycle_chunk(chunk)
			elif chunk.position.z < max_z:
				max_z = chunk.position.z
	
	# Spawn a new chunk ahead if needed
	for chunk in chunk_pool.pooled_chunks:
		if not chunk.visible:
			if max_z > spawn_threshold_z:
				chunk_pool.spawn_at_offset(max_z - 50.0)
				break
