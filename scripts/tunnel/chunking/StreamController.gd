extends Node

var flow_speed: float = 10.0 # Multiplied by delta later
var cull_threshold_z: float = 50.0 # Once behind camera by this much, recycle
var spawn_threshold_z: float = -150.0 # When furthest chunk reaches this, spawn new

func set_flow_speed(multiplier: float):
	flow_speed = multiplier * 10.0

func _process(_delta):
	var _movement = flow_speed * _delta
	
	# Iterate over active pool from ChunkPool
	# chunk.position.z += movement
	
	# If chunk.position.z > cull_threshold_z:
	#     ChunkPool.recycle_chunk(chunk)
	#     ChunkSpawner.spawn_at_offset(last_chunk.position.z - CHUNK_LENGTH)
	pass
