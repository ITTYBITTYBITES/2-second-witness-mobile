extends CanvasLayer

@onready var btn_google_play = $Panel/VBoxContainer/BtnGooglePlay
@onready var btn_website = $Panel/VBoxContainer/BtnWebsite

const GOOGLE_PLAY_URL = "https://play.google.com/store/apps/details?id=com.ittybittybites.the2secondwitness"
const WEBSITE_URL = "https://ittybittybites.com"

func _ready():
	print("[WEB DEMO] End Screen Active. Funneling user to conversions.")
	
	var bg = get_node_or_null("ColorRect")
	if bg and bg is ColorRect:
		bg.color.a = 0.15 # Ensure persistent animated TunnelLayer remains visible as outermost frame
	
	btn_google_play.pressed.connect(func(): OS.shell_open(GOOGLE_PLAY_URL))
	btn_website.pressed.connect(func(): OS.shell_open(WEBSITE_URL))
	
	$Panel.modulate.a = 0
	var tween = get_tree().create_tween()
	tween.tween_property($Panel, "modulate:a", 1.0, 1.0)
