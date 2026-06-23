@tool
extends EditorScript

# ---------------------------------------------------------
# TOOL: CROSS-UNIVERSE PAIRED RUNNER (DATA MOCK)
# Validates the Salience Bias Index across perceptual manifolds
# ---------------------------------------------------------

func _run():
	print("\n=============================================")
	print("[CALIBRATION RUNNER] Simulating Paired-Sample Trials...")
	print("=============================================\n")
	
	# Simulate 100 paired trials on fixed seed
	var trials = 100
	var science_lab_rt = []
	var tech_ops_rt = []
	
	# Hypothetical execution simulation (in production, this reads physical session logs)
	for i in range(trials):
		# Baseline Cognitive RT for this specific spatial seed
		var cognitive_baseline = randf_range(500.0, 900.0) 
		
		# Science Lab (Soft UI, Low Contrast)
		var sl_noise = randf_range(-20.0, 20.0)
		science_lab_rt.append(cognitive_baseline + sl_noise)
		
		# Tech Ops (Sharp UI, High Contrast -> Pre-attentive Salience Pull)
		# We simulate a systemic 40ms perceptual bias due to visual sharpness
		var tech_bias = -40.0
		var tech_noise = randf_range(-15.0, 15.0)
		tech_ops_rt.append(cognitive_baseline + tech_bias + tech_noise)
		
	_generate_invariance_report(science_lab_rt, tech_ops_rt)

func _generate_invariance_report(dist_a: Array, dist_b: Array):
	dist_a.sort(); dist_b.sort()
	
	var a_p50 = dist_a[int(dist_a.size() * 0.5)]
	var b_p50 = dist_b[int(dist_b.size() * 0.5)]
	
	var drift_ms = a_p50 - b_p50
	var drift_percent = (drift_ms / a_p50) * 100.0
	
	print("--- INVARIANCE REPORT ---")
	print("Universe A (Science Lab) P50 RT: %.2f ms" % a_p50)
	print("Universe B (Tech Ops)    P50 RT: %.2f ms" % b_p50)
	print("-------------------------")
	print("Salience Bias Index: %.2f ms (%.2f%% drift)" % [drift_ms, drift_percent])
	
	if abs(drift_percent) > 5.0:
		print("[FATAL] Instrument Stability Compromised. Perceptual bias exceeds 5% threshold.")
	else:
		print("[PASS] Instrument Stable. Perceptual manifolds are measurement-invariant.")
	print("=============================================\n")
