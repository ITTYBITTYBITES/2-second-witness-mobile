extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# UNIFIED MODAL WINDOW MANAGER (STACK OWNERSHIP GRAPH ONLY)
# ---------------------------------------------------------

signal modal_stack_changed(active_modal: CanvasLayer)

var _modal_stack: Array[CanvasLayer] = []

func _ready():
	BootTracer.log_init("ModalWindowManager")
	print("[MODAL MANAGER] Online. Operating strictly as stack ownership graph. Input eligibility delegated to UIInputArbiter.")

func push_modal(screen: CanvasLayer, is_modal: bool = true):
	if _modal_stack.has(screen): return
	
	_modal_stack.append(screen)
	print("[MODAL MANAGER] Pushed modal to stack: ", screen.name)
	
	if not screen.is_inside_tree():
		var ui_layer = get_tree().root.get_node_or_null("MainShell/UILayer/NavigationUI")
		if not ui_layer: ui_layer = get_tree().root.get_node_or_null("MainShell/UILayer")
		if ui_layer: ui_layer.add_child(screen)
		
	if UIInputArbiter and is_modal:
		var panel = screen.get_node_or_null("Panel")
		if not panel: panel = screen.get_node_or_null("PanelContainer")
		if panel: UIInputArbiter.register_panel(panel, screen.name, UIInputArbiter.UIState.MODAL_ACTIVE)
		
	modal_stack_changed.emit(screen)

func pop_modal(screen: CanvasLayer = null):
	if _modal_stack.is_empty(): return
	
	var target = screen if screen != null else _modal_stack[-1]
	if _modal_stack.has(target):
		_modal_stack.erase(target)
		print("[MODAL MANAGER] Popped modal from stack: ", target.name)
		
		if UIInputArbiter:
			var panel = target.get_node_or_null("Panel")
			if not panel: panel = target.get_node_or_null("PanelContainer")
			if panel: UIInputArbiter.unregister_panel(panel)
			
		if is_instance_valid(target) and target.is_inside_tree():
			target.queue_free()
			
	var active = _modal_stack[-1] if _modal_stack.size() > 0 else null
	modal_stack_changed.emit(active)
