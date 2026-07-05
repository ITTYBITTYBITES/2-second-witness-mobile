# PROTOCOL 8: CROSS-UNIVERSE CALIBRATION TESTING
*Validating the Invariance of the Mirror*

**Objective:**
Falsify the assumption that the `WitnessEngine` measures cognition equally across all perceptual manifolds. We actively attempt to prove that World rendering (Colors, Fog, Audio, Geometry) biases the reaction time (RT) or error distribution of a fixed Cognitive Task.

## 1. THE CALIBRATION UNIT (THE ANCHOR)
A `CalibrationTrial` is an immutable, paired-sample experiment execution.
- **Task Kernel:** `signal_vs_noise_001` & `stroop_test`
- **Invariant State:** Fixed Seed `88888`. Fixed Target Distribution. Fixed 5.0s Timing Envelope.

## 2. EXPERIMENTAL CONSTRAINTS (ANTI-CONFOUNDS)
To prevent hardware and psychological artifacts from corrupting the Salience Bias Index, trials must adhere to the following rigid constraints:

**A. Counterbalanced World Ordering (Anti-Carryover)**
Participants must never run the Worlds in the same sequential order. Group A will run (Astronomy -> Physics -> Rome -> Egypt), while Group B will run the exact inverse. This mathematically neutralizes adaptation and fatigue carryover effects.

**B. The Hardware Variance Index (HVI)**
Hardware latency is not uniformly distributed. Mobile touch-sampling (120Hz vs 60Hz screens) drastically shifts baseline RTs. The `MCT-0` hardware offset must be calculated and subtracted from every single raw RT before cross-device data can be aggregated into the calibration pool.

## 3. STATISTICAL METHODOLOGY & DRIFT METRICS
We compare distributions using within-subject paired testing.
- **The Primary Test:** *Wilcoxon signed-rank test* on paired RT distributions.
- **The Secondary Test:** *McNemar's test* on paired Error Typology (False Positive vs False Negative ratios).

**Drift Detection Metrics:**
1. **Δ P50 RT:** The median reaction time drift between Universe A and Universe B.
2. **Δ P95 RT:** The tail-latency drift (hesitation marker).
3. **Salience Bias Index (SBI):** The raw millisecond deviation from the baseline Universe.

## 4. THE DUAL-GATE PASS / FAIL CRITERIA
A World must pass BOTH gates to be merged into production.

### GATE 1: The Scientific Gate (Measurement Validity)
- **Bias Threshold 1:** The Δ P50 RT between Universe A and B must not exceed **± 25ms**.
- **Bias Threshold 2:** The Error Typology shift must not exceed **5%**.
- **Bias Threshold 3:** The Δ P95 RT must not exceed **± 50ms**.

### GATE 2: The Engagement Gate (Experiential Utility Index - EUI)
A World that is scientifically valid but sterile is a failed World. The World must demonstrate:
- **Voluntary Selection Threshold:** In `UNIVERSE_EXPLORATION` mode, if a user is given a choice, the World must be selected > 15% of the time (avoiding dead content).
- **Session Replay Rate:** The World must not cause a > 10% spike in session abandonment compared to the baseline Science Lab. 

## 5. CORRECTION MECHANISMS
If a Universe FAILS the Scientific Gate, we adjust the Universe (Luminance, Motion Dampening) to fit the data.
If a Universe FAILS the Engagement Gate, the Art Department must re-evaluate the emotional framing, audio profile, or aesthetic density of the World until it hits the EUI thresholds.
