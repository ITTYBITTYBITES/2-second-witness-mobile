# PROTOCOL 10: MOBILE CALIBRATION TRIAL (MCT-0)

**Objective:**
Establish a device-specific correction vector before any human testing begins. Android introduces touch-sampling quantization, variable refresh pacing, and input latency. This protocol mathematically normalizes those hardware artifacts so cross-device and cross-modality (Mouse vs Touch) Reaction Time (RT) data remains statistically comparable.

**The Calibration Vector:**
The system must never assume 1ms on PC = 1ms on Android. The MCT-0 calculates a `hardware_latency_offset` which is subtracted from all future RT logs on that specific device.

**The Execution Plan (On First Launch):**
1. **The Scenario:** `reflex_tap` (The purest measure of raw input-to-render latency without complex cognitive overhead).
2. **The Execution:** The system runs a silent, rapid 5-iteration loop of `reflex_tap`.
3. **The Calculation:** The system calculates the P50 RT of this loop. If the Android P50 is 400ms, and the known PC baseline is 320ms, the `hardware_latency_offset` for this specific phone is `80ms`.
4. **The Application:** This 80ms offset is permanently appended to the `PlayerProfile` and subtracted from all future cognitive tasks before the Insight Engine analyzes them.

**Constraint:**
This is NOT adjusting difficulty. It is normalizing the measurement instrument. The user experience remains identical; only the data analysis layer is adjusted.
