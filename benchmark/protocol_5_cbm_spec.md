# PROTOCOL 5: CONSTRAINT BEHAVIOR MODELING (DENSITY-TO-CLARITY CURVE)

**Objective:**
Map the functional relationship between simulation density and perceptual breakdown. We are locating the inflection point where human cognition fails *before* the hardware budget collapses.

**The Independent Variable (Discretized Load Steps):**
We test fixed, isolated density multipliers. No continuous ramping.
*   **D1:** 1.0x (Baseline HIGH tier load)
*   **D2:** 1.25x
*   **D3:** 1.50x
*   **D4:** 1.75x
*   **D5:** 2.00x (Enforced Cap Boundary)
*   **D6:** 2.50x (Failure Pressure / Violation Regime)

**The Dependent Variables (Clarity Proxies):**
1.  **System Volatility:** Tier switching frequency (HIGH->MID->LOW).
2.  **Enforcement Friction:** Violation rate per second (`FidelityEnforcer.violation_count`).
3.  **Frame Stability:** P99 spike frequency.
4.  **Perceptual Clarity (Human Annotation):** A manual timestamped log noting when motion becomes unreadable or structural depth is lost to noise.

**Experimental Protocol (Per Density Step):**
1.  **Cold Start:** Full application restart to purge thermal carryover.
2.  **Stabilization Window (15s):** Allow engine to spin up and chunk buffer to saturate. Discard telemetry.
3.  **Measurement Window (60s):** Record telemetry dump and manual perceptual annotation.

**Expected Outcome:**
We expect to find a non-linear decay curve. The critical finding will be the gap between the "Perceptual Inflection Point" (where the screen becomes unreadable noise) and the "System Failure Region" (where the Enforcer starts dropping allocations). *That gap is the usable design margin.*

---
*Note: Do not steer the system during measurement. Observe the fixed constraints.*
