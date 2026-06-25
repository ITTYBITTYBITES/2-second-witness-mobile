extends Node
class_name FidelityEnforcerNode

enum ResourceType { MULTIMESH_INSTANCE, PARTICLE_EMITTER, POINT_LIGHT }

var budget_caps = {
	0: { # HIGH
		ResourceType.MULTIMESH_INSTANCE: 1000,
		ResourceType.PARTICLE_EMITTER: 4,
		ResourceType.POINT_LIGHT: 3
	},
	1: { # MID
		ResourceType.MULTIMESH_INSTANCE: 400,
		ResourceType.PARTICLE_EMITTER: 2,
		ResourceType.POINT_LIGHT: 0
	},
	2: { # LOW
		ResourceType.MULTIMESH_INSTANCE: 100,
		ResourceType.PARTICLE_EMITTER: 0,
		ResourceType.POINT_LIGHT: 0
	}
}

var current_usage = {
	ResourceType.MULTIMESH_INSTANCE: 0,
	ResourceType.PARTICLE_EMITTER: 0,
	ResourceType.POINT_LIGHT: 0
}

func _ready():
	BootTracer.log_init("FidelityEnforcer")
	print("[FIDELITY ENFORCER] Online. Enforcing hard budget constraints.")

var violation_count: int = 0

func request_allocation(type: int, amount: int, requester_tag: String) -> int:
	var current_profile = SystemHealthMonitor.current_profile
	var cap = budget_caps[current_profile][type]
	var available = cap - current_usage[type]
	var type_name = ResourceType.keys()[type]
	
	if available <= 0:
		print("[BUDGET VIOLATION] BLOCKED: Allocation refused for ", requester_tag, ". Type: ", type_name, ". Cap reached (", cap, ").")
		violation_count += 1
		return 0
		
	var approved = min(amount, available)
	if approved < amount:
		print("[BUDGET VIOLATION] RESTRICTED: ", requester_tag, " requested ", amount, " but only approved ", approved, " for type: ", type_name)
		violation_count += 1
	
	current_usage[type] += approved
	return approved

func release_allocation(type: int, amount: int):
	current_usage[type] = max(0, current_usage[type] - amount)

func get_remaining_budget(type: int) -> int:
	var current_profile = SystemHealthMonitor.current_profile
	return budget_caps[current_profile][type] - current_usage[type]
