extends Node

# Simulates finding a portal anchor in a stream chunk and requesting content.

func trigger_scenario_injection(_universe_id: String, _world_id: String, chunk_id: String, _anchor_node: Node3D):
	# 1. ChunkManager finds an empty slot
	print("[SYSTEM] Slot found in Chunk: ", chunk_id)
	
	# 2. Request deterministic content from Registry
	var scenario_data = ContentRegistry.resolve_scenario(_universe_id, _world_id, chunk_id)
	
	if scenario_data.is_empty():
		print("[SYSTEM] No valid content found for anchor.")
		return
		
	# Deep copy to prevent pass-by-reference mutation of the base truth
	var payload = scenario_data.duplicate(true)
	
	# 3. Instantiate ScenarioNode via PortalLayer (NOT chunk system)
	print("[SYSTEM] Content resolved: ", payload["id"], ". Routing to PortalLayer for visual creation.")
	
	# This would technically be routed to PortalLayerManager.gd to instantiate the ScenarioNode
