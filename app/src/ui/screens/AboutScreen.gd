extends Control
## AboutScreen - About ITTYBITTYBITES + Two Second Witness, privacy policy placeholder

@onready var title_label: Label = $Margin/Scroll/VBox/Title
@onready var brand_label: Label = $Margin/Scroll/VBox/BrandSection/BrandTitle
@onready var privacy_btn: Button = $Margin/Scroll/VBox/PrivacySection/PrivacyButton
@onready var website_btn: Button = $Margin/Scroll/VBox/BrandSection/WebsiteButton
@onready var back_btn: Button = $Margin/Scroll/VBox/BackButton

func _ready() -> void:
	_ensure_wired()
	_apply_theme()

func _ensure_wired() -> void:
	if has_node("Margin/Scroll/VBox/PrivacySection/PrivacyButton"):
		var btn = $Margin/Scroll/VBox/PrivacySection/PrivacyButton
		if not btn.pressed.is_connected(_on_privacy):
			btn.pressed.connect(_on_privacy)
	if has_node("Margin/Scroll/VBox/BrandSection/WebsiteButton"):
		var wb = $Margin/Scroll/VBox/BrandSection/WebsiteButton
		if not wb.pressed.is_connected(_on_website):
			wb.pressed.connect(_on_website)
	if has_node("Margin/Scroll/VBox/BackButton"):
		var back = $Margin/Scroll/VBox/BackButton
		if not back.pressed.is_connected(_on_back):
			back.pressed.connect(_on_back)

func _apply_theme() -> void:
	if not ThemeService:
		return
	var tokens = ThemeService.tokens
	# Apply theme to labels
	var heading_paths := [
		"Margin/Scroll/VBox/Title",
		"Margin/Scroll/VBox/BrandSection/BrandTitle",
		"Margin/Scroll/VBox/AboutTitle"
	]
	for path in heading_paths:
		if has_node(path):
			get_node(path).add_theme_color_override("font_color", tokens.get("primary", Color("#7C5CFF")))

func _on_privacy() -> void:
	if AudioService:
		AudioService.play_ui("ui_click")
	# Placeholder URL - replace with real policy when published
	var url = "https://ittybittybites.github.io/two-second-witness/privacy"
	print("[About] Open privacy policy %s" % url)
	OS.shell_open(url)

func _on_website() -> void:
	if AudioService:
		AudioService.play_ui("ui_click")
	var url = "https://ittybittybites.com"
	OS.shell_open(url)

func _on_back() -> void:
	if AudioService:
		AudioService.play_ui("ui_click")
	if NavigationService:
		if NavigationService.can_go_back():
			NavigationService.go_back()
		else:
			NavigationService.navigate_to("settings")

func on_navigated_to(params: Dictionary) -> void:
	var section = params.get("section", "")
	if section == "privacy":
		# Scroll to privacy section if needed
		pass
	if AnalyticsService:
		AnalyticsService.log_screen_view("about", params)
