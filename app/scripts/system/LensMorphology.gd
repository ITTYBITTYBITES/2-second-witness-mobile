extends Node
class_name LensMorphology

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# COCKPIT LENS ACCUMULATION TRACKER
# ---------------------------------------------------------

enum MasteryTier { BASE, DEVELOPING, COMPLEX, ZENITH }

func get_lens_mastery(universe_id: String) -> int:
	var profile = get_node_or_null("/root/PlayerProfile")
	if not profile: return MasteryTier.BASE
	
	# The lens accumulates visual complexity based on the player's lifetime interaction count in this universe
	var affinity = profile.universe_affinity.get(universe_id, 0)
	
	if affinity > 500:
		return MasteryTier.ZENITH
	elif affinity > 200:
		return MasteryTier.COMPLEX
	elif affinity > 50:
		return MasteryTier.DEVELOPING
	
	return MasteryTier.BASE

# In production, the AssetResolver queries this state and loads the specific 3D variant of the Lens.
# e.g., "historical_astrolabe_tier_3.obj" (extra brass rings) vs "historical_astrolabe_tier_1.obj" (simple ring).
