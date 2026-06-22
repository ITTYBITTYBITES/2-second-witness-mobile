# EXPERIMENTAL RESULTS SUMMARY

## The Core Finding
The observed P99 tail-latency spikes (18.0-19.5ms) originally detected in Protocol 1 are **not rendering bottlenecks, spatial graph churn, or GPU submission stalls.** 

They are entirely **frame pacing artifacts caused by V-Sync scheduling alignment.**

## Falsification Record
1. **Visibility Toggling (Protocol 2):** 
   - **Hypothesis:** Render state invalidation forces a pipeline flush.
   - **Result:** Falsified. Removing `visible` toggles did not alter P99 spikes.
2. **Transform Propagation (Protocol 3):**
   - **Hypothesis:** Continuous spatial updates (BVH/AABB) cause CPU/GPU stalls.
   - **Result:** Falsified. Freezing spatial movement did not alter P99 spikes.
3. **Swapchain Coupling (Protocol 4):**
   - **Hypothesis:** The spikes are symptoms of the Vulkan driver stalling the main thread while waiting for display presentation (V-Sync).
   - **Result:** Confirmed. Uncoupling V-Sync collapsed the P50 from 16.6ms to 8.7ms and completely eliminated the 19ms P99 spikes, tightening the tail to 8.9ms.

## Engineering Impact
The system is highly performant. The CPU/GPU workload requires ~8.7ms to complete. The remaining time in the 16.6ms budget is spent idling/waiting for the display driver to accept the frame. 

The original "instability" was simply the Godot scheduler slightly missing the V-Sync boundary and catching the next refresh window.

We are NOT compute-bound. We are display-bound.
