extends RefCounted
## AppRoutes - Route definitions for new vision
## Includes publisher splash, title splash, first-run flow, and main tabs

const ROUTES := {
	# Publisher & Title Splash (ITTYBITTYBITES identity)
	"publisher_splash": {"screen": "PublisherSplashScreen", "is_tab": false, "requires_auth": false},
	"splash": {"screen": "SplashScreen", "is_tab": false, "requires_auth": false},
	"title_splash": {"screen": "TitleSplashScreen", "is_tab": false, "requires_auth": false},
	
	# First-run flow
	"privacy": {"screen": "PrivacyScreen", "is_tab": false, "requires_auth": false},
	"tutorial": {"screen": "TutorialScreen", "is_tab": false, "requires_auth": false},
	"observation": {"screen": "ObservationChallengeScreen", "is_tab": false, "requires_auth": false},
	"memory_question": {"screen": "MemoryQuestionScreen", "is_tab": false, "requires_auth": false},
	"result": {"screen": "ResultScreen", "is_tab": false, "requires_auth": false},
	
	# Main app
	"home": {"screen": "HomeScreen", "is_tab": true, "requires_auth": false, "icon": "home", "label": "Home"},
	"experiences": {"screen": "ExperiencesScreen", "is_tab": true, "requires_auth": false, "icon": "grid", "label": "Play"},
	"profile": {"screen": "ProfileScreen", "is_tab": true, "requires_auth": false, "icon": "person", "label": "Profile"},
	"settings": {"screen": "SettingsScreen", "is_tab": true, "requires_auth": false, "icon": "settings", "label": "Settings"},
	"about": {"screen": "AboutScreen", "is_tab": false, "requires_auth": false},
	
	# Legacy future routes
	"experience_detail": {"screen": "ExperienceDetail", "is_tab": false, "requires_auth": false},
	"experience_play": {"screen": "ExperiencePlay", "is_tab": false, "requires_auth": false},
}

const TAB_ORDER := ["home", "experiences", "profile", "settings"]

const FIRST_RUN_FLOW := ["privacy", "tutorial", "observation", "memory_question", "result", "home"]

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

static func is_first_run_route(route: String) -> bool:
	return FIRST_RUN_FLOW.has(route)
