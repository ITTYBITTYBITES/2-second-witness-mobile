extends Node
class_name IVC0_InstrumentConfig

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# THE SILENT OBSERVER (A/B TESTING & TELEMETRY STRATIFICATION)
# ---------------------------------------------------------

var is_cohort_member: bool = false
var device_hash: String = ""

func _ready():
	device_hash = str(OS.get_unique_id().hash())
	
	# Deterministically decide if this specific installation is part of the global test cohort
	# Using modulo 100 means roughly 1% of the global playerbase will be silently enrolled.
	# For early testing, we might want 1 in 5 (modulo 5).
	is_cohort_member = (device_hash.hash() % 5 == 0)
	
	if is_cohort_member:
		print("[SILENT OBSERVER] Device selected for Telemetry Cohort.")
		# Force Engine Invariants for the cohort to ensure clean data
		Engine.physics_ticks_per_second = 60 
	else:
		print("[SILENT OBSERVER] Device excluded from Telemetry Cohort.")
