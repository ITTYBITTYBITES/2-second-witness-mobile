# EXPERIMENTAL RESULTS SUMMARY

## The Core Finding
The observed P99 tail-latency spikes (18.0-19.5ms) originally detected in Protocol 1 are **not rendering bottlenecks, spatial graph churn, or GPU submission stalls.** 

They are entirely **frame pacing artifacts caused by V-Sync scheduling alignment.**

## Falsification Record
1. **Visibility Toggling (Protocol 2):** 
   - **Result:** Falsified. Removing `visible` toggles did not alter P99 spikes.
2. **Transform Propagation (Protocol 3):**
   - **Result:** Falsified. Freezing spatial movement did not alter P99 spikes.
3. **Swapchain Coupling (Protocol 4):**
   - **Result:** Confirmed. Uncoupling V-Sync collapsed the P50 to 8.7ms and completely eliminated the 19ms P99 spikes, tightening the tail to 8.9ms.

## Dual-Domain Engineering Model
The architecture operates under two distinct, orthogonal domains:
1. **Simulation Cost (Truth Layer):** The raw CPU workload (GDScript, scene traversal, render submission) requires **~8.7ms**. It is deterministic and stable.
2. **Presentation Constraint (Experience Layer):** The OS/Display hardware enforces a ~16.6ms cadence boundary. The original 19ms spikes were synchronization artifacts, not compute overruns.

*Correction:* We do not have "8ms of extra performance budget." The uncoupled 8.7ms measurement removes real-world pacing constraints. However, because we are not currently compute-bound, we can safely increase visual complexity (particles, shaders) until the Simulation Cost begins to threaten the Presentation Constraint boundary.

We are ready to scale visual fidelity.
