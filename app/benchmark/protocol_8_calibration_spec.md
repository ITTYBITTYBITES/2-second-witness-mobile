# PROTOCOL 8: CROSS-UNIVERSE CALIBRATION TESTING
*Validating the Invariance of the Cognitive Mirror*

**Objective:**
Falsify the assumption that the `WitnessEngine` measures cognition equally across all perceptual manifolds. We actively attempt to prove that World rendering (Colors, Fog, Audio, Geometry) biases the reaction time (RT) or error distribution of a fixed Cognitive Task.

## 1. THE CALIBRATION UNIT (THE ANCHOR)
A `CalibrationTrial` is an immutable, paired-sample experiment execution.
- **Task Kernel:** `signal_vs_noise` (Visual Search) & `stroop_test` (Interference).
- **Invariant State:** Fixed Seed `88888`. Fixed Target Distribution. Fixed 5.0s Timing Envelope.
- **The Variable:** Rendered sequentially in Universe A (Science Lab) and Universe B (Tech Ops).

## 2. REQUIRED SAMPLE SIZES
To achieve statistical significance (avoiding Type II errors) in RT distributions:
- **Minimum N:** 30 unique human subjects (IVC-0 cohort scaling).
- **Trials Per Subject:** 50 paired iterations (100 trials total per subject, alternating Universes).
- **Outlier Scrubbing:** Discard any RT sample where the Godot P99 frame-time > 17.0ms in the 1 second prior to the tap (filters device latency). Discard RTs > 2.5s (filters distraction).

## 3. STATISTICAL METHODOLOGY & DRIFT METRICS
We do not compare means (Averages lie). We compare distributions using within-subject paired testing.
- **The Primary Test:** *Wilcoxon signed-rank test* on paired RT distributions (Universe A vs Universe B).
- **The Secondary Test:** *McNemar's test* on paired Error Typology (False Positive vs False Negative ratios).

**Drift Detection Metrics:**
1. **Δ P50 RT:** The median reaction time drift between Universe A and Universe B.
2. **Δ P95 RT:** The tail-latency drift (Does Tech Ops cause more hesitation?).
3. **Salience Bias Index (SBI):** The raw millisecond deviation from the baseline Universe.

## 4. PASS / FAIL CRITERIA
The Perceptual Manifold is **FAILED** and must be re-art-directed if any of the following occur:
- **Bias Threshold 1:** The Δ P50 RT between Universe A and Universe B exceeds **± 25ms** (Statistical significance *p < 0.05*).
- **Bias Threshold 2:** The Error Typology shifts by more than **5%** (e.g., Players make 5% more False Negative errors in Life Sciences because the organic shapes camouflage the target).
- **Bias Threshold 3:** The Δ P95 RT exceeds **± 50ms**.

## 5. CORRECTION MECHANISMS
If a Universe FAILS the calibration protocol, it is mathematically proven to be a corrupted instrument. 
**We DO NOT adjust the data to fit the Universe. We adjust the Universe to fit the data.**
1. **Luminance Adjustment:** If RT is systematically slower in *Roman Empire*, the ambient lighting is too dark or the background contrast is competing with the Task Kernel. Raise `computed_contrast` in the `ThemeResolver`.
2. **Motion Dampening:** If P95 hesitation is higher, the background tunnel flow (`speed_multiplier`) or particle count is inducing motion sickness/distraction. Clamp the `TunnelIntensity` to a lower max state.
3. **Re-Test:** Execute Protocol 8 again until the SBI falls below the ± 25ms threshold.
