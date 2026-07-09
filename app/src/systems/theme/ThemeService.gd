extends Node
## ThemeService - UI theming, design tokens, light/dark, dynamic theming
## Independent and reusable, exposes tokens for UI

signal theme_changed(theme_name: String, tokens: Dictionary)
signal theme_tokens_updated()

enum ThemeMode { DARK, LIGHT, SYSTEM }

var current_mode: ThemeMode = ThemeMode.DARK
var current_theme_name: String = "dark"
var tokens: Dictionary = {}

const DARK_TOKENS := {
	"name": "dark",
	"background": Color("#0F0F12"),
	"background_secondary": Color("#1A1A1F"),
	"background_tertiary": Color("#24242C"),
	"surface": Color("#1E1E26"),
	"surface_elevated": Color("#2A2A36"),
	"primary": Color("#7C5CFF"),
	"primary_variant": Color("#9B83FF"),
	"secondary": Color("#2EE6A6"),
	"accent": Color("#FF6B6B"),
	"text_primary": Color("#FFFFFF"),
	"text_secondary": Color("#A1A1B3"),
	"text_tertiary": Color("#6B6B80"),
	"text_on_primary": Color("#FFFFFF"),
	"border": Color("#2E2E3A"),
	"border_strong": Color("#3D3D4D"),
	"error": Color("#FF4D5E"),
	"success": Color("#2EE6A6"),
	"warning": Color("#FFC84D"),
	"shadow": Color(0,0,0,0.4),
	"overlay": Color(0,0,0,0.6),
	"font_family": "default",
	"radius_sm": 8,
	"radius_md": 12,
	"radius_lg": 20,
	"radius_full": 9999,
	"spacing_xs": 4,
	"spacing_sm": 8,
	"spacing_md": 16,
	"spacing_lg": 24,
	"spacing_xl": 32,
	"typography": {
		"display": {"size": 36, "weight": 700},
		"headline": {"size": 24, "weight": 700},
		"title": {"size": 20, "weight": 600},
		"body": {"size": 16, "weight": 400},
		"body_small": {"size": 14, "weight": 400},
		"caption": {"size": 12, "weight": 500},
		"label": {"size": 14, "weight": 600}
	}
}

const LIGHT_TOKENS := {
	"name": "light",
	"background": Color("#F8F8FB"),
	"background_secondary": Color("#FFFFFF"),
	"background_tertiary": Color("#F0F0F5"),
	"surface": Color("#FFFFFF"),
	"surface_elevated": Color("#FFFFFF"),
	"primary": Color("#7C5CFF"),
	"primary_variant": Color("#5A3EDC"),
	"secondary": Color("#0ABF86"),
	"accent": Color("#FF4D5E"),
	"text_primary": Color("#111113"),
	"text_secondary": Color("#636378"),
	"text_tertiary": Color("#8D8DA3"),
	"text_on_primary": Color("#FFFFFF"),
	"border": Color("#E8E8EF"),
	"border_strong": Color("#D4D4DF"),
	"error": Color("#FF4D5E"),
	"success": Color("#0ABF86"),
	"warning": Color("#FF9F1C"),
	"shadow": Color(0,0,0,0.1),
	"overlay": Color(0,0,0,0.4),
	"font_family": "default",
	"radius_sm": 8,
	"radius_md": 12,
	"radius_lg": 20,
	"radius_full": 9999,
	"spacing_xs": 4,
	"spacing_sm": 8,
	"spacing_md": 16,
	"spacing_lg": 24,
	"spacing_xl": 32,
	"typography": {
		"display": {"size": 36, "weight": 700},
		"headline": {"size": 24, "weight": 700},
		"title": {"size": 20, "weight": 600},
		"body": {"size": 16, "weight": 400},
		"body_small": {"size": 14, "weight": 400},
		"caption": {"size": 12, "weight": 500},
		"label": {"size": 14, "weight": 600}
	}
}

func _ready() -> void:
	print("[ThemeService] Ready")
	if SettingsService:
		SettingsService.setting_changed.connect(_on_setting_changed)

func initialize() -> void:
	# Load theme preference from settings
	var preferred: String = "dark"
	if SettingsService:
		preferred = SettingsService.get_value("theme_mode", "dark")

	match preferred:
		"light":
			set_theme_mode(ThemeMode.LIGHT)
		"dark":
			set_theme_mode(ThemeMode.DARK)
		_:
			set_theme_mode(ThemeMode.DARK)

	print("[ThemeService] Initialized - Theme: %s" % current_theme_name)

func set_theme_mode(mode: ThemeMode) -> void:
	current_mode = mode
	match mode:
		ThemeMode.DARK:
			tokens = DARK_TOKENS.duplicate(true)
			current_theme_name = "dark"
		ThemeMode.LIGHT:
			tokens = LIGHT_TOKENS.duplicate(true)
			current_theme_name = "light"
		ThemeMode.SYSTEM:
			# Detect system theme - default dark for now
			tokens = DARK_TOKENS.duplicate(true)
			current_theme_name = "dark"

	theme_changed.emit(current_theme_name, tokens)
	EventBus.publish_theme_changed(current_theme_name)
	print("[ThemeService] Theme changed to %s" % current_theme_name)

func get_color(token_name: String, fallback: Color = Color.WHITE) -> Color:
	return tokens.get(token_name, fallback)

func get_spacing(size_name: String) -> int:
	return tokens.get(size_name, 16)

func get_radius(size_name: String) -> int:
	return tokens.get(size_name, 12)

func get_typography(style: String) -> Dictionary:
	var typo: Dictionary = tokens.get("typography", {})
	return typo.get(style, {"size": 16, "weight": 400})

func apply_theme_to_control(control: Control) -> void:
	if not control:
		return
	# Can be extended to apply theme dynamically
	theme_tokens_updated.emit()

func _on_setting_changed(key: String, value: Variant) -> void:
	if key == "theme_mode":
		match str(value):
			"dark":
				set_theme_mode(ThemeMode.DARK)
			"light":
				set_theme_mode(ThemeMode.LIGHT)
			_:
				set_theme_mode(ThemeMode.DARK)
