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
	"primary": Color("#6A3DFF"),
	"primary_variant": Color("#8A68FF"),
	"primary_text": Color("#A78FFF"),
	"secondary": Color("#2EE6A6"),
	"accent": Color("#FF6B6B"),
	"text_primary": Color("#FFFFFF"),
	"text_secondary": Color("#B8B8CC"),
	"text_tertiary": Color("#A2A2B8"),
	"text_on_primary": Color("#FFFFFF"),
	"border": Color("#67677A"),
	"border_strong": Color("#858599"),
	"error": Color("#FF4D5E"),
	"error_container": Color("#3A1A1E"),
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
	"touch_target_min": 48,
	"safe_area_top": 0,
	"safe_area_bottom": 0,
	"typography": {
		"display": {"size": 34, "weight": 700},
		"headline": {"size": 26, "weight": 700},
		"title": {"size": 22, "weight": 600},
		"body": {"size": 18, "weight": 400},
		"body_small": {"size": 16, "weight": 400},
		"caption": {"size": 14, "weight": 500},
		"label": {"size": 16, "weight": 600},
		"label_small": {"size": 14, "weight": 600},
		"button": {"size": 18, "weight": 600}
	}
}

const LIGHT_TOKENS := {
	"name": "light",
	"background": Color("#F8F8FB"),
	"background_secondary": Color("#FFFFFF"),
	"background_tertiary": Color("#F0F0F5"),
	"surface": Color("#FFFFFF"),
	"surface_elevated": Color("#FFFFFF"),
	"primary": Color("#5336C9"),
	"primary_variant": Color("#6A4BE0"),
	"primary_text": Color("#4930B2"),
	"secondary": Color("#087A59"),
	"accent": Color("#FF4D5E"),
	"text_primary": Color("#111113"),
	"text_secondary": Color("#4A4A5E"),
	"text_tertiary": Color("#6B6B80"),
	"text_on_primary": Color("#FFFFFF"),
	"border": Color("#8C8C9A"),
	"border_strong": Color("#5D5D68"),
	"error": Color("#E53945"),
	"error_container": Color("#FFEBEE"),
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
	"touch_target_min": 48,
	"safe_area_top": 0,
	"safe_area_bottom": 0,
	"typography": {
		"display": {"size": 34, "weight": 700},
		"headline": {"size": 26, "weight": 700},
		"title": {"size": 22, "weight": 600},
		"body": {"size": 18, "weight": 400},
		"body_small": {"size": 16, "weight": 400},
		"caption": {"size": 14, "weight": 500},
		"label": {"size": 16, "weight": 600},
		"label_small": {"size": 14, "weight": 600},
		"button": {"size": 18, "weight": 600}
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

	_apply_accessibility_tokens()
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
	return typo.get(style, {"size": 18, "weight": 400})

func get_font_size(style: String) -> int:
	var base_size: int = int(get_typography(style).get("size", 18))
	var scale := 1.0
	if SettingsService:
		scale = SettingsService.get_font_scale()
	return maxi(12, int(round(base_size * scale)))

func apply_typography(control: Control, style: String) -> void:
	if not control:
		return
	var typo := get_typography(style)
	control.add_theme_font_size_override("font_size", typo.get("size", 18))

func apply_label_style(label: Label, style: String, color_token: String = "text_primary") -> void:
	if not label:
		return
	apply_typography(label, style)
	label.add_theme_color_override("font_color", get_color(color_token))
	if not label.autowrap_mode:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func get_safe_area() -> Rect2i:
	# Returns safe area insets for notches / gesture bars
	var area := DisplayServer.get_display_safe_area()
	var window_size := DisplayServer.window_get_size()
	var top := area.position.y
	var bottom := window_size.y - (area.position.y + area.size.y)
	var left := area.position.x
	var right := window_size.x - (area.position.x + area.size.x)
	# Fallback minimums for desktop / editor
	if top < 24 and OS.get_name() in ["Android", "iOS"]:
		top = 32
	if bottom < 16 and OS.get_name() in ["Android", "iOS"]:
		bottom = 24
	return Rect2i(left, top, right, bottom)

func apply_theme_to_control(control: Control) -> void:
	if not control:
		return
	# Can be extended to apply theme dynamically
	theme_tokens_updated.emit()

func _apply_accessibility_tokens() -> void:
	if not SettingsService or not SettingsService.get_value("high_contrast", false):
		return
	if current_theme_name == "light":
		tokens["background"] = Color("#FFFFFF")
		tokens["background_secondary"] = Color("#FFFFFF")
		tokens["surface"] = Color("#FFFFFF")
		tokens["surface_elevated"] = Color("#F4F4F7")
		tokens["text_primary"] = Color("#000000")
		tokens["text_secondary"] = Color("#24242B")
		tokens["text_tertiary"] = Color("#3E3E48")
		tokens["primary_text"] = Color("#321B9D")
		tokens["border"] = Color("#565660")
		tokens["border_strong"] = Color("#24242B")
	else:
		tokens["background"] = Color("#000000")
		tokens["background_secondary"] = Color("#08080A")
		tokens["surface"] = Color("#101014")
		tokens["surface_elevated"] = Color("#18181E")
		tokens["text_primary"] = Color("#FFFFFF")
		tokens["text_secondary"] = Color("#E6E6F0")
		tokens["text_tertiary"] = Color("#CCCCD8")
		tokens["primary_text"] = Color("#BBAAFF")
		tokens["border"] = Color("#8C8C9A")
		tokens["border_strong"] = Color("#FFFFFF")

func _on_setting_changed(key: String, value: Variant) -> void:
	match key:
		"theme_mode":
			match str(value):
				"dark":
					set_theme_mode(ThemeMode.DARK)
				"light":
					set_theme_mode(ThemeMode.LIGHT)
				_:
					set_theme_mode(ThemeMode.DARK)
		"high_contrast":
			set_theme_mode(current_mode)
		"font_scale":
			# Typography is calculated lazily from the saved scale. Emitting the
			# theme signal refreshes all cached screens after the slider is released.
			theme_changed.emit(current_theme_name, tokens)
