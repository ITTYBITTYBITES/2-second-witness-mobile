extends RefCounted
## AppRoutes - Route definitions and param validation
## Central routing table for type-safe navigation

const ROUTES := {
	"splash": {"screen": "SplashScreen", "is_tab": false, "requires_auth": false},
	"home": {"screen": "HomeScreen", "is_tab": true, "requires_auth": false, "icon": "home", "label": "Home"},
	"experiences": {"screen": "ExperiencesScreen", "is_tab": true, "requires_auth": false, "icon": "grid", "label": "Experiences"},
	"profile": {"screen": "ProfileScreen", "is_tab": true, "requires_auth": false, "icon": "person", "label": "Profile"},
	"settings": {"screen": "SettingsScreen", "is_tab": true, "requires_auth": false, "icon": "settings", "label": "Settings"},
	"experience_detail": {"screen": "ExperienceDetail", "is_tab": false, "requires_auth": false},
	"experience_play": {"screen": "ExperiencePlay", "is_tab": false, "requires_auth": false},
}

const TAB_ORDER := ["home", "experiences", "profile", "settings"]

static func is_valid_route(route: String) -> bool:
	return ROUTES.has(route)

static func is_tab_route(route: String) -> bool:
	if not ROUTES.has(route):
		return false
	return ROUTES[route].get("is_tab", false)

static func get_screen_name(route: String) -> String:
	if ROUTES.has(route):
		return ROUTES[route].get("screen", "")
	return ""

static func get_tab_routes() -> Array:
	var tabs: Array = []
	for r in TAB_ORDER:
		if ROUTES.has(r):
			tabs.append(r)
	return tabs
