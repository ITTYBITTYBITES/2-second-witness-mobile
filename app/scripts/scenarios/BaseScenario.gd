extends CanvasLayer
class_name BaseScenario

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# COGNITIVE TASK KERNEL (STRICT INJECTION BASE)
# ---------------------------------------------------------

var _scenario_payload: Dictionary = {}
var _deterministic_rng: RandomNumberGenerator

func normalize_id(id: Variant) -> String:
	return str(id)

func _enter_tree():
	if StructuredLogger and StructuredLogger.has_method("log_event_trace"):
		StructuredLogger.log_event_trace(self, "_enter_tree", "Node entering active scene tree.")

func _ready():
	if StructuredLogger and StructuredLogger.has_method("log_event_trace"):
		StructuredLogger.log_event_trace(self, "_ready", "Node ready and fully mounted.")

func inject_payload(payload: Dictionary, seed_val: int = 12345):
	var s_id = normalize_id(payload.get("id", "UNKNOWN"))
	if StructuredLogger and StructuredLogger.has_method("log_event_trace"):
		StructuredLogger.log_event_trace(self, "inject_payload", "External method call (scenario_id: " + s_id + ")")
	print("INJECT PAYLOAD:", payload.size())
	if payload.is_empty():
		push_error("[SCENARIO FATAL] Injection failed. Payload is empty. Terminating.")
		queue_free()
		return
		
	_scenario_payload = payload
	_scenario_payload["id"] = s_id
	_scenario_payload["universe"] = normalize_id(payload.get("universe", "unknown"))
	_scenario_payload["world"] = normalize_id(payload.get("world", "unknown"))
	_scenario_payload["type"] = normalize_id(payload.get("type", "unknown"))
	
	_deterministic_rng = RandomNumberGenerator.new()
	_deterministic_rng.seed = seed_val
	
	print("[INJECTION TRACE] scenario_id: ", s_id)
	print("[INJECTION TRACE] resolved_from_registry: true")
	print("[INJECTION TRACE] world_id: ", _scenario_payload["world"])
	print("[INJECTION TRACE] deterministic_seed: ", seed_val)
	
	_validate_and_apply_payload()

func _validate_and_apply_payload():
	var req_keys = ["id", "universe", "world", "type", "rules"]
	for k in req_keys:
		if not _scenario_payload.has(k):
			push_error("[SCENARIO FATAL] Schema violation. Missing key: ", k)
			queue_free()
			return
			
	_apply_specific_rules(_scenario_payload["rules"])

func _apply_specific_rules(_rules: Dictionary):
	pass

func execute_render_pipeline():
	if _scenario_payload.is_empty(): return 
	
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
