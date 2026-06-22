extends CanvasLayer

@onready var fps_label = $Panel/VBoxContainer/FPSLabel
@onready var mem_label = $Panel/VBoxContainer/MemLabel
@onready var chunk_label = $Panel/VBoxContainer/ChunkLabel
@onready var state_label = $Panel/VBoxContainer/StateLabel

var _update_timer = 0.0

func _ready():
	print("[DEBUG] Telemetry Overlay Active.")
	
func _process(delta):
	_update_timer += delta
	if _update_timer > 0.5:
		_update_timer = 0.0
		
		# CPU / Memory
		var fps = Engine.get_frames_per_second()
		var mem_mb = OS.get_static_memory_usage() / 1048576.0
		
		fps_label.text = "FPS: " + str(fps)
		if fps < 45:
			fps_label.add_theme_color_override("font_color", Color(1, 0, 0))
		else:
			fps_label.add_theme_color_override("font_color", Color(0, 1, 0))
			
		mem_label.text = "Memory: %.2f MB" % mem_mb
		if mem_mb > 900.0:
			mem_label.add_theme_color_override("font_color", Color(1, 0, 0))
		else:
			mem_label.add_theme_color_override("font_color", Color(1, 1, 1))
			
		# Chunk Stream Verification
		var pool_node = get_node_or_null("/root/MainShell/WorldLayer/TunnelLayer/Tier2_InstancedGeometry/ChunkPool")
		if pool_node:
			var active = pool_node.pooled_chunks.size()
			chunk_label.text = "Active Chunks: " + str(active)
		else:
			chunk_label.text = "ChunkPool: UNLINKED"
			
		# Health Monitor State
		var health_node = get_node_or_null("/root/SystemHealthMonitor")
		if health_node:
			var prof_id = health_node.current_profile
			state_label.text = "Gov Profile: " + str(health_node.PerformanceProfile.keys()[prof_id])
