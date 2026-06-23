# PROTOCOL 8: CROSS-UNIVERSE CALIBRATION TESTING

**Objective:**
Prove that the underlying psychometric instrument (The Cognitive Mirror) remains statistically invariant under systematic perceptual perturbation (Universe Rendering Manifolds). 

**The Hypothesis:**
The canonical output of a scenario (RT distributions, Error Types) is driven entirely by the user's cognitive state and the scenario's logical constraints, NOT by the aesthetic framing or luminance contrast of the Universe it is rendered within.

**The Calibration Unit (The Invariant Anchor):**
We define a `CalibrationTrial`. This is an immutable experiment execution:
- Fixed Scenario: `signal_vs_noise_001`
- Fixed Seed: `88888` (Forces identical spatial distribution of the 15 noise labels and 1 target)
- Fixed Timing: `5.0s` envelope.
- Executed as a paired-sample across Universe A (Science Lab) and Universe B (Tech Ops).

**The Dependent Variables (Invariance Dimensions):**
1. **Behavioral Invariance:** P50 and P95 Reaction Time (RT). We are looking for distribution shifts, not just mean shifts.
2. **Error Type Distribution:** Ratio of False Positives (clicked 'Present' when absent) vs False Negatives (time expired or clicked 'Absent' when present). 
3. **Salience Bias Index:** A derived residual measuring the pre-attentive pull of the manifold. If Universe B consistently produces RTs 50ms faster than Universe A on the exact same spatial seed, Universe B has a Salience Bias that must be mathematically neutralized before logging to the `PlayerProfile`.

**Execution Constraints:**
- Must use within-subject paired testing (same human runs the exact same seed on both universes).
- The `UniverseRenderer` is the *only* allowed variable. The `AssetResolver` mounts the respective textures.

**Falsification:**
If the Instrument Stability Index drops (i.e., RT distributions diverge by > 5% between Universe A and Universe B for the exact same seed), the hypothesis is falsified. The perceptual manifold is contaminating the cognitive measurement, and the Universe aesthetics must be re-calibrated.
