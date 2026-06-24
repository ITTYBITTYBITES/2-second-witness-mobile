extends Node

var active_profiles = {}

func assign_mesh_profiles(_theme_data: Dictionary):
	print("[INSTANCE REGISTRY] Assigning thematic mesh profiles (Max Material Variants = 3)")
	# Load specific meshes (e.g. molecular rings, asteroids) depending on theme_data
