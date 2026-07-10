extends Control
## AboutScreen - Product, publisher, and privacy information.

@onready var background: ColorRect = $Background
@onready var brand_label: Label = $Margin/Scroll/VBox/BrandSection/BrandTitle
@onready var brand_desc: Label = $Margin/Scroll/VBox/BrandSection/BrandDesc
@onready var about_title: Label = $Margin/Scroll/VBox/AboutTitle
@onready var about_desc: Label = $Margin/Scroll/VBox/AboutDesc
@onready var privacy_title: Label = $Margin/Scroll/VBox/PrivacySection/PrivacyTitle
@onready var privacy_desc: Label = $Margin/Scroll/VBox/PrivacySection/PrivacyDesc
@onready var version_info: Label = $Margin/Scroll/VBox/VersionInfo
@onready var privacy_btn: Button = $Margin/Scroll/VBox/PrivacySection/PrivacyButton
@onready var website_btn: Button = $Margin/Scroll/VBox/BrandSection/WebsiteButton
@onready var back_btn: Button = $Margin/Scroll/VBox/BackButton

func _ready() -> void:
	_wire_actions()
	_apply_theme()
	_refresh_content()
	if ThemeService and not ThemeService.theme_changed.is_connected(_on_theme_changed):
		ThemeService.theme_changed.connect(_on_theme_changed)

func _wire_actions() -> void:
	if not privacy_btn.pressed.is_connected(_on_privacy):
		privacy_btn.pressed.connect(_on_privacy)
	if not website_btn.pressed.is_connected(_on_website):
		website_btn.pressed.connect(_on_website)
	if not back_btn.pressed.is_connected(_on_back):
		back_btn.pressed.connect(_on_back)

func _refresh_content() -> void:
	var version := "4.0.0"
	if ConfigService:
		version = str(ConfigService.get_value("app_version", version))
	version_info.text = "Version %s\n© ITTYBITTYBITES" % version

func _apply_theme() -> void:
	if not ThemeService:
		return
	background.color = ThemeService.get_color("background")
	ThemeService.apply_label_style(brand_label, "title", "primary_text")
	ThemeService.apply_label_style(brand_desc, "body_small", "text_secondary")
	ThemeService.apply_label_style(about_title, "title", "text_primary")
	ThemeService.apply_label_style(about_desc, "body", "text_secondary")
	ThemeService.apply_label_style(privacy_title, "title", "text_primary")
	ThemeService.apply_label_style(privacy_desc, "body_small", "text_secondary")
	ThemeService.apply_label_style(version_info, "caption", "text_tertiary")
	for label in [brand_label, brand_desc, about_title, about_desc, privacy_title, privacy_desc, version_info]:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_apply_button(privacy_btn, true)
	_apply_button(website_btn, false)
	_apply_button(back_btn, false)

func _apply_button(button: Button, primary: bool) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = ThemeService.get_color("primary") if primary else ThemeService.get_color("surface")
	style.set_corner_radius_all(12)
	style.border_color = ThemeService.get_color("border")
	style.set_border_width_all(1)
	var hover := style.duplicate() as StyleBoxFlat
	hover.bg_color = ThemeService.get_color("primary_variant") if primary else ThemeService.get_color("surface_elevated")
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_stylebox_override("focus", hover)
	button.add_theme_color_override("font_color", ThemeService.get_color("text_on_primary") if primary else ThemeService.get_color("text_primary"))
	ThemeService.apply_typography(button, "button")
	button.custom_minimum_size.y = maxf(button.custom_minimum_size.y, 48.0)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_ALL

func _open_url(config_key: String, fallback: String) -> void:
	var url := fallback
	if ConfigService:
		url = str(ConfigService.get_value(config_key, fallback))
	if OS.shell_open(url) != OK and ErrorHandler:
		ErrorHandler.user_message_requested.emit(
			"Unable to open the link. Check your connection and try again.",
			ErrorHandler.Severity.WARNING
		)

func _on_privacy() -> void:
	_open_url("privacy_policy_url", "https://ittybittybites.github.io/privacy-policy/")

func _on_website() -> void:
	_open_url("website_url", "https://ittybittybites.itch.io/2-second-witness")

func _on_back() -> void:
	if NavigationService:
		if NavigationService.can_go_back():
			NavigationService.go_back()
		else:
			NavigationService.navigate_to("settings")

func on_navigated_to(_params: Dictionary) -> void:
	_refresh_content()
	_apply_theme()

func _on_theme_changed(_theme: String, _tokens: Dictionary) -> void:
	_apply_theme()
