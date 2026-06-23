extends Node
class_name AssetResolver

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# ASSET CONCRETIZATION LAYER (STRICT SUBSTITUTION ENGINE)
# ---------------------------------------------------------

# Maps primitive internal names to their final art asset paths.
# Structure: { Universe_ID : { Primitive_Tag : Resource_Path } }
var asset_manifest = {
	"science_lab": {
		"button_frame": "res://assets/textures/ui/btn_frame_scilab.png",
		"bg_noise": "res://assets/textures/env/grid_noise_soft.png",
		"stimulus_node": "res://assets/textures/sprites/neural_node_v3.png"
	},
	"tech_ops": {
		"button_frame": "res://assets/textures/ui/btn_frame_tech.png",
		"bg_noise": "res://assets/textures/env/plasma_static.png",
		"stimulus_node": "res://assets/textures/sprites/hard_geo_hex.png"
	}
}

func substitute_assets(target_ui: CanvasLayer, universe_id: String):
	var manifest = asset_manifest.get(universe_id, asset_manifest["science_lab"])
	_recursive_substitution(target_ui, manifest)

func _recursive_substitution(node: Node, manifest: Dictionary):
	for child in node.get_children():
		# 1. Background Grid Replacement
		if child is ColorRect and child.name == "VoidBG":
			_apply_texture_bg(child, manifest["bg_noise"])
			
		# 2. Button Frame Replacement
		elif child is Button:
			_apply_button_texture(child, manifest["button_frame"])
			
		# 3. Stimulus Node Replacement
		elif child.is_in_group("stimulus_node"):
			if child is TextureRect or child is Sprite2D:
				child.texture = load(manifest["stimulus_node"])
				
		_recursive_substitution(child, manifest)

func _apply_texture_bg(rect: ColorRect, tex_path: String):
	# We cannot delete the ColorRect (that breaks logic assumptions).
	# We wrap it or add a child TextureRect that matches its exact rect_size.
	var tex = TextureRect.new()
	tex.texture = load(tex_path)
	tex.set_anchors_preset(Control.PRESET_FULL_RECT)
	tex.modulate = rect.color # Inherit the UniverseRenderer's perceptual color math
	rect.color = Color(0,0,0,0) # Make base rect invisible but keep it as spatial anchor
	rect.add_child(tex)

func _apply_button_texture(btn: Button, tex_path: String):
	# Substitute the StyleBoxFlat with a StyleBoxTexture while maintaining exact geometry
	var style = StyleBoxTexture.new()
	style.texture = load(tex_path)
	style.margin_left = 10; style.margin_right = 10
	style.margin_top = 10; style.margin_bottom = 10
	
	# The StyleInjector/UniverseRenderer already set the baseline colors. 
	# We strictly apply the texture mask, inheriting the existing Color math.
	var old_normal = btn.get_theme_stylebox("normal")
	if old_normal and old_normal is StyleBoxFlat:
		style.modulate_color = old_normal.bg_color
		
	btn.add_theme_stylebox_override("normal", style)
	# Hover and Pressed states would similarly duplicate and modulate
