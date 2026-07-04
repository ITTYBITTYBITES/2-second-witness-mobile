extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# UNIFIED MODAL WINDOW MANAGER (SERVICE-ORIENTED UTILITY CUSTODIAN)
# ---------------------------------------------------------

enum UtilityID { MIRROR, STORE, SETTINGS, INVENTORY, ACHIEVEMENTS }

signal modal_stack_changed(active_modal: CanvasLayer)

var _modal_stack: Array[CanvasLayer] = []
var _instanced_modals: Dictionary = {}
var _previous_focus_owners: Dictionary = {}
var _input_blocker: Control

var modal_write_owner: String = ""
var _last_write_frame: int = -1
var _is_blocker_active: bool = false

func _ready():
	if BootTracer: BootTracer.log_init("ModalWindowManager")
	print("[MODAL MANAGER] Online. Operating as authoritative owner of modal state and focus invariants.")
	set_process(true)
	
	_input_blocker = Control.new()
	_input_blocker.name = "AuthoritativeInputBlocker"
	_input_blocker.set_anchors_preset(Control.PRESET_FULL_RECT)
	_input_blocker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	call_deferred("_mount_blocker")

func _mount_blocker():
	var ui_layer = get_tree().root.get_node_or_null("MainShell/UILayer/NavigationUI")
	if not ui_layer: ui_layer = get_tree().root.get_node_or_null("MainShell/UILayer")
	if ui_layer:
		ui_layer.add_child(_input_blocker)

func _process(_delta):
	if _modal_stack.is_empty() and _is_blocker_active:
		print("[MODAL WATCHDOG] Safety rule enforced: modal stack == empty but blocker was active. Auto-clearing deadlock.")
		set_input_blocker(false)

func set_input_blocker(active: bool):
	_is_blocker_active = active
	if is_instance_valid(_input_blocker):
		if active:
			_input_blocker.mouse_filter = Control.MOUSE_FILTER_STOP
			print("[MODAL MANAGER] Input Blocker ACTIVE. Isolating underlying layers.")
		else:
			_input_blocker.mouse_filter = Control.MOUSE_FILTER_IGNORE
			print("[MODAL MANAGER] Input Blocker IGNORE. Restoring global input tree.")

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and (event.keycode == KEY_ESCAPE or event.keycode == KEY_BACK):
		if not _modal_stack.is_empty():
			get_viewport().set_input_as_handled()
			print("[MODAL MANAGER] Escape/Back intercepted. Popping top modal.")
			pop_modal(null, "ModalWindowManager")

func _arbitrate_write_owner(caller: String) -> bool:
	var current_frame = Engine.get_frames_drawn() if Engine else 0
	if _last_write_frame == current_frame:
		if modal_write_owner != caller and modal_write_owner != "":
			print("[MODAL MANAGER GUARD] Suppressed multi-authority collision in same frame. Active owner: ", modal_write_owner, ", Blocked caller: ", caller)
			return false
	else:
		_last_write_frame = current_frame
		modal_write_owner = caller
		print("modal_write_owner = ", modal_write_owner)
	return true

func toggle_utility(utility_id: Variant, caller: String = "ModalWindowManager"):
	var u_id: int = UtilityID.MIRROR
	if typeof(utility_id) == TYPE_STRING:
		match str(utility_id).to_lower():
			"mirror": u_id = UtilityID.MIRROR
			"store": u_id = UtilityID.STORE
			"settings": u_id = UtilityID.SETTINGS
			"inventory": u_id = UtilityID.INVENTORY
			"achievements": u_id = UtilityID.ACHIEVEMENTS
			_: u_id = UtilityID.MIRROR
	elif typeof(utility_id) == TYPE_INT or typeof(utility_id) == TYPE_FLOAT:
		u_id = int(utility_id)
	else:
		return

	if _instanced_modals.has(u_id) and is_instance_valid(_instanced_modals[u_id]):
		var existing_screen = _instanced_modals[u_id]
		if _modal_stack.has(existing_screen):
			pop_modal(existing_screen, caller)
		else:
			push_modal(existing_screen, true, caller)
		return
		
	var scene_path = ""
	match u_id:
		UtilityID.MIRROR: scene_path = "res://scenes/ui/screens/PlayerProfileScreen.tscn"
		UtilityID.STORE: scene_path = "res://scenes/ui/screens/MonetizationGate.tscn"
		UtilityID.SETTINGS: scene_path = "res://scenes/ui/screens/SettingsScreen.tscn"
		
	if scene_path == "": return
	
	var scene = load(scene_path)
	if not scene: return
	
	var screen = scene.instantiate()
	_instanced_modals[u_id] = screen
	
	var hud_root = get_tree().root.get_node_or_null("MainShell/UILayer/HUDRoot")
	if not hud_root: hud_root = get_tree().root.get_node_or_null("MainShell/UILayer")
	if hud_root: hud_root.add_child(screen)
	
	if screen.has_signal("return_requested"):
		screen.return_requested.connect(func(): pop_modal(screen, caller))
		
	push_modal(screen, true, caller)

func push_modal(screen: CanvasLayer, is_modal: bool = true, caller: String = "ModalWindowManager"):
	if not _arbitrate_write_owner(caller): return
	
	if _modal_stack.has(screen):
		print("[MODAL MANAGER] Suppressed duplicate push for modal already in stack: ", screen.name)
		return
	
	var current_focus = get_viewport().gui_get_focus_owner()
	if current_focus: _previous_focus_owners[screen] = current_focus
	
	_modal_stack.append(screen)
	screen.visible = true
	print("[MODAL MANAGER] Pushed modal to stack: ", screen.name)
	
	if not screen.is_inside_tree():
		var ui_layer = get_tree().root.get_node_or_null("MainShell/UILayer/NavigationUI")
		if not ui_layer: ui_layer = get_tree().root.get_node_or_null("MainShell/UILayer")
		if ui_layer: ui_layer.add_child(screen)
		
	var kernel = InteractionKernel if InteractionKernel else get_tree().root.get_node_or_null("InteractionKernel")
	if kernel and is_modal:
		var panel = screen.get_node_or_null("Panel")
		if not panel: panel = screen.get_node_or_null("PanelContainer")
		if panel: kernel.register_panel(panel, screen.name, kernel.UIState.MODAL_ACTIVE)
		
	_arbitrate_input_zoning(is_modal)
	modal_stack_changed.emit(screen)

func pop_modal(screen: CanvasLayer = null, caller: String = "ModalWindowManager"):
	if not _arbitrate_write_owner(caller): return
	if _modal_stack.is_empty():
		set_input_blocker(false)
		return
	
	var target = screen if screen != null else _modal_stack[-1]
	if _modal_stack.has(target):
		_modal_stack.erase(target)
		print("[MODAL MANAGER] Popped modal from stack: ", target.name)
		
		var kernel = InteractionKernel if InteractionKernel else get_tree().root.get_node_or_null("InteractionKernel")
		if kernel:
			var panel = target.get_node_or_null("Panel")
			if not panel: panel = target.get_node_or_null("PanelContainer")
			if panel: kernel.unregister_panel(panel)
			
		if _previous_focus_owners.has(target):
			var prev_focus = _previous_focus_owners[target]
			if is_instance_valid(prev_focus) and prev_focus.is_inside_tree():
				prev_focus.grab_focus()
			_previous_focus_owners.erase(target)
			
		var router = NavigationRouter if NavigationRouter else get_tree().root.get_node_or_null("NavigationRouter")
		if _instanced_modals.values().has(target) or (router and target == router.active_landing_screen):
			target.visible = false
		elif is_instance_valid(target) and target.is_inside_tree():
			target.queue_free()
			
	_arbitrate_input_zoning(_modal_stack.size() > 0)
	var active = _modal_stack[-1] if _modal_stack.size() > 0 else null
	modal_stack_changed.emit(active)

func pop_all_modals(except_screen: CanvasLayer = null, caller: String = "ModalWindowManager"):
	var modals_to_pop = _modal_stack.duplicate()
	for modal in modals_to_pop:
		if is_instance_valid(modal) and modal != except_screen:
			pop_modal(modal, caller)
		elif not is_instance_valid(modal):
			_modal_stack.erase(modal)
	if _modal_stack.is_empty():
		set_input_blocker(false)

func _arbitrate_input_zoning(has_active_modal: bool):
	if not is_instance_valid(_input_blocker): return
	
	var should_be_active = (has_active_modal and _modal_stack.size() > 0)
	if _is_blocker_active == should_be_active: return
	
	if should_be_active:
		var top_modal = _modal_stack[-1]
		var parent = _input_blocker.get_parent()
		if parent and top_modal.get_parent() == parent:
			parent.move_child(_input_blocker, max(0, top_modal.get_index() - 1))
		set_input_blocker(true)
	else:
		set_input_blocker(false)

func has_modal(screen: CanvasLayer) -> bool:
	return _modal_stack.has(screen)

func get_modal_stack() -> Array[CanvasLayer]:
	return _modal_stack
