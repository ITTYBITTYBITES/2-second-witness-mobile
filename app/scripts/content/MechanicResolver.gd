extends Node
class_name MechanicResolver

# ---------------------------------------------------------
# MECHANIC RESOLVER
# ---------------------------------------------------------
# Single source of truth for translating observation types
# into playable BaseScenario mechanics.
#
# "dynamic" = v3_entity polymorphic type. The frozen v4.2
# compiler proves these entities satisfy all 5 contract
# mechanics. This is the ONLY place that knowledge lives.
#
# If a future observation type restricts mechanics, add it
# here. GameplayDirector, ScenarioSelectScreen, and any
# other consumer asks this resolver — never hardcodes the
# mapping.
# ---------------------------------------------------------

const PLAYABLE_MECHANICS = {
	# v3_entity (polymorphic): compatible with all contract-driven mechanics
	"dynamic": [
		"rapid_classification",
		"signal_vs_noise",
		"odd_one_out",
		"stroop_test",
		"memory_cascade"
	],
	# v2_compiled / v1_legacy: already typed, 1:1 mapping
	"rapid_classification": ["rapid_classification"],
	"signal_vs_noise": ["signal_vs_noise"],
	"odd_one_out": ["odd_one_out"],
	"stroop_test": ["stroop_test"],
	"memory_cascade": ["memory_cascade"],
	"sequence_reverse": ["sequence_reverse"],
	"spatial_recall": ["spatial_recall"],
	"pattern_continuation": ["pattern_continuation"],
	"speed_sort": ["speed_sort"],
	"math_surprise": ["math_surprise"],
	"reflex_tap": ["reflex_tap"],
	"risk_selection": ["risk_selection"]
}

## Expands a raw observation type (e.g. "dynamic") into the list
## of playable BaseScenario mechanics it supports.
static func expand(observation_type: String) -> Array:
	var key = str(observation_type).to_lower().strip_edges()
	if PLAYABLE_MECHANICS.has(key):
		return (PLAYABLE_MECHANICS[key] as Array).duplicate()
	# Unknown type: treat as a direct mechanic name if it looks valid
	if key != "":
		return [key]
	return []

## Expands a list of raw types, deduplicating the result.
static func expand_all(raw_types: Array) -> Array:
	var result: Array = []
	for t in raw_types:
		for mech in expand(str(t)):
			if not result.has(mech):
				result.append(mech)
	result.sort()
	return result

## Returns true if the given mechanic is playable (exists as a key
## or appears in any expansion list).
static func is_playable(mechanic: String) -> bool:
	var key = str(mechanic).to_lower().strip_edges()
	if PLAYABLE_MECHANICS.has(key):
		return true
	for mechs in PLAYABLE_MECHANICS.values():
		if (mechs as Array).has(key):
			return true
	return false
