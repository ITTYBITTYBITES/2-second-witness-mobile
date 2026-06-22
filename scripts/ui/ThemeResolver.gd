extends Node
class_name ThemeResolver

# Option C: Hybrid Resolution
# Universe drives palette/material identity.
# Task type drives spatial density and motion curves.

enum MotionProfile { FAST_SNAP, SMOOTH_EASE, ORGANIC_DRIFT }
enum DensityProfile { MINIMAL, STRUCTURED, HEAVY }

var universe_palettes = {
	"science_lab": {
		"primary": Color("#00D4FF"),
		"bg": Color("#0B1320"),
		"glass_blur": 1.2
	},
	"tech_ops": {
		"primary": Color("#00F5FF"),
		"bg": Color("#050505"),
		"glass_blur": 0.5
	},
	"life_sciences": {
		"primary": Color("#2ECC71"),
		"bg": Color("#0A1A10"),
		"glass_blur": 2.0
	}
	# Others to be populated...
}

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

func resolve_theme(scenario_data: Dictionary) -> Dictionary:
	var universe = scenario_data.get("universe", "science_lab")
	var type = scenario_data.get("type", "rapid_classification")
	var difficulty = scenario_data.get("difficulty", 1)
	
	var base_palette = universe_palettes.get(universe, universe_palettes["science_lab"])
	var task_profile = task_profiles.get(type, task_profiles["rapid_classification"])
	
	# Difficulty modulates motion and contrast natively
	var active_contrast = task_profile["contrast_boost"] * (1.0 + (difficulty * 0.1))
	
	return {
		"palette": base_palette,
		"motion_curve": task_profile["motion"],
		"layout_density": task_profile["density"],
		"computed_contrast": active_contrast
	}
