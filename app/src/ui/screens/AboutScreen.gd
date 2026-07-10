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
	if title_label:
		ThemeService.apply_label_style(title_label, "headline", "primary")
	if brand_label:
		ThemeService.apply_label_style(brand_label, "title", "primary")
	var about_title_path := "Margin/Scroll/VBox/AboutTitle"
	if has_node(about_title_path):
		var about_lbl: Label = get_node(about_title_path)
		ThemeService.apply_label_style(about_lbl, "title", "primary")
	# Style buttons
	for btn in [privacy_btn, website_btn, back_btn]:
		if btn:
			ThemeService.apply_typography(btn, "button")
			btn.custom_minimum_size.y = max(btn.custom_minimum_size.y, tokens.get("touch_target_min", 48))
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

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
	# Screen-view analytics are centralized in NavigationService.navigate_to.
