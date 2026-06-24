# PROTOCOL 7: COGNITIVE KNEE IDENTIFIABILITY (VALIDATION HARNESS)

**Objective:**
Prove whether the "Cognitive Knee" (estimated via Interaction RT spike) is a stable, intrinsic human parameter or an unstable, induced artifact of the adaptive system itself. 

**The Core Risk (Feedback Contamination):**
If the adaptive system shapes the environment, and the environment shapes the user's RT, the system may converge on a false equilibrium. Furthermore, RT spikes are highly noisy (distraction, thermal stutter, motor variance). 

**Experimental Design: The Frozen State Matrix**
We must disable the `CognitiveController`'s adaptive feedback loop entirely. The system must not learn. It must only observe under rigidly enforced, invariant conditions across multiple distinct sessions.

**The Test Variables:**
- **Invariant:** Thermal State (Cold vs Sustained).
- **Invariant:** Session Count (Loop 1-5 vs Loop 50-55).
- **Invariant:** Target Density (Hard-locked to 1.35x vs 1.6x across alternating days).

**Data Collection (The "True" RT Signal):**
To isolate the cognitive signal from transient noise, the harness must filter out:
1.  *Systemic Noise:* Discard any RT sample where the Godot P99 frame-time > 17.0ms in the 1 second prior to the tap. (Eliminates thermal/driver stutter).
2.  *Motor Variance:* Establish a baseline RT for the user during a zero-density "Void" test prior to the tunnel injection.

**Expected Outcome & Falsification:**
- **Stable Parameter (PASS):** If the user's RT consistently spikes at 1.45x density across Day 1, Day 3, Cold Start, and Thermal Load, the Cognitive Knee is an identifiable property.
- **Moving Target (FAIL):** If the RT spike drifts to 1.6x on Day 3 (adaptation), or fluctuates wildly between 1.2x and 1.8x depending on the thermal state, Protocol 6 is falsified. The system is measuring a process, not a property, and implicit calibration must be abandoned in favor of a global hard cap.
