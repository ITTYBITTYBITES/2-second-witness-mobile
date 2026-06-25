extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# THE SILENT OBSERVER (A/B TESTING & TELEMETRY STRATIFICATION)
# ---------------------------------------------------------

var is_cohort_member: bool = false
var device_hash: String = ""

# Set this to TRUE only when building the internal clinical trial APK.
# For public release on the Play Store, this should remain FALSE.
const FORCE_IVC0_CLINICAL_MODE = false

func _ready():
	device_hash = str(OS.get_unique_id().hash())
	
	if FORCE_IVC0_CLINICAL_MODE:
		_enforce_clinical_lock()
		return
	
	# PRODUCTION BEHAVIOR:
	# Deterministically decide if this specific installation is part of the global test cohort
	# Using modulo 100 means roughly 1% of the global playerbase will be silently enrolled.
	is_cohort_member = (device_hash.hash() % 5 == 0)
	
	if is_cohort_member:
		print("[SILENT OBSERVER] Device selected for Telemetry Cohort.")
		Engine.physics_ticks_per_second = 60 
	else:
		print("[SILENT OBSERVER] Device excluded from Telemetry Cohort.")

func _enforce_clinical_lock():
	is_cohort_member = true
	print("=================================================")
	print("[IVC-0 LOCK] Study Instrument Booting.")
	print("[IVC-0 LOCK] Adaptive Systems: DISABLED.")
	print("=================================================")
	Engine.physics_ticks_per_second = 60
	seed(88888) # Enforce deterministic sequence selection for the trial
