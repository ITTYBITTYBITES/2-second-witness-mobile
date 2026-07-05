extends Node3D

var active_speed_multiplier: float = 1.0
var active_universe_id: String = ""
var active_world_id: String = ""

func apply_theme(theme_data: Dictionary, universe_id: String = "", world_id: String = ""):
	var u_id = universe_id if universe_id != "" else theme_data.get("id", "")
	if u_id == "":
		var registry = get_tree().root.get_node_or_null("ContentRegistry")
		if registry and registry.has_method("get_first_universe"):
			u_id = registry.get_first_universe()
	active_universe_id = u_id
	active_world_id = world_id
	var tunnel = theme_data.get("tunnel", {})
	var world_prof = WorldProfileCustodian.get_profile(world_id) if world_id != "" and Engine.get_main_loop().root.has_node("WorldProfileCustodian") else {}
	active_speed_multiplier = world_prof.get("tunnel", {}).get("speed_multiplier", tunnel.get("speed_multiplier", 1.0))
	
	print("[TIER 3 - PORTALS] Interaction layer synchronized. Lens Identity updated to: ", active_universe_id, " | ", active_world_id)

func spawn_lens_portal(chunk_id: String):
	print("STEP 5: PORTAL SPAWN ENTERED")
	
	# Purge old ScenarioNodes to prevent overlapping Area3D picking confusion
	for child in get_children():
		child.queue_free()
		
	var renderer = UniverseRenderer.new()
	var profile_spec = renderer.get_render_profile(active_universe_id)
	
	var lens = preload("res://scripts/portals/ScenarioNode.gd").new()
	lens.position = Vector3(0, 0, -20)
	
	var mastery_engine = LensMorphology
	var mastery_tier = mastery_engine.get_world_mastery(active_universe_id, active_world_id)
	
	var profile = str(profile_spec.get("lens_profile", "particle_accelerator")) + "_tier_" + str(mastery_tier)
	
	print("[COCKPIT] Spawning world lens: ", profile)
	lens.setup(2, {"universe": active_universe_id, "world": active_world_id, "chunk_id": chunk_id, "lens_profile": profile})
	add_child(lens)
