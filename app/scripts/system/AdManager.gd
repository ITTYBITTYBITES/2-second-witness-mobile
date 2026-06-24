extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# PRODUCTION ADVERTISEMENT CONTROLLER (AdMob)
# ---------------------------------------------------------

signal ad_finished
signal reward_granted

var ad_frequency: int = 3
var _loops_since_last_ad: int = 0

# Network Singletons
var admob_plugin = null

# --- PRODUCTION IDS (SWAP TO TRUE BEFORE EXPORTING FOR PLAY STORE) ---
const USE_LIVE_ADS = false 

var ADMOB_INTERSTITIAL_ID: String
var ADMOB_REWARDED_ID: String
var ADMOB_BANNER_ID: String

func _init():
	if USE_LIVE_ADS:
		# REAL IDS - ONLY FOR PUBLIC GOOGLE PLAY RELEASE
		ADMOB_INTERSTITIAL_ID = "ca-app-pub-1566091161594729/6094062214" 
		ADMOB_REWARDED_ID = "ca-app-pub-1566091161594729/7748455589"     
		ADMOB_BANNER_ID = "ca-app-pub-1566091161594729/8898589492"
	else:
		# GOOGLE TEST IDS - SAFE FOR PERSONAL PLAYING & DEVELOPMENT
		ADMOB_INTERSTITIAL_ID = "ca-app-pub-3940256099942544/1033173712"
		ADMOB_REWARDED_ID = "ca-app-pub-3940256099942544/5224354917"
		ADMOB_BANNER_ID = "ca-app-pub-3940256099942544/6300978111"

func _ready():
	print("[AD MANAGER] Online. Live Ads Enabled: ", USE_LIVE_ADS)
	NavigationEngine.navigation_event.connect(_on_loop_completed)
	
	if Engine.has_singleton("AdMob"):
		admob_plugin = Engine.get_singleton("AdMob")
		print("[AD MANAGER] AdMob Plugin Found.")
		admob_plugin.interstitial_closed.connect(_on_video_closed)
		admob_plugin.rewarded_video_closed.connect(_on_video_closed)
		admob_plugin.rewarded.connect(_on_reward_earned)
		admob_plugin.load_interstitial(ADMOB_INTERSTITIAL_ID)
		admob_plugin.load_rewarded_video(ADMOB_REWARDED_ID)
	else:
		print("[AD MANAGER] AdMob Plugin NOT found. Using simulated fallback.")

func _on_loop_completed(payload: Dictionary):
	_loops_since_last_ad += 1

func check_and_show_ad() -> bool:
	var profile = get_node_or_null("/root/PlayerProfile")
	if profile and profile.has_directors_pass:
		return false
		
	if _loops_since_last_ad >= ad_frequency:
		if GoodwillManager.consume_ad_skip():
			print("[AD MANAGER] Override Token used. Bypassing Ad.")
			_loops_since_last_ad = 0
			return false
			
		print("[AD MANAGER] Triggering AdMob Interstitial...")
		_loops_since_last_ad = 0
		_show_video_ad(false)
		return true
		
	return false

func _show_video_ad(is_rewarded: bool):
	if admob_plugin:
		if is_rewarded:
			admob_plugin.show_rewarded_video()
			admob_plugin.load_rewarded_video(ADMOB_REWARDED_ID)
		else:
			admob_plugin.show_interstitial()
			admob_plugin.load_interstitial(ADMOB_INTERSTITIAL_ID)
	else:
		_show_dummy_ad()

func _on_video_closed():
	ad_finished.emit()

func _on_reward_earned(currency: String, amount: int):
	reward_granted.emit()

func _show_dummy_ad():
	var ad_layer = CanvasLayer.new()
	ad_layer.layer = 110
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.9)
	ad_layer.add_child(bg)
	var lbl = Label.new()
	lbl.text = "[ ADMOB VIDEO SIMULATION ]\n[ WAITING 3 SECONDS ]"
	lbl.add_theme_font_size_override("font_size", 32)
	lbl.set_anchors_preset(Control.PRESET_CENTER)
	ad_layer.add_child(lbl)
	get_tree().root.add_child(ad_layer)
	
	await get_tree().create_timer(3.0).timeout
	ad_layer.queue_free()
	
	reward_granted.emit()
	_on_video_closed()

func show_banner():
	var profile = get_node_or_null("/root/PlayerProfile")
	if profile and profile.has_directors_pass:
		return 
		
	if admob_plugin:
		admob_plugin.load_banner(ADMOB_BANNER_ID, 1) 
		print("[AD MANAGER] AdMob Banner Displayed.")
	else:
		print("[AD MANAGER] AdMob Simulation: Showing Banner.")

func hide_banner():
	if admob_plugin:
		admob_plugin.hide_banner()
		print("[AD MANAGER] AdMob Banner Hidden.")
	else:
		print("[AD MANAGER] AdMob Simulation: Hiding Banner.")
