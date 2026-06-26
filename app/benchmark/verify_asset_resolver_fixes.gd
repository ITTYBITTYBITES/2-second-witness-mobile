extends SceneTree

func _init():
	print("\n=================================================================")
	print("[PHASE 2.5+] AUTOMATED REGRESSION HARNESS: ASSET RESOLVER FIXES")
	print("=================================================================\n")
	
	print("--- STAGE 1: VERIFYING PHYSICAL EXISTENCE OF MANIFEST TEXTURES ---")
	var resolver = load("res://scripts/ui/AssetResolver.gd").new()
	var manifest = resolver.asset_manifest["science_lab"]
	
	var bg_noise = manifest["bg_noise"]
	print("  Checking Background Texture Path: ", bg_noise)
	if not FileAccess.file_exists(bg_noise):
		push_error("ASSET FAIL: Resource file not found: " + bg_noise)
		quit(1)
		return
	print("✅ ASSET PASS: Texture file physically confirmed at: " + bg_noise)
	
	var btn_frame = manifest["button_frame"]
	print("  Checking Button Frame Texture Path: ", btn_frame)
	if not FileAccess.file_exists(btn_frame):
		push_error("ASSET FAIL: Resource file not found: " + btn_frame)
		quit(1)
		return
	print("✅ ASSET PASS: Button texture physically confirmed at: " + btn_frame)
	
	print("\n--- STAGE 2: ASSERTING STYLEBOX TEXTURE PROPERTY MAPPING IN GODOT 4 ---")
	var btn = Button.new()
	btn.name = "TestButton"
	
	print("  [Action] Invoking _apply_button_texture(btn, btn_frame)...")
	resolver._apply_button_texture(btn, btn_frame)
	
	var style = btn.get_theme_stylebox("normal")
	if not style or not style is StyleBoxTexture:
		push_error("STYLE FAIL: Button failed to override normal stylebox with StyleBoxTexture.")
		quit(1)
		return
		
	print("  StyleBoxTexture texture_margin_left: ", style.texture_margin_left)
	if style.texture_margin_left != 10.0:
		push_error("STYLE FAIL: Expected texture_margin_left 10.0, got: " + str(style.texture_margin_left))
		quit(1)
		return
		
	print("✅ STAGE 2 PASS: StyleBoxTexture properties cleanly assigned via texture_margin_left. Zero assignment crashes.\n")
	
	print("=================================================================")
	print("🏆 ASSET RESOLVER HARNESS PASS: 100% ASSET CONCRETIZATION SATISFIED.")
	print("=================================================================\n")
	
	resolver.free()
	btn.free()
	quit(0)
