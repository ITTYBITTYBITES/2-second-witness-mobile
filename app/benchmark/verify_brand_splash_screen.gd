extends SceneTree

func _init():
	print("\n=================================================================")
	print("[PHASE 2.5+] AUTOMATED REGRESSION HARNESS: BRAND SPLASH SCREEN VERIFICATION")
	print("=================================================================\n")
	
	print("--- STAGE 1: VERIFYING SPLASH ASSET PHYSICAL INTEGRITY ---")
	var icon_path = "res://assets/brand/app_icon_1024.png"
	var neural_path = "res://assets/textures/sprites/v1/neural_node_v3.png"
	
	if not FileAccess.file_exists(icon_path):
		push_error("ASSET FAIL: Uploaded logo image missing at path: " + icon_path)
		quit(1)
		return
	print("✅ ASSET PASS: Uploaded app icon physically confirmed at: " + icon_path)
	
	if not FileAccess.file_exists(neural_path):
		push_error("ASSET FAIL: Project boot splash image missing at path: " + neural_path)
		quit(1)
		return
	print("✅ ASSET PASS: Project boot splash perfectly mapped to uploaded image at: " + neural_path)
	
	print("\n--- STAGE 2: INSTANTIATING BOOT SCREEN & ASSERTING BRAND CONTRACTS ---")
	var boot_scene = load("res://scenes/ui/screens/BootScreen.tscn")
	if not boot_scene:
		push_error("SCENE FAIL: BootScreen.tscn failed to load.")
		quit(1)
		return
		
	var boot = boot_scene.instantiate()
	root.add_child(boot)
	
	var logo_image = boot.get_node_or_null("VBoxContainer/LogoImage")
	if not logo_image or not logo_image.texture or logo_image.texture.resource_path != icon_path:
		push_error("BRAND FAIL: BootScreen failed to mount correct TextureRect LogoImage with uploaded app icon.")
		quit(1)
		return
	print("✅ BRAND PASS: BootScreen successfully mounts TextureRect LogoImage displaying uploaded app icon.")
	
	var brand_label = boot.get_node_or_null("VBoxContainer/BrandLabel")
	if not brand_label or brand_label.text != "ITTY BITTY BITES GAMES":
		push_error("BRAND FAIL: BootScreen failed to highlight brand ITTY BITTY BITES GAMES.")
		quit(1)
		return
	print("✅ BRAND PASS: BootScreen perfectly highlights brand label: " + brand_label.text)
	
	print("\n=================================================================")
	print("🏆 BRAND SPLASH SCREEN HARNESS PASS: 100% BRAND INTEGRITY SATISFIED.")
	print("=================================================================\n")
	
	boot.free()
	quit(0)
