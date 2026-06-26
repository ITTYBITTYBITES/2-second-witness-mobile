extends Node
class_name AssetResolver

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# ASSET CONCRETIZATION LAYER (STRICT SUBSTITUTION ENGINE)
# ---------------------------------------------------------

var asset_manifest = {
	"science_lab": {
		"button_frame": "res://assets/textures/ui/v1/btn_frame_scilab.png",
		"bg_noise": "res://assets/textures/env/v1/grid_noise_soft.png",
		"stimulus_node": "res://assets/textures/sprites/v1/neural_node_v3.png"
	},
	"tech_ops": {
		"button_frame": "res://assets/textures/ui/v1/btn_frame_tech.png",
		"bg_noise": "res://assets/textures/env/v1/plasma_static.png",
		"stimulus_node": "res://assets/textures/sprites/v1/hard_geo_hex.png"
	},
	"history": {
		"button_frame": "res://assets/textures/ui/v1/btn_frame_scilab.png",
		"bg_noise": "res://assets/textures/env/v1/bg_society_mind.png",
		"stimulus_node": "res://assets/textures/sprites/v1/neural_node_v3.png"
	}
}

func substitute_assets(target_ui: CanvasLayer, universe_id: String):
	var manifest = asset_manifest.get(universe_id, asset_manifest["science_lab"])
	_recursive_substitution(target_ui, manifest)

func _recursive_substitution(node: Node, manifest: Dictionary):
	for child in node.get_children():
		if child is ColorRect and child.name == "VoidBG":
			_apply_texture_bg(child, manifest["bg_noise"])
			
		elif child is Button:
			_apply_button_texture(child, manifest["button_frame"])
			
		elif child.is_in_group("stimulus_node"):
			if child is TextureRect or child is Sprite2D:
				child.texture = load(manifest["stimulus_node"])
				
		_recursive_substitution(child, manifest)

func _apply_texture_bg(rect: ColorRect, tex_path: String):
	if not ResourceLoader.exists(tex_path) and not FileAccess.file_exists(tex_path):
		push_error("[ASSET RESOLVER ERROR] Texture file physically missing at path: " + tex_path)
		return
		
	var tex = TextureRect.new()
	tex.texture = load(tex_path)
	tex.set_anchors_preset(Control.PRESET_FULL_RECT)
	tex.modulate = rect.color 
	rect.color = Color(0,0,0,0) 
	rect.add_child(tex)

func _apply_button_texture(btn: Button, tex_path: String):
	if not ResourceLoader.exists(tex_path) and not FileAccess.file_exists(tex_path):
		push_error("[ASSET RESOLVER ERROR] Button texture physically missing at path: " + tex_path)
		return
		
	var style = StyleBoxTexture.new()
	style.texture = load(tex_path)
	style.texture_margin_left = 10.0; style.texture_margin_right = 10.0
	style.texture_margin_top = 10.0; style.texture_margin_bottom = 10.0
	
	var old_normal = btn.get_theme_stylebox("normal")
	if old_normal and old_normal is StyleBoxFlat:
		style.modulate_color = old_normal.bg_color
		
	btn.add_theme_stylebox_override("normal", style)
