extends Node
class_name LensMorphology

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# COCKPIT LENS ACCUMULATION TRACKER (WORLD LEVEL)
# ---------------------------------------------------------

enum MasteryTier { BASE, DEVELOPING, COMPLEX, ZENITH }

func get_world_mastery(universe_id: String, world_id: String) -> int:
	var profile = get_node_or_null("/root/PlayerProfile")
	if not profile: return MasteryTier.BASE
	
	# Mastery is now tracked at the granular World level, not just the Universe level.
	# Example: You can be a Zenith in Astronomy but a Base novice in Physics.
	var world_key = universe_id + "_" + world_id
	var affinity = profile.world_affinity.get(world_key, 0)
	
	if affinity > 500:
		return MasteryTier.ZENITH
	elif affinity > 200:
		return MasteryTier.COMPLEX
	elif affinity > 50:
		return MasteryTier.DEVELOPING
	
	return MasteryTier.BASE

# In production, the AssetResolver queries this state and loads the specific 3D variant of the Lens.
# e.g., "historical_astrolabe_tier_3.obj" (extra brass rings) vs "historical_astrolabe_tier_1.obj" (simple ring).
