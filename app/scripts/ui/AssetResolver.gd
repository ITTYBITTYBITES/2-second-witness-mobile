extends Node
class_name AssetResolver

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# ASSET CONCRETIZATION LAYER (REGISTRY-DRIVEN)
# All universe-specific asset mappings are sourced from ContentRegistry.
# ---------------------------------------------------------

func substitute_assets(target_ui: CanvasLayer, universe_id: String):
	var reg = ContentRegistry if ContentRegistry else get_tree().root.get_node_or_null("ContentRegistry")
	var manifest = reg.get_universe_asset_manifest(universe_id) if (reg and reg.has_method("get_universe_asset_manifest")) else {}
	if manifest.is_empty():
		push_warning("[ASSET RESOLVER] No asset manifest for universe: " + universe_id)
		return
	_recursive_substitution(target_ui, manifest)

func _recursive_substitution(node: Node, manifest: Dictionary):
	for child in node.get_children():
		if child is ColorRect and child.name == "VoidBG":
			if manifest.has("bg_noise"):
				_apply_texture_bg(child, manifest["bg_noise"])
			
		elif child is Button:
			if manifest.has("button_frame"):
				_apply_button_texture(child, manifest["button_frame"])
			
		elif child.is_in_group("stimulus_node"):
			if (child is TextureRect or child is Sprite2D) and manifest.has("stimulus_node"):
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
