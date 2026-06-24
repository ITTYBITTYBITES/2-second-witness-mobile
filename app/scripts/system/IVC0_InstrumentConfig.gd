extends Node
class_name IVC0_InstrumentConfig

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# IVC-0 STUDY INSTRUMENT LOCK
# ---------------------------------------------------------

# 1. HARD-LOCK VERSION IDENTITY
const BUILD_ID = "IVC0.1.0"
const ASSET_VERSION = "v1.0.0"
const PROTOCOL_LOCK = "P7_P8_P9_P10"

# 2. DETERMINISTIC COHORT EXECUTION
const COHORT_SEED = 88888

# 3. DISABLE ALL ADAPTIVE MUTATION
const ENABLE_LIVE_TUNING = false
const ENABLE_DYNAMIC_DIFFICULTY = false
const ENABLE_ADAPTIVE_UI = false
const DEBUG_OVERLAYS = false

func _ready():
	print("=================================================")
	print("[IVC-0 LOCK] Study Instrument Booting.")
	print("[IVC-0 LOCK] Build: ", BUILD_ID, " | Assets: ", ASSET_VERSION)
	print("[IVC-0 LOCK] Adaptive Systems: DISABLED.")
	print("=================================================")
	
	# Force Engine Invariants
	Engine.physics_ticks_per_second = 60 # Fixed physics tick
	seed(COHORT_SEED) # Enforce deterministic sequence selection
