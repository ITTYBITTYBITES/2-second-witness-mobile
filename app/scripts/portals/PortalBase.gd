extends Node3D
class_name PortalBase

var current_state: int = 0 # NavigationEngine.PortalState.LOCKED
var destination_data: Dictionary = {}

func _ready():
	ThemeManager.theme_applied.connect(_on_theme_applied)

func setup(state: int, dest: Dictionary):
	current_state = state
	destination_data = dest
	_update_visual_state()

func _on_theme_applied(_theme_data: Dictionary):
	# Driven purely by ThemeManager. Subclasses implement visual morphing.
	pass

func _update_visual_state():
	# 0 = LOCKED, 1 = VISIBLE, 2 = AVAILABLE, 3 = ACTIVE
	if current_state == 0:
		print("[PORTAL] ", name, " -> Visual State: LOCKED (Dim / Fractured)")
	elif current_state == 2:
		print("[PORTAL] ", name, " -> Visual State: AVAILABLE (Glowing / Stable)")

func select_portal():
	if current_state == 2: # AVAILABLE
		current_state = 3 # ACTIVE
		print("[PORTAL] Selection triggered. Handing off to NavigationEngine.")
		NavigationEngine.process_selection(self, _get_portal_type(), destination_data)
	else:
		print("[PORTAL] Selection rejected. State is: ", current_state)

func _get_portal_type() -> String:
	return "base_portal"
