extends Node
class_name ThemeResolver

# Option C: Hybrid Resolution
# Universe drives palette/material identity from registry.
# Task type drives spatial density and motion curves.

enum MotionProfile { FAST_SNAP, SMOOTH_EASE, ORGANIC_DRIFT }
enum DensityProfile { MINIMAL, STRUCTURED, HEAVY }

var task_profiles = {
	"rapid_classification": {
		"motion": MotionProfile.FAST_SNAP,
		"density": DensityProfile.MINIMAL,
		"contrast_boost": 1.5
	},
	"stroop_test": {
		"motion": MotionProfile.FAST_SNAP,
		"density": DensityProfile.STRUCTURED,
		"contrast_boost": 2.0
	},
	"memory_cascade": {
		"motion": MotionProfile.SMOOTH_EASE,
		"density": DensityProfile.MINIMAL,
		"contrast_boost": 1.0
	}
}

func _registry() -> Node:
	return ContentRegistry if ContentRegistry else get_tree().root.get_node_or_null("ContentRegistry")

func resolve_theme(scenario_data: Dictionary) -> Dictionary:
	var universe = scenario_data.get("universe", "")
	var type = scenario_data.get("type", "rapid_classification")
	var difficulty = scenario_data.get("difficulty", 1)
	
	var reg = _registry()
	var base_palette = {"bg": "#0B1320", "primary": "#00D4FF", "accent": "#80E5FF"}
	if reg and reg.has_method("get_universe_identity"):
		var identity = reg.get_universe_identity(universe)
		base_palette = identity.get("palette", base_palette)
	
	var task_profile = task_profiles.get(type, task_profiles["rapid_classification"])
	
	var active_contrast = task_profile.get("contrast_boost", 1.0) * (1.0 + (float(difficulty) * 0.1))
	active_contrast = clamp(active_contrast, 0.5, 2.5)
	
	return {
		"palette": base_palette,
		"motion_curve": task_profile.get("motion", MotionProfile.FAST_SNAP),
		"layout_density": task_profile.get("density", DensityProfile.MINIMAL),
		"computed_contrast": active_contrast
	}
