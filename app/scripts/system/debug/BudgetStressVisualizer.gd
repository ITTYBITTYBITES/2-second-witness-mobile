extends CanvasLayer

@onready var pressure_bar_mm = $Panel/VBoxContainer/PressureBarMM
@onready var pressure_bar_pt = $Panel/VBoxContainer/PressureBarPT
@onready var tier_label = $Panel/VBoxContainer/TierLabel
@onready var violation_label = $Panel/VBoxContainer/ViolationLabel

var _update_timer = 0.0

func _ready():
	print("[BUDGET VISUALIZER] Online. Monitoring perceptual load and allocation pressure.")

func _process(delta):
	_update_timer += delta
	if _update_timer > 0.1: # High frequency update for real-time feel
		_update_timer = 0.0
		_update_visuals()

func _update_visuals():
	if not FidelityEnforcer: return
	
	# 1. Tier Transition Status
	var current_profile = SystemHealthMonitor.current_profile
	var profile_name = SystemHealthMonitor.PerformanceProfile.keys()[current_profile]
	tier_label.text = "Active Tier: " + profile_name
	
	# 2. Budget Utilization Telemetry (Pressure Mapping)
	var cap_mm = FidelityEnforcer.budget_caps[current_profile][FidelityEnforcer.ResourceType.MULTIMESH_INSTANCE]
	var usage_mm = FidelityEnforcer.current_usage[FidelityEnforcer.ResourceType.MULTIMESH_INSTANCE]
	var pressure_mm = float(usage_mm) / float(cap_mm)
	
	pressure_bar_mm.value = pressure_mm * 100
	pressure_bar_mm.tint_progress = _get_pressure_color(pressure_mm)
	
	# Particle Pressure
	var cap_pt = FidelityEnforcer.budget_caps[current_profile][FidelityEnforcer.ResourceType.PARTICLE_EMITTER]
	var usage_pt = FidelityEnforcer.current_usage[FidelityEnforcer.ResourceType.PARTICLE_EMITTER]
	var pressure_pt = 0.0
	if cap_pt > 0:
		pressure_pt = float(usage_pt) / float(cap_pt)
		
	pressure_bar_pt.value = pressure_pt * 100
	pressure_bar_pt.tint_progress = _get_pressure_color(pressure_pt)
	
	# 3. Violation Attempt Rate
	var violations = FidelityEnforcer.violation_count
	violation_label.text = "Violations Blocked: " + str(violations)
	if violations > 0:
		violation_label.add_theme_color_override("font_color", Color(1, 0, 0))

func _get_pressure_color(ratio: float) -> Color:
	if ratio < 0.5:
		return Color(0, 1, 0) # Green (Safe)
	elif ratio < 0.85:
		return Color(1, 1, 0) # Yellow (Warning)
	else:
		return Color(1, 0, 0) # Red (Critical Load)
