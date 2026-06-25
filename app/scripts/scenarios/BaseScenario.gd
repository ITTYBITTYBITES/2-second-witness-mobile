extends CanvasLayer
class_name BaseScenario

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# COGNITIVE TASK KERNEL (STRICT INJECTION BASE)
# ---------------------------------------------------------

var _scenario_payload: Dictionary = {}
var _deterministic_rng: RandomNumberGenerator

func inject_payload(payload: Dictionary, seed_val: int):
	if payload.is_empty():
		push_error("[SCENARIO FATAL] Injection failed. Payload is empty. Terminating.")
		queue_free()
		return
		
	_scenario_payload = payload
	
	# Establish Deterministic RNG for this specific task execution
	_deterministic_rng = RandomNumberGenerator.new()
	_deterministic_rng.seed = seed_val
	
	# Trace Logging (Auditable Truth)
	print("[INJECTION TRACE] scenario_id: ", payload.get("id", "UNKNOWN"))
	print("[INJECTION TRACE] resolved_from_registry: true")
	print("[INJECTION TRACE] world_id: ", payload.get("world", "UNKNOWN"))
	print("[INJECTION TRACE] deterministic_seed: ", seed_val)
	
	_validate_and_apply_payload()

func _validate_and_apply_payload():
	# 1. Structural Validation
	var req_keys = ["id", "universe", "world", "type", "rules"]
	for k in req_keys:
		if not _scenario_payload.has(k):
			push_error("[SCENARIO FATAL] Schema violation. Missing key: ", k)
			queue_free()
			return
			
	# 2. Handoff to specific child scenario implementation
	_apply_specific_rules(_scenario_payload["rules"])

func _apply_specific_rules(_rules: Dictionary):
	# Child classes must override this
	pass

# Canonical Workflow Execution
func execute_render_pipeline():
	if _scenario_payload.is_empty(): return # Prevent rendering if injection failed
	
	var resolver = ThemeResolver.new()
	var style = resolver.resolve_theme({"universe": _scenario_payload["universe"], "type": _scenario_payload["type"], "difficulty": _scenario_payload.get("difficulty", 1)})
	StyleInjector.apply(style, self)
	
	var gate = LayoutQuiescenceGate.new()
	add_child(gate)
	gate.begin_quiescence_wait(self)
	
	await gate.layout_stabilized
	gate.queue_free()
	
	LayoutFreezer.enforce_freeze(self)
	RuntimeInvarianceMonitor.capture_canonical_geometry(self)
	
	var asset_resolver = AssetResolver.new()
	asset_resolver.substitute_assets(self, _scenario_payload["universe"])
	
	if Engine.get_main_loop().root.has_node("RuntimeMeasurementIsolation"):
		Engine.get_main_loop().root.get_node("RuntimeMeasurementIsolation").anchor_stimulus_spawn()
	
	print("[SYSTEM] Canonical UI pipeline execution complete.")
