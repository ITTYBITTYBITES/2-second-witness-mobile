extends Node

# ---------------------------------------------------------
# PRODUCT: 2 Second Witness
# BOOT SEQUENCE TRACER & DEPENDENCY VALIDATOR
# ---------------------------------------------------------

var _init_log: Array = []
var _start_time: int = 0

func _init():
	_start_time = Time.get_ticks_msec()
	print("\n=============================================")
	print("[BOOT TRACER] Cold Boot Sequence Initiated.")
	print("=============================================\n")

func log_init(system_name: String):
	var t = Time.get_ticks_msec() - _start_time
	_init_log.append({"time": t, "system": system_name})
	print(str("[+%04dms] %s initialized.") % [t, system_name])

func _ready():
	# Ensure this runs after all other singletons by deferring the report
	call_deferred("_dump_boot_trace")

func _dump_boot_trace():
	print("\n=== FINAL BOOT TRACE REPORT ===")
	for entry in _init_log:
		print(str("[+%04dms] %s") % [entry["time"], entry["system"]])
	print("===============================\n")
