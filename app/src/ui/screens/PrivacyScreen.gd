extends Control
## PrivacyScreen - Privacy acknowledgment for first-run

@onready var continue_btn: Button = $Margin/VBox/ContinueButton
@onready var privacy_link: Button = $Margin/VBox/PrivacyLink

func _ready() -> void:
	_apply_theme()
	_ensure_wired()

func _ensure_wired() -> void:
	if has_node("Margin/VBox/ContinueButton"):
		var btn = $Margin/VBox/ContinueButton
		if not btn.pressed.is_connected(_on_continue):
			btn.pressed.connect(_on_continue)
	if has_node("Margin/VBox/PrivacyLink"):
		var link = $Margin/VBox/PrivacyLink
		if not link.pressed.is_connected(_on_privacy_link):
			link.pressed.connect(_on_privacy_link)

func _apply_theme() -> void:
	if not ThemeService:
		return
	var tokens = ThemeService.tokens
	if has_node("Margin/VBox/Title"):
		$Margin/VBox/Title.add_theme_color_override("font_color", tokens.get("text_primary", Color.WHITE))
		$Margin/VBox/Title.add_theme_font_size_override("font_size", 24)
	if has_node("Margin/VBox/Message"):
		$Margin/VBox/Message.add_theme_color_override("font_color", tokens.get("text_secondary", Color.GRAY))
	if has_node("Margin/VBox/PrivacyDetails"):
		$Margin/VBox/PrivacyDetails.add_theme_color_override("font_color", tokens.get("text_tertiary", Color.GRAY))

func _on_continue() -> void:
	if AccessibilityService:
		AccessibilityService.vibrate(30)
	if AudioService:
		AudioService.play_ui("ui_click")
	
	# Mark privacy acknowledged but not yet onboarding completed
	if ProfileService:
		var prefs = ProfileService.profile.get("preferences", {})
		prefs["privacy_acknowledged"] = true
		ProfileService.profile["preferences"] = prefs
		ProfileService.save()
	
	if AnalyticsService:
		AnalyticsService.log_event("privacy_acknowledged")
	
	if NavigationService:
		NavigationService.navigate_to("tutorial")

func _on_privacy_link() -> void:
	if AudioService:
		AudioService.play_ui("ui_click")
	# Placeholder for privacy policy - could open URL or navigate to about
	if NavigationService:
		NavigationService.navigate_to("about", {"section": "privacy"})
	# For now just show info
	if ErrorHandler:
		ErrorHandler.handle("PRIVACY_LINK", "Privacy policy: https://ittybittybites.github.io/privacy-policy/", {}, ErrorHandler.Severity.INFO)

func on_navigated_to(_params: Dictionary) -> void:
	if AnalyticsService:
		AnalyticsService.log_screen_view("privacy")
