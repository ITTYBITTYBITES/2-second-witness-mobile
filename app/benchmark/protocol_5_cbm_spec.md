# PROTOCOL 5: CONSTRAINT BEHAVIOR MODELING (DENSITY-TO-CLARITY CURVE)
*(REVISED: Psychophysical Human-in-the-Loop constraints enforced)*

**Objective:**
Map the functional relationship between simulation density and perceptual breakdown. We are locating the inflection point where human cognition fails *before* the hardware budget collapses.

**The Independent Variable (Discretized Load Steps):**
- **D1:** 1.0x (Baseline HIGH tier load)
- **D2:** 1.25x
- **D3:** 1.50x
- **D4:** 1.75x
- **D5:** 2.00x (Enforced Cap Boundary)
- **D6:** 2.50x (Failure Pressure / Violation Regime)

**Execution Constraint 1: Randomized Order (Blind Testing)**
Runs must NOT be executed D1 -> D6 sequentially to avoid learning effects and expectation bias. The engine will roll a random density multiplier on boot and *hide the UI visualizer* until the run completes. 

**Execution Constraint 2: Operational Definition of "Clarity"**
Clarity is defined strictly as: *"The ability to correctly track the Crystalline Iris across 5 seconds without loss of identity or requiring active visual searching."*

**The Dependent Variables (Clarity Proxies):**
1. **Perceptual Clarity Score (Primary Signal):** A manual 1-5 score graded blindly post-run based on the operational definition.
2. **System Volatility (Secondary):** Tier switching frequency.
3. **Enforcement Friction (Secondary):** Violation rate per second (`FidelityEnforcer.violation_count`).
4. **Frame Stability (Secondary):** P99 spike frequency.

**Experimental Protocol (Per Density Step):**
1. **Cold Start:** Full application restart.
2. **Stabilization Window (15s):** Allow engine to spin up. Discard telemetry.
3. **Measurement Window (60s):** Record telemetry dump and execute human tracking of the Iris.
4. **Annotation:** Grade the Perceptual Clarity Score. Only then, reveal the true Density multiplier from the telemetry dump.

**Expected Outcome:**
We expect to find a non-linear decay curve (Stable Plateau -> Transition Knee -> Saturation). The most critical output is the exact density at which human tracking fails while the Godot engine is still stable. *This gap is the usable design margin.*
