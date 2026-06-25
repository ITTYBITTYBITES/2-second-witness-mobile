# RUNTIME DISTORTION MODEL (ANDROID EXECUTION ANALYSIS)
*The Framework for Signal Decomposition & Integrity Protection*

We expect the Android runtime to actively distort our cognitive measurements. This document defines the taxonomy of those failures and the strict rules for filtering the telemetry before it can be interpreted as human behavior.

---

## SIGNAL DECOMPOSITION TAXONOMY

### Class A: Deterministic Overhead
*The Normalized Baseline.*
- **Observation:** Consistent, predictable latency across all runs (e.g., base JVM overhead, touch quantization, display refresh alignment).
- **Action:** Extracted and mathematically subtracted via the `MCT-0` calibration offset.

### Class B: Stochastic Spikes
*The Corrupting Artifacts.*
- **Observation:** Unpredictable, transient latency (e.g., Garbage Collection pauses, CPU thermal throttling spikes).
- **Action:** If a frame-time exceeds the safe threshold (e.g., `P99 > 18ms`) *during the 2-second cognitive stimulus window*, the RT measurement is flagged **INVALID**. We cannot separate system hesitation from human hesitation.

### Class C: State Integrity Breaks
*The Fatal Errors.*
- **Observation:** OS-level interference (e.g., App backgrounding, `EGL` context loss, interrupted disk I/O).
- **Action:** The session is marked **CORRUPT**. Data is purged. No partial recovery is attempted.

### Class D: Invisible Latency
*GPU Pipeline Stalls.*
- **Observation:** The CPU logs the start timestamp instantly, but the Mali driver takes 3 frames to compile the shader or upload the texture to VRAM before drawing the pixels to the glass.
- **Action:** If `_process()` detects a massive delta on the first frame of instantiation, the run is flagged. We assume the user could not physically see the stimulus when the timer began.

---

## THE ANALYTICAL PLEDGE
No reaction time will be attributed to "human cognition" until it has successfully passed through this taxonomy and proven to be free of Android runtime distortion. We measure the noise before we measure the mind.
