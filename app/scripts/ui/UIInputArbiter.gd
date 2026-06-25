extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# CENTRAL UI INPUT ARBITER (SINGLE ARBITRATION GRAPH)
# ---------------------------------------------------------

enum UIState {
	HIDDEN,
	PASSIVE_VISIBLE,
	MODAL_ACTIVE,
	TRANSITIONAL_LOCK
}

signal ui_lock_state_changed(is_blocking: bool)

var _registered_panels: Dictionary = {}
var _pending_mutations: Array[Dictionary] = []
var _modal_active_panel: Control = null
var _transitional_suppression_lock: bool = false
var _active_transitions_count: int = 0
var _mutation_scheduled: bool = false

func _ready():
	BootTracer.log_init("UIInputArbiter")
	print("[INPUT ARBITER] Online. Enforcing frame-batched input arbitration and single-authority ownership.")

func register_panel(panel: Control, initial_state: int = UIState.HIDDEN):
	if not is_instance_valid(panel): return
	_registered_panels[panel] = initial_state
	set_panel_state(panel, initial_state)

func unregister_panel(panel: Control):
	if _registered_panels.has(panel):
		if _modal_active_panel == panel:
			_modal_active_panel = null
		_registered_panels.erase(panel)
		_schedule_mutation()

func set_panel_state(panel: Control, state: int):
	if not is_instance_valid(panel): return
	_registered_panels[panel] = state
	
	_pending_mutations.append({"panel": panel, "state": state})
	_schedule_mutation()

func begin_transition(panel: Control):
	_active_transitions_count += 1
	set_panel_state(panel, UIState.TRANSITIONAL_LOCK)
	print("[INPUT ARBITER] Transitional Lock INTENT declared. Suppressing input race conditions.")

func end_transition(panel: Control, final_state: int):
	_active_transitions_count = max(0, _active_transitions_count - 1)
	set_panel_state(panel, final_state)
	print("[INPUT ARBITER] Transition resolution INTENT declared. Remaining active locks: ", _active_transitions_count)

func _schedule_mutation():
	if not _mutation_scheduled:
		_mutation_scheduled = true
		call_deferred("_apply_batched_mutations")

func _apply_batched_mutations():
	_mutation_scheduled = false
	
	for mutation in _pending_mutations:
		var panel = mutation["panel"]
		var state = mutation["state"]
		if not is_instance_valid(panel): continue
		
		match state:
			UIState.HIDDEN:
				panel.visible = false
				panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
				if _modal_active_panel == panel: _modal_active_panel = null
				
			UIState.PASSIVE_VISIBLE:
				panel.visible = true
				panel.mouse_filter = Control.MOUSE_FILTER_PASS
				if _modal_active_panel == panel: _modal_active_panel = null
				
			UIState.MODAL_ACTIVE:
				panel.visible = true
				if is_instance_valid(_modal_active_panel) and _modal_active_panel != panel:
					print("[INPUT ARBITER] Exclusivity enforced at frame boundary. Stripping STOP from: ", _modal_active_panel.name)
					_modal_active_panel.mouse_filter = Control.MOUSE_FILTER_PASS
				_modal_active_panel = panel
				panel.mouse_filter = Control.MOUSE_FILTER_STOP
				
			UIState.TRANSITIONAL_LOCK:
				panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
				if _modal_active_panel == panel: _modal_active_panel = null
				
	_pending_mutations.clear()
	
	_transitional_suppression_lock = (_active_transitions_count > 0)
	var is_blocking = is_ui_blocking()
	ui_lock_state_changed.emit(is_blocking)

func is_ui_blocking() -> bool:
	return _transitional_suppression_lock or is_instance_valid(_modal_active_panel)
