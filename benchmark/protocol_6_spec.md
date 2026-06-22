# PROTOCOL 6: ADAPTIVE PERCEPTUAL CALIBRATION

**Objective:**
Shift from a static transfer function (Knee = 1.4x) to a dynamic, user-specific calibration model. Acknowledge that the cognitive knee drifts based on screen size, framerate, and individual tracking capacity.

**The Mechanism (Implicit Calibration Phase):**
1. **The Probe Window:** During the first 5 loops of a new installation, the `CognitiveController` gently oscillates the density multiplier from `1.0x` up to `1.8x` across different scenarios.
2. **The Measurement:** The `SessionTracker` monitors the exact latency between the *Iris Spawn* and the *User Tap*, as well as the error rate during the Cognitive Spike.
3. **The Lock-In:** The system maps the tracking latency against the density level. It finds the exact density where the user's reaction time spikes by >20% (The Personal Cognitive Knee).

**The Execution Rules:**
- Do NOT prompt the user. Calibration must be completely invisible and embedded in the early gameplay.
- Once the personal knee is located, the `CognitiveController` clamps its `COGNITIVE_KNEE_DENSITY` variable permanently for that device.
- If framerate drops (e.g., thermal throttling), the Controller scales down, but it NEVER scales up past the personal knee.
