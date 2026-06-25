extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# UNIFIED MODAL WINDOW MANAGER (STACK OWNERSHIP GRAPH ONLY)
# ---------------------------------------------------------

signal modal_stack_changed(active_modal: CanvasLayer)

var _modal_stack: Array[CanvasLayer] = []
var _input_blocker: Control

func _ready():
	BootTracer.log_init("ModalWindowManager")
	print("[MODAL MANAGER] Online. Operating strictly as stack ownership graph. Input eligibility delegated to InteractionKernel.")
	
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

func push_modal(screen: CanvasLayer, is_modal: bool = true):
	if _modal_stack.has(screen): return
	
	_modal_stack.append(screen)
	print("[MODAL MANAGER] Pushed modal to stack: ", screen.name)
	
	if not screen.is_inside_tree():
		var ui_layer = get_tree().root.get_node_or_null("MainShell/UILayer/NavigationUI")
		if not ui_layer: ui_layer = get_tree().root.get_node_or_null("MainShell/UILayer")
		if ui_layer: ui_layer.add_child(screen)
		
	if InteractionKernel and is_modal:
		var panel = screen.get_node_or_null("Panel")
		if not panel: panel = screen.get_node_or_null("PanelContainer")
		if panel: InteractionKernel.register_panel(panel, screen.name, InteractionKernel.UIState.MODAL_ACTIVE)
		
	_arbitrate_input_zoning(is_modal)
	modal_stack_changed.emit(screen)

func pop_modal(screen: CanvasLayer = null):
	if _modal_stack.is_empty(): return
	
	var target = screen if screen != null else _modal_stack[-1]
	if _modal_stack.has(target):
		_modal_stack.erase(target)
		print("[MODAL MANAGER] Popped modal from stack: ", target.name)
		
		if InteractionKernel:
			var panel = target.get_node_or_null("Panel")
			if not panel: panel = target.get_node_or_null("PanelContainer")
			if panel: InteractionKernel.unregister_panel(panel)
			
		if is_instance_valid(target) and target.is_inside_tree():
			target.queue_free()
			
	_arbitrate_input_zoning(_modal_stack.size() > 0)
	var active = _modal_stack[-1] if _modal_stack.size() > 0 else null
	modal_stack_changed.emit(active)

func pop_all_modals(except_screen: CanvasLayer = null):
	var modals_to_pop = _modal_stack.duplicate()
	for modal in modals_to_pop:
		if modal != except_screen:
			pop_modal(modal)

func _arbitrate_input_zoning(has_active_modal: bool):
	if not is_instance_valid(_input_blocker): return
	
	if has_active_modal and _modal_stack.size() > 0:
		var top_modal = _modal_stack[-1]
		var parent = _input_blocker.get_parent()
		if parent and top_modal.get_parent() == parent:
			parent.move_child(_input_blocker, max(0, top_modal.get_index() - 1))
			
		_input_blocker.mouse_filter = Control.MOUSE_FILTER_STOP
		print("[MODAL MANAGER] Input Blocker ACTIVE. Isolating underlying layers.")
	else:
		_input_blocker.mouse_filter = Control.MOUSE_FILTER_IGNORE
		print("[MODAL MANAGER] Input Blocker IGNORE. Restoring global input tree.")
