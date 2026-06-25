extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# CENTRAL UI INPUT ARBITER (MODAL MODALITY LOCKS)
# ---------------------------------------------------------

enum UIState {
	HIDDEN,
	PASSIVE_VISIBLE,
	MODAL_ACTIVE,
	TRANSITIONAL_LOCK
}

enum InputModality {
	POINTER,
	FOCUS
}

signal ui_lock_state_changed(is_blocking: bool)

var _registered_panels: Dictionary = {}
var _active_pointer_domains: Dictionary = {}
var _active_focus_domains: Dictionary = {}
var _pending_mutations: Array[Dictionary] = []
var _transitional_suppression_lock: bool = false
var _active_transitions_count: int = 0
var _mutation_scheduled: bool = false

func _ready():
	BootTracer.log_init("UIInputArbiter")
	print("[INPUT ARBITER] Online. Enforcing exclusive locks per input modality (POINTER vs FOCUS).")

func register_panel(panel: Control, domain: String = "default", initial_state: int = UIState.HIDDEN, block_focus: bool = true):
	if not is_instance_valid(panel): return
	_registered_panels[panel] = {"domain": domain, "state": initial_state, "block_focus": block_focus}
	set_panel_state(panel, initial_state, domain, block_focus)

func unregister_panel(panel: Control):
	if _registered_panels.has(panel):
		var domain = _registered_panels[panel]["domain"]
		if _active_pointer_domains.get(domain) == panel: _active_pointer_domains.erase(domain)
		if _active_focus_domains.get(domain) == panel: _active_focus_domains.erase(domain)
		_registered_panels.erase(panel)
		_schedule_mutation()

func set_panel_state(panel: Control, state: int, domain: String = "default", block_focus: bool = true):
	if not is_instance_valid(panel): return
	if _registered_panels.has(panel):
		_registered_panels[panel]["state"] = state
		_registered_panels[panel]["domain"] = domain
		_registered_panels[panel]["block_focus"] = block_focus
	else:
		_registered_panels[panel] = {"domain": domain, "state": state, "block_focus": block_focus}
		
	_pending_mutations.append({"panel": panel, "state": state, "domain": domain, "block_focus": block_focus})
	_schedule_mutation()

func begin_transition(panel: Control, domain: String = "default"):
	_active_transitions_count += 1
	set_panel_state(panel, UIState.TRANSITIONAL_LOCK, domain)
	print("[INPUT ARBITER] Transitional Lock INTENT declared. Suppressing input race conditions.")

func end_transition(panel: Control, final_state: int, domain: String = "default"):
	_active_transitions_count = max(0, _active_transitions_count - 1)
	set_panel_state(panel, final_state, domain)
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
		var domain = mutation["domain"]
		var block_focus = mutation["block_focus"]
		if not is_instance_valid(panel): continue
		
		match state:
			UIState.HIDDEN:
				panel.visible = false
				panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
				if _active_pointer_domains.get(domain) == panel: _active_pointer_domains.erase(domain)
				if _active_focus_domains.get(domain) == panel: _active_focus_domains.erase(domain)
				
			UIState.PASSIVE_VISIBLE:
				panel.visible = true
				panel.mouse_filter = Control.MOUSE_FILTER_PASS
				if _active_pointer_domains.get(domain) == panel: _active_pointer_domains.erase(domain)
				if _active_focus_domains.get(domain) == panel: _active_focus_domains.erase(domain)
				
			UIState.MODAL_ACTIVE:
				panel.visible = true
				var existing_pointer = _active_pointer_domains.get(domain)
				if is_instance_valid(existing_pointer) and existing_pointer != panel:
					print("[INPUT ARBITER] Pointer Exclusivity enforced. Stripping STOP from domain '", domain, "': ", existing_pointer.name)
					existing_pointer.mouse_filter = Control.MOUSE_FILTER_PASS
				_active_pointer_domains[domain] = panel
				panel.mouse_filter = Control.MOUSE_FILTER_STOP
				
				if block_focus:
					var existing_focus = _active_focus_domains.get(domain)
					if is_instance_valid(existing_focus) and existing_focus != panel:
						print("[INPUT ARBITER] Focus Exclusivity enforced. Stripping focus lock from domain '", domain, "': ", existing_focus.name)
					_active_focus_domains[domain] = panel
				
			UIState.TRANSITIONAL_LOCK:
				panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
				if _active_pointer_domains.get(domain) == panel: _active_pointer_domains.erase(domain)
				if _active_focus_domains.get(domain) == panel: _active_focus_domains.erase(domain)
				
	_pending_mutations.clear()
	
	_transitional_suppression_lock = (_active_transitions_count > 0)
	var is_blocking = is_ui_blocking()
	ui_lock_state_changed.emit(is_blocking)

func is_ui_blocking() -> bool:
	return _transitional_suppression_lock or not _active_pointer_domains.is_empty() or not _active_focus_domains.is_empty()

func is_focus_blocked_for_domain(domain: String) -> bool:
	return _transitional_suppression_lock or _active_focus_domains.has(domain)
